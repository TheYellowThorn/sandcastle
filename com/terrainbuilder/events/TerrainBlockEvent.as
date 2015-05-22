/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.events
{
	import flash.events.Event;
	
	public class TerrainBlockEvent extends Event
	{
		private var _relatedObject:* = null;
		
		public static const ON_TERRAIN_BLOCK_UPDATED 					:String = "onTerrainBlockUpdated";
		public static const ON_ELEVATION_COMPLETE 						:String = "onElevationComplete";
		public static const ON_WATER_ELEVATION_COMPLETE 				:String = "onWaterElevationComplete";

		public function TerrainBlockEvent( type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super( type, bubbles, cancelable );
		}
		override public function clone():Event 
		{
			return new TerrainBlockEvent(type, bubbles, cancelable);
		}
		
		override public function toString():String 
		{
			return formatToString('TerrainBlockEvent', 'type', 'success', 'data', 'error');
		}
		
		public function get relatedObject():* { return _relatedObject; }
		public function set relatedObject(value:*):void {
			_relatedObject = value;
		}
		

	}
}