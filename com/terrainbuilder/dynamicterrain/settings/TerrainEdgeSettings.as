/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.dynamicterrain.settings
{
	import flash.display.BitmapData;

	public class TerrainEdgeSettings
	{
		private var _terrainEdgeType:String = TerrainEdgeType.CONTOUR;
		private var _edgeFadePercent:Number = 0.05;
		private var _customEdge:BitmapData;
		
		public function TerrainEdgeSettings()
		{
		}
		
		public function get terrainEdgeType():String { return _terrainEdgeType; }
		public function set terrainEdgeType(value:String):void { _terrainEdgeType = value; }
		public function get edgeFadePercent():Number { return _edgeFadePercent; }
		public function set edgeFadePercent(value:Number):void { _edgeFadePercent = value; }
		
		public function get customEdge():BitmapData { return _customEdge; }
		public function set customEdge(value:BitmapData):void { 
			_customEdge = value;
			if (value) {
				_terrainEdgeType = TerrainEdgeType.CUSTOM;
			}
		}
	}
}