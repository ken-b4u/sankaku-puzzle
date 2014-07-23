package sankakupuzzle.scene.ui
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.AudioPlaybackMode;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	
	// 【iOSのみ】マナーモード時に無音にする
	SoundMixer.audioPlaybackMode = AudioPlaybackMode.AMBIENT;
	
	public class SoundManager extends EventDispatcher
	{
		private var so:SharedObject = SharedObject.getLocal("SoundManager");
		
		// soundタイプ
		public static const TYPE_BGM:int = 0;
		public static const TYPE_SE:int = 1;
		
		// BGM_KEY
		public static const BGM_KEY_INIT:String = 'init';

		// SE_KEY
		public static const SE_KEY_CLICK:String = 'click';
		
		// 現在再生中のBGM_KEY
		private var nowBgmKey:String = BGM_KEY_INIT;
		private var activeFlag:Boolean = true;
		
		// ユニークID
		private var uniqId:int = 0;
		
		// BGM・SE配列
		private var bgmList:Object = {};
		private var seList:Object = {};
		private var utilSeList:Object = {};
		
		public function SoundManager()
		{
		}
		
		public function isEnableBgm():Boolean {
			var obj = so.data;
			// 初回起動
			if (obj.bgm == undefined) {
				obj.bgm = true;
			}
			return obj.bgm;
		}
		
		public function isEnableSe():Boolean {
			// TODO:後で
			return true;
		}
		
		public function enableBgm():void {
			var obj = so.data;
			obj.bgm = true;
		}
		
		public function disableBgm():void {
			var obj = so.data;
			obj.bgm = false;
		}
		
		/**
		 * [読み取り専用]現在再生中のBgmKeyを取得する
		 * @return nowBgmKey:String
		 */
		public function get nowPlayBgmKey():String {
			return nowBgmKey;
		}
		
		/**
		 * [読み取り専用]共通用SeListを取得する
		 * @return utilSeList:Object
		 */
		public function get utilSe():Object {
			return utilSeList;
		}
		
		public function set isActive(flag:Boolean):void {
			activeFlag = flag;
		}
		
		/**
		 * 共通用SEを読み込み、配列に格納する
		 * @param soundList:Array
		 */
		public function loadUtilSe(soundList:Array):void {
			var loadCount:int = 0;
			var loadCountMax:int = soundList.length;
			var sound:Sound;
			load(soundList[loadCount]);
			// 読み込み
			function load(soundInfo:Object):void {
				sound = new Sound(new URLRequest(soundInfo.src));
				sound.addEventListener(Event.COMPLETE, onCompleteHandler);
			}
			// 完了処理
			function onCompleteHandler(e:Event):void {
				var target:Object = soundList[loadCount];
				utilSeList[target.key] = {
					soundChList:{},
					sound:e.target,
					position:0
				};
				sound.removeEventListener(Event.COMPLETE, onCompleteHandler);
				if(++loadCount < loadCountMax) {
					load(soundList[loadCount]);
				} else {
					dispatchEvent(new Event(Event.COMPLETE));
				}
			}
		}
		
		/**
		 * soundデータの読み込み. bgmとseを分ける格納する
		 * @param soundList:Array
		 */
		public function loadSound(soundList:Array):void {
			var loadCount:int = 0;
			var loadCountMax:int = soundList.length;
			var sound:Sound;
			load(soundList[loadCount]);
			// 読み込み
			function load(soundInfo:Object):void {
				sound = new Sound(new URLRequest(soundInfo.src));
				sound.addEventListener(Event.COMPLETE, onCompleteHandler);
			}
			// 完了時処理
			function onCompleteHandler(e:Event):void {
				var target:Object = soundList[loadCount];
				// TODO: volumeで音量を変更できるようにしたい
				if(target.type == TYPE_BGM) {
					bgmList[target.key] = {
						soundCh:null,
						sound:e.target,
						position:0
					};
				} else {
					seList[target.key] = {
						soundChList:{},
						sound:e.target,
						position:0
					};
				}
				sound.removeEventListener(Event.COMPLETE, onCompleteHandler);
				if (++loadCount < loadCountMax) {
					load(soundList[loadCount]);
				} else {
					dispatchEvent(new Event(Event.COMPLETE));
				}
			}
		}
		
		/**
		 * SE用配列に共通用SEを追加する
		 * @param utilSe:Object
		 */
		public function addUtilSe(utilSe:Object):void {
			if(utilSeList) {
				for(var key:String in utilSe) {
					seList[key] = utilSe[key];
				}
			}
		}
		
		/**
		 * BGMの再生
		 * @param bgmKey:String
		 */
		public function bgmPlay(bgmKey:String):void {
			if(isEnableBgm()) {
				// 現在流れているBGMと同じ場合はここで終了
				if(nowBgmKey == bgmKey) return;
				// 再生中と異なるKeyが選択されていたら差し替える
				if(nowBgmKey != BGM_KEY_INIT && nowBgmKey != bgmKey) {
					bgmList[nowBgmKey].soundCh.stop();
					// ループ再生用終了イベントの削除も行う
					if(bgmList[nowBgmKey].soundCh.hasEvnetListener(Event.SOUND_COMPLETE)) {
						bgmList[nowBgmKey].soundCh.removeEventListener(Event.SOUND_COMPLETE, onLoopBgmCompleteHandler);
						bgmList[nowBgmKey].soundCh = null;
					}
					// 初期Keyがセットされてる場合はここで終了
					if(bgmKey == BGM_KEY_INIT) return;
				}
				nowBgmKey = bgmKey;
				if(bgmList[nowBgmKey] && activeFlag) {
					bgmList[nowBgmKey].soundCh = new SoundChannel();
					bgmList[nowBgmKey].soundCh = bgmList[nowBgmKey].sound.play(0, 1);
					// ループ再生用終了イベントを登録
					bgmList[nowBgmKey].soundCh.addEventListener(Event.SOUND_COMPLETE, onLoopBgmCompleteHandler);
				}
			}
		}
		
		/**
		 * BGMの停止
		 */
		public function bgmStop():void {
			if(nowBgmKey == BGM_KEY_INIT || !bgmList[nowBgmKey].soundCh) return;
			bgmList[nowBgmKey].soundCh.stop();
			// ループ再生用終了イベントの削除も行う
			if(bgmList[nowBgmKey].soundCh.hasEventListener(Event.SOUND_COMPLETE)) {
				bgmList[nowBgmKey].soundCh.removeEventListener(Event.SOUND_COMPLETE, onLoopBgmCompleteHandler);
			}
			// soundChannelの解放
			bgmList[nowBgmKey].soundCh = null;
		}
		
		/**
		 * BGMの一時停止
		 */
		public function bgmPause():void {
			if(isEnableBgm()) {
				// 設定しているBGM情報がない場合はここで終了
				if(bgmList[nowBgmKey] == null) return;
				// 停止位置を保持
				bgmList[nowBgmKey].position = bgmList[nowBgmKey].soundCh.position;
				bgmList[nowBgmKey].soundCh.stop();
				// リスナーの削除
				if(bgmList[nowBgmKey].soundCh.hasEventListener(Event.SOUND_COMPLETE)) {
					bgmList[nowBgmKey].soundCh.removeEventListener(Event.SOUND_COMPLETE, onLoopBgmCompleteHandler);
				}
				// soundChannelの解放
				bgmList[nowBgmKey].soundCh = null;
			}
		}
		
		// BGMはリスタート出来る常態か返す
		public function isEnableReStartBgm() {
			if(bgmList[nowBgmKey] == undefined) {
				return false
			}
			return true;
		}
		
		/**
		 * BGMのリスタート
		 */
		public function bgmReStart():void {
			if(isEnableBgm()) {
				// 設定しているBGM情報がない又はsoundChにsoundがセットされてる場合はここで終了				
				if(bgmList[nowBgmKey] == null || bgmList[nowBgmKey].soundCh) return;
				// 前回の停止位置から再生し直す
				bgmList[nowBgmKey].soundCh = new SoundChannel();
				bgmList[nowBgmKey].soundCh = bgmList[nowBgmKey].sound.play(bgmList[nowBgmKey].position, 1);
				// ループ再生用終了イベントを登録
				bgmList[nowBgmKey].soundCh.addEventListener(Event.SOUND_COMPLETE, onLoopBgmCompleteHandler);
				// 念の為、停止位置の初期化
				bgmList[nowBgmKey].position = 0;
			}
		}
		
		/**
		 * SEの再生
		 * @param seKey:String
		 * @return seData:Object 作成されたSE情報
		 */
		public function sePlay(seKey:String):Object {
			// SeListに入っていない場合はここでnullを返して終了
			if(seList[seKey] == null) return　null;
			// uniqKeyの作成
			var uniqKey:String = createSeUniqKey();
			// Se情報の作成
			seList[seKey].soundChList[uniqKey] = {
				uniqKey:uniqKey,
				seKey:seKey,
				soundCh:new SoundChannel(),
				position:0,
				handler:null
			};
			var seData:Object = seList[seKey].soundChList[uniqKey];
			seData.soundCh = seList[seKey].sound.play(0, 1);
			// リスナーにセットするハンドラーの作成
			seData.handler = function(e:Event) {
				seData.soundCh.removeEventListener(Event.SOUND_COMPLETE, seData.handler);
				seData.soundCh = null;
				// seListから指定したプロバティ(SE情報)を削除
				delete seList[seData.seKey].soundChList[seData.uniqKey];
			};
			seData.soundCh.addEventListener(Event.SOUND_COMPLETE, seData.handler);
			// SEを指定して停止させたりするためSE情報を返す
			return seData;
		}
		
		/**
		 * SEの停止
		 * @param seData:Object 個別に選択したSE情報
		 */
		public function seStop(seData:Object):void {
			if(seData == null || seData.soundCh == null) return;
			seData.soundCh.stop();
			if(seData.soundCh.hasEventListener(Event.SOUND_COMPLETE)) {
				seData.soundCh.removeEventListener(Event.SOUND_COMPLETE, seData.handler);
			}
			seData.soundCh = null;
			// seListから指定したプロバティ(SE情報)を削除
			delete seList[seData.seKey].soundChList[seData.uniqKey];
		}
		
		/**
		 * SEの一時停止
		 */
		public function sePause():void {
			for(var seKey:String in seList) {
				for(var uniqKey:String in seList[seKey].soundChList) {
					// 即時関数で処理を行う
					(function(sKey:String, uKey:String):void {
						var seData:Object = seList[sKey].soundChList[uKey];
						if(seData == null || seData.soundCh == null) return;
						// 停止位置を保持
						seData.position = seData.soundCh.position;
						seData.soundCh.stop();
						// リスナーの削除
						if(seData.soundCh.hasEventListener(Event.SOUND_COMPLETE)) {
							seData.soundCh.removeEventListener(Event.SOUND_COMPLETE, seData.handler);
							seData.handler = null;
						}
						// soundChannelの解放
						seData.soundCh = null;
					})(seKey, uniqKey);
				}
			}
		}
		
		/**
		 * SEのリスタート
		 */
		public function seReStart():void {
			for(var seKey:String in seList) {
				for(var uniqKey:String in seList[seKey].soundChList) {
					// 即時関数で処理を行う
					(function(sKey:String, uKey:String):void {
						var seData:Object = seList[seKey].soundChList[uniqKey];
						// 停止位置から再生
						seData.soundCh = new SoundChannel();
						seData.soundCh = seList[sKey].sound.play(seData.position, 1);
						seData.handler = function(e:Event):void {
							seData.soundCh.removeEventListener(Event.SOUND_COMPLETE, seData.handler);
							seData.soundCh = null;
							// seListから指定したプロバティ(SE情報)を削除
							delete seList[seData.seKey].soundChList[seData.uniqKey];
						}
						seData.soundCh.addEventListener(Event.SOUND_COMPLETE, seData.handler);
						// 念の為、停止位置を初期化
						seData.position = 0;
					})(seKey, uniqKey);
				}
			}
		}
		
		/**
		 * BGM及びSEの削除
		 */
		public function removeSound():void {
			// BGMの停止
			bgmStop();
			for(var seKey:String in seList) {
				for(var uniqKey:String in seList[seKey].soundChList) {
					// SEの全停止
					seStop(seList[seKey].soundChList[uniqKey]);
				}
			}
			// BGM情報とSEの初期化
			bgmList = null;
			seList = null;
			// 念の為、uniqIdの初期化
			uniqId = 0;
		}
		
		/**
		 * se用UniqKeyの作成
		 */
		private function createSeUniqKey():String {
			var uniqKey = 'se'+uniqId;
			++uniqId;
			return uniqKey;
		}
		
		/**
		 * BGMループ再生用終了イベント
		 */
		private function onLoopBgmCompleteHandler(e:Event):void {
			bgmList[nowBgmKey].soundCh.removeEventListener(Event.SOUND_COMPLETE, onLoopBgmCompleteHandler);
			bgmList[nowBgmKey].soundCh = null;
			bgmList[nowBgmKey].soundCh = bgmList[nowBgmKey].sound.play(0, 1);
			bgmList[nowBgmKey].soundCh.addEventListener(Event.SOUND_COMPLETE, onLoopBgmCompleteHandler);
		}
		
	}
}