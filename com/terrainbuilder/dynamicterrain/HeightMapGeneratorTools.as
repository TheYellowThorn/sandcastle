/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.dynamicterrain
{
	import com.terrainbuilder.dynamicterrain.display.BitmapDataRGBA;
	import com.terrainbuilder.dynamicterrain.settings.PerlinBaseSettings;
	import com.terrainbuilder.dynamicterrain.settings.PerlinDisplacementMapSettings;
	import com.terrainbuilder.dynamicterrain.settings.StripeType;
	import com.terrainbuilder.dynamicterrain.settings.TerrainBaseType;
	import com.terrainbuilder.dynamicterrain.settings.TerrainSettings;
	import com.terrainbuilder.dynamicterrain.utils.BitmapDataDrawTools;
	import com.terrainbuilder.tools.BitmapUtils;
	
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class HeightMapGeneratorTools
	{
		
		private var _baseBitmapData:BitmapData;
		private var _terrainSettings:TerrainSettings;
		private var _radialBaseBitmapData:BitmapData;
		private var _stripedBaseBitmapData:BitmapData;
		private var _perlinBaseBitmapData:BitmapData;
		private var _displacementMapFilter:DisplacementMapFilter = new DisplacementMapFilter();
		private var _lightenBitmapData:BitmapData;
		private var _darkenBitmapData:BitmapData;
		public var bitmapDataDrawTools:BitmapDataDrawTools = new BitmapDataDrawTools();
		public var stage:Stage;
		
		
		public function HeightMapGeneratorTools()
		{
		}
		
		public function createCheckeredBackground(width:uint, height:uint, checkeredBlockSize:uint = 8):BitmapData {
			var checkeredBg:BitmapData = new BitmapData(width, height, true, 0);
			
			var w:uint = (width / checkeredBlockSize) + 1;
			var h:uint = (height / checkeredBlockSize) + 1;
			var rect:Rectangle = new Rectangle(0, 0, checkeredBlockSize, checkeredBlockSize);
			var colors:Array = new Array(0xFFFFFFFF, 0xFFDFDFDF);
			var color:uint;
			
			for (var i:uint = 0; i<w; i++) {
				for (var j:uint = 0; j<h; j++) {
					rect.x = j*checkeredBlockSize;
					rect.y = i*checkeredBlockSize;
					color = colors[((j % 2) + (i % 2)) % 2];
					checkeredBg.fillRect(rect, color);
				}
			}
			
			return checkeredBg;
		}
			
		
		public function createRadialBase(_terrainSettings:TerrainSettings):BitmapDataRGBA {
			
			var bitmapDataRGBA:BitmapDataRGBA = new BitmapDataRGBA();
			var maxSize:uint = 128;
			
			var radius:Number;
			radius = _terrainSettings.radialBaseSettings.radiusPercent == 0 ? _terrainSettings.width * (5/16) : _terrainSettings.radialBaseSettings.radiusPercent * _terrainSettings.width;
			
			if (_terrainSettings.width > maxSize) {
				radius = _terrainSettings.radialBaseSettings.radiusPercent * maxSize;
				_radialBaseBitmapData = new BitmapData(maxSize, maxSize, true, 0xFF000000);
			} else {
				_radialBaseBitmapData = new BitmapData(_terrainSettings.width, _terrainSettings.height, true, 0xFF000000);
				
			}
			var lowestColor:uint = (_terrainSettings.lowestElevation << 16 | _terrainSettings.lowestElevation << 8 | _terrainSettings.lowestElevation);
			var highestColor:uint = (_terrainSettings.highestElevation << 16 | _terrainSettings.highestElevation << 8 | _terrainSettings.highestElevation);
			
			if (_terrainSettings.radialBaseSettings.customGradientColors) { var colors:Array = _terrainSettings.radialBaseSettings.customGradientColors; }
			else { colors = [highestColor, lowestColor]; }
			
			if (_terrainSettings.radialBaseSettings.customGradientAlphas) { var alphas:Array = _terrainSettings.radialBaseSettings.customGradientAlphas.concat(); }
			else { alphas = [1,1]; }
			
			for (var i:uint = 0; i<alphas.length; i++) {
				alphas[i] = 1;
			}
			if (_terrainSettings.radialBaseSettings.customGradientRatios) { var ratios:Array = _terrainSettings.radialBaseSettings.customGradientRatios; }
			else { ratios = [0,255]; }			
			
			bitmapDataDrawTools.drawGradientCircleOn(_radialBaseBitmapData, radius, radius, radius, colors, alphas, ratios, 0, 0);
			
			var tempBmd:BitmapData = new BitmapData(_radialBaseBitmapData.width, _radialBaseBitmapData.height,  false, 0x000000);
			tempBmd.copyPixels(_radialBaseBitmapData, _radialBaseBitmapData.rect, new Point((_radialBaseBitmapData.width - (2 * radius)) / 2, (_radialBaseBitmapData.height - (2 * radius)) / 2));

			_radialBaseBitmapData = tempBmd.clone();
			
			if (_terrainSettings.width > maxSize) {
				_radialBaseBitmapData = BitmapUtils.scaleBitmap2(_radialBaseBitmapData, _terrainSettings.width / maxSize, _terrainSettings.height / maxSize);
			}
			
			_baseBitmapData = _radialBaseBitmapData.clone();
			tempBmd.dispose();
			
			if (_terrainSettings.width > maxSize) {
				radius = _terrainSettings.radialBaseSettings.radiusPercent * maxSize;
				_radialBaseBitmapData = new BitmapData(maxSize, maxSize, true, 0x00000000);
			} else {
				_radialBaseBitmapData = new BitmapData(_terrainSettings.width, _terrainSettings.height, true, 0x00000000);
			}
			
			if (_terrainSettings.radialBaseSettings.customGradientAlphas) { alphas = _terrainSettings.radialBaseSettings.customGradientAlphas; }
			else { alphas = [1,1]; }
			
			bitmapDataDrawTools.drawGradientCircleOn(_radialBaseBitmapData, radius, radius, radius, colors, alphas, ratios, 0, 0);
			
			tempBmd = new BitmapData(_radialBaseBitmapData.width, _radialBaseBitmapData.height,  true, 0x00000000);
			tempBmd.copyPixels(_radialBaseBitmapData, _radialBaseBitmapData.rect, new Point((_radialBaseBitmapData.width - (2 * radius)) / 2, (_radialBaseBitmapData.height - (2 * radius)) / 2));

			_radialBaseBitmapData = tempBmd.clone();
			
			if (_terrainSettings.width > maxSize) {
				_radialBaseBitmapData = BitmapUtils.scaleBitmap2(_radialBaseBitmapData, _terrainSettings.width / maxSize, _terrainSettings.height / maxSize);
			}
			
			tempBmd.dispose();
			
			bitmapDataRGBA.bitmapDataRGB = _baseBitmapData;
			bitmapDataRGBA.bitmapDataA = _radialBaseBitmapData;
			
			return bitmapDataRGBA;

		}
		
		public function createStripedBase(_terrainSettings:TerrainSettings):BitmapDataRGBA {
			
			var bitmapDataRGBA:BitmapDataRGBA = new BitmapDataRGBA();
			
			var stripeSize:uint = _terrainSettings.height / _terrainSettings.stripedBaseSettings.stripes;
			_stripedBaseBitmapData = new BitmapData(_terrainSettings.width, _terrainSettings.height, true, 0);
			
			var lowestColor:uint = (_terrainSettings.lowestElevation << 16 | _terrainSettings.lowestElevation << 8 | _terrainSettings.lowestElevation);
			var highestColor:uint = (_terrainSettings.highestElevation << 16 | _terrainSettings.highestElevation << 8 | _terrainSettings.highestElevation);
			
			var firstColor:uint = _terrainSettings.stripedBaseSettings.stripeLowestElevationFirst ? lowestColor : highestColor;
			var secondColor:uint = _terrainSettings.stripedBaseSettings.stripeLowestElevationFirst ? highestColor : lowestColor;
			
			var colors:Array = _terrainSettings.stripedBaseSettings.customGradientColors ? _terrainSettings.stripedBaseSettings.customGradientColors : new Array(firstColor, secondColor);
			var alphas:Array = _terrainSettings.stripedBaseSettings.customGradientAlphas ? _terrainSettings.stripedBaseSettings.customGradientAlphas : new Array(1, 1);
			var ratios:Array = _terrainSettings.stripedBaseSettings.customGradientRatios ? _terrainSettings.stripedBaseSettings.customGradientRatios : new Array(64, 191);
			
			var m:MovieClip = stripedMovieClip(_terrainSettings, colors, alphas, ratios);
			_stripedBaseBitmapData.draw(m);
			
			if (_terrainSettings.stripedBaseSettings.stripeType == StripeType.HORIZONTAL) {
				_stripedBaseBitmapData = BitmapUtils.rotateBitmap(_stripedBaseBitmapData, 90, stage);
			}
			
			_baseBitmapData = _stripedBaseBitmapData;
			
			bitmapDataRGBA.bitmapDataRGB = _baseBitmapData;
			bitmapDataRGBA.bitmapDataA = _stripedBaseBitmapData;
			
			return bitmapDataRGBA;
			
		}
		public function createPerlinBase(_terrainSettings:TerrainSettings):BitmapData {
			
			var settings:PerlinBaseSettings = _terrainSettings.perlinBaseSettings;
			
			_perlinBaseBitmapData = new BitmapData(_terrainSettings.width, _terrainSettings.height, true, 0);
			_perlinBaseBitmapData.perlinNoise(settings.baseX, settings.baseY, settings.numOctaves, settings.seed, settings.stitch, settings.fractalNoise, settings.channelOptions, settings.grayScale, settings.offsets);
			
			_baseBitmapData = _perlinBaseBitmapData;
			
			return _baseBitmapData;
		}
		public function createDisplacementPerlinBase(_terrainSettings:TerrainSettings):BitmapData {
			
			var bmd:BitmapData = new BitmapData(_terrainSettings.width, _terrainSettings.height, true, 0xFFFFFFFF);
			
			var perlinSettings:PerlinDisplacementMapSettings = _terrainSettings.displacementMapSettings.perlinSettings;
			bmd.perlinNoise(perlinSettings.baseX, perlinSettings.baseY, perlinSettings.numOctaves, perlinSettings.seed, perlinSettings.stitch, perlinSettings.fractalNoise, perlinSettings.channelOptions, perlinSettings.grayScale, perlinSettings.offsets);
		
			return bmd;
		}
		
		public function radialGradientCircle(_terrainSettings:TerrainSettings, radius:Number, useAlphaChannel:Boolean = false):MovieClip
		{
			var lowestColor:uint = (_terrainSettings.lowestElevation << 16 | _terrainSettings.lowestElevation << 8 | _terrainSettings.lowestElevation);
			var highestColor:uint = (_terrainSettings.highestElevation << 16 | _terrainSettings.highestElevation << 8 | _terrainSettings.highestElevation);
			var c:MovieClip = new MovieClip();
			var mtx:Matrix = new Matrix();
			mtx.createGradientBox(radius*2,radius*2,0,0, 0);
			
			if (_terrainSettings.radialBaseSettings.customGradientColors) { var colors:Array = _terrainSettings.radialBaseSettings.customGradientColors; }
			else { colors = [highestColor, lowestColor]; }
			
			if (_terrainSettings.radialBaseSettings.customGradientAlphas) { var alphas:Array = _terrainSettings.radialBaseSettings.customGradientAlphas; }
			else { alphas = [1,1]; }
			
			if (_terrainSettings.radialBaseSettings.customGradientRatios) { var ratios:Array = _terrainSettings.radialBaseSettings.customGradientRatios; }
			else { ratios = [0,255]; }
			
			if (!useAlphaChannel) {
				for (var i:uint = 0; i<alphas.length; i++) {
					alphas[i] = 1;
				}
			}
			
			if (colors.length !== alphas.length) throw new Error("CUSTOM GRADIENT COLOR ARRAY LENGTH MUST MATCH ALPHA ARRAY LENGTH");
			if (colors.length !== ratios.length) throw new Error("CUSTOM GRADIENT COLOR ARRAY LENGTH MUST MATCH RATIO ARRAY LENGTH");
			if (alphas.length !== ratios.length) throw new Error("CUSTOM GRADIENT ALPHA ARRAY LENGTH MUST MATCH RATIO ARRAY LENGTH");
			
			c.graphics.beginGradientFill(GradientType.RADIAL, colors, alphas, ratios, mtx);
			
			c.graphics.drawCircle(radius,radius,radius);
			
			return c;
		}
		
		private function stripedMovieClip(_terrainSettings:TerrainSettings, colors:Array, alphas:Array, ratios:Array):MovieClip
		{
			var c:MovieClip = new MovieClip();
			var mtx:Matrix = new Matrix();
			mtx.createGradientBox(_terrainSettings.width, _terrainSettings.height, 0, 0, 0);
			
			c.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, mtx);
			
			c.graphics.drawRect(0, 0, _terrainSettings.width, _terrainSettings.height);
			
			return c;
		}
		
		public function createRectangularMask(_terrainSettings:TerrainSettings):BitmapData {
			
			var fadeSize:uint = _terrainSettings.terrainEdgeSettings.edgeFadePercent * _terrainSettings.width;
			var filter:GlowFilter = new GlowFilter(0x000000, 1, fadeSize, fadeSize, 3, 3, true, false);
			
			var bmd:BitmapData = new BitmapData(_terrainSettings.width, _terrainSettings.height, true, 0xFFFFFFFF);
			
			bmd.applyFilter(bmd, bmd.rect, new Point(), filter);
			bmd.copyChannel(bmd, bmd.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
			
			return bmd;
		}
		
		public function createEllipticalMask(_terrainSettings:TerrainSettings):BitmapData {
			
			var fadeSize:uint = _terrainSettings.terrainEdgeSettings.edgeFadePercent * _terrainSettings.width;
			var filter:GlowFilter = new GlowFilter(0x000000, 1, fadeSize, fadeSize, 3, 3, true, false);
			var m:MovieClip;
			
			var bmd:BitmapData = new BitmapData(_terrainSettings.width, _terrainSettings.height, true, 0x00FFFFFF);
			
			m = new MovieClip();
			m.graphics.beginFill(0xFFFFFF, 1);
			m.graphics.drawEllipse(0, 0, _terrainSettings.width, _terrainSettings.height);
			m.graphics.endFill();
			
			bmd.draw(m);
			
			bmd.applyFilter(bmd, bmd.rect, new Point(), filter);
			bmd.copyChannel(bmd, bmd.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
			
			return bmd;
		}
		
		public function createRadialMask(_terrainSettings:TerrainSettings):BitmapData {
			
			var fadeSize:uint = _terrainSettings.terrainEdgeSettings.edgeFadePercent * _terrainSettings.width;
			var filter:GlowFilter = new GlowFilter(0x000000, 1, fadeSize, fadeSize, 3, 3, true, false);
			var m:MovieClip;
			
			var bmd:BitmapData = new BitmapData(_terrainSettings.width, _terrainSettings.height, true, 0x00FFFFFF);
			
			m = new MovieClip();
			m.graphics.beginFill(0xFFFFFF, 1);
			m.graphics.drawCircle(_terrainSettings.width / 2, _terrainSettings.height / 2, _terrainSettings.width / 2);
			m.graphics.endFill();
			
			bmd.draw(m);
			
			bmd.applyFilter(bmd, bmd.rect, new Point(), filter);
			bmd.copyChannel(bmd, bmd.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
			
			return bmd;
		}
		
		public function get16BitHeightMapAlphaMap(srcBitmapData:BitmapData, _terrainSettings:TerrainSettings):BitmapData {
			
			var bmd:BitmapData = new BitmapData(srcBitmapData.width, srcBitmapData.height, true, 0);
			var srcPixel:uint;
			var bmdR:uint;
			var bmdG:uint;
			
			for (var i:uint = 0; i<srcBitmapData.height; i++) {
				for (var j:uint = 0; j<srcBitmapData.width; j++) {
					srcPixel = srcBitmapData.getPixel32(j, i);
					
					bmdR = srcPixel >> 16 & 0xFF;
					bmdG = srcPixel >> 8 & 0xFF;
					
					if (bmdR > 0 || bmdG > 0) {
						bmd.setPixel32(j, i, 0xFF000000);
					} else {
						bmd.setPixel32(j, i, 0x00000000);
					}
				}
				
			}
			
			
			var blurX:uint;
			var blurY:uint;
			var strength:uint;
			
			if (_terrainSettings.terrainBaseType == TerrainBaseType.RADIAL) {
				blurX = Math.ceil(srcBitmapData.width * _terrainSettings.terrainEdgeSettings.edgeFadePercent);
				blurY = Math.ceil(srcBitmapData.height * _terrainSettings.terrainEdgeSettings.edgeFadePercent);
				strength = Math.ceil(blurX / 2);
			} else {
				blurX = Math.ceil(srcBitmapData.width * _terrainSettings.terrainEdgeSettings.edgeFadePercent);
				blurY = Math.ceil(srcBitmapData.height * _terrainSettings.terrainEdgeSettings.edgeFadePercent);
				strength = 2;
			}
			var glowFilter:GlowFilter = new GlowFilter(0xFF0000, 1, blurX, blurY, strength, 3, true, false);
			
			var bmd2:BitmapData = bmd.clone();
			bmd2.applyFilter(bmd, bmd.rect, new Point(), glowFilter);
			bmd2.draw(bmd2, null, null, BlendMode.INVERT, bmd2.rect);
			
			bmd.copyChannel(bmd2, bmd2.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
			
			if (_terrainSettings.scaleX !== 1 || _terrainSettings.scaleY !== 1) {
				bmd = BitmapUtils.scaleBitmap2(bmd, _terrainSettings.scaleX, _terrainSettings.scaleY);
			}
			
			return bmd;
		}
		
		public function get16BitHeightOffsetBitmapData(_terrainSettings:TerrainSettings, rotation:Number = 0):BitmapData {
			
			var bmdR:uint;
			var bmdG:uint;
			var rotatedSize:uint = Math.abs(_terrainSettings.width * Math.sin(rotation * (Math.PI / 180))) + Math.abs(_terrainSettings.height * Math.cos(rotation * (Math.PI / 180)));
			
			var offset:Number = _terrainSettings.heightOffset * (_terrainSettings.width / _terrainSettings.brushSizeAt100PercentHeight) * _terrainSettings.heightScale;
			
			bmdR = uint(Math.abs(offset / 256));
			bmdG = Math.abs(offset % 256);
			
			var color:uint = 0xFF << 24 | bmdR << 16 | bmdG << 8;
			
			var bmd:BitmapData = new BitmapData(rotatedSize * _terrainSettings.scaleX, rotatedSize * _terrainSettings.scaleY, true, color);

			return bmd;
		}
		
		
	}
}