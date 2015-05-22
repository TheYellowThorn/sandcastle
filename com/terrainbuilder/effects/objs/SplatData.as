/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.effects.objs
{
	import flash.display.BitmapData;

	public class SplatData extends Object
	{
		protected var _splatURL:String;
		protected var _blendURL:String;
		protected var _normalMapURL:String;
		protected var _splat:BitmapData;
		protected var _blend:BitmapData;
		protected var _normalMap:BitmapData;
		protected var _color:uint;
		protected var _heightMapRange:Array;
		protected var _useSlopeBlend:Boolean = false;
		protected var _maxOpacityAngle:Number = 0.45;
		protected var _opacityAngleSpreadRange:Number = 0.3;
		protected var _visible:Boolean = true;
		
		/** splat is the full-colored image used for splat texture **/
		/** blend is the greyscale map used for blending the splat onto the texture **/
		/** color is the color used to saturate the blended splat **/
		/** heightMapRange determines minimum and maximum height values for displaying the blended splat**/
		/** maxOpacityAngle sets the angle where the splat is visible in percentage (0.0 is a slope of 0 degress related to a normal pointing straight up, 1.0 is a slope of 90 degrees related to a normal pointing straight up) **/
		/** opacityAngleSpreadRange sets the percentage of the slope that is faded on either side of the areas that are 100% visible **/  
		
		public function SplatData(splat:BitmapData, blend:BitmapData, normalMap:BitmapData = null)
		{
			super();
			
			_splat = splat;
			_blend = blend;
			_normalMap = normalMap;

		}
		
		public function clone():SplatData {
			var clone:SplatData = new SplatData(_splat, _blend.clone(), normalMap);
			clone.heightMapRange = _heightMapRange.concat();
			clone.useSlopeBlend = _useSlopeBlend;
			clone.maxOpacityAngle = _maxOpacityAngle;
			clone.opacityAngleSpreadRange = _opacityAngleSpreadRange;
			clone.visible = _visible;
			
			return clone;
		}
		
		public function get splatURL():String { return _splatURL; }
		public function set splatURL(value:String):void { _splatURL = value; }
		
		public function get blendURL():String { return _blendURL; }
		public function set blendURL(value:String):void { _blendURL = value; }
		
		public function get normalMapURL():String { return _normalMapURL; }
		public function set normalMapURL(value:String):void { _normalMapURL = value; }
		
		public function get splat():BitmapData { return _splat; }
		public function set splat(value:BitmapData):void { _splat = value; }
		
		public function get blend():BitmapData { return _blend; }
		public function set blend(value:BitmapData):void { _blend = value; }
		
		public function get normalMap():BitmapData { return _normalMap; }
		public function set normalMap(value:BitmapData):void { _normalMap = value; }
		
		public function get heightMapRange():Array { return _heightMapRange; }
		public function set heightMapRange(value:Array):void { _heightMapRange = value; }
		
		public function get useSlopeBlend():Boolean { return _useSlopeBlend; }
		public function set useSlopeBlend(value:Boolean):void { _useSlopeBlend = value; }
		
		public function get maxOpacityAngle():Number { return _maxOpacityAngle; }
		public function set maxOpacityAngle(value:Number):void { _maxOpacityAngle = value; }
		
		public function get opacityAngleSpreadRange():Number { return _opacityAngleSpreadRange; }
		public function set opacityAngleSpreadRange(value:Number):void { _opacityAngleSpreadRange = value; }
		
		public function get visible():Boolean { return _visible; }
		public function set visible(value:Boolean):void { _visible = value; }
	}
}