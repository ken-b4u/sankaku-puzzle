﻿package sankakupuzzle.scene
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	import sankakupuzzle.scene.base.SceneBase;

	public class LogoScene extends SceneBase
	{
		public function LogoScene() 
		{
		}
		
		override public function startScene():void 
		{
			
			super.startScene();
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			loader.load(new URLRequest("/assets/scene/logo.png"));
			function completeHandler(e:Event):void {
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
				loader.scaleX = 0.5;
				loader.scaleY = 0.5;
				uiLayer.addChild(loader);
				var timer:Timer = new Timer(2000,1);
				// 指定した時間隔で、繰り返し実行されるイベント
				timer.addEventListener(TimerEvent.TIMER,function (e:TimerEvent):void{
					loader.addEventListener(Event.ENTER_FRAME, clearLogo);
					function clearLogo(event:Event):void
					{
						var loader = event.currentTarget;
						loader.alpha -= 0.1;
						if (loader.alpha <= 0)
						{
							// アルファが0以下になった円は動作を止めて消す。
							loader.removeEventListener(Event.ENTER_FRAME, clearLogo);
							uiLayer.removeChild(loader);
							
//							_nextScene = new TopScene();
//							isEnableInit = true;
//							setPlayerData(_nextScene);
						}
					}
				});
				timer.start();
				dispatchLoadEndEvent();
			}
			
		}
		
		override protected function dispatchLoadEndEvent(sec:int=0):void
		{
			if(sec <= 0) {
				dispatchEvent(new Event(SCENE_LOAD_COMPLETE));
			} else {
				setTimeout(function():void {
					dispatchEvent(new Event(SCENE_LOAD_COMPLETE));
				}, sec);
			}
		}
		
		override public function stopScene():void 
		{
			super.stopScene();
		}
	}

}