package sankakupuzzle.scene.base
{	
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.InvokeEvent;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.net.NetConnection;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Mouse;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.setTimeout;
	
	import sankakupuzzle.scene.ui.SoundManager;
	import sankakupuzzle.sankakupuzzleconst.Colors;

	public class SceneBase extends MovieClip
	{
		// デバッグフラグ
		public static const DEBUG = 0;
		public static const SCENE_LOAD_COMPLETE:String = 'sceneLoadComplete';
		public static const SENDER_ID = '191688635634';
		
		// レイヤーナンバー
		const BG_LAYER_NUM = 0;
		const CONTENT_LAYER_NUM = 1;
		const UI_LAYER_NUM = 2;
		
		//各画面の最前面におかれる黒マスクの座標		
		const MASK_X = -784;
		const MASK_Y = -624;
		
		public static const CONTENT_WIDTH = 480;
		public static const CONTENT_HEIGHT = 800;
		
		protected var app:NativeApplication = NativeApplication.nativeApplication;
		
		// 画面初期化Flag
		protected var isEnableInit:Boolean = false;		
		
		// SoundManager関連
		protected var isEnableBgmInit:Boolean = true;					// 初期化Flag
		protected var setBgmKey:String = SoundManager.BGM_KEY_INIT;	// 次シーンで流すBgmKey
		protected var soundMg:SoundManager;								// SoundManager
		protected var utilSeList:Object;								// 共通SE
		protected var _nextScene:SceneBase;
		protected var overlaySprite:Sprite = new Sprite();
		
		protected var bgLayer:Sprite;
		protected var contentLayer:Sprite;
		public var uiLayer:Sprite;
		protected var monitorLayer:Sprite;
		// rtmp通信に使う用のネットコネクション
		protected var rtmpNc:NetConnection = new NetConnection();
		protected var remoteSo:SharedObject;
		protected var isRtmpConnected:Boolean = false;

		private var loadingTextField:TextField = new TextField();	// loadingText
		
		// UserModelからの値 モデル名+カラム名のキャメルケースで並べていきます。
		private var userName:String;
		
		// HttpStatus
		private var _httpStatus:int = 0;
		
		public function getIsEnableInit():Boolean
		{
			return isEnableInit;
		}
		
		public function getIsEnableBgmInit():Boolean
		{
			return isEnableBgmInit;
		}

		public function setSoundManager(setSoundMg:SoundManager):void {
			soundMg = setSoundMg;
		}
		
		public function getSoundManager():SoundManager
		{
			return soundMg;
		}
		
		public function getSetBgmKey():String
		{
			return setBgmKey;
		}
		
		public function getNextScene():SceneBase
		{
			return _nextScene;
		}
		
		public function getLayer(num:int) {
			return getChildAt(num);
		}
		
		public function SceneBase() 
		{
			app.addEventListener(Event.EXITING , onExiting);
			app.addEventListener(InvokeEvent.INVOKE, onInvoke, false, 0, true);
		}
		
		protected function onExiting(e:Event):void {
			// アプリケーション終了時の処理
			// rtmp通信がある場合接続を破棄する
			if(rtmpNc.connected) {
				rtmpNc.close();
			}
		}
		
		public function init():void
		{
			
			bgLayer = new Sprite();
			contentLayer = new Sprite();
			uiLayer = new Sprite();
			monitorLayer = new Sprite();
			contentLayer.y = 30;
				
			addChildAt(bgLayer,BG_LAYER_NUM);
			addChildAt(contentLayer,CONTENT_LAYER_NUM);
			addChildAt(uiLayer,UI_LAYER_NUM);
		}
		
		public function initWithoutUiLayer():void {
			bgLayer = new Sprite();
			contentLayer = new Sprite();
			monitorLayer = new Sprite();
			uiLayer = new Sprite();
			contentLayer.y = 70;
			addChildAt(bgLayer,BG_LAYER_NUM);
			addChildAt(contentLayer,CONTENT_LAYER_NUM);
			addChildAt(uiLayer,UI_LAYER_NUM);
		}
		
		public function startScene():void
		{
			app.addEventListener(Event.DEACTIVATE,onDeactivate);
			app.addEventListener(Event.ACTIVATE,onActivate);
			soundMg = new SoundManager();
		}
		
		public function onDeactivate(evt:Event):void{
			//バックエンド時の処理
			if(soundMg) {
				soundMg.isActive = false;
				soundMg.bgmPause();
				soundMg.sePause();
			}
		}
		public function onActivate(evt:Event):void{
			//アクティブ時の処理
			if(soundMg) {
				soundMg.isActive = true;
				soundMg.bgmReStart();
				soundMg.seReStart();
			}
		}
		
		public function stopScene():void
		{
			// シーン変更で破棄しないとError出すっぽい
			app.removeEventListener(Event.DEACTIVATE,onDeactivate);
			app.removeEventListener(Event.ACTIVATE,onActivate);
		}

		public function loadingStart():void
		{
			showOverLay();
			var loadingTextFormat:TextFormat = new TextFormat();
			loadingTextFormat.bold = true;
			loadingTextField.embedFonts = true;
			loadingTextFormat.color = Colors.WHITE;
			loadingTextFormat.size = 30;
			loadingTextField.defaultTextFormat = loadingTextFormat;
			loadingTextField.selectable = false;
			loadingTextField.width = 220;
			loadingTextField.height = 38;
			loadingTextField.x = (CONTENT_WIDTH/2)-(loadingTextField.width/2);
			loadingTextField.y = (CONTENT_HEIGHT/2)-(loadingTextField.height/2);
			loadingTextField.text = 'Now Loading...';
			uiLayer.addChild(loadingTextField);
		}
		
		public function loadingEnd():void
		{
			uiLayer.removeChild(loadingTextField);
		}
		
		protected function dispatchCompleteEvent():void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function dispatchLoadEndEvent(sec:int=0):void
		{
			if(sec <= 0) {
				dispatchEvent(new Event(SCENE_LOAD_COMPLETE));
			} else {
				setTimeout(function():void {
					dispatchEvent(new Event(SCENE_LOAD_COMPLETE));
				}, sec);
			}
		}
		
		public function showOverLay(layer:Sprite=null):void {
			overlaySprite = new Sprite();
			var graphic = overlaySprite.graphics;
			graphic.beginFill(Colors.BLACK, 0.7);
			graphic.drawRect(0, 0, CONTENT_WIDTH, CONTENT_HEIGHT);
			if(layer == null) {
				uiLayer.addChild(overlaySprite);
			} else {
				layer.addChild(overlaySprite);
			}
			overlaySprite.addEventListener(MouseEvent.CLICK, onCancelHD);
		}
		
		public function hideOverLay(layer:Sprite=null):void {
			overlaySprite.removeEventListener(MouseEvent.CLICK, onCancelHD);
			if(layer == null) {
				if(uiLayer.contains(overlaySprite)) uiLayer.removeChild(overlaySprite);
			} else {
				layer.removeChild(overlaySprite);
			}
		}
		
		private function onCancelHD(e:Event):void {
			e.preventDefault();
		}

		private function onInvoke(e:InvokeEvent):void
		{
			app.removeEventListener(InvokeEvent.INVOKE, onInvoke);
			
		}
		
	}
}