package com.terrainbuilder.tools
{
	import flash.display.BitmapData;
	
	/**
	 * ...
	 * @author Michael Gouwens
	 */
	public class NormalMapUtils
	{
		
		public function NormalMapUtils():void {
			
		}
		
		public static function createNormalMapFromHeightMap(bmdN:BitmapData, intensity:uint = 1):BitmapData {
			var nbmd:BitmapData = new BitmapData(bmdN.width-1, bmdN.height-1, false, 0x000000);
			
			var thisPixel:uint;
			var topPixel:uint;
			var bottomPixel:uint; // BOTTOM PIXEL COLOR INTENSITY
			var leftPixel:uint; // LEFT PIXEL COLOR INTENSITY
			var rightPixel:uint; // RIGHT PIXEL COLOR INTENSITY
			
			var v1x:Number;
			var v1y:Number;
			var v1z:Number;
			var v2x:Number;
			var v2y:Number;
			var v2z:Number;
			var v3x:Number;
			var v3y:Number;
			var v3z:Number;
			var v4x:Number;
			var v4y:Number;
			var v4z:Number;
			var vDifVecx:Number;
			var vDifVecy:Number;
			var vDifVecz:Number;
			var hDifVecx:Number;
			var hDifVecy:Number;
			var hDifVecz:Number;
			
			var normalVecx:Number;
			var normalVecz:Number;
			
			var vDif:int; // DIFFERENCE IN INTENSITY BETWEEN TOP AND BOTTOM
			var hDif:int; // DIFFERENCE IN INTENSITY BETWEEN LEFT AND RIGHT
			var vertAverage:int;
			var horizAverage:int;
			
			var pix:uint;
			var w1:uint = bmdN.width - 1;
			var h1:uint = bmdN.height - 1;
			var w2:uint = w1 - 3;
			var h2:uint = h1 - 3;
			
			for (var i:uint = 0; i<w1; i++) {
				for (var j:uint = 0; j<h1; j++) {
					
					thisPixel = bmdN.getPixel(i, j) & 0xff;
					bottomPixel = bmdN.getPixel(i, j+1) & 0xff; // BOTTOM PIXEL COLOR INTENSITY
					rightPixel = bmdN.getPixel(i+1, j) & 0xff; // RIGHT PIXEL COLOR INTENSITY
					
					v1x = v2x = i;
					v1y = thisPixel;
					v1z = j - 1;
					v2y = bottomPixel;
					v2z = j + 1;
					v3x = i - 1;
					v3y = thisPixel;
					v3z = v4z = j;
					v4x = i + 1;
					v4y = rightPixel;
					
					/***START COMPUTE NORMALS FROM SURROUNDING VECTOR POSITIONS***/
					vDifVecx = 0;
					vDifVecy = Math.round(v1y - v2y);
					vDifVecz = -2;
					hDifVecx = -2;
					hDifVecy = Math.round(v3y - v4y);
					hDifVecz = 0;
					
					normalVecx = vDifVecy * hDifVecz - vDifVecz * hDifVecy;
					normalVecz = vDifVecx * hDifVecy - vDifVecy * hDifVecx;
					/***END COMPUTE NORMALS FROM SURROUNDING VECTOR POSITIONS***/
					
					vDif = thisPixel - bottomPixel; // DIFFERENCE IN INTENSITY BETWEEN TOP AND BOTTOM
					hDif = thisPixel - rightPixel; // DIFFERENCE IN INTENSITY BETWEEN LEFT AND RIGHT
					
					vertAverage = normalVecz;
					horizAverage = normalVecx;
					
					if (vertAverage*intensity > 127) {
						vertAverage = 127;
					}
					if (vertAverage*intensity < -127) {
						vertAverage = -127;
					}
					if (horizAverage*intensity > 127) {
						horizAverage = 127;
					}
					if (horizAverage*intensity < -127) {
						horizAverage = -127;
					}
					
					pix = (65536*(127+(vertAverage*intensity))) + (256*((127+(horizAverage*intensity)))) + 255;					
					
					nbmd.setPixel(i, j, pix);
					
				}
			}
			return nbmd;
			
		}
	}
	
}