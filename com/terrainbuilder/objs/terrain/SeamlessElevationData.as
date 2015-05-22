/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.objs.terrain
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import away3d.core.base.Geometry;
	import away3d.materials.MaterialBase;
	import away3d.textures.BitmapTexture;
	import away3d.textures.Texture2DBase;

	public class SeamlessElevationData extends Object
	{
		
		private var _material:MaterialBase;
		private var _baseTexture:Texture2DBase;
		private var _wireframeTexture:BitmapTexture;
		private var _heightMap:BitmapData;
		private var _heightMapData:Vector.<uint>;
		private var _width:Number = 1000;
		private var _height:Number = 100;
		private var _depth:Number = 1000;
		private var _tilesWide:uint = 2;
		private var _tilesHigh:uint = 2;
		private var _lowestYPosition:Number = 0; //USED TO ANCHOR THE TERRAIN METHOD IN CASE ELEVATIONS AREN'T SET AT (0, 0, 0)
		private var _positionOffsetX:Number = 0;
		private var _positionOffsetZ:Number = 0;
		private var _currentLOD:uint = 3;
		private var _maxElevation:uint = (256*256 - 1);
		private var _minElevation:uint = 0;
		private var _buildGeometryOnInit:Boolean = true;
		private var _updateGeometryOnInit:Boolean = false;
		private var _geometry:Geometry;
		private var _actualVertices:Vector.<Number>;
		private var _baseVertices:Vector.<Number>;
		private var _fullVertices:Vector.<Number>;
		private var _vertices:Vector.<Number>;
		private var _uvs:Vector.<Number>;
		private var _indicesList:Vector.<Vector.<uint>>;
		private var _actualNormals:Vector.<Number>;
		private var _isOcean:Boolean = false;
		private var _worldGridPosition:Point = new Point();
		private var _sharedHeightMapBitmapData:BitmapData;
		private var _sharedWaterMaskBitmapData:BitmapData;
		private var _waterHeight:Number;
		private var _firstElevation:SeamlessElevation;
		private var _lowestColor:Number;
		
		private var _baseIndicesList:Vector.<Vector.<uint>>;
		private var _leftIndicesList:Vector.<Vector.<uint>>;
		private var _rightIndicesList:Vector.<Vector.<uint>>;
		private var _topIndicesList:Vector.<Vector.<uint>>;
		private var _bottomIndicesList:Vector.<Vector.<uint>>;
		private var _leftSkippedIndicesList:Vector.<Vector.<uint>>;
		private var _rightSkippedIndicesList:Vector.<Vector.<uint>>;
		private var _topSkippedIndicesList:Vector.<Vector.<uint>>;
		private var _bottomSkippedIndicesList:Vector.<Vector.<uint>>;
		private var _indicesCombinations:Vector.<Vector.<Vector.<uint>>>;
		
		public function SeamlessElevationData()
		{
			super();
		}
		
		public function clone():SeamlessElevationData {
			
			var seamlessElevationData:SeamlessElevationData = new SeamlessElevationData();
			
			seamlessElevationData.material = _material;
			seamlessElevationData.baseTexture = _baseTexture;
			seamlessElevationData.wireframeTexture = _wireframeTexture;
			seamlessElevationData.heightMapData = _heightMapData.concat();
			seamlessElevationData.heightMap = this.heightMap.clone();
			seamlessElevationData.width = _width;
			seamlessElevationData.height = _height;
			seamlessElevationData.depth = _depth;
			seamlessElevationData.tilesWide = _tilesWide;
			seamlessElevationData.tilesHigh = _tilesHigh;
			seamlessElevationData.lowestYPosition = _lowestYPosition;
			seamlessElevationData.positionOffsetX = _positionOffsetX;
			seamlessElevationData.positionOffsetZ = _positionOffsetZ;
			seamlessElevationData.currentLOD = _currentLOD;
			seamlessElevationData.maxElevation = _maxElevation;
			seamlessElevationData.minElevation = _minElevation;
			seamlessElevationData.geometry = _geometry.clone();
			seamlessElevationData.firstElevation = _firstElevation;
			seamlessElevationData.actualVertices = seamlessElevationData.firstElevation.actualVertices.concat();
			seamlessElevationData.fullVertices = seamlessElevationData.firstElevation.fullVertices.concat();
			seamlessElevationData.vertices = seamlessElevationData.fullVertices;
			seamlessElevationData.baseVertices = seamlessElevationData.firstElevation.baseVertices.concat();
			seamlessElevationData.uvs = _uvs.concat();
			seamlessElevationData.indicesList = _indicesList;
			seamlessElevationData.baseIndicesList = _baseIndicesList;
			seamlessElevationData.leftIndicesList = _leftIndicesList;
			seamlessElevationData.rightIndicesList = _rightIndicesList;
			seamlessElevationData.topIndicesList = _topIndicesList;
			seamlessElevationData.bottomIndicesList = _bottomIndicesList;
			seamlessElevationData.leftSkippedIndicesList = _leftSkippedIndicesList;
			seamlessElevationData.rightSkippedIndicesList = _rightSkippedIndicesList;
			seamlessElevationData.topSkippedIndicesList = _topSkippedIndicesList;
			seamlessElevationData.bottomSkippedIndicesList = _bottomSkippedIndicesList;
			seamlessElevationData.indicesCombinations = _indicesCombinations;
			seamlessElevationData.actualNormals = _actualNormals.concat();
			seamlessElevationData.isOcean = _isOcean;
			seamlessElevationData.sharedHeightMapBitmapData = _sharedHeightMapBitmapData;
			seamlessElevationData.sharedWaterMaskBitmapData = _sharedWaterMaskBitmapData;
			seamlessElevationData.lowestColor = _lowestColor;
			seamlessElevationData.buildGeometryOnInit = false;
			seamlessElevationData.updateGeometryOnInit = true;
			
			return seamlessElevationData;
		}
		
		public function get material():MaterialBase { return _material; }
		public function set material(value:MaterialBase):void { _material = value; }
		public function get baseTexture():Texture2DBase { return _baseTexture; }
		public function set baseTexture(value:Texture2DBase):void { _baseTexture = value; }
		public function get wireframeTexture():BitmapTexture { return _wireframeTexture; }
		public function set wireframeTexture(value:BitmapTexture):void { _wireframeTexture = value; }
		public function get heightMap():BitmapData { 
			var _heightMapWidth:uint = Math.sqrt(_heightMapData.length);
			var _heightMapHeight:uint = _heightMapWidth;
			var bmd:BitmapData = new BitmapData(_heightMapWidth, _heightMapHeight, false, 0);
			bmd.setVector(new Rectangle(0, 0, _heightMapWidth, _heightMapHeight), _heightMapData);
			
			return bmd; 
		}
		public function set heightMap(value : BitmapData) : void
		{
			_heightMap = value;
			_heightMapData = _heightMap.getVector(new Rectangle(0, 0, _heightMap.width, _heightMap.height));
			_heightMap.dispose();
		}

		public function get heightMapData():Vector.<uint> { return _heightMapData; }
		public function set heightMapData(value:Vector.<uint>):void { _heightMapData = value; }
		public function get width():Number { return _width; }
		public function set width(value:Number):void { _width = value; }
		public function get depth():Number { return _depth; }
		public function set depth(value:Number):void { _depth = value; }
		public function get height():Number { return _height; }
		public function set height(value:Number):void { _height = value; }
		public function get currentLOD():uint { return _currentLOD; }
		public function set currentLOD(value:uint):void { _currentLOD = value; }
		public function get maxElevation():uint { return _maxElevation; }
		public function set maxElevation(value:uint):void { _maxElevation = value; }
		public function get minElevation():uint { return _minElevation; }
		public function set minElevation(value:uint):void { _minElevation = value; }
		public function get buildGeometryOnInit():Boolean { return _buildGeometryOnInit; }
		public function set buildGeometryOnInit(value:Boolean):void { _buildGeometryOnInit = value; }
		public function get updateGeometryOnInit():Boolean { return _updateGeometryOnInit; }
		public function set updateGeometryOnInit(value:Boolean):void { _updateGeometryOnInit = value; }
		public function get geometry():Geometry { return _geometry; }
		public function set geometry(value:Geometry):void { _geometry = value; }
		public function get actualVertices():Vector.<Number> { return _actualVertices; }
		public function set actualVertices(value:Vector.<Number>):void { _actualVertices = value; }
		public function get baseVertices():Vector.<Number> { return _baseVertices; }
		public function set baseVertices(value:Vector.<Number>):void { _baseVertices = value; }
		public function get uvs():Vector.<Number> { return _uvs; }
		public function set uvs(value:Vector.<Number>):void { _uvs = value; }
		public function get indicesList():Vector.<Vector.<uint>> { return _indicesList; }
		public function set indicesList(value:Vector.<Vector.<uint>>):void { _indicesList = value; }
		public function get actualNormals():Vector.<Number> { return _actualNormals; }
		public function set actualNormals(value:Vector.<Number>):void { _actualNormals = value; }
		public function get isOcean():Boolean { return _isOcean; }
		public function set isOcean(value:Boolean):void { _isOcean = value; }
		public function get worldGridPosition():Point { return _worldGridPosition; }
		public function set worldGridPosition(value:Point):void { _worldGridPosition = value; }
		public function get lowestYPosition():Number { return _lowestYPosition; }
		public function set lowestYPosition(value:Number):void { _lowestYPosition = value; }
		public function get positionOffsetX():Number { return _positionOffsetX; }
		public function set positionOffsetX(value:Number):void { _positionOffsetX = value; }
		public function get positionOffsetZ():Number { return _positionOffsetZ; }
		public function set positionOffsetZ(value:Number):void { _positionOffsetZ = value; }
		public function get sharedHeightMapBitmapData():BitmapData { return _sharedHeightMapBitmapData; }
		public function set sharedHeightMapBitmapData(value:BitmapData):void { _sharedHeightMapBitmapData = value; }
		public function get sharedWaterMaskBitmapData():BitmapData { return _sharedWaterMaskBitmapData; }
		public function set sharedWaterMaskBitmapData(value:BitmapData):void { _sharedWaterMaskBitmapData = value; }
		public function get waterHeight():Number { return _waterHeight; }
		public function set waterHeight(value:Number):void { _waterHeight = value; }
		public function get firstElevation():SeamlessElevation { return _firstElevation; }
		public function set firstElevation(value:SeamlessElevation):void { _firstElevation = value; }
		public function get vertices():Vector.<Number> { return _vertices; }
		public function set vertices(value:Vector.<Number>):void { _vertices = value; }
		public function get fullVertices():Vector.<Number> { return _fullVertices; }
		public function set fullVertices(value:Vector.<Number>):void { _fullVertices = value; }
		
		public function get baseIndicesList():Vector.<Vector.<uint>> { return _baseIndicesList; }
		public function set baseIndicesList(value:Vector.<Vector.<uint>>):void { _baseIndicesList = value; }
		public function get leftIndicesList():Vector.<Vector.<uint>> { return _leftIndicesList; }
		public function set leftIndicesList(value:Vector.<Vector.<uint>>):void { _leftIndicesList = value; }
		public function get rightIndicesList():Vector.<Vector.<uint>> { return _rightIndicesList; }
		public function set rightIndicesList(value:Vector.<Vector.<uint>>):void { _rightIndicesList = value; }
		public function get topIndicesList():Vector.<Vector.<uint>> { return _topIndicesList; }
		public function set topIndicesList(value:Vector.<Vector.<uint>>):void { _topIndicesList = value; }
		public function get bottomIndicesList():Vector.<Vector.<uint>> { return _bottomIndicesList; }
		public function set bottomIndicesList(value:Vector.<Vector.<uint>>):void { _bottomIndicesList = value; }
		public function get leftSkippedIndicesList():Vector.<Vector.<uint>> { return _leftSkippedIndicesList; }
		public function set leftSkippedIndicesList(value:Vector.<Vector.<uint>>):void { _leftSkippedIndicesList = value; }
		public function get rightSkippedIndicesList():Vector.<Vector.<uint>> { return _rightSkippedIndicesList; }
		public function set rightSkippedIndicesList(value:Vector.<Vector.<uint>>):void { _rightSkippedIndicesList = value; }
		public function get topSkippedIndicesList():Vector.<Vector.<uint>> { return _topSkippedIndicesList; }
		public function set topSkippedIndicesList(value:Vector.<Vector.<uint>>):void { _topSkippedIndicesList = value; }
		public function get bottomSkippedIndicesList():Vector.<Vector.<uint>> { return _bottomSkippedIndicesList; }
		public function set bottomSkippedIndicesList(value:Vector.<Vector.<uint>>):void { _bottomSkippedIndicesList = value; }
		public function get indicesCombinations():Vector.<Vector.<Vector.<uint>>> { return _indicesCombinations; }
		public function set indicesCombinations(value:Vector.<Vector.<Vector.<uint>>>):void { _indicesCombinations = value; }
		
		public function get lowestColor():Number { return _lowestColor; }
		public function set lowestColor(value:Number):void { _lowestColor = value; }
		
		public function get tilesWide():uint { return _tilesWide; }
		public function set tilesWide(value:uint):void { _tilesWide = value; }
		public function get tilesHigh():uint { return _tilesHigh; }
		public function set tilesHigh(value:uint):void { _tilesHigh = value; }

	}
}