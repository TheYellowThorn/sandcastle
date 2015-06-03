/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.effects.objs
{
	import flash.display.BitmapData;

	public class ColoredSplatData extends SplatData
	{
		
		
		/** splat is the greyscale image used for splat texture **/
		/** blend is the greyscale map used for blending the splat onto the texture **/
		/** color is the color used to saturate the blended splat **/
		/** heightMapRange determines minimum and maximum height values for displaying the blended splat**/
		/** maxOpacityAngle sets the angle where the splat is visible in percentage (0.0 is a slope of 0 degress related to a normal pointing straight up, 1.0 is a slope of 90 degrees related to a normal pointing straight up) **/
		/** opacityAngleSpreadRange sets the percentage of the slope that is faded on either side of the areas that are 100% visible **/  
		
		public function ColoredSplatData(splat:BitmapData, blend:BitmapData, color:uint, normalMap:BitmapData = null)
		{
			super(splat, blend, normalMap);
			
			_splat = splat;
			_blend = blend;
			_color = color;
			_normalMap = normalMap;
		}
		
		public override function clone():SplatData {
			var clone:ColoredSplatData = new ColoredSplatData(_splat, _blend.clone(), _color, _normalMap);
			clone.heightMapRange = this.heightMapRange.concat();
			clone.useSlopeBlend = this.useSlopeBlend;
			clone.maxOpacityAngle = this.maxOpacityAngle;
			clone.opacityAngleSpreadRange = this.opacityAngleSpreadRange;
			clone.visible = this.visible;
			
			return clone;
		}
		
		
		public function get color():uint { return _color; }
		public function set color(value:uint):void { _color = value; }
		
	}
}