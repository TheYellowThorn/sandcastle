/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.dynamicterrain.presets
{
	import com.terrainbuilder.dynamicterrain.settings.TerrainBaseType;
	import com.terrainbuilder.dynamicterrain.settings.TerrainEdgeType;
	import com.terrainbuilder.dynamicterrain.settings.TerrainSettings;
	
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	

	public class TerrainPresets
	{
		private var _width:uint;
		private var _height:uint;
		public var bmd:BitmapData;
		public var movie:MovieClip;
		public function TerrainPresets(width:uint = 256, height:uint = 256)
		{
			_width = width;
			_height = height;
		}
		
		public function CRATER(seed:uint = 100):TerrainSettings {
			
			var terrainSettings:TerrainSettings = new TerrainSettings();
		
			terrainSettings.width = _width;
			terrainSettings.height = _height;
			terrainSettings.terrainBaseFillColor = 0;
			terrainSettings.lowestElevation = 0;
			terrainSettings.highestElevation = 255;
			terrainSettings.smoothLevel = 2;
			terrainSettings.heightScale = 512 * 1 / 100;
			terrainSettings.heightOffset = -204;
			terrainSettings.terrainEdgeSettings.edgeFadePercent = 1/20;
			terrainSettings.terrainEdgeSettings.terrainEdgeType = TerrainEdgeType.CONTOUR;
			
			/*** CUSTOM RADIAL BASE ***/
			if (this.bmd) this.bmd.dispose();
			if (terrainSettings.customTerrainBase) { 
				terrainSettings.customTerrainBase.dispose(); 
				terrainSettings.customTerrainBase = null;
			}
			terrainSettings.terrainBaseType = TerrainBaseType.RADIAL;
			terrainSettings.radialBaseSettings.radiusPercent = 1/2;
			terrainSettings.radialBaseSettings.customGradientColors = [0x222222, 0x222222, 0xCCCCCC, 0xFFFFFF, 0xDDDDDD, 0xCCCCCC];
			terrainSettings.radialBaseSettings.customGradientAlphas = [1,1,1,1,1,1];
			terrainSettings.radialBaseSettings.customGradientRatios = [0, 100, 140, 160, 210,255];
			
			/*** CUSTOM DISPLACEMENT SETTINGS ***/
			terrainSettings.displacementMapSettings.seed = seed;
			terrainSettings.displacementMapSettings.scaleX = 1 / 10;
			terrainSettings.displacementMapSettings.scaleY = 1 / 10;
			terrainSettings.displacementMapSettings.perlinSettings.baseX = 16;
			terrainSettings.displacementMapSettings.perlinSettings.baseY = 16;
			terrainSettings.displacementMapSettings.perlinSettings.numOctaves = 3;
			terrainSettings.displacementMapSettings.usePerlinDisplacementSettings = true;
			
			return terrainSettings;
		}
		
		public function MOUNTAIN(seed:uint = 1000):TerrainSettings {
			
			var terrainSettings:TerrainSettings = new TerrainSettings();
			
			terrainSettings.width = _width;
			terrainSettings.height = _height;
			terrainSettings.terrainBaseFillColor = 0;
			terrainSettings.lowestElevation = 0;
			terrainSettings.highestElevation = 255;
			terrainSettings.smoothLevel = 2;
			terrainSettings.heightScale = 512 * 1 / 25;
			terrainSettings.terrainEdgeSettings.edgeFadePercent = 1/20;
			terrainSettings.terrainEdgeSettings.terrainEdgeType = TerrainEdgeType.CONTOUR;
			
			/*** CUSTOM RADIAL BASE ***/
			if (this.bmd) this.bmd.dispose();
			if (terrainSettings.customTerrainBase) { 
				terrainSettings.customTerrainBase.dispose(); 
				terrainSettings.customTerrainBase = null;
			}
			terrainSettings.terrainBaseType = TerrainBaseType.RADIAL;
			terrainSettings.radialBaseSettings.radiusPercent = 1/2;
			terrainSettings.radialBaseSettings.customGradientColors = [0xFFFFFF,0xCCCCCC, 0x444444, 0x2F2F2F, 0x111111, 0x000000];//[0xFFFFFF, 0x888888, 0x777777, 0x333333, 0x000000];
			terrainSettings.radialBaseSettings.customGradientAlphas = [1,1,1,1,1,1];
			terrainSettings.radialBaseSettings.customGradientRatios = [10,70, 140, 160, 205,245];
			
			/*** CUSTOM DISPLACEMENT SETTINGS ***/
			terrainSettings.displacementMapSettings.seed = seed;
			terrainSettings.displacementMapSettings.scaleX = 0.15;
			terrainSettings.displacementMapSettings.scaleY = 0.15;
			terrainSettings.displacementMapSettings.perlinSettings.fractalNoise = false;
			terrainSettings.displacementMapSettings.perlinSettings.baseX = 64;
			terrainSettings.displacementMapSettings.perlinSettings.baseY = 64;
			terrainSettings.displacementMapSettings.perlinSettings.numOctaves = 3;
			terrainSettings.displacementMapSettings.usePerlinDisplacementSettings = true;
			
			return terrainSettings;
		}
		
		public function VOLCANO(seed:uint = 1000):TerrainSettings {
			
			var terrainSettings:TerrainSettings = new TerrainSettings();
			
			terrainSettings.width = _width;
			terrainSettings.height = _height;
			terrainSettings.terrainBaseFillColor = 0;
			terrainSettings.lowestElevation = 0;
			terrainSettings.highestElevation = 255;
			terrainSettings.smoothLevel = 2;
			terrainSettings.heightScale = 512 * 1 / 25;
			terrainSettings.terrainEdgeSettings.edgeFadePercent = 1/20;
			terrainSettings.terrainEdgeSettings.terrainEdgeType = TerrainEdgeType.CONTOUR;
			
			/*** CUSTOM RADIAL BASE ***/
			if (this.bmd) this.bmd.dispose();
			if (terrainSettings.customTerrainBase) { 
				terrainSettings.customTerrainBase.dispose(); 
				terrainSettings.customTerrainBase = null;
			}
			terrainSettings.terrainBaseType = TerrainBaseType.RADIAL;
			terrainSettings.radialBaseSettings.radiusPercent = 1/2;//54;
			terrainSettings.radialBaseSettings.customGradientColors = [0x000000, 0x111111, 0xCCCCCC, 0xFFFFFF, 0xEEEEEE, 0x444444, 0x2F2F2F, 0x111111, 0x000000];//[0xFFFFFF, 0x888888, 0x777777, 0x333333, 0x000000];
			terrainSettings.radialBaseSettings.customGradientAlphas = [1,1,1,1,1,1,1,1,1];
			terrainSettings.radialBaseSettings.customGradientRatios = [10, 15, 20, 40, 50, 140, 160, 205,245];
			
			/*** CUSTOM DISPLACEMENT SETTINGS ***/
			terrainSettings.displacementMapSettings.seed = seed;//Math.random()*1000;
			terrainSettings.displacementMapSettings.scaleX = 1 / 6.66;//60;
			terrainSettings.displacementMapSettings.scaleY = 1 / 6.66;//60;
			terrainSettings.displacementMapSettings.perlinSettings.baseX = 64;
			terrainSettings.displacementMapSettings.perlinSettings.baseY = 64;
			terrainSettings.displacementMapSettings.perlinSettings.numOctaves = 3;
			terrainSettings.displacementMapSettings.usePerlinDisplacementSettings = true;
			
			return terrainSettings;
		}
		
		public function RIDGE(seed:uint = 1000):TerrainSettings {
			
			var terrainSettings:TerrainSettings = new TerrainSettings();
			
			terrainSettings.width = _width;
			terrainSettings.height = _height;
			terrainSettings.terrainBaseFillColor = 0;
			terrainSettings.lowestElevation = 0;
			terrainSettings.highestElevation = 255;
			terrainSettings.smoothLevel = 2;
			terrainSettings.heightScale = 512 * 22;
			terrainSettings.terrainEdgeSettings.edgeFadePercent = 1/16;
			terrainSettings.terrainEdgeSettings.terrainEdgeType = TerrainEdgeType.CONTOUR;
			
			if (this.bmd) this.bmd.dispose();
			if (terrainSettings.customTerrainBase) { 
				terrainSettings.customTerrainBase.dispose(); 
				terrainSettings.customTerrainBase = null;
			}
			
			/*** CUSTOM PERLIN BASE ***/
			terrainSettings.terrainBaseType = TerrainBaseType.PERLIN;
			terrainSettings.perlinBaseSettings.baseX = 512;
			terrainSettings.perlinBaseSettings.baseY = 512;
			terrainSettings.perlinBaseSettings.numOctaves = 3;
			terrainSettings.perlinBaseSettings.seed = seed;
			terrainSettings.perlinBaseSettings.fractalNoise = false;
			
			/*** CUSTOM DISPLACEMENT SETTINGS ***/
			terrainSettings.displacementMapSettings.seed = seed;//Math.random()*1000;
			terrainSettings.displacementMapSettings.scaleX = 0;//355;
			terrainSettings.displacementMapSettings.scaleY = 0;//1;
			terrainSettings.displacementMapSettings.perlinSettings.baseX = 54;//40;
			terrainSettings.displacementMapSettings.perlinSettings.baseY = 54;//40;
			terrainSettings.displacementMapSettings.perlinSettings.numOctaves = 1;
			terrainSettings.displacementMapSettings.usePerlinDisplacementSettings = true;
			
			return terrainSettings;
		}
		public function DUNE(seed:uint = 1000):TerrainSettings {
			
			var terrainSettings:TerrainSettings = new TerrainSettings();
			
			terrainSettings.width = _width;
			terrainSettings.height = _height;
			terrainSettings.terrainBaseFillColor = 0;
			terrainSettings.lowestElevation = 0;
			terrainSettings.highestElevation = 255;
			terrainSettings.smoothLevel = 2;
			terrainSettings.heightScale = 512 * 1/100;//4;
			terrainSettings.terrainEdgeSettings.edgeFadePercent = 1/4;
			terrainSettings.terrainEdgeSettings.terrainEdgeType = TerrainEdgeType.CONTOUR;
			
			/*** CUSTOM STRIPED BASE SETTINGS ***/
			if (this.bmd) this.bmd.dispose();
			if (terrainSettings.customTerrainBase) { 
				terrainSettings.customTerrainBase.dispose(); 
				terrainSettings.customTerrainBase = null;
			}
			terrainSettings.terrainBaseType = TerrainBaseType.STRIPED;
			terrainSettings.stripedBaseSettings.customGradientColors = [0x000000, 0xFFFFFF, 0x000000, 0xFFFFFF, 0x000000];
			terrainSettings.stripedBaseSettings.customGradientAlphas = [1,1,1,1,1];
			terrainSettings.stripedBaseSettings.customGradientRatios = [0,54,107,155,225];
			
			/*** CUSTOM DISPLACEMENT SETTINGS ***/
			terrainSettings.displacementMapSettings.seed = seed;
			terrainSettings.displacementMapSettings.scaleX = 2/5;
			terrainSettings.displacementMapSettings.scaleY = 2/5;
			terrainSettings.displacementMapSettings.perlinSettings.baseX = 160;
			terrainSettings.displacementMapSettings.perlinSettings.baseY = 72;
			terrainSettings.displacementMapSettings.perlinSettings.numOctaves = 4;
			terrainSettings.displacementMapSettings.usePerlinDisplacementSettings = true;
			
			return terrainSettings;
		}
		
		public function LAKE(seed:uint = 1000):TerrainSettings {
			
			var terrainSettings:TerrainSettings = new TerrainSettings();
			
			terrainSettings.width = _width;
			terrainSettings.height = _height;
			terrainSettings.terrainBaseFillColor = 0;
			terrainSettings.lowestElevation = 0;
			terrainSettings.highestElevation = 255;
			terrainSettings.smoothLevel = 2;
			terrainSettings.heightScale = 512 * 1 / 100;
			terrainSettings.heightOffset = -212;
			terrainSettings.terrainEdgeSettings.edgeFadePercent = 1/20;
			terrainSettings.terrainEdgeSettings.terrainEdgeType = TerrainEdgeType.CONTOUR;
			
			/*** CUSTOM RADIAL BASE ***/
			if (this.bmd) this.bmd.dispose();
			if (terrainSettings.customTerrainBase) { 
				terrainSettings.customTerrainBase.dispose(); 
				terrainSettings.customTerrainBase = null;
			}
			terrainSettings.terrainBaseType = TerrainBaseType.RADIAL;
			terrainSettings.radialBaseSettings.radiusPercent = 1/2;
			terrainSettings.radialBaseSettings.customGradientColors = [0x111111, 0x111111, 0x666666, 0x999999, 0xDDDDDD, 0xCCCCCC];
			terrainSettings.radialBaseSettings.customGradientAlphas = [1,1,1,1,1,1];
			terrainSettings.radialBaseSettings.customGradientRatios = [0, 100, 140, 160, 210,255];
			
			/*** CUSTOM DISPLACEMENT SETTINGS ***/
			terrainSettings.displacementMapSettings.seed = seed;
			terrainSettings.displacementMapSettings.scaleX = (3 / 4);
			terrainSettings.displacementMapSettings.scaleY = (3 / 4);
			terrainSettings.displacementMapSettings.perlinSettings.baseX = 100;
			terrainSettings.displacementMapSettings.perlinSettings.baseY = 100;
			terrainSettings.displacementMapSettings.perlinSettings.numOctaves = 3;
			terrainSettings.displacementMapSettings.usePerlinDisplacementSettings = true;
			
			return terrainSettings;
		}
		
		public function HILLS(seed:uint = 1000):TerrainSettings {
		
			var terrainSettings:TerrainSettings = new TerrainSettings();
			
			terrainSettings.width = _width;
			terrainSettings.height = _height;
			terrainSettings.terrainBaseFillColor = 0;
			terrainSettings.lowestElevation = 0;
			terrainSettings.highestElevation = 255;
			terrainSettings.smoothLevel = 3;
			terrainSettings.heightScale = 512 * 1 / 40;
			terrainSettings.contrast = 65;
			terrainSettings.terrainEdgeSettings.edgeFadePercent = 1/4;
			terrainSettings.terrainEdgeSettings.terrainEdgeType = TerrainEdgeType.CONTOUR;
			
			if (this.bmd) this.bmd.dispose();
			if (terrainSettings.customTerrainBase) { 
				terrainSettings.customTerrainBase.dispose(); 
				terrainSettings.customTerrainBase = null;
			}
			terrainSettings.terrainBaseType = TerrainBaseType.PERLIN;
			terrainSettings.perlinBaseSettings.baseX = 512;
			terrainSettings.perlinBaseSettings.baseY = 512;
			terrainSettings.perlinBaseSettings.numOctaves = 3;
			terrainSettings.perlinBaseSettings.seed = seed;
			terrainSettings.perlinBaseSettings.fractalNoise = false;
			terrainSettings.perlinBaseSettings.stitch = true;
			
			
			terrainSettings.displacementMapSettings.seed = seed;
			terrainSettings.displacementMapSettings.scaleX = 1 / 40;
			terrainSettings.displacementMapSettings.scaleY = 1 / 40;
			terrainSettings.displacementMapSettings.perlinSettings.baseX = 54;
			terrainSettings.displacementMapSettings.perlinSettings.baseY = 54;
			terrainSettings.displacementMapSettings.perlinSettings.numOctaves = 3;
			terrainSettings.displacementMapSettings.usePerlinDisplacementSettings = true;
			
			return terrainSettings;
		}
		
		public function RIVER(seed:uint = 4338):TerrainSettings {
			
			var terrainSettings:TerrainSettings = new TerrainSettings();
			
			terrainSettings.width = _width;
			terrainSettings.height = _height;
			terrainSettings.terrainBaseFillColor = 0;
			terrainSettings.lowestElevation = 0;
			terrainSettings.highestElevation = 255;
			terrainSettings.smoothLevel = 3;
			terrainSettings.heightScale = 512 * 1 / 20;
			terrainSettings.heightOffset = -50;
			terrainSettings.terrainEdgeSettings.edgeFadePercent = 1/16;
			terrainSettings.terrainEdgeSettings.terrainEdgeType = TerrainEdgeType.CONTOUR;
			
			terrainSettings.stripedBaseSettings.customGradientColors = [0x323232, 0x333333,0x333333, 0x111111, 0x111111, 0x111111, 0x333333,0x333333, 0x323232];
			terrainSettings.stripedBaseSettings.customGradientAlphas = [1,1,1,1,1,1,1,1,1];
			terrainSettings.stripedBaseSettings.customGradientRatios = [0,74,94,122,127,132,148,168, 255];
			
			terrainSettings.terrainBaseType = TerrainBaseType.CUSTOM;
			var m:MovieClip = linearGradientMovieClip(_width, _height, terrainSettings.stripedBaseSettings.customGradientColors, terrainSettings.stripedBaseSettings.customGradientAlphas, terrainSettings.stripedBaseSettings.customGradientRatios);
			var baseBmd:BitmapData = new BitmapData(m.width, m.height, false, 0xFF000000);
			baseBmd.draw(m);
			
			this.bmd = baseBmd.clone();
			
			terrainSettings.customTerrainBase = baseBmd;
			
			/*** CUSTOM DISPLACEMENT SETTINGS ***/
			terrainSettings.displacementMapSettings.seed = seed;
			terrainSettings.displacementMapSettings.scaleX = 3 / 8;
			terrainSettings.displacementMapSettings.scaleY = 0;
			terrainSettings.displacementMapSettings.perlinSettings.baseX = 80;
			terrainSettings.displacementMapSettings.perlinSettings.baseY = 80;
			terrainSettings.displacementMapSettings.perlinSettings.numOctaves = 3;
			terrainSettings.displacementMapSettings.usePerlinDisplacementSettings = true;
			
			return terrainSettings;
		}
		
		public function RIVERBED(seed:uint = 4338):TerrainSettings {
			
			var terrainSettings:TerrainSettings = new TerrainSettings();
			
			terrainSettings.width = _width;
			terrainSettings.height = _height;
			terrainSettings.terrainBaseFillColor = 0;
			terrainSettings.lowestElevation = 0;
			terrainSettings.highestElevation = 255;
			terrainSettings.smoothLevel = 3;
			terrainSettings.heightScale = 512 * 1 / 20;
			terrainSettings.heightOffset = -50;
			terrainSettings.terrainEdgeSettings.edgeFadePercent = 1/16;
			terrainSettings.terrainEdgeSettings.terrainEdgeType = TerrainEdgeType.CONTOUR;
		
			terrainSettings.stripedBaseSettings.customGradientColors = [0x383838, 0x454545, 0x333333,0x333333, 0x111111, 0x111111, 0x111111, 0x333333,0x333333, 0x454545, 0x383838];
			terrainSettings.stripedBaseSettings.customGradientAlphas = [1,1,1,1,1,1,1,1,1,1,1];
			terrainSettings.stripedBaseSettings.customGradientRatios = [0, 63,74,94,122,127,132,148,168,179, 255];

			terrainSettings.terrainBaseType = TerrainBaseType.CUSTOM;
			var m:MovieClip = linearGradientMovieClip(_width, _height, terrainSettings.stripedBaseSettings.customGradientColors, terrainSettings.stripedBaseSettings.customGradientAlphas, terrainSettings.stripedBaseSettings.customGradientRatios);
			var baseBmd:BitmapData = new BitmapData(m.width, m.height, false, 0xFF000000);
			baseBmd.draw(m);
			
			this.bmd = baseBmd.clone();
			
			terrainSettings.customTerrainBase = baseBmd;
			
			/*** CUSTOM DISPLACEMENT SETTINGS ***/
			terrainSettings.displacementMapSettings.seed = seed;
			terrainSettings.displacementMapSettings.scaleX = 3 / 8;
			terrainSettings.displacementMapSettings.scaleY = 0;
			terrainSettings.displacementMapSettings.perlinSettings.baseX = 80;
			terrainSettings.displacementMapSettings.perlinSettings.baseY = 80;
			terrainSettings.displacementMapSettings.perlinSettings.numOctaves = 3;
			terrainSettings.displacementMapSettings.usePerlinDisplacementSettings = true;
			
			return terrainSettings;
		}
		
		public function CANYON(seed:uint = 1000):TerrainSettings {
		
			var terrainSettings:TerrainSettings = new TerrainSettings();
			
			terrainSettings.width = _width;
			terrainSettings.height = _height;
			terrainSettings.terrainBaseFillColor = 0;
			terrainSettings.lowestElevation = 0;
			terrainSettings.highestElevation = 255;
			terrainSettings.smoothLevel = 3;
			terrainSettings.heightScale = 512 * 1 / 10;
			terrainSettings.heightOffset = 0;
			terrainSettings.useOverlaySettings = true;
			terrainSettings.terrainEdgeSettings.edgeFadePercent = 1/16;
			terrainSettings.terrainEdgeSettings.terrainEdgeType = TerrainEdgeType.CONTOUR;
			
			terrainSettings.stripedBaseSettings.customGradientColors = [0x383838, 0x454545, 0x333333,0x333333, 0x111111, 0x111111, 0x111111, 0x333333,0x333333, 0x454545, 0x383838];
			terrainSettings.stripedBaseSettings.customGradientAlphas = [0,1,1,1,1,1,1,1,1,1,0];
			terrainSettings.stripedBaseSettings.customGradientRatios = [0, 63,74,94,114,127,140,148,168,179, 255];
			
			terrainSettings.terrainBaseType = TerrainBaseType.CUSTOM;
			var m:MovieClip = linearGradientMovieClip(_width, _height, terrainSettings.stripedBaseSettings.customGradientColors, terrainSettings.stripedBaseSettings.customGradientAlphas, terrainSettings.stripedBaseSettings.customGradientRatios);
			var baseBmd:BitmapData = new BitmapData(m.width, m.height, false, 0xFF000000);
			baseBmd.draw(m);
			
			this.bmd = baseBmd.clone();
			
			terrainSettings.customTerrainBase = baseBmd;
			
			/*** CUSTOM DISPLACEMENT SETTINGS ***/
			terrainSettings.displacementMapSettings.seed = seed;
			terrainSettings.displacementMapSettings.scaleX = 3 / 8;
			terrainSettings.displacementMapSettings.scaleY = 0;
			terrainSettings.displacementMapSettings.perlinSettings.baseX = 80;
			terrainSettings.displacementMapSettings.perlinSettings.baseY = 80;
			terrainSettings.displacementMapSettings.perlinSettings.numOctaves = 3;
			terrainSettings.displacementMapSettings.usePerlinDisplacementSettings = true;
			
			return terrainSettings;
		}
		
		public function CANYONRIVER(seed:uint = 728):TerrainSettings {
			
			var terrainSettings:TerrainSettings = new TerrainSettings();
			
			terrainSettings.width = _width;
			terrainSettings.height = _height;
			terrainSettings.terrainBaseFillColor = 0;
			terrainSettings.lowestElevation = 0;
			terrainSettings.highestElevation = 255;
			terrainSettings.smoothLevel = 3;
			terrainSettings.heightScale = 512 * 1 / 10;
			terrainSettings.heightOffset = -40;
			terrainSettings.useOverlaySettings = false;
			terrainSettings.bumpOverlaySettings.strength = 0.2;
			terrainSettings.terrainEdgeSettings.edgeFadePercent = 1/16;
			terrainSettings.terrainEdgeSettings.terrainEdgeType = TerrainEdgeType.CONTOUR;
			
			terrainSettings.stripedBaseSettings.customGradientColors = [0x555555, 0x555555, 0x555555, 0x454545,0x333333, 0x111111, 0x111111, 0x111111, 0x333333,0x454545, 0x555555, 0x555555, 0x555555];
			terrainSettings.stripedBaseSettings.customGradientAlphas = [0.5,1,1,1,1,1,1,1,1,1,1,1,0.5];
			terrainSettings.stripedBaseSettings.customGradientRatios = [0, 40, 63,74,94,114,127,140,148,168,179, 215, 255];
			
			terrainSettings.terrainBaseType = TerrainBaseType.CUSTOM;
			var m:MovieClip = linearGradientMovieClip(_width, _height, terrainSettings.stripedBaseSettings.customGradientColors, terrainSettings.stripedBaseSettings.customGradientAlphas, terrainSettings.stripedBaseSettings.customGradientRatios);
			var baseBmd:BitmapData = new BitmapData(m.width, m.height, false, 0xFF000000);
			baseBmd.draw(m);
			
			this.bmd = baseBmd.clone();
			
			terrainSettings.customTerrainBase = baseBmd;
			
			/*** CUSTOM DISPLACEMENT SETTINGS ***/
			terrainSettings.displacementMapSettings.seed = seed;
			terrainSettings.displacementMapSettings.scaleX = 3 / 8;
			terrainSettings.displacementMapSettings.scaleY = 0;
			terrainSettings.displacementMapSettings.perlinSettings.baseX = 80;
			terrainSettings.displacementMapSettings.perlinSettings.baseY = 80;
			terrainSettings.displacementMapSettings.perlinSettings.numOctaves = 3;
			terrainSettings.displacementMapSettings.usePerlinDisplacementSettings = true;
			
			return terrainSettings;
		}
		
		public function SINGLEPLATEAU(seed:uint = 100):TerrainSettings {
			
			var terrainSettings:TerrainSettings = new TerrainSettings();
			
			terrainSettings.width = _width;
			terrainSettings.height = _height;
			terrainSettings.terrainBaseFillColor = 0;
			terrainSettings.lowestElevation = 0;
			terrainSettings.highestElevation = 255;
			terrainSettings.smoothLevel = 0;
			terrainSettings.heightScale = 512 * 1/40;
			terrainSettings.terrainEdgeSettings.edgeFadePercent = 1/20;
			terrainSettings.terrainEdgeSettings.terrainEdgeType = TerrainEdgeType.CONTOUR;
			
			/*** CUSTOM RADIAL BASE ***/
			if (this.bmd) this.bmd.dispose();
			if (terrainSettings.customTerrainBase) { 
				terrainSettings.customTerrainBase.dispose(); 
				terrainSettings.customTerrainBase = null;
			}
			terrainSettings.terrainBaseType = TerrainBaseType.RADIAL;
			terrainSettings.radialBaseSettings.radiusPercent = 1/2;
			terrainSettings.radialBaseSettings.customGradientColors = [0xFFFFFF, 0xFFFFFF, 0xCCCCCC, 0x888888, 0x333333, 0x222222, 0x111111, 0x060606, 0x000000];
			terrainSettings.radialBaseSettings.customGradientAlphas = [1,1,1,1,1,1,1,1,1];
			terrainSettings.radialBaseSettings.customGradientRatios = [10, 100, 130, 150, 170, 185, 200, 215,255];
			
			/*** CUSTOM DISPLACEMENT SETTINGS ***/
			
			terrainSettings.displacementMapSettings.seed = seed;
			terrainSettings.displacementMapSettings.scaleX = 1/4;
			terrainSettings.displacementMapSettings.scaleY = 1/4;
			terrainSettings.displacementMapSettings.perlinSettings.fractalNoise = false;
			terrainSettings.displacementMapSettings.perlinSettings.baseX = 80;
			terrainSettings.displacementMapSettings.perlinSettings.baseY = 80;
			terrainSettings.displacementMapSettings.perlinSettings.numOctaves = 3;
			terrainSettings.displacementMapSettings.usePerlinDisplacementSettings = true;
			
			return terrainSettings;
		}
		
		public function TWOTIEREDPLATEAU(seed:uint = 100):TerrainSettings {
			
			var terrainSettings:TerrainSettings = new TerrainSettings();
			
			terrainSettings.width = _width;
			terrainSettings.height = _height;
			terrainSettings.terrainBaseFillColor = 0;
			terrainSettings.lowestElevation = 0;
			terrainSettings.highestElevation = 255;
			terrainSettings.smoothLevel = 2;
			terrainSettings.heightScale = 512 * 1/40;
			terrainSettings.terrainEdgeSettings.edgeFadePercent = 1/20;
			terrainSettings.terrainEdgeSettings.terrainEdgeType = TerrainEdgeType.CONTOUR;
			
			/*** CUSTOM RADIAL BASE ***/
			if (this.bmd) this.bmd.dispose();
			if (terrainSettings.customTerrainBase) { 
				terrainSettings.customTerrainBase.dispose(); 
				terrainSettings.customTerrainBase = null;
			}
			terrainSettings.terrainBaseType = TerrainBaseType.RADIAL;
			terrainSettings.radialBaseSettings.radiusPercent = 1/2;
			terrainSettings.radialBaseSettings.customGradientColors = [0xFFFFFF, 0xFFFFFF, 0xAAAAAA, 0x999999, 0x999999, 0x666666, 0x161616, 0x060606, 0x000000];
			terrainSettings.radialBaseSettings.customGradientAlphas = [1,1,1,1,1,1,1,1,1];
			terrainSettings.radialBaseSettings.customGradientRatios = [10, 70, 100, 122, 150, 175, 190, 215,255];
			
			/*** CUSTOM DISPLACEMENT SETTINGS ***/
			terrainSettings.displacementMapSettings.seed = seed;
			terrainSettings.displacementMapSettings.scaleX = 1/5;
			terrainSettings.displacementMapSettings.scaleY = 1/5;
			terrainSettings.displacementMapSettings.perlinSettings.fractalNoise = false;
			terrainSettings.displacementMapSettings.perlinSettings.baseX = 80;
			terrainSettings.displacementMapSettings.perlinSettings.baseY = 80;
			terrainSettings.displacementMapSettings.perlinSettings.numOctaves = 3;
			terrainSettings.displacementMapSettings.usePerlinDisplacementSettings = true;
			
			return terrainSettings;
		}
		
		public function THREETIEREDPLATEAU(seed:uint = 100):TerrainSettings {
			
			var terrainSettings:TerrainSettings = new TerrainSettings();
			
			terrainSettings.width = _width;
			terrainSettings.height = _height;
			terrainSettings.terrainBaseFillColor = 0;
			terrainSettings.lowestElevation = 0;
			terrainSettings.highestElevation = 255;
			terrainSettings.smoothLevel = 2;
			terrainSettings.heightScale = 512 * 1/20;
			terrainSettings.terrainEdgeSettings.edgeFadePercent = 1/20;
			terrainSettings.terrainEdgeSettings.terrainEdgeType = TerrainEdgeType.CONTOUR;
			
			/*** CUSTOM RADIAL BASE ***/
			if (this.bmd) this.bmd.dispose();
			if (terrainSettings.customTerrainBase) { 
				terrainSettings.customTerrainBase.dispose(); 
				terrainSettings.customTerrainBase = null;
			}
			terrainSettings.terrainBaseType = TerrainBaseType.RADIAL;
			terrainSettings.radialBaseSettings.radiusPercent = 1/2;
			terrainSettings.radialBaseSettings.customGradientColors = [0xFFFFFF, 0xFFFFFF, 0xCCCCCC, 0xAAAAAA, 0xAAAAAA, 0x999999, 0x777777, 0x777777, 0x555555, 0x161616, 0x060606, 0x000000];
			terrainSettings.radialBaseSettings.customGradientAlphas = [1,1,1,1,1,1,1,1,1,1,1,1];
			terrainSettings.radialBaseSettings.customGradientRatios = [10, 50, 80, 102, 122, 135, 145, 175, 190, 200, 215,255];
			
			/*** CUSTOM DISPLACEMENT SETTINGS ***/
			terrainSettings.displacementMapSettings.seed = seed;
			terrainSettings.displacementMapSettings.scaleX = 1/5;
			terrainSettings.displacementMapSettings.scaleY = 1/5;
			terrainSettings.displacementMapSettings.perlinSettings.fractalNoise = false;
			terrainSettings.displacementMapSettings.perlinSettings.baseX = 80;
			terrainSettings.displacementMapSettings.perlinSettings.baseY = 80;
			terrainSettings.displacementMapSettings.perlinSettings.numOctaves = 3;
			terrainSettings.displacementMapSettings.usePerlinDisplacementSettings = true;
			
			return terrainSettings;
		}
		
		private function radialGradientCircle(radius:Number, colors, alphas, ratios):MovieClip
		{
			var c:MovieClip = new MovieClip();
			var mtx:Matrix = new Matrix();
			mtx.createGradientBox(radius*2,radius*2,0,0, 0);
			
			c.graphics.beginGradientFill(GradientType.RADIAL, colors, alphas, ratios, mtx);
			
			c.graphics.drawCircle(radius,radius,radius);
			
			return c;
		}
		
		private function ellipticalGradientCircle(width:uint, height:uint, colors:Array, alphas:Array, ratios:Array):MovieClip
		{
			var c:MovieClip = new MovieClip();
			var mtx:Matrix = new Matrix();
			mtx.createGradientBox(width,height,0,width/2, 0);
			
			c.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, mtx);
			
			c.graphics.drawRect(0, 0, width*2, height);
			
			return c;
		}
		private function linearGradientMovieClip(width:uint, height:uint, colors:Array, alphas:Array, ratios:Array):MovieClip
		{
			var c:MovieClip = new MovieClip();
			var mtx:Matrix = new Matrix();
			mtx.createGradientBox(width,height,0,0, 0);
			
			c.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, mtx);
			
			c.graphics.drawRect(0, 0, width, height);
			
			return c;
		}
		
		public function set width(value:uint):void { _width = value; }
		public function set height(value:uint):void { _height = value; }
		
	}
}