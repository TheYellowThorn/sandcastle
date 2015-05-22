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
	import com.terrainbuilder.dynamicterrain.settings.TerrainEdgeType;
	import com.terrainbuilder.dynamicterrain.settings.TerrainSettings;
	import com.terrainbuilder.dynamicterrain.utils.BitmapDataDrawTools;
	import com.terrainbuilder.dynamicterrain.utils.HeightMap16BitTools;
	import com.terrainbuilder.tools.BitmapUtils;
	
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.MovieClip;
	import flash.display.StageQuality;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;

	public class HeightMapGenerator
	{
		
		private var _baseBitmapData:BitmapData;
		private var _terrainSettings:TerrainSettings;
		private var _radialBaseBitmapData:BitmapData;
		private var _stripedBaseBitmapData:BitmapData;
		private var _perlinBaseBitmapData:BitmapData;
		private var _displacementMapFilter:DisplacementMapFilter = new DisplacementMapFilter();
		private var _lightenBitmapData:BitmapData;
		private var _darkenBitmapData:BitmapData;
		private var _heightMapGeneratorTools:HeightMapGeneratorTools = new HeightMapGeneratorTools();
		private var _bitmapDataDrawTools:BitmapDataDrawTools = new BitmapDataDrawTools();
		private var _heightMap16BitTools:HeightMap16BitTools = new HeightMap16BitTools();
		private var _contourAlphaBitmap:BitmapData;
		private var _lastHeightMapRGBA:BitmapDataRGBA;
		private var _lastScaledHeightMapRGBA:BitmapDataRGBA;
		
		
		public function HeightMapGenerator()
		{
		}
		
		public function generateHeightMap(settings:TerrainSettings):BitmapDataRGBA {
			
			_terrainSettings = settings;
			
			var bmdRGBA:BitmapDataRGBA = new BitmapDataRGBA();
			var heightMap:BitmapData = new BitmapData(_terrainSettings.width, _terrainSettings.height, true, 0xFF000000);//_terrainSettings.terrainBaseFillColor);
			var alphaMap:BitmapData = new BitmapData(_terrainSettings.width, _terrainSettings.height, true, 0x00000000);
			
			
			if (_terrainSettings.terrainBaseType == TerrainBaseType.RADIAL) {
				_baseBitmapData = _heightMapGeneratorTools.createRadialBase(_terrainSettings).bitmapDataA;
			} else if (_terrainSettings.terrainBaseType == TerrainBaseType.STRIPED) {
				_baseBitmapData = _heightMapGeneratorTools.createStripedBase(_terrainSettings).bitmapDataA;
			} else if (_terrainSettings.terrainBaseType == TerrainBaseType.PERLIN) {
				createPerlinBase();
			} else if (_terrainSettings.terrainBaseType == TerrainBaseType.CUSTOM) {
				_baseBitmapData = BitmapUtils.scaleBitmap2(_terrainSettings.customTerrainBase.clone(), _terrainSettings.width / _terrainSettings.customTerrainBase.width, _terrainSettings.height / _terrainSettings.customTerrainBase.height, true, StageQuality.HIGH);
			}
			
			if (_terrainSettings.invertBase) {
				_baseBitmapData.drawWithQuality(_baseBitmapData, new Matrix(), null, BlendMode.INVERT, _baseBitmapData.rect, false, StageQuality.LOW);
			}

			var dispMap:BitmapData = new BitmapData(uint(_terrainSettings.width/4), uint(_terrainSettings.height/4), true, 0);
			if (_terrainSettings.useDisplacementMap) {
				
				_displacementMapFilter.alpha = _terrainSettings.displacementMapSettings.alpha;
				_displacementMapFilter.color = _terrainSettings.displacementMapSettings.color;
				_displacementMapFilter.componentX = _terrainSettings.displacementMapSettings.componentX;
				_displacementMapFilter.componentY = _terrainSettings.displacementMapSettings.componentY;
				_displacementMapFilter.scaleX = _terrainSettings.width * _terrainSettings.displacementMapSettings.scaleX;
				_displacementMapFilter.scaleY = _terrainSettings.width * _terrainSettings.displacementMapSettings.scaleY;
				_displacementMapFilter.mode = _terrainSettings.displacementMapSettings.mode;
				_displacementMapFilter.mapPoint = _terrainSettings.displacementMapSettings.mapPoint;
				
				if (_terrainSettings.displacementMapSettings.customDisplacementMap) {
					dispMap = BitmapUtils.scaleBitmap2(dispMap, _terrainSettings.width / dispMap.width, _terrainSettings.height / dispMap.height, true, StageQuality.HIGH);
					dispMap.copyPixels(_terrainSettings.displacementMapSettings.customDisplacementMap, dispMap.rect, new Point());
				} else {
					var perlinSettings:PerlinDisplacementMapSettings = _terrainSettings.displacementMapSettings.perlinSettings;
					dispMap.perlinNoise(uint(perlinSettings.baseX / 4), uint(perlinSettings.baseY / 4), perlinSettings.numOctaves, perlinSettings.seed, perlinSettings.stitch, perlinSettings.fractalNoise, perlinSettings.channelOptions, perlinSettings.grayScale, perlinSettings.offsets);
					dispMap = BitmapUtils.scaleBitmap2(dispMap, _terrainSettings.width / dispMap.width, _terrainSettings.height / dispMap.height, true, StageQuality.HIGH);
				}
				
				if (_terrainSettings.invertDisplacementMap) {
					dispMap.drawWithQuality(dispMap, new Matrix(), null, BlendMode.INVERT, dispMap.rect, false, StageQuality.LOW);
				}
				
				_displacementMapFilter.mapBitmap = dispMap;
				dispMap.applyFilter(_baseBitmapData, dispMap.rect, new Point(), _displacementMapFilter);
				_baseBitmapData.copyPixels(dispMap, _baseBitmapData.rect, new Point());
			}
			
			if (_terrainSettings.useEdgeSettings) {
				if (_terrainSettings.terrainEdgeSettings.customEdge) {
					alphaMap = _terrainSettings.terrainEdgeSettings.customEdge;
				} else {
					
					var edgeShadeBmd:BitmapData;
					var fadeSize:uint = _terrainSettings.terrainEdgeSettings.edgeFadePercent * _terrainSettings.width;
					var filter:GlowFilter = new GlowFilter(0x000000, 1, fadeSize, fadeSize, 3, 3, true, false);
					var m:MovieClip;
					
					if (_terrainSettings.terrainEdgeSettings.terrainEdgeType == TerrainEdgeType.RECTANGULAR) {
						
						edgeShadeBmd = _heightMapGeneratorTools.createRectangularMask(_terrainSettings);
						alphaMap = edgeShadeBmd;
					
					} else if (_terrainSettings.terrainEdgeSettings.terrainEdgeType == TerrainEdgeType.ELLIPTICAL) {
						
						edgeShadeBmd = _heightMapGeneratorTools.createEllipticalMask(_terrainSettings);
						alphaMap = edgeShadeBmd;
					
					} else if (_terrainSettings.terrainEdgeSettings.terrainEdgeType == TerrainEdgeType.RADIAL) {
						
						edgeShadeBmd = _heightMapGeneratorTools.createRadialMask(_terrainSettings);
						alphaMap = edgeShadeBmd;
						
					}
				}
			} else {
				alphaMap = new BitmapData(_terrainSettings.width, _terrainSettings.height, true, 0xFFFFFFFF);
			}
			
			if (_terrainSettings.invertEdge) {
				alphaMap.drawWithQuality(alphaMap, new Matrix(), null, BlendMode.INVERT, alphaMap.rect, false, StageQuality.LOW);
			}
			
			if (_terrainSettings.useThresholdSettings) {
				var cloneBmd:BitmapData = _baseBitmapData.clone();
				_baseBitmapData.threshold(_baseBitmapData, _baseBitmapData.rect, new Point(), ">", _terrainSettings.thresholdSettings.highestHeightColor, _terrainSettings.thresholdSettings.highestHeightReplacementColor, 0x00FF0000, true);
				_baseBitmapData.threshold(_baseBitmapData, _baseBitmapData.rect, new Point(), "<", _terrainSettings.thresholdSettings.lowestHeightColor, _terrainSettings.thresholdSettings.lowestHeightReplacementColor, 0x00FF0000, true);
				_baseBitmapData.copyPixels(_baseBitmapData, _baseBitmapData.rect, new Point(), cloneBmd, new Point(), false);
			}
			
			if (_terrainSettings.strength !== 1) {
				var colorTransform:ColorTransform = new ColorTransform(1, 1, 1, _terrainSettings.strength, 0, 0, 0, 0);
				_baseBitmapData.colorTransform(_baseBitmapData.rect,  colorTransform);
			}
			if (_terrainSettings.contrast !== 0) {
				_baseBitmapData.applyFilter(_baseBitmapData, _baseBitmapData.rect, new Point(), setContrast(_terrainSettings.contrast));
			}
			
			if (_terrainSettings.flipVertically || _terrainSettings.flipHorizontally) {
				_baseBitmapData = BitmapUtils.flipBitmap(_baseBitmapData, _terrainSettings.flipHorizontally, _terrainSettings.flipVertically, true, StageQuality.LOW);
			}
			
			if (_terrainSettings.scaleX !== 1 || _terrainSettings.scaleY !== 1) {
				_baseBitmapData = BitmapUtils.scaleBitmap2(_baseBitmapData, _terrainSettings.scaleX, _terrainSettings.scaleY, true, StageQuality.LOW);
			}
			
			if (_terrainSettings.rotation !== 0) {
				_baseBitmapData = BitmapUtils.rotateBitmap(_baseBitmapData, _terrainSettings.rotation, null, false, StageQuality.LOW);
			}
			
			if (_terrainSettings.smoothLevel > 0) {
				var blurFilter:BlurFilter = new BlurFilter(_terrainSettings.smoothLevel, _terrainSettings.smoothLevel, 3);
				_baseBitmapData.applyFilter(_baseBitmapData, _baseBitmapData.rect, new Point(), blurFilter);
			}
			
			heightMap.copyChannel(_baseBitmapData, heightMap.rect, new Point(), BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);
			_baseBitmapData = heightMap;
			
			if (_terrainSettings.useEdgeSettings !== true) {
				_contourAlphaBitmap = alphaMap;
			} else if (_terrainSettings.terrainEdgeSettings.terrainEdgeType == TerrainEdgeType.RECTANGULAR) {
				_contourAlphaBitmap = alphaMap;
			} else if (_terrainSettings.terrainEdgeSettings.terrainEdgeType == TerrainEdgeType.ELLIPTICAL) {
				_contourAlphaBitmap = alphaMap;
			} else if (_terrainSettings.terrainEdgeSettings.terrainEdgeType == TerrainEdgeType.RADIAL) {
				_contourAlphaBitmap = alphaMap;
			} else {
				_contourAlphaBitmap = _heightMapGeneratorTools.get16BitHeightMapAlphaMap(heightMap, _terrainSettings);//generatedMapRGBA.bitmapDataA;//heightMapGeneratorTools.get16BitHeightMapAlphaMap(generatedMapRGBA.bitmapDataRGB);
			}
			
			bmdRGBA.bitmapDataRGB = heightMap;
			bmdRGBA.bitmapDataA = _contourAlphaBitmap;
			
			_lastHeightMapRGBA = bmdRGBA.clone();
			
			return bmdRGBA;
		}
		
		public function generateScaledHeightMap(settings:TerrainSettings):BitmapDataRGBA {
			
			_terrainSettings = settings;
			
			var bmdRGBA:BitmapDataRGBA = generateHeightMap(settings);
			
			if (_terrainSettings.heightScale !== 1) {
				_heightMap16BitTools.scalePixels16Bit(bmdRGBA.bitmapDataRGB, bmdRGBA.bitmapDataRGB.rect, bmdRGBA.bitmapDataRGB, new Point(), (_terrainSettings.width / _terrainSettings.brushSizeAt100PercentHeight) * _terrainSettings.heightScale);
			}
			if (_terrainSettings.useOverlaySettings) {
				var overlayBitmapData:BitmapData = new BitmapData(bmdRGBA.bitmapDataRGB.width, bmdRGBA.bitmapDataRGB.height, true, 0xFF000000);
				overlayBitmapData.perlinNoise(_terrainSettings.bumpOverlaySettings.baseX, _terrainSettings.bumpOverlaySettings.baseY, _terrainSettings.bumpOverlaySettings.numOctaves, _terrainSettings.bumpOverlaySettings.seed, _terrainSettings.bumpOverlaySettings.stitch, _terrainSettings.bumpOverlaySettings.fractalNoise, BitmapDataChannel.GREEN, false, _terrainSettings.bumpOverlaySettings.offsets);
				_heightMap16BitTools.addPixels16Bit(overlayBitmapData, overlayBitmapData.rect, bmdRGBA.bitmapDataRGB, new Point(), bmdRGBA.bitmapDataA, new Point(), _terrainSettings.bumpOverlaySettings.strength);
			}
			
			_lastScaledHeightMapRGBA = bmdRGBA.clone();
			
			return bmdRGBA;
		}
		
		public function generateScaledHeightMapFromBitmapRGBA(bmdRGBA:BitmapDataRGBA, settings:TerrainSettings):BitmapDataRGBA {
			
			_terrainSettings = settings;
			
			var newBmdRGBA:BitmapDataRGBA = new BitmapDataRGBA();
			newBmdRGBA.bitmapDataRGB = bmdRGBA.bitmapDataRGB.clone();
			newBmdRGBA.bitmapDataA = bmdRGBA.bitmapDataA.clone();
			
			if (_terrainSettings.heightScale !== 1) {
				_heightMap16BitTools.scalePixels16Bit(bmdRGBA.bitmapDataRGB, bmdRGBA.bitmapDataRGB.rect, newBmdRGBA.bitmapDataRGB, new Point(), (_terrainSettings.width / _terrainSettings.brushSizeAt100PercentHeight) * _terrainSettings.heightScale);
			}
			if (_terrainSettings.useOverlaySettings) {
				var overlayBitmapData:BitmapData = new BitmapData(newBmdRGBA.bitmapDataRGB.width, newBmdRGBA.bitmapDataRGB.height, true, 0xFF000000);
				overlayBitmapData.perlinNoise(_terrainSettings.bumpOverlaySettings.baseX, _terrainSettings.bumpOverlaySettings.baseY, _terrainSettings.bumpOverlaySettings.numOctaves, _terrainSettings.bumpOverlaySettings.seed, _terrainSettings.bumpOverlaySettings.stitch, _terrainSettings.bumpOverlaySettings.fractalNoise, BitmapDataChannel.GREEN, false, _terrainSettings.bumpOverlaySettings.offsets);
				_heightMap16BitTools.addPixels16Bit(overlayBitmapData, overlayBitmapData.rect, newBmdRGBA.bitmapDataRGB, new Point(), newBmdRGBA.bitmapDataA, new Point(), _terrainSettings.bumpOverlaySettings.strength);
			}
			
			_lastScaledHeightMapRGBA = newBmdRGBA.clone();
			
			return newBmdRGBA;
		}
		
		public function createRadialBase():void {
			
			var radius:Number;
			radius = _terrainSettings.radialBaseSettings.radiusPercent == 0 ? _terrainSettings.width * (5/16) : _terrainSettings.radialBaseSettings.radiusPercent * _terrainSettings.width;
			
			var radialMovieClip:MovieClip = radialGradientCircle(radius);
			_radialBaseBitmapData = new BitmapData(_terrainSettings.width, _terrainSettings.height, true, 0);
			_radialBaseBitmapData.draw(radialMovieClip);
			
			var tempBmd:BitmapData = new BitmapData(_terrainSettings.width, _terrainSettings.height,  true, 0);
			tempBmd.copyPixels(_radialBaseBitmapData, _radialBaseBitmapData.rect, new Point((_terrainSettings.width - (2 * radius)) / 2, (_terrainSettings.height - (2 * radius)) / 2));
			_radialBaseBitmapData = tempBmd.clone();
			
			_baseBitmapData = _radialBaseBitmapData;
			
			tempBmd.dispose();
		}
		public function createStripedBase():void {
			var stripeSize:uint = _terrainSettings.height / _terrainSettings.stripedBaseSettings.stripes;
			var stripedClip:MovieClip = stripedMovieClip(stripeSize);
			_stripedBaseBitmapData = new BitmapData(_terrainSettings.width, _terrainSettings.height, true, 0);
			_stripedBaseBitmapData.draw(stripedClip);
			
			_baseBitmapData = _stripedBaseBitmapData;
			
		}
		public function createPerlinBase():void {
			
			var settings:PerlinBaseSettings = _terrainSettings.perlinBaseSettings;
			
			_perlinBaseBitmapData = new BitmapData(uint(_terrainSettings.width / 4), uint(_terrainSettings.height / 4), true, 0);
			_perlinBaseBitmapData.perlinNoise(uint(settings.baseX / 4), uint(settings.baseY / 4), settings.numOctaves, settings.seed, settings.stitch, settings.fractalNoise, settings.channelOptions, settings.grayScale, settings.offsets);
			_perlinBaseBitmapData = BitmapUtils.scaleBitmap2(_perlinBaseBitmapData, _terrainSettings.width / _perlinBaseBitmapData.width, _terrainSettings.height / _perlinBaseBitmapData.height, true, StageQuality.HIGH);
			
			_baseBitmapData = _perlinBaseBitmapData;
		}
		
		public function get baseBitmapData():BitmapData { return _baseBitmapData; }
		
		public function radialGradientCircle(radius:Number):MovieClip
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
			
			
			if (colors.length !== alphas.length) throw new Error("CUSTOM GRADIENT COLOR ARRAY LENGTH MUST MATCH ALPHA ARRAY LENGTH");
			if (colors.length !== ratios.length) throw new Error("CUSTOM GRADIENT COLOR ARRAY LENGTH MUST MATCH RATIO ARRAY LENGTH");
			if (alphas.length !== ratios.length) throw new Error("CUSTOM GRADIENT ALPHA ARRAY LENGTH MUST MATCH RATIO ARRAY LENGTH");
			
			c.graphics.beginGradientFill(GradientType.RADIAL, colors, alphas, ratios, mtx);
			
			c.graphics.drawCircle(radius,radius,radius);
			
			return c;
		}
		
		private function stripedMovieClip(size:uint):MovieClip {
			
			var lowestColor:uint = (_terrainSettings.lowestElevation << 16 | _terrainSettings.lowestElevation << 8 | _terrainSettings.lowestElevation);
			var highestColor:uint = (_terrainSettings.highestElevation << 16 | _terrainSettings.highestElevation << 8 | _terrainSettings.highestElevation);
			
			var firstColor:uint = _terrainSettings.stripedBaseSettings.stripeLowestElevationFirst ? lowestColor : highestColor;
			var secondColor:uint = _terrainSettings.stripedBaseSettings.stripeLowestElevationFirst ? highestColor : lowestColor;
			
			var colors:Array = new Array(firstColor, secondColor);
			
			var c:MovieClip = new MovieClip();
			
			for (var i:uint = 0; i<_terrainSettings.stripedBaseSettings.stripes; i++) {
				
				var color:uint = _terrainSettings.stripedBaseSettings.customGradientColors ? _terrainSettings.stripedBaseSettings.customGradientColors[i % _terrainSettings.stripedBaseSettings.customGradientColors.length] : colors[i % 2];
				
				
				c.graphics.beginFill(color, 1);
				
				if (_terrainSettings.stripedBaseSettings.stripeType == StripeType.HORIZONTAL) {
					c.graphics.drawRect(0, size*i, _terrainSettings.width, size);
				} else {
					c.graphics.drawRect(size*i, 0, size, _terrainSettings.height);
				}
				c.graphics.endFill();
			}
			
			return c;
		}
		
		private function setContrast(value:Number):ColorMatrixFilter {
			
			var brightnessValue:Number = 1;
			var contrastValue:Number = value;
			value /= 100;
			
			var s: Number = value + 1;
			var o : Number = 128 * (1 - s);
			
			var m:Array = new Array();
			m = m.concat([s, 0, 0, 0, brightnessValue]);  // red
			m = m.concat([0, s, 0, 0, brightnessValue]);  // green
			m = m.concat([0, 0, s, 0, brightnessValue]);  // blue
			m = m.concat([0, 0, 0, 1, 0]);  // alpha
			
			return new ColorMatrixFilter(m);
		}
		
		public function get contourAlphaBitmap():BitmapData { return _contourAlphaBitmap; }
		public function set contourAlphaBitmap(value:BitmapData):void { _contourAlphaBitmap = value; }
		
		public function get lastScaledHeightMapRGBA():BitmapDataRGBA { return _lastScaledHeightMapRGBA; }
		public function get lastHeightMapRGBA():BitmapDataRGBA { return _lastHeightMapRGBA; }
	}
}