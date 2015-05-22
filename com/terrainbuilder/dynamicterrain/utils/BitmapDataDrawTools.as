/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.dynamicterrain.utils
{
	import flash.display.BitmapData;

	public class BitmapDataDrawTools
	{
			
		public function BitmapDataDrawTools()
		{
		}
		
		public function drawCircleOn(bitmapData:BitmapData, x:Number, y:Number, radius:Number, color:uint):void {
			
			var startX:Number = x - radius < 0 ? 0 : x - radius;
			var endX:Number = x + radius > bitmapData.width ? bitmapData.width : x + radius;
			var startY:Number = y - radius < 0 ? 0 : y - radius;
			var endY:Number = y + radius > bitmapData.height ? bitmapData.height : y + radius;
			
			var distance:Number;
			
			for (var i:uint = startY; i<endY; i++) {
				for (var j:uint = startX; j<endX; j++) {
					distance = Math.sqrt(Math.pow(x - j, 2) + Math.pow(y - i, 2));
					
					if (distance <= radius) {
						bitmapData.setPixel32(j, i, color);	
					}
				}
			}
			
		}
		
		public function drawGradientCircleOn(bitmapData:BitmapData, x:Number, y:Number, radius:Number, colors:Array, alphas:Array, ratios:Array, tx:Number = 0, ty:Number = 0):void {
			
			if (colors.length !== alphas.length || alphas.length !== ratios.length) throw Error ("COLORS, ALPHAS, AND RATIOS MUST BE OF EQUAL LENGTHS");
			
			var startX:Number = x - radius < 0 ? 0 : x - radius;
			var endX:Number = x + radius > bitmapData.width ? bitmapData.width : x + radius;
			var startY:Number = y - radius < 0 ? 0 : y - radius;
			var endY:Number = y + radius > bitmapData.height ? bitmapData.height : y + radius;
			
			var distance:Number;
			var distanceFromGradientCenter:Number;
			var nextDistanceFromGradientCenter:Number;
			var color:uint;
			var alpha:Number;
			var ratio:Number;
			var currentRatio:Number;
			var nextDistanceRatio:Number;
			
			var ratioIndex:uint;
			var k:uint;
			var perc:Number;
			var tempRatio1:Number;
			var tempRatio2:Number;
			
			var a:int;
			var r:int;
			var g:int;
			var b:int;
			var currColor:uint;
			
			var prevA:int;
			var prevR:int;
			var prevG:int;
			var prevB:int;
			var prevColor:uint;
			var varianceA:int;
			var varianceR:int;
			var varianceG:int;
			var varianceB:int;
			var newA:int;
			var newR:int;
			var newG:int;
			var newB:int;
			
			for (var i:uint = startY; i<endY; i++) {
				for (var j:uint = startX; j<endX; j++) {
					
					distance = Math.sqrt(Math.pow(x - j, 2) + Math.pow(y - i, 2));
					
					if (distance <= radius) {
						
						distanceFromGradientCenter = Math.sqrt(Math.pow(x - (j - tx), 2) + Math.pow(y - (i - ty), 2));
						currentRatio = 255 * (distanceFromGradientCenter / radius);
						
						ratioIndex = 0;
						for (k = 0; k<ratios.length - 1; k++) {
							if (currentRatio >= ratios[k]) {	
								ratioIndex = k + 1;
							}
						}
						
						currColor = colors[ratioIndex];
						a = alphas[ratioIndex] * 255;
						r = currColor >> 16 & 0xFF;
						g = currColor >> 8 & 0xFF;
						b = currColor & 0xFF;
						
						if (ratioIndex == 0) {
							perc = 1;
							color = a << 24 | r << 16 | g << 8 | b;
						} else if (distanceFromGradientCenter >= radius) {
							color = a << 24 | r << 16 | g << 8 | b;
						} else {
							perc = ((currentRatio - ratios[ratioIndex - 1]) / (ratios[ratioIndex] - ratios[ratioIndex - 1]));
							if (perc > 1) perc = 1;
							if (perc < 0) perc = 0;
							
							prevColor = colors[ratioIndex - 1];
							prevA = alphas[ratioIndex - 1] * 255;
							prevR = prevColor >> 16 & 0xFF;
							prevG = prevColor >> 8 & 0xFF;
							prevB = prevColor & 0xFF;
							
							varianceA = a - prevA;
							varianceR = r - prevR;
							varianceG = g - prevG;
							varianceB = b - prevB;
							
							newA = prevA + Math.floor(varianceA * perc);
							newR = prevR + Math.floor(varianceR * perc);
							newG = prevG + Math.floor(varianceG * perc);
							newB = prevB + Math.floor(varianceB * perc);
							
							newA > 255 ? 255 : newA;
							newR > 255 ? 255 : newR;
							newG > 255 ? 255 : newG;
							newB > 255 ? 255 : newB;
							
							newA < 0 ? 0 : newA;
							newR < 0 ? 0 : newR;
							newG < 0 ? 0 : newG;
							newB < 0 ? 0 : newB;
							
							color = newA << 24 | newR << 16 | newG << 8 | newB;
						}
						
						bitmapData.setPixel32(j, i, color);	
					}
				}
			}	
		}
	}
}