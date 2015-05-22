/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.dynamicterrain.settings
{
	import flash.display.BitmapDataChannel;

	public class BumpOverlaySettings
	{
		private var _seed:uint = 200;
		private var _baseX:uint = 16;
		private var _baseY:uint = 16;
		private var _numOctaves:uint = 8;
		private var _stitch:Boolean = true;
		private var _fractalNoise:Boolean = true;
		private var _channelOptions:uint = BitmapDataChannel.GREEN;
		private var _grayScale:Boolean = true;
		private var _offsets:Array;
		private var _strength:Number = 0.4;
		
		public function BumpOverlaySettings()
		{
		}
		
		public function get seed():uint { return _seed; }
		public function set seed(value:uint):void { _seed = value; }
		public function get baseX():uint { return _baseX; }
		public function set baseX(value:uint):void { _baseX = value; }
		public function get baseY():uint { return _baseY; }
		public function set baseY(value:uint):void { _baseY = value; }
		public function get numOctaves():uint { return _numOctaves; }
		public function set numOctaves(value:uint):void { _numOctaves = value; }
		public function get stitch():Boolean { return _stitch; }
		public function set stitch(value:Boolean):void { _stitch = value; }
		public function get fractalNoise():Boolean { return _fractalNoise; }
		public function set fractalNoise(value:Boolean):void { _fractalNoise = value; }
		public function get channelOptions():uint { return _channelOptions; }
		public function set channelOptions(value:uint):void { _channelOptions = value; }
		public function get grayScale():Boolean { return _grayScale; }
		public function set grayScale(value:Boolean):void { _grayScale = value; }
		public function get offsets():Array { return _offsets; }
		public function set offsets(value:Array):void { _offsets = value; }
		public function get strength():Number { return _strength; }
		public function set strength(value:Number):void { _strength = value; }
		
	}
}