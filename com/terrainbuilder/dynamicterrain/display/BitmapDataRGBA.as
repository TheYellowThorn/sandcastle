/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.dynamicterrain.display
{
	import flash.display.BitmapData;

	public class BitmapDataRGBA
	{
		
		private var _bitmapDataRGB:BitmapData;
		private var _bitmapDataA:BitmapData;
		
		public function BitmapDataRGBA()
		{
		}
		
		public function set bitmapDataRGB(value:BitmapData):void {
			_bitmapDataRGB = value;
		}
		public function get bitmapDataRGB():BitmapData {
			return _bitmapDataRGB;
		}
		public function set bitmapDataA(value:BitmapData):void {
			_bitmapDataA = value;
		}
		public function get bitmapDataA():BitmapData {
			return _bitmapDataA;
		}
		
		public function clone():BitmapDataRGBA {
			var bmdRGBA:BitmapDataRGBA = new BitmapDataRGBA();
			bmdRGBA.bitmapDataRGB = _bitmapDataRGB.clone();
			bmdRGBA.bitmapDataA = _bitmapDataA.clone();
			
			return bmdRGBA;
			
		}
	}
}