package sankakupuzzle.scene
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.media.Sound;
	
	import sankakupuzzle.scene.base.SceneBase;
	import sankakupuzzle.scene.ui.SoundManager;	

	public class Main extends MovieClip
	{
		private var _childScene:SceneBase;
		private var utilSoundMg:SoundManager = new SoundManager();
		
		public function Main() 
		{
			init();
		}
		private function init():void
		{
			var soundList:Array = [
				{ key:SoundManager.SE_KEY_CLICK, src:'/assets/se/button_click.mp3', type:SoundManager.TYPE_SE }
			];
			utilSoundMg.loadUtilSe(soundList);
			_childScene = new LogoScene();
			
			_childScene.init();
			_childScene.startScene();
			_childScene.addEventListener(Event.COMPLETE, childSceneCompleteHD);

			// 最初に一度だけ呼び出す
			_childScene.addEventListener(SceneBase.SCENE_LOAD_COMPLETE, function() {
				_childScene.removeEventListener(SceneBase.SCENE_LOAD_COMPLETE, arguments.callee);
				var isEnableBgmInit:Boolean = _childScene.getIsEnableBgmInit();
				var childSoundMg = _childScene.getSoundManager();
				childSoundMg.addUtilSe(utilSoundMg.utilSe);
				if(isEnableBgmInit) childSoundMg.bgmPlay(_childScene.getSetBgmKey());
				addChild(_childScene);
			});
		}
		
		private function childSceneCompleteHD(e:Event):void
		{
			_childScene.removeEventListener(Event.COMPLETE, childSceneCompleteHD);
			var tempScene:SceneBase = _childScene.getNextScene(); //一時保存
			var isEnableInit:Boolean = _childScene.getIsEnableInit();
			var isEnableBgmInit:Boolean = _childScene.getIsEnableBgmInit();
			
			// loadingの開始
			_childScene.loadingStart();
			
			// 一時保存中の新シーンを展開
			if(isEnableInit) {
				tempScene.init();
			} else {
				tempScene.initWithoutUiLayer();
			}
			
			tempScene.addEventListener(SceneBase.SCENE_LOAD_COMPLETE, function():void {
				// リスナー削除
				tempScene.removeEventListener(SceneBase.SCENE_LOAD_COMPLETE, arguments.callee);
				// 現在のシーンを削除する
				_childScene.stopScene();
				
				// 現在のシーンで使われているSoundManagerを取得
				var childSoundMg = _childScene.getSoundManager();
				// 次シーンで使われるSoundManagerを取得
				var soundMg = tempScene.getSoundManager();
				
				removeChild(_childScene);
				// loading終了
				_childScene.loadingEnd();
				
				if(isEnableBgmInit) {
					// インスタンス化されている場合はSoundを停止・破棄する
					if(childSoundMg) childSoundMg.removeSound();
					// 共通用SEの追加
					soundMg.addUtilSe(utilSoundMg.utilSe);
					// 事前にセットしておいたBgmKeyを渡して再生
					soundMg.bgmPlay(tempScene.getSetBgmKey());
				} else {
					// 初期化Flagが偽ならば、次シーンのSoundMgに引き継ぐ
					tempScene.setSoundManager(_childScene.getSoundManager());
				}

				// _childSceneにtempSceneを格納
				_childScene = null;
				_childScene = tempScene;
				addChild(_childScene);
				_childScene.addEventListener(Event.COMPLETE, childSceneCompleteHD);
			});
			tempScene.startScene();
		}
	}

}