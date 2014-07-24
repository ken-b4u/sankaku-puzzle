package sankakupuzzle.scene
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import sankakupuzzle.debug.Dump;
	import sankakupuzzle.logic.Util;
	import sankakupuzzle.scene.base.SceneBase;
	import sankakupuzzle.scene.ui.SoundManager;

	public class TitleScene extends SceneBase
	{
		public function TitleScene() 
		{
		}
		
		override public function startScene():void 
		{
			super.startScene();
			var title:Title = new Title();
			title.y = 100;
			Util.horizontalAlignCenterDisplayObject(title);
			uiLayer.addChild(title);
			
			var touchString:TouchString = new TouchString();
			touchString.y = 500;
			Util.horizontalAlignCenterDisplayObject(touchString);
			uiLayer.addChild(touchString);
			
			setBgmKey = 'Title';
			var soundList:Array = [
				{ key:'Title', src:'/assets/bgm/198-Ravel-Miroirs-Alborada-del-Gracioso.mp3', type:SoundManager.TYPE_BGM }
			];
			soundMg.loadSound(soundList);
			addEventListener(MouseEvent.CLICK, onClickStage);
			dispatchLoadEndEvent();
		}
		
		private function onClickStage(e:MouseEvent):void {
			trace('てすてす');
			soundMg.sePlay(SoundManager.SE_KEY_CLICK);
		}
	}

}