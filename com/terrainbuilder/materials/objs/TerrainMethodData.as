/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.materials.objs
{
	import flash.geom.Point;

	public class TerrainMethodData extends Object
	{
		
		private var _tileData:Number;
		private var _squaredTiles:uint;
		private var _tilesHigh:uint;
		private var _tileSize:Number;
		private var _height:Number;
		private var _anchorYPosition:Number;
		private var _maxHeight:Number;
		private var _positionOffsetX:Number;
		private var _positionOffsetZ:Number;
		private var _worldGridPosition:Point;
		private var _ambientColor:uint = 0xffffff;
		private var _ambient:Number = 0;
		private var _specularColor:uint = 0xffffff;
		private var _specular:Number = 0.02;
		private var _gloss:Number = 0;
		private var _normalMapStrength:Number;
		private var _heightMapSize:uint;
		private var _numLights:uint = 0;
		private var _fogEnabled:Boolean = false;
		private var _minimumFogDistance:Number = 2500;
		private var _maximumFogDistance:Number = 5000;
		private var _fogColor:uint = 0x9FBFCF;
		private var _addFogInFinalTerrainPass:Boolean = true;
		private var _showShadows:Boolean = false;
		private var _shadowAlpha:Number = 0.5;
		private var _useLights:Boolean = true;
		
		/** splat is the image used for splat texture (greyscale for ColoredSplatData and full-colored for SplatData) **/
		/** blend is the greyscale map used for blending the splat onto the texture **/
		/** color is the color used to saturate the blended splat **/
		/** heightMapRange determines minimum and maximum height values for displaying the blended splat**/
		/** displaySlope sets the slope where the splat is visible in percentage (0.0 is a slope of 0 degress related to a normal pointing straight up, 1.0 is a slope of 90 degrees related to a normal pointing straight up) **/
		/** displaySlopeSpread sets the percentage of either side of the _displaySlope that is 100% visible **/
		/** fadeSlopeSpread sets the percentage of the slope that is faded on either side of the areas that are 100% visible **/  
		
		public function TerrainMethodData()
		{
			super();
			
			
		}
		
		public function get numLights():uint { return _numLights; }
		public function set numLights(value:uint):void { _numLights = value; }
		
		public function get tileData():Number { return _tileData; }
		public function set tileData(value:Number):void { _tileData = value; }
		
		public function get squaredTiles():uint { return _squaredTiles; }
		public function set squaredTiles(value:uint):void { _squaredTiles = value; }
		
		public function get tilesHigh():uint { return _tilesHigh; }
		public function set tilesHigh(value:uint):void { _tilesHigh = value; }
		
		public function get tileSize():Number { return _tileSize; }
		public function set tileSize(value:Number):void { _tileSize = value; }
		
		public function get height():Number { return _height; }
		public function set height(value:Number):void { _height = value; }
		
		public function get anchorYPosition():Number { return _anchorYPosition; }
		public function set anchorYPosition(value:Number):void { _anchorYPosition = value; }
		
		public function get maxHeight():Number { return _maxHeight; }
		public function set maxHeight(value:Number):void { _maxHeight = value; }
		
		public function get positionOffsetX():Number { return _positionOffsetX; }
		public function set positionOffsetX(value:Number):void { _positionOffsetX = value; }
		
		public function get positionOffsetZ():Number { return _positionOffsetZ; }
		public function set positionOffsetZ(value:Number):void { _positionOffsetZ = value; }
		
		public function get worldGridPosition():Point { return _worldGridPosition; }
		public function set worldGridPosition(value:Point):void { _worldGridPosition = value; }
		
		public function get ambientColor():uint { return _ambientColor; }
		public function set ambientColor(value:uint):void { _ambientColor = value; }
		
		public function get ambient():Number { return _ambient; }
		public function set ambient(value:Number):void { _ambient = value; }
		
		public function get specularColor():uint { return _specularColor; }
		public function set specularColor(value:uint):void { _specularColor = value; }
		
		public function get specular():Number { return _specular; }
		public function set specular(value:Number):void { _specular = value; }
		
		public function get gloss():Number { return _gloss; }
		public function set gloss(value:Number):void { _gloss = value; }
		
		public function get normalMapStrength():Number { return _normalMapStrength; }
		public function set normalMapStrength(value:Number):void { _normalMapStrength = value; }
		
		public function get heightMapSize():uint { return _heightMapSize; }
		public function set heightMapSize(value:uint):void { _heightMapSize = value; }
		
		public function get fogEnabled():Boolean { return  _fogEnabled; }
		public function set fogEnabled(value:Boolean):void {  _fogEnabled = value; }
		
		public function get minimumFogDistance():Number { return _minimumFogDistance; }
		public function set minimumFogDistance(value:Number):void { _minimumFogDistance = value; }
		
		public function get maximumFogDistance():Number { return _maximumFogDistance; }
		public function set maximumFogDistance(value:Number):void { _maximumFogDistance = value; }
		
		public function get fogColor():uint { return _fogColor; }
		public function set fogColor(value:uint):void { _fogColor = value; }
		
		public function get showShadows():Boolean { return  _showShadows; }
		public function set showShadows(value:Boolean):void {  _showShadows = value; }
		
		public function get useLights():Boolean { return  _useLights; }
		public function set useLights(value:Boolean):void {  _useLights = value; }
		
		public function get shadowAlpha():Number { return _shadowAlpha; }
		public function set shadowAlpha(value:Number):void { _shadowAlpha = value; }
		
		public function get addFogInFinalTerrainPass():Boolean { return _addFogInFinalTerrainPass; }
		public function set addFogInFinalTerrainPass(value:Boolean):void { _addFogInFinalTerrainPass = value; }
		
		
	}
}