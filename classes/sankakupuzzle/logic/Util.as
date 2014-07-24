package sankakupuzzle.logic
{
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.text.StaticText;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	
	import sankakupuzzle.sankakupuzzleconst.Colors;
	import sankakupuzzle.scene.base.SceneBase;
	
	public class Util
	{
		public function Util()
		{
		}
		
		public static function verticalAlignCenterTextField(tf: TextField): void {
			tf.y += Math.round((tf.height - tf.textHeight) / 2);
		}
		
		public static function verticalAlignCenterDisplayObject(disOb:DisplayObject): void {
			disOb.y = (SceneBase.CONTENT_HEIGHT/2)-(disOb.height/2);
		}
		
		public static function horizontalAlignCenterDisplayObject(disOb:DisplayObject): void {
			disOb.x = (SceneBase.CONTENT_WIDTH/2)-(disOb.width/2);
		}
		
		/**
		 * 子の位置を親の水平方向中央揃えに配置する
		 * @param parentObj:DisplayObject 親となるオブジェクトを指定
		 * @param childObj:DisplayObject 子となるオブジェクトを指定
		 */
		public static function horizontalAlignCenterInstance(parentObj:DisplayObject, childObj:DisplayObject):void{
			childObj.x = (parentObj.width / 2) - (childObj.width / 2);
		}
		
		/**
		 * 子の位置を親の垂直方向中央揃えに配置する
		 * @param parentObj:DisplayObject 親となるオブジェクトを指定
		 * @param childObj:DisplayObject 子となるオブジェクトを指定
		 */
		public static function verticalAlignCenterInstance(parentObj:DisplayObject, childObj:DisplayObject):void{
			childObj.y = (parentObj.height / 2) - (childObj.height / 2);
		}
		
		/**
		 * 秒を分に変更して返す
		 */
		public static function changeStringMinute(time:int):String {
			var min:int = time/60;
			var sec:int = time%60;
			return ((min < 10) ? '0' : '') + min + ':' + ((sec < 10) ? '0' : '') + sec;
		}
		
		/**
		 * 特定の文字列(YYYY-MM-DD hh:mm:ss等)をX秒前、X分前に変換して返す
		 */
		public static function getVagueTime(date:String):String {
			date = date.replace(/\-/g, '/');
			var vagueTime:String = '';
			var vagueDate:Date = new Date(Date.parse(date));
			var nowDate:Date = new Date();
			var diffSec:Number = Math.floor((nowDate.getTime()-vagueDate.getTime())/1000);
			// TODO:定数化したい
			if(diffSec >= 0 && diffSec < 60) {
				vagueTime = diffSec + '秒前';
			} else if(diffSec >= 60 && diffSec < (60*60)) {
				vagueTime = Math.floor(diffSec/60) + '分前';
			} else if(diffSec > (60*60) && diffSec < (60*60*24)) {
				vagueTime = Math.floor(diffSec/(60*60)) + '時間前';
			} else if(diffSec >= (60*60*24)) {
				vagueTime = Math.floor(diffSec/(60*60*24)) + '日前';
			} else {
				var hour:String = (vagueDate.hours < 10) ? '0'+vagueDate.hours : vagueDate.hours.toString();
				var min:String = (vagueDate.minutes < 10) ? '0'+vagueDate.minutes : vagueDate.minutes.toString();
				var sec:String = (vagueDate.seconds < 10) ? '0'+vagueDate.seconds : vagueDate.seconds.toString();
				vagueTime = vagueDate.fullYear+'-'+(vagueDate.month+1)+'-'+vagueDate.date+' '+hour+':'+min+':'+sec;
			}
			return vagueTime;
		}
		
		/**
		 * オブジェクトのディープコピー 
		 */
		public static function cloneObject(object:Object):* {
			var ba:ByteArray = new ByteArray();
			ba.writeObject(object);
			ba.position = 0;
			return ba.readObject();
		}
		
		public static function countTextFieldLength(tf:TextField):int{
			return tf.length;
		}
		
		public static function initForMovieClipProperties(mc:MovieClip, rect:Rectangle=null):void {
			var g = mc.graphics;
			g.clear();
			g.beginFill (Colors.TRANCEPARENCY, 0);
			if(rect) {
				g.drawRect(rect.x, rect.y, rect.width, rect.height);
			} else {
				g.drawRect (0,0,1,1);
			}
			g.endFill();
		}
		
		
	}
}