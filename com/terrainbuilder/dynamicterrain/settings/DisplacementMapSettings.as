/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.dynamicterrain.settings
{
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.Point;

	public class DisplacementMapSettings
	{
		private var _customDisplacementMap:BitmapData;
		private var _perlinSettings:PerlinDisplacementMapSettings = new PerlinDisplacementMapSettings();
		private var _color:Number = 0;
		private var _alpha:Number = 0;
		private var _componentX:uint = BitmapDataChannel.RED;
		private var _componentY:uint = BitmapDataChannel.GREEN;
		private var _scaleX:Number = 1/5;
		private var _scaleY:Number =  1/5;
		private var _mode:String = DisplacementMapFilterMode.WRAP;
		private var _mapPoint:Point = new Point();
		private var _usePerlinDisplacementSettings:Boolean = true;
		
		public function DisplacementMapSettings()
		{
		}
		
		public function get customDisplacementMap():BitmapData { return _customDisplacementMap; }
		public function set customDisplacementMap(value:BitmapData):void { _customDisplacementMap = value; }
		public function get perlinSettings():PerlinDisplacementMapSettings { return _perlinSettings; }
		public function set perlinSettings(value:PerlinDisplacementMapSettings):void { _perlinSettings = value; }
		public function get seed():uint { return _perlinSettings.seed; }
		public function set seed(value:uint):void { _perlinSettings.seed = value; }
		public function get color():Number { return _color; }
		public function set color(value:Number):void { _color = value; }
		public function get alpha():Number { return _alpha; }
		public function set alpha(value:Number):void { _alpha = value; }
		public function get componentX():uint { return _componentX; }
		public function set componentX(value:uint):void { _componentX = value; }
		public function get componentY():uint { return _componentY; }
		public function set componentY(value:uint):void { _componentY = value; }
		public function get scaleX():Number { return _scaleX; }
		public function set scaleX(value:Number):void { _scaleX = value; }
		public function get scaleY():Number { return _scaleY; }
		public function set scaleY(value:Number):void { _scaleY = value; }
		public function get mode():String { return _mode; }
		public function set mode(value:String):void { _mode = value; }
		public function get mapPoint():Point { return _mapPoint; }
		public function set mapPoint(value:Point):void { _mapPoint = value; }
		public function get usePerlinDisplacementSettings():Boolean { return _usePerlinDisplacementSettings; }
		public function set usePerlinDisplacementSettings(value:Boolean):void { _usePerlinDisplacementSettings = value; }
		
		
	}
}