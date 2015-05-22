/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.dynamicterrain.utils
{
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	public class HeightMap16BitTools
	{
			
		public function HeightMap16BitTools()
		{
		}
		
		public function getBitmapDataFromByteArray(byteArray:ByteArray):BitmapData {
			
			var size:uint = Math.sqrt(byteArray.length / 4);
			var bitmapData:BitmapData = new BitmapData(size, size, true, 0);
			bitmapData.setPixels(bitmapData.rect, byteArray);
			
			return bitmapData;
			
		}
		
		public function copyPixels16Bit(srcBitmapData:BitmapData, srcRect:Rectangle, destBitmapData:BitmapData, destPoint:Point, alphaBitmapData:BitmapData, alphaPoint:Point, alphaStrength:Number = 1):void {
			
			
			var startX:Number = destPoint.x < 0 ? 0 : destPoint.x;
			var endX:Number = destPoint.x + srcRect.width > destBitmapData.width ? destBitmapData.width : destPoint.x + srcRect.width;
			var startY:Number = destPoint.y < 0 ? 0 : destPoint.y;
			var endY:Number = destPoint.y + srcRect.height > destBitmapData.height ? destBitmapData.height : destPoint.y + srcRect.height;
			
			var destPointX:int = destPoint.x;
			var destPointY:int = destPoint.y;
			var alphaPointX:int = alphaPoint.x;
			var alphaPointY:int = alphaPoint.y;
			var alphaBitmapDataPointX:int;
			var alphaBitmapDataPointY:int;
			var currX:int;
			var currY:int;
			var srcX:int = srcRect.x;
			var srcY:int = srcRect.y;
			
			var srcPixel:uint;
			var destPixel:uint;
			var alphaPixel:uint;
			var srcR:Number;
			var srcG:Number;

			var alphaA:Number;
			var multipliedR:Number;
			var multipliedG:Number;
			
			var tempColorAverage:Number;

			var floatingAlpha:Number;
			var flip:int;
			var pixDiff:int;
			
			
			for (var i:int = startY; i<endY; i++) {
				for (var j:int = startX; j<endX; j++) {
					
					currX = j - destPointX + srcX;
					currY = i - destPointY + srcY;
					
					alphaBitmapDataPointX = j - destPointX + alphaPointX;
					alphaBitmapDataPointY = i - destPointY + alphaPointY;
					alphaPixel = alphaBitmapData.getPixel32(alphaBitmapDataPointX, alphaBitmapDataPointY);
					alphaA = alphaPixel >> 24 & 0xFF;
					floatingAlpha = (alphaA / 255)*alphaStrength;
					
					if (floatingAlpha == 0) { continue; }
					
					destPixel = destBitmapData.getPixel32(j, i);
					pixDiff = srcBitmapData.getPixel32(currX, currY) - destPixel;
					
					flip = pixDiff < 0 ? -1 : 1;
					srcPixel = Math.abs(pixDiff);
					
					srcR = srcPixel >> 16 & 0xFF;
					srcG = srcPixel >> 8 & 0xFF;
					
					tempColorAverage = Math.round(((srcR << 8) + srcG) * floatingAlpha);
					multipliedR = (tempColorAverage >> 8);
					multipliedG = tempColorAverage - (multipliedR*256);
				
					destPixel += flip*((multipliedR << 16 | multipliedG << 8));
						
					destPixel = destPixel < 0 ? 0 : destPixel;
					destPixel = destPixel > 0xFFFFFF00 ? 0xFFFFFF00 : destPixel;

					destBitmapData.setPixel32(j, i, destPixel);	
				}
			}
		}
		
		public function addPixels16Bit(srcBitmapData:BitmapData, srcRect:Rectangle, destBitmapData:BitmapData, destPoint:Point, alphaBitmapData:BitmapData, alphaPoint:Point, alphaStrength:Number = 1):void {
			
			var startX:Number = destPoint.x < 0 ? 0 : destPoint.x;
			var endX:Number = destPoint.x + srcRect.width > destBitmapData.width ? destBitmapData.width : destPoint.x + srcRect.width;
			var startY:Number = destPoint.y < 0 ? 0 : destPoint.y;
			var endY:Number = destPoint.y + srcRect.height > destBitmapData.height ? destBitmapData.height : destPoint.y + srcRect.height;
			
			var destPointX:int = destPoint.x;
			var destPointY:int = destPoint.y;
			var alphaPointX:int = alphaPoint.x;
			var alphaPointY:int = alphaPoint.y;
			var alphaBitmapDataPointX:int;
			var alphaBitmapDataPointY:int;
			var currX:int;
			var currY:int;
			var srcX:int = srcRect.x;
			var srcY:int = srcRect.y;
			
			var srcPixel:uint;
			var destPixel:uint;
			var alphaPixel:uint;
			var srcR:Number;
			var srcG:Number;
			
			var alphaA:Number;
			var destR:Number;
			var destG:Number;
			var destB:Number;
			var destA:Number;
			var multipliedR:Number;
			var multipliedG:Number;
			
			var tempColorAverage:Number;
			
			var floatingAlpha:Number;
			
			
			for (var i:int = startY; i<endY; i++) {
				for (var j:int = startX; j<endX; j++) {
					
					currX = j - destPointX + srcX;
					currY = i - destPointY + srcY;
					
					alphaBitmapDataPointX = j - destPointX + alphaPointX;
					alphaBitmapDataPointY = i - destPointY + alphaPointY;
					alphaPixel = alphaBitmapData.getPixel32(alphaBitmapDataPointX, alphaBitmapDataPointY);
					
					alphaA = alphaPixel >> 24 & 0xFF;
					floatingAlpha = (alphaA / 255)*alphaStrength;
					
					if (floatingAlpha == 0) { continue; } 
					
					destPixel = destBitmapData.getPixel32(j, i);
					srcPixel = Math.abs(srcBitmapData.getPixel32(currX, currY));// - destPixel);
					
					srcR = srcPixel >> 16 & 0xFF;
					srcG = srcPixel >> 8 & 0xFF;
					
					
					destA = destBitmapData.transparent ? destPixel >> 24 & 0xFF : 0xFF;
					destR = destPixel >> 16 & 0xFF;
					destG = destPixel >> 8 & 0xFF;
					destB = destPixel & 0xFF;
					
					tempColorAverage = Math.round(((srcR << 8) + srcG) * floatingAlpha);
					multipliedR = (tempColorAverage >> 8);
					multipliedG = tempColorAverage - (multipliedR*256);
					
					destPixel += ((multipliedR << 16 | multipliedG << 8));
					
					destPixel = destPixel < 0 ? 0 : destPixel;
					destPixel = destPixel > 0xFFFFFF00 ? 0xFFFFFF00 : destPixel;
					
					destBitmapData.setPixel32(j, i, destPixel);

				}
			}
		}
		
		public function subtractPixels16Bit(srcBitmapData:BitmapData, srcRect:Rectangle, destBitmapData:BitmapData, destPoint:Point, alphaBitmapData:BitmapData, alphaPoint:Point, alphaStrength:Number = 1):void {
			
			var startX:Number = destPoint.x < 0 ? 0 : destPoint.x;
			var endX:Number = destPoint.x + srcRect.width > destBitmapData.width ? destBitmapData.width : destPoint.x + srcRect.width;
			var startY:Number = destPoint.y < 0 ? 0 : destPoint.y;
			var endY:Number = destPoint.y + srcRect.height > destBitmapData.height ? destBitmapData.height : destPoint.y + srcRect.height;
			
			var destPointX:int = destPoint.x;
			var destPointY:int = destPoint.y;
			var alphaPointX:int = alphaPoint.x;
			var alphaPointY:int = alphaPoint.y;
			var alphaBitmapDataPointX:int;
			var alphaBitmapDataPointY:int;
			var currX:int;
			var currY:int;
			var srcX:int = srcRect.x;
			var srcY:int = srcRect.y;
			
			var srcPixel:uint;
			var destPixel:uint;
			var alphaPixel:uint;
			var srcR:Number;
			var srcG:Number;
			
			var alphaA:Number;
			var destR:Number;
			var destG:Number;
			var destB:Number;
			var destA:Number;
			var multipliedR:Number;
			var multipliedG:Number;
			
			var tempColorAverage:Number;
			
			var floatingAlpha:Number;

			for (var i:int = startY; i<endY; i++) {
				for (var j:int = startX; j<endX; j++) {
					
					currX = j - destPointX + srcX;
					currY = i - destPointY + srcY;
					
					alphaBitmapDataPointX = j - destPointX + alphaPointX;
					alphaBitmapDataPointY = i - destPointY + alphaPointY;
					alphaPixel = alphaBitmapData.getPixel32(alphaBitmapDataPointX, alphaBitmapDataPointY);
					
					alphaA = alphaPixel >> 24 & 0xFF;
					floatingAlpha = (alphaA / 255)*alphaStrength;
					
					if (floatingAlpha == 0) { continue; }
					
					destPixel = destBitmapData.getPixel32(j, i);
					
					srcPixel = Math.abs(srcBitmapData.getPixel32(currX, currY));
					
					srcR = srcPixel >> 16 & 0xFF;
					srcG = srcPixel >> 8 & 0xFF;
					
					destA = destBitmapData.transparent ? destPixel >> 24 & 0xFF : 0xFF;
					destR = destPixel >> 16 & 0xFF;
					destG = destPixel >> 8 & 0xFF;
					destB = destPixel & 0xFF;
					
					tempColorAverage = Math.round(((srcR << 8) + srcG) * floatingAlpha);
					multipliedR = (tempColorAverage >> 8);
					multipliedG = tempColorAverage - (multipliedR*256);
					
					destPixel -= ((multipliedR << 16 | multipliedG << 8));
					
					destPixel = destPixel < 0 ? 0 : destPixel;
					destPixel = destPixel > 0xFFFFFF00 ? 0xFFFFFF00 : destPixel;
					
					destBitmapData.setPixel32(j, i, destPixel);
						
				}
			}	
		}
		
		public function blurPixels16Bit(destBitmapData:BitmapData, destRect:Rectangle, alphaBitmapData:BitmapData = null, alphaStrength:Number = 1, _use9x9:Boolean = false):void {
			
			var blurredBitmapData:BitmapData = new BitmapData(destRect.width, destRect.height, true, 0xFF000000);
			var copyBitmapData:BitmapData = new BitmapData(destRect.width, destRect.height, true, 0xFF000000);
			copyPixels16Bit(destBitmapData, destRect, copyBitmapData, new Point(), destBitmapData, new Point());
			
			var xOffset:uint = destRect.x;
			var yOffset:uint = destRect.y;
			var pixelAverageCount:uint;
			var heightSum:uint;
			var heightAverage:uint;
			var pixel:uint;
			var srcR:uint;
			var srcG:uint;
			var averagedColor:uint;
			
			var alphaPixel:uint;
			var alphaA:uint;
			var floatingAlpha:Number;
			var destPixel:uint;
			var destR:uint;
			var destG:uint;
			var destHeightSum:uint;
			var heightDifference:int;
			var colorChange:uint;
			
			for (var i:int = 0; i<copyBitmapData.height; i++) {
				for (var j:int = 0; j<copyBitmapData.width; j++) {
					
					pixel = copyBitmapData.getPixel32(j, i);
					srcR = pixel >> 16 & 0xFF;
					srcG = pixel >> 8 & 0xFF;
					
					heightSum = 256 * srcR + srcG;
					pixelAverageCount = 1;
					
					if (j !== 0) {
						pixel = copyBitmapData.getPixel(j - 1, i);
						srcR = pixel >> 16 & 0xFF;
						srcG = pixel >> 8 & 0xFF;
						heightSum += 256 * srcR + srcG;
						pixelAverageCount++;
						if (_use9x9) {
							if (i !== 0) {
								pixel = copyBitmapData.getPixel(j - 1, i - 1);
								srcR = pixel >> 16 & 0xFF;
								srcG = pixel >> 8 & 0xFF;
								heightSum += 256 * srcR + srcG;
								pixelAverageCount++;
							}
							
							if (i !== copyBitmapData.height - 1) {
								pixel = copyBitmapData.getPixel(j - 1, i + 1);
								srcR = pixel >> 16 & 0xFF;
								srcG = pixel >> 8 & 0xFF;
								heightSum += 256 * srcR + srcG;
								pixelAverageCount++;
							}
						}
						
					}
					
					if (j !== copyBitmapData.width - 1) {
						
						pixel = copyBitmapData.getPixel(j + 1, i);
						srcR = pixel >> 16 & 0xFF;
						srcG = pixel >> 8 & 0xFF;
						heightSum += 256 * srcR + srcG;
						pixelAverageCount++;
						if (_use9x9) {
							if (i !== 0) {
								pixel = copyBitmapData.getPixel(j + 1, i - 1);
								srcR = pixel >> 16 & 0xFF;
								srcG = pixel >> 8 & 0xFF;
								heightSum += 256 * srcR + srcG;
								pixelAverageCount++;
							}
							
							if (i !== copyBitmapData.height - 1) {
								pixel = copyBitmapData.getPixel(j + 1, i + 1);
								srcR = pixel >> 16 & 0xFF;
								srcG = pixel >> 8 & 0xFF;
								heightSum += 256 * srcR + srcG;
								pixelAverageCount++;
							}
						}
					}
					
					if (i !== 0) {
						pixel = copyBitmapData.getPixel(j, i - 1);
						srcR = pixel >> 16 & 0xFF;
						srcG = pixel >> 8 & 0xFF;
						heightSum += 256 * srcR + srcG;
						pixelAverageCount++;
					}
					
					if (i !== copyBitmapData.height - 1) {
						pixel = copyBitmapData.getPixel(j, i + 1);
						srcR = pixel >> 16 & 0xFF;
						srcG = pixel >> 8 & 0xFF;
						heightSum += 256 * srcR + srcG;
						pixelAverageCount++;
					}
					
					heightAverage = Math.round(heightSum / pixelAverageCount);
					averagedColor = 255 << 24 | uint(heightAverage / 256) << 16 | uint(heightAverage % 256) << 8 | 0; 
					
					blurredBitmapData.setPixel32(j, i, averagedColor);
					
				}
			}
			
			for (i = 0; i<copyBitmapData.height; i++) {
				for (j = 0; j<copyBitmapData.width; j++) {
					
					if (alphaBitmapData) {
						alphaPixel = alphaBitmapData.getPixel32(j, i);
						alphaA = alphaPixel >> 24 & 0xFF;
						floatingAlpha = (alphaA / 255)*alphaStrength;
					} else {
						floatingAlpha = 1;
					}
					
					
					pixel = blurredBitmapData.getPixel32(j, i);
					srcR = pixel >> 16 & 0xFF;
					srcG = pixel >> 8 & 0xFF;
					heightSum += 256 * srcR + srcG;
					
					destPixel = copyBitmapData.getPixel32(j, i);
					destR = destPixel >> 16 & 0xFF;
					destG = destPixel >> 8 & 0xFF;
					heightDifference = (pixel - destPixel)*floatingAlpha;

					if (heightDifference < 0) {
						destPixel = destPixel + heightDifference < 0 ? 0 : destPixel + heightDifference;
						destBitmapData.setPixel32(j + xOffset, i + yOffset, destPixel);
					} else if (heightDifference > 0) {
						destPixel = destPixel + heightDifference > 0xFFFFFF00 ? 0xFFFFFF00 : destPixel + heightDifference;
						destBitmapData.setPixel32(j + xOffset, i + yOffset, destPixel);
					}
				}
			}
		}
		
		public function createAveraged16BitBitmapData(srcBitmapData:BitmapData, ingoreEmptyPixels:Boolean = true):BitmapData {
			
			var bmd:BitmapData = new BitmapData(srcBitmapData.width - 1, srcBitmapData.height - 1, true, 0xFF000000);
			
			var topLeftPoint:Point = new Point();
			var topRightPoint:Point = new Point();
			var bottomLeftPoint:Point = new Point();
			var bottomRightPoint:Point = new Point();
			var sqr:uint = srcBitmapData.width;
			
			var pix1:uint; var pix2:uint; var pix3:uint; var pix4:uint;
			var r1:uint; var r2:uint; var r3:uint; var r4:uint;
			var g1:uint; var g2:uint; var g3:uint; var g4:uint;
			var sum1:uint; var sum2:uint; var sum3:uint; var sum4:uint;
			var avg:uint;
			var averagedColor:uint;
			
			
			for (var i:int = 0; i<srcBitmapData.height - 1; i++) {
				for (var j:int = 0; j<srcBitmapData.width - 1; j++) {
					
					var count:uint = 0;
					
					topLeftPoint.x = j;
					topLeftPoint.y = i;
					topRightPoint.x = j + 1;
					topRightPoint.y = i;
					bottomLeftPoint.x = j;
					bottomLeftPoint.y = i + 1;
					bottomRightPoint.x = j + 1;
					bottomRightPoint.y=  i + 1;
					
					pix1 = srcBitmapData.getPixel(topLeftPoint.x, topLeftPoint.y);
					pix2 = srcBitmapData.getPixel(topRightPoint.x, topRightPoint.y);
					pix3 = srcBitmapData.getPixel(bottomLeftPoint.x, bottomLeftPoint.y);
					pix4 = srcBitmapData.getPixel(bottomRightPoint.x, bottomRightPoint.y);
					
					r1 = pix1 >> 16 & 0xFF;
					r2 = pix2 >> 16 & 0xFF;
					r3 = pix3 >> 16 & 0xFF;
					r4 = pix4 >> 16 & 0xFF;
					
					g1 = pix1 >> 8 & 0xFF;
					g2 = pix2 >> 8 & 0xFF;
					g3 = pix3 >> 8 & 0xFF;
					g4 = pix4 >> 8 & 0xFF;
					
					sum1 = 256 * r1 + g1;
					sum2 = 256 * r2 + g2;
					sum3 = 256 * r3 + g3;
					sum4 = 256 * r4 + g4;
					
					if (ingoreEmptyPixels) {
						if (pix1 !== 0) count++;
						if (pix2 !== 0) count++;
						if (pix3 !== 0) count++;
						if (pix4 !== 0) count++;
					} else {
						count = 4;
					}
					
					avg = Math.round((sum1 + sum2 + sum3 + sum4) / count);
					
					averagedColor = 255 << 24 | uint(avg / 256) << 16 | uint(avg % 256) << 8 | 0; 
					
					bmd.setPixel32(j, i, averagedColor);
				}
			}
			
			return bmd;
		}
		
		public function createExpandedBitmap(srcBitmapData:BitmapData, expandRect:Rectangle, repeatedEdges:uint = 3):BitmapData {
			
			if (repeatedEdges == 0) { return srcBitmapData; }
			
			var bmd:BitmapData = new BitmapData(expandRect.width + repeatedEdges*2, expandRect.height + repeatedEdges*2, true, 0x00000000);
			var pixel:uint;
			var i:uint;
			
			bmd.copyPixels(srcBitmapData, expandRect, new Point(repeatedEdges, repeatedEdges), null, null, true); //COPY MAIN IMAGE
			
			//COPY LEFT EDGES
			for (i = 0; i<repeatedEdges; i++) {
				bmd.copyPixels(srcBitmapData, new Rectangle(expandRect.x, expandRect.y, 1, expandRect.height), new Point(i, repeatedEdges), null, null, true);
			}
			
			//COPY RIGHT EDGES
			for (i = 0; i<repeatedEdges; i++) {
				bmd.copyPixels(srcBitmapData, new Rectangle(expandRect.x + expandRect.width - 1, expandRect.y, 1, expandRect.height), new Point(expandRect.width + repeatedEdges + i, repeatedEdges), null, null, true);
			}
			//COPY TOP EDGES
			for (i = 0; i<repeatedEdges; i++) {
				bmd.copyPixels(srcBitmapData, new Rectangle(expandRect.x, expandRect.y, expandRect.width, 1), new Point(repeatedEdges, i), null, null, true);
			}
			
			//COPY BOTTOM EDGES
			for (i = 0; i<repeatedEdges; i++) {
				bmd.copyPixels(srcBitmapData, new Rectangle(expandRect.x, expandRect.y + expandRect.height - 1, expandRect.width, 1), new Point(repeatedEdges, expandRect.height + repeatedEdges + i), null, null, true);
			}
			//TOP LEFT repeatedEdges x repeatedEdges CORNER
			pixel = srcBitmapData.getPixel32(expandRect.x, expandRect.y);
			if (repeatedEdges > 0) bmd.fillRect(new Rectangle(0, 0, repeatedEdges, repeatedEdges), pixel);
			
			//TOP RIGHT repeatedEdges x repeatedEdges CORNER
			pixel = srcBitmapData.getPixel32(expandRect.x + expandRect.width - 1, expandRect.y);
			if (repeatedEdges > 0) bmd.fillRect(new Rectangle(expandRect.width + repeatedEdges, 0, repeatedEdges, repeatedEdges), pixel);
			
			//BOTTOM LEFT repeatedEdges x repeatedEdges CORNER
			pixel = srcBitmapData.getPixel32(expandRect.x, expandRect.y + expandRect.height - 1);
			if (repeatedEdges > 0) bmd.fillRect(new Rectangle(0, expandRect.height + repeatedEdges, repeatedEdges, repeatedEdges), pixel);
			
			//BOTTOM RIGHT repeatedEdges x repeatedEdges CORNER
			pixel = srcBitmapData.getPixel32(expandRect.x + expandRect.width - 1, expandRect.y + expandRect.height - 1);
			if (repeatedEdges > 0) bmd.fillRect(new Rectangle(expandRect.width + repeatedEdges, expandRect.height + repeatedEdges, repeatedEdges, repeatedEdges), pixel);
			
			return bmd;
		}
		
		public function scalePixels16Bit(srcBitmapData:BitmapData, srcRect:Rectangle, destBitmapData:BitmapData, destPoint:Point, scale:Number):void {
			
			
			var startX:Number = destPoint.x < 0 ? 0 : destPoint.x;
			var endX:Number = destPoint.x + srcRect.width > destBitmapData.width ? destBitmapData.width : destPoint.x + srcRect.width;
			var startY:Number = destPoint.y < 0 ? 0 : destPoint.y;
			var endY:Number = destPoint.y + srcRect.height > destBitmapData.height ? destBitmapData.height : destPoint.y + srcRect.height;
			
			var destPointX:int = destPoint.x;
			var destPointY:int = destPoint.y;
			var currX:int;
			var currY:int;
			var srcX:int = srcRect.x;
			var srcY:int = srcRect.y;
			
			var srcPixel:uint;
			var destPixel:uint;
			var srcR:Number;
			var srcG:Number;
			
			var multipliedR:Number;
			var multipliedG:Number;
			
			var tempColorHeight:Number;
			
			
			for (var i:int = startY; i<endY; i++) {
				for (var j:int = startX; j<endX; j++) {
					
					currX = j - destPointX + srcX;
					currY = i - destPointY + srcY;
					
					srcPixel = Math.abs(srcBitmapData.getPixel32(currX, currY));
					srcR = srcPixel >> 16 & 0xFF;
					srcG = srcPixel >> 8 & 0xFF;
					
					tempColorHeight = Math.round(((srcR << 8) + srcG)*scale);
					
					multipliedR = (tempColorHeight >> 8);
					multipliedG = tempColorHeight - (multipliedR*256);
					
					destPixel = (0xFF << 24) | multipliedR << 16 | multipliedG << 8;
					
					destPixel = destPixel < 0 ? 0 : destPixel;
					destPixel = destPixel > 0xFFFFFF00 ? 0xFFFFFF00 : destPixel;
					
					
					destBitmapData.setPixel32(j, i, destPixel);	
				}
			}
			
			
		}
		
		public function getDifferenceVector(bmd1:BitmapData, bmd2:BitmapData, transparent:Boolean = false):Vector.<uint> {
			
			var bmdVec1:Vector.<uint> = bmd1.getVector(bmd1.rect);
			var bmdVec2:Vector.<uint> = bmd2.getVector(bmd2.rect);
			
			if (bmdVec1.length !== bmdVec2.length) throw new Error("BitmapData objects must be the same size to get the difference");
			
			var diffVec:Vector.<uint> = new Vector.<uint>(bmdVec1.length, true);
			
			for (var i:uint = 0; i<bmdVec1.length; i++) {
				var diff:int = bmdVec1[i] - bmdVec2[i];
				
				diffVec[i] = diff < 0 ? 0 : diff;
				
				if (transparent == false) {
					diffVec[i] += 0xFF000000;
				}
			}
			
			return diffVec;
			
		}
	}
}