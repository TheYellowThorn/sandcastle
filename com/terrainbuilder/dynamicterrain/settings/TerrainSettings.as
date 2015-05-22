/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.dynamicterrain.settings
{
	import flash.display.BitmapData;

	public class TerrainSettings extends Object
	{
		
		private var _width:uint = 256;
		private var _height:uint = 256;
		private var _brushSizeAt100PercentHeight:Number = 512;
		private var _lowestElevation:uint = 0;
		private var _highestElevation:uint = 255;
		private var _terrainEdgeSettings:TerrainEdgeSettings = new TerrainEdgeSettings();
		private var _radialBaseSettings:RadialBaseSettings = new RadialBaseSettings();
		private var _stripedBaseSettings:StripedBaseSettings = new StripedBaseSettings();
		private var _perlinBaseSettings:PerlinBaseSettings = new PerlinBaseSettings();
		private var _bumpOverlaySettings:BumpOverlaySettings = new BumpOverlaySettings();
		private var _terrainBaseType:String = TerrainBaseType.RADIAL;
		private var _terrainBaseFillColor:uint = 0xFF000000;
		private var _customTerrainBase:BitmapData;
		private var _useDisplacementMap:Boolean = true;
		private var _displacementMapSettings:DisplacementMapSettings = new DisplacementMapSettings();
		private var _thresholdSettings:ThresholdSettings = new ThresholdSettings();
		private var _useThresholdSettings:Boolean = true;
		private var _useEdgeSettings:Boolean = true;
		private var _useOverlaySettings:Boolean = false;
		private var _smoothLevel:uint = 2;
		private var _rotation:Number = 0;
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		private var _heightScale:Number = 1;
		private var _flipVertically:Boolean = false;
		private var _flipHorizontally:Boolean = false;
		private var _heightOffset:int = 0;
		private var _contrast:int = 0;
		private var _strength:Number = 1;
		private var _invertBase:Boolean = false;
		private var _invertDisplacementMap:Boolean = false;
		private var _invertEdge:Boolean = false;
		
		public function TerrainSettings()
		{
		}
		

		public function get width():uint { return _width; }
		public function set width(value:uint):void { _width = value; }
		public function get brushSizeAt100PercentHeight():Number { return _brushSizeAt100PercentHeight; }
		public function set brushSizeAt100PercentHeight(value:Number):void { _brushSizeAt100PercentHeight = value; }
		public function get lowestElevation():uint { return _lowestElevation; }
		public function set lowestElevation(value:uint):void { _lowestElevation = value; }
		public function get highestElevation():uint { return _highestElevation; }
		public function set highestElevation(value:uint):void { _highestElevation = value; }
		public function get height():uint { return _height; }
		public function set height(value:uint):void { _height = value; }
		public function get terrainEdgeSettings():TerrainEdgeSettings { return _terrainEdgeSettings; }
		public function set terrainEdgeSettings(value:TerrainEdgeSettings):void { _terrainEdgeSettings = value; }
		public function get radialBaseSettings():RadialBaseSettings { return _radialBaseSettings; }
		public function set radialBaseSettings(value:RadialBaseSettings):void { _radialBaseSettings = value; }
		public function get stripedBaseSettings():StripedBaseSettings { return _stripedBaseSettings; }
		public function set stripedBaseSettings(value:StripedBaseSettings):void { _stripedBaseSettings = value; }
		public function get perlinBaseSettings():PerlinBaseSettings { return _perlinBaseSettings; }
		public function set perlinBaseSettings(value:PerlinBaseSettings):void { _perlinBaseSettings = value; }
		public function get bumpOverlaySettings():BumpOverlaySettings { return _bumpOverlaySettings; }
		public function set bumpOverlaySettings(value:BumpOverlaySettings):void { _bumpOverlaySettings = value; }
		public function get terrainBaseType():String { return _terrainBaseType; }
		public function set terrainBaseType(value:String):void { _terrainBaseType = value; }
		public function get terrainBaseFillColor():uint { return _terrainBaseFillColor; }
		public function set terrainBaseFillColor(value:uint):void { _terrainBaseFillColor = value; }
		
		public function get customTerrainBase():BitmapData { return _customTerrainBase; }
		public function set customTerrainBase(value:BitmapData):void {
			_customTerrainBase = value;
			
			if (value) { _terrainBaseType = TerrainBaseType.CUSTOM; }
		}
		
		public function get displacementMapSettings():DisplacementMapSettings { return _displacementMapSettings; }
		public function set displacementMapSettings(value:DisplacementMapSettings):void {  _displacementMapSettings = value; }
		public function get useDisplacementMap():Boolean { return  _useDisplacementMap; }
		public function set useDisplacementMap(value:Boolean):void {  _useDisplacementMap = value; }
		public function get thresholdSettings():ThresholdSettings { return _thresholdSettings; }
		public function set thresholdSettings(value:ThresholdSettings):void {  _thresholdSettings = value; }
		public function get useThresholdSettings():Boolean { return  _useThresholdSettings; }
		public function set useThresholdSettings(value:Boolean):void {  _useThresholdSettings = value; }
		public function get useEdgeSettings():Boolean { return  _useEdgeSettings; }
		public function set useEdgeSettings(value:Boolean):void {  _useEdgeSettings = value; }
		public function get useOverlaySettings():Boolean { return  _useOverlaySettings; }
		public function set useOverlaySettings(value:Boolean):void {  _useOverlaySettings = value; }
		public function get smoothLevel():uint { return _smoothLevel; }
		public function set smoothLevel(value:uint):void { _smoothLevel = value; }
		public function get rotation():Number { return _rotation; }
		public function set rotation(value:Number):void { _rotation = value; }
		public function get scaleX():Number { return _scaleX; }
		public function set scaleX(value:Number):void { _scaleX = value; }
		public function get scaleY():Number { return _scaleY; }
		public function set scaleY(value:Number):void { _scaleY = value; }
		public function get heightScale():Number { return _heightScale; }
		public function set heightScale(value:Number):void { _heightScale = value; }
		public function get flipVertically():Boolean { return  _flipVertically; }
		public function set flipVertically(value:Boolean):void {  _flipVertically = value; }
		public function get flipHorizontally():Boolean { return  _flipHorizontally; }
		public function set flipHorizontally(value:Boolean):void {  _flipHorizontally = value; }
		public function get heightOffset():int { return _heightOffset; }
		public function set heightOffset(value:int):void { _heightOffset = value; }
		public function get contrast():int { return _contrast; }
		public function set contrast(value:int):void { _contrast = value; }
		public function get strength():Number { return _strength; }
		public function set strength(value:Number):void { 
			if (value < 0) value = 0;
			if (value > 1) value = 1;
			_strength = value; 
		}
		public function get invertBase():Boolean { return _invertBase; }
		public function set invertBase(value:Boolean):void { _invertBase = value; }
		public function get invertDisplacementMap():Boolean { return _invertDisplacementMap; }
		public function set invertDisplacementMap(value:Boolean):void { _invertDisplacementMap = value; }
		public function get invertEdge():Boolean { return _invertEdge; }
		public function set invertEdge(value:Boolean):void { _invertEdge = value; }
		
		public function clone():TerrainSettings {
			
			var newSettings:TerrainSettings = new TerrainSettings();
			
			newSettings.customTerrainBase = _customTerrainBase;
			
			newSettings.width = _width;
			newSettings.brushSizeAt100PercentHeight = _brushSizeAt100PercentHeight;
			newSettings.lowestElevation = _lowestElevation;
			newSettings.highestElevation = _highestElevation;
			newSettings.height =  _height;
			newSettings.terrainEdgeSettings = _terrainEdgeSettings;
			newSettings.radialBaseSettings = _radialBaseSettings;
			newSettings.stripedBaseSettings = _stripedBaseSettings;
			newSettings.perlinBaseSettings = _perlinBaseSettings;
			newSettings.bumpOverlaySettings = _bumpOverlaySettings;
			newSettings.terrainBaseType = _terrainBaseType;
			newSettings.terrainBaseFillColor = _terrainBaseFillColor;
			
			newSettings.displacementMapSettings = _displacementMapSettings;
			newSettings.useDisplacementMap = _useDisplacementMap;
			newSettings.thresholdSettings = _thresholdSettings;
			newSettings.useThresholdSettings = _useThresholdSettings;
			newSettings.useEdgeSettings = _useEdgeSettings;
			newSettings.useOverlaySettings = _useOverlaySettings;
			newSettings.smoothLevel =  _smoothLevel;
			newSettings.rotation = _rotation;
			newSettings.scaleX = _scaleX;
			newSettings.scaleY = _scaleY;
			newSettings.heightScale = _heightScale;
			newSettings.flipVertically = _flipVertically;
			newSettings.flipHorizontally = _flipHorizontally;
			newSettings.heightOffset = _heightOffset;
			newSettings.contrast = _contrast;
			newSettings.strength = _strength;
			
			newSettings.invertBase = _invertBase;
			newSettings.invertDisplacementMap = _invertDisplacementMap;
			newSettings.invertEdge = _invertEdge;
			
			return newSettings;
			
		
		}
		
		
	}
}