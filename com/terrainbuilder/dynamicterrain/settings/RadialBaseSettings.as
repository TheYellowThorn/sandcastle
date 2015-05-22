/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.dynamicterrain.settings
{

	public class RadialBaseSettings
	{
		private var _radiusPercent:Number = 0;
		private var _customGradientColors:Array;
		private var _customGradientAlphas:Array;
		private var _customGradientRatios:Array;
		
		public function RadialBaseSettings()
		{
		}
		
		public function get radiusPercent():Number { return _radiusPercent; }
		public function set radiusPercent(value:Number):void { _radiusPercent = value; }
		public function get customGradientColors():Array { return _customGradientColors; }
		public function set customGradientColors(value:Array):void { _customGradientColors = value; }
		public function get customGradientAlphas():Array { return _customGradientAlphas; }
		public function set customGradientAlphas(value:Array):void { _customGradientAlphas = value; }
		public function get customGradientRatios():Array { return _customGradientRatios; }
		public function set customGradientRatios(value:Array):void { _customGradientRatios = value; }
		
	}
}