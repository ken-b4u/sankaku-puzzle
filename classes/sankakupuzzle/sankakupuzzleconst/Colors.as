package sankakupuzzle.sankakupuzzleconst
{
	public class Colors
	{
		public static const RED = 0xFF0000;
		public static const GREEN = 0x00FF00;
		public static const BLUE = 0x0000FF;
		public static const WHITE = 0xFFFFFF;
		public static const BLACK = 0x000000;
		public static const YELLOW = 0xFFFF00; 
		public static const GRAY = 0xBFBFBF; 
		public static const TRANCEPARENCY = 0x00FFFFFF;
		
		public function Colors()
		{
		}
		
		// 16進数から10進数のRGB値に変換して取得する
		public static function getRGB(colorCode:uint):Object {
			var rgbData:Object = {
				red:(colorCode >> 16 & 0xFF),
				green:(colorCode >> 8 & 0xFF),
				blue:(colorCode & 0xFF)
			}
			return rgbData;
		}
		
		// 10進数のRGB値を16進数に変換して取得する
		public static function getHexColorValue(rgbData:Object):uint {
			var colorCode:uint = 0;
			colorCode += (rgbData.red << 16);
			colorCode += (rgbData.green << 8);
			colorCode += (rgbData.blue);
			return colorCode;
		}
		
	}
}