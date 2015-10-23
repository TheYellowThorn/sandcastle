package com.terrainbuilder.objs.terrain
{
	import flash.events.EventDispatcher;

	public class TerrainBlockDispatcher extends EventDispatcher
	{
		private var _parent:Object;
		
		public function TerrainBlockDispatcher()
		{
		}
		
		public function set parent(value:Object):void { _parent = value; }
		public function get parent():Object { return _parent; }
	}
}