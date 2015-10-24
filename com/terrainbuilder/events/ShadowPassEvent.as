/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.events
{
	import flash.events.Event;
	
	public class ShadowPassEvent extends Event
	{
		private var _relatedObject:* = null;
		
		public static const SHADOW_QUALITY_CHANGED:String = "shadowQualityChanged";
		public static const SHADOW_TYPE_CHANGED:String = "shadowTypeChanged";

		public function ShadowPassEvent( type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super( type, bubbles, cancelable );
		}
		override public function clone():Event 
		{
			return new ShadowPassEvent(type, bubbles, cancelable);
		}
		
		override public function toString():String 
		{
			return formatToString('ShadowPassEvent', 'type', 'success', 'data', 'error');
		}
		
		public function get relatedObject():* { return _relatedObject; }
		public function set relatedObject(value:*):void {
			_relatedObject = value;
		}
		

	}
}