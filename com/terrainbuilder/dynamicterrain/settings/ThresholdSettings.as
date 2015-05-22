/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.dynamicterrain.settings
{

	public class ThresholdSettings
	{
		
		private var _highestHeight:uint = 255;
		private var _highestHeightReplacement:uint = 255;
		private var _lowestHeight:uint = 0;
		private var _lowestHeightReplacement:uint = 0;
		private var _highestHeightColor:uint = _highestHeight << 16 | _highestHeight << 8 | _highestHeight;
		private var _highestHeightReplacementColor:uint = _highestHeightColor << 16 | _highestHeightColor << 8 | _highestHeightColor;
		private var _lowestHeightColor:uint = _lowestHeight << 16 | _lowestHeight << 8 | _lowestHeight;
		private var _lowestHeightReplacementColor:uint = _lowestHeightColor << 16 | _lowestHeightColor << 8 | _lowestHeightColor;
		
		public function ThresholdSettings()
		{
		}
		
		public function get highestHeight():uint { return _highestHeight; }
		public function set highestHeight(value:uint):void { _highestHeight = value; }
		public function get highestHeightReplacement():uint { return _highestHeightReplacement; }
		public function set highestHeightReplacement(value:uint):void { _highestHeightReplacement = value; }
		public function get lowestHeight():uint { return _lowestHeight; }
		public function set lowestHeight(value:uint):void { _lowestHeight = value; }
		public function get lowestHeightReplacement():uint { return _lowestHeightReplacement; }
		public function set lowestHeightReplacement(value:uint):void { _lowestHeightReplacement = value; }
		public function get highestHeightColor():uint { return _highestHeight << 24 | _highestHeight << 16 | _highestHeight << 8 | _highestHeight; }
		public function get highestHeightReplacementColor():uint { return 255 << 24 | _highestHeightReplacement << 16 | _highestHeightReplacement << 8 | _highestHeightReplacement; }
		public function get lowestHeightColor():uint { return _lowestHeight << 24 | _lowestHeight << 16 | _lowestHeight << 8 | _lowestHeight; }
		public function get lowestHeightReplacementColor():uint { return 255 << 24 | _lowestHeightReplacement << 16 | _lowestHeightReplacement << 8 | _lowestHeightReplacement; }
		
	}
}