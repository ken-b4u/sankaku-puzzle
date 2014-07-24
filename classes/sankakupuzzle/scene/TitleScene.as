package sankakupuzzle.scene
{
	import flash.display.MovieClip;
	
	import sankakupuzzle.debug.Dump;
	import sankakupuzzle.logic.Util;
	import sankakupuzzle.scene.base.SceneBase;

	public class TitleScene extends SceneBase
	{
		public function TitleScene() 
		{
		}
		
		override public function startScene():void 
		{
			super.startScene();
			var title:Title = new Title();
			title.scaleX = 1;
			title.scaleY = 1;
			title.y = 150;
			Util.horizontalAlignCenterDisplayObject(title);
			uiLayer.addChild(title);
			dispatchLoadEndEvent();
		}
	}

}