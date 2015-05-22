/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.dynamicterrain.settings
{

	public class StripedBaseSettings
	{
		private var _stripes:uint = 5;
		private var _stripeType:String = StripeType.HORIZONTAL;
		private var _stripeLowestElevationFirst:Boolean = true;
		private var _customStripeColors:Array;
		private var _customGradientColors:Array;
		private var _customGradientAlphas:Array;
		private var _customGradientRatios:Array;
		
		public function StripedBaseSettings()
		{
		}
		
		public function get stripes():uint { return _stripes; }
		public function set stripes(value:uint):void { _stripes = value; }
		public function get stripeType():String { return _stripeType; }
		public function set stripeType(value:String):void { _stripeType = value; }
		public function get stripeLowestElevationFirst():Boolean { return _stripeLowestElevationFirst; }
		public function set stripeLowestElevationFirst(value:Boolean):void { _stripeLowestElevationFirst = value; }
		public function get customGradientColors():Array { return _customGradientColors; }
		public function set customGradientColors(value:Array):void { _customGradientColors = value; }
		public function get customGradientAlphas():Array { return _customGradientAlphas; }
		public function set customGradientAlphas(value:Array):void { _customGradientAlphas = value; }
		public function get customGradientRatios():Array { return _customGradientRatios; }
		public function set customGradientRatios(value:Array):void { _customGradientRatios = value; }
		
	}
}