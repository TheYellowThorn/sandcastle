/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.objs.terrain
{
	import flash.display.BitmapData;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import away3d.arcane;
	import away3d.core.base.Geometry;
	import away3d.core.base.SubGeometry;
	import away3d.entities.Mesh;
	import away3d.materials.MaterialBase;
	
	use namespace arcane;

	public class SeamlessElevation extends Mesh
    {
		public var indicesList:Vector.<Vector.<uint>>;
		public var baseIndicesList:Vector.<Vector.<uint>>;
		public var leftIndicesList:Vector.<Vector.<uint>>;
		public var rightIndicesList:Vector.<Vector.<uint>>;
		public var topIndicesList:Vector.<Vector.<uint>>;
		public var bottomIndicesList:Vector.<Vector.<uint>>;
		public var leftSkippedIndicesList:Vector.<Vector.<uint>>;
		public var rightSkippedIndicesList:Vector.<Vector.<uint>>;
		public var topSkippedIndicesList:Vector.<Vector.<uint>>;
		public var bottomSkippedIndicesList:Vector.<Vector.<uint>>;
		public var normal:Vector.<Number>;
		public var actualVertices : Vector.<Number>;
		public var fullVertices : Vector.<Number>;
		public var baseActualVertices : Vector.<Number> = new Vector.<Number>();
		public var baseVertices : Vector.<Number> = new Vector.<Number>();
		
		private var _segmentsW : uint;
		private var _segmentsH : uint;
		private var _width : Number;
		private var _height : Number;
		private var _depth : Number;
		private var _heightMap : BitmapData;
		private var _heightMapData:Vector.<uint>;
		private var _heightMapWidth:uint;
		private var _heightMapHeight:uint;
		private var _activeMap : BitmapData;
		private var _minElevation:uint;
		private var _maxElevation:uint;
		private var _visiblePoints:uint;
		private var _visibleSegments:uint;
		protected var _geomDirty : Boolean = true;
		protected var _uvDirty : Boolean = true;
		private var _subGeometry : SubGeometry;
		private var _secondarySubGeometry : SubGeometry;
		private var _vertices:Vector.<Number>;
		private var _vertexTangents : Vector.<Number>;
		private var _faceTangents : Vector.<Number>;
		private var _tangents:Vector.<Number>;
		private var _indices:Vector.<uint>;
		private var _normals:Vector.<Number>;
		private var _faceNum:uint;
		private var _morphLODs:Boolean;
		private var _isOcean:Boolean;
		private var _sectorPosition:Point;
		private var _faceDivision:uint;
		private var _size:uint;
		private var _LODs:uint;
		private var _LOD:uint;
		private var _LODDirty:Boolean;
		private var _indicesDirty:Boolean;
		private var _segments:uint;
		private var _largeUVs:Vector.<Number>;
		private var _uvs:Vector.<Number>;
		private var _leftIndices:Vector.<uint>;
		private var _rightIndices:Vector.<uint>;
		private var _topIndices:Vector.<uint>;
		private var _bottomIndices:Vector.<uint>;
		private var _leftSkippedIndices:Vector.<uint>;
		private var _rightSkippedIndices:Vector.<uint>;
		private var _topSkippedIndices:Vector.<uint>;
		private var _bottomSkippedIndices:Vector.<uint>;
		private var _leftVertices:Vector.<Number>;
		private var _rightVertices:Vector.<Number>;
		private var _topVertices:Vector.<Number>;
		private var _bottomVertices:Vector.<Number>;
		private var _highestColor:uint = 0;
		private var _lowestColor:uint = 0xFFFFFFFF;
		private var _highestPoint:Vector3D;
		private var _vertexNormals:Vector.<Number>;
		private var _useFaceWeights:Boolean = false;
		private var _faceWeights:Vector.<Number>;
		private var _faceNormalsData:Vector.<Number>;
		private var _leftSector:SeamlessElevation;
		private var _rightSector:SeamlessElevation;
		private var _topSector:SeamlessElevation;
		private var _bottomSector:SeamlessElevation;
		private var _edgeFormation:Vector.<Boolean>;
		private var _lastEdgeFormation:Vector.<Boolean>;
		private var _formationDirty:Boolean = true;
		private var actualNormals:Vector.<Number>;
		private var sqrootNorms:uint;
		private var vertNum:uint;
		private var normalCount:uint;
		
		private var rotPoint:Vector3D;
		private var rotVec:Vector3D = new Vector3D();
		private var rotVec2:Vector3D = new Vector3D();
		private var rotatedPoint:Vector3D = new Vector3D();
		private var m:Matrix3D = new Matrix3D();
		private var rotDegrees:Number;
		private var axis:Vector3D;
		private var _baseExpand:Number = 1;
		private const newVec:Vector3D = new Vector3D();
		private var _renderMaterial:MaterialBase;
		private var _updateNormalsByGPU:Boolean;
		private var _seamlessElevationData:SeamlessElevationData;
		private var indicesCombinations:Vector.<Vector.<Vector.<uint>>>;
		
		
		public function SeamlessElevation(seamlessElevationData:SeamlessElevationData)
		{
			
			_seamlessElevationData = seamlessElevationData ? seamlessElevationData : new SeamlessElevationData();
		
			_heightMap = _seamlessElevationData.heightMap;
			
			_heightMapWidth = _heightMap.width;
			_heightMapHeight = _heightMap.height;
			_heightMapData = _heightMap.getVector(new Rectangle(0, 0, _heightMap.width, _heightMap.height));
			
			_seamlessElevationData.heightMapData = _heightMapData.concat();
			_sectorPosition = _seamlessElevationData.worldGridPosition;

			if (_seamlessElevationData.geometry) {
				_lowestColor = seamlessElevationData.lowestColor;
				_subGeometry = _seamlessElevationData.geometry.subGeometries[0] as SubGeometry;
			} else {
				_subGeometry =  new SubGeometry();
			}
			
			_secondarySubGeometry = new SubGeometry();
			_size = _seamlessElevationData.depth;
			_depth = _seamlessElevationData.depth;
			_width = _seamlessElevationData.width;
			_height = _seamlessElevationData.height;
			_isOcean = _seamlessElevationData.isOcean;
			_LODs = getLog(_heightMapWidth-3) - 1;
			_LOD = _LODs - 1;
			_LODDirty = true;
			_indicesDirty = true;
			
			_segments = (2 << _LODs) + 2;
			_segmentsW = _segments;
			_segmentsH = _segments;
			_visibleSegments = _segments - 2;
			_visiblePoints = _visibleSegments + 1;
			
			super(new Geometry(), _seamlessElevationData.material);
			
			if (!_seamlessElevationData.geometry) {
				this.geometry.convertToSeparateBuffers();
				this.geometry.addSubGeometry(_subGeometry);
				_seamlessElevationData.geometry = this.geometry;
				
			} else {

				this.geometry.addSubGeometry(_subGeometry);
				_seamlessElevationData.geometry = this.geometry;

			}

			_renderMaterial = this.material;
				
			_maxElevation = _seamlessElevationData.maxElevation;
			_minElevation = _seamlessElevationData.minElevation;
			
			if (_seamlessElevationData.buildGeometryOnInit) {
				_seamlessElevationData.firstElevation = this;
				buildUVs();
				_seamlessElevationData.uvs = _uvs.concat();
				buildGeometry();
				
			}
			
			if (_seamlessElevationData.updateGeometryOnInit) { 
				
				
				_seamlessElevationData.baseVertices = _seamlessElevationData.firstElevation.baseVertices.concat();
				_seamlessElevationData.actualVertices = _seamlessElevationData.firstElevation.actualVertices.concat();
				_seamlessElevationData.uvs = _seamlessElevationData.firstElevation.uvs.concat();
				_seamlessElevationData.indicesList = _seamlessElevationData.firstElevation.indicesList.concat();
				_seamlessElevationData.heightMap = _seamlessElevationData.firstElevation.heightMap.clone();
				
				baseVertices = _seamlessElevationData.baseVertices.concat();
				actualVertices = _seamlessElevationData.actualVertices.concat();
				_uvs = seamlessElevationData.uvs.concat();
				indicesList = seamlessElevationData.indicesList.concat();

				updateGeometry(this.heightMap.rect, true, true, true);
				
			} else { 
				_seamlessElevationData.fullVertices = _seamlessElevationData.firstElevation.fullVertices.concat();
				_seamlessElevationData.baseVertices = _seamlessElevationData.firstElevation.baseVertices.concat();
				_seamlessElevationData.actualVertices = _seamlessElevationData.firstElevation.actualVertices.concat();
				_seamlessElevationData.uvs = _seamlessElevationData.firstElevation.uvs.concat();
				_seamlessElevationData.indicesList = _seamlessElevationData.firstElevation.indicesList.concat();
				_seamlessElevationData.heightMap = _seamlessElevationData.firstElevation.heightMap.clone();
				
				baseVertices = _seamlessElevationData.baseVertices.concat();
				actualVertices = _seamlessElevationData.actualVertices.concat();
				_uvs = seamlessElevationData.uvs.concat();
				indicesList = seamlessElevationData.indicesList.concat();
			}

        }
		 
		private function getLog(xx:int):int {
			var num:int = xx >> 16;
			var sign:int = int(!num);
			var ans:int = (sign << 4) ^ 24;
			
			num = xx >> ans;
			sign = int(!num);
			ans = (sign << 3) ^ (ans + 4);
			
			num = xx >> ans;
			sign = int(!num);
			ans = (sign << 2) ^ (ans + 2);
			
			num = xx >> ans;
			sign = int(!num);
			ans = (sign << 1) ^ (ans + 1);
			
			num = xx >> ans;
			sign = int(!num);
			ans = sign ^ ans;
			
			return ans;
		}
		
        /**
         * The number of segments that make up the plane along the Y or Z-axis, depending on whether yUp is true or
         * false, respectively. Defaults to 1.
         */
        public function get segmentsH() : uint
        {
            return _segmentsH;
        }

        public function set segmentsH(value : uint) : void
        {
            _segmentsH = value;
            invalidateGeometry();
            invalidateUVs();
        }

        /**
		 * The width of the terrain plane.
		 */
		public function get width() : Number
		{
			return _width;
		}

		public function set width(value : Number) : void
		{
			_width = value;
			invalidateGeometry();
		}
 
        public function get height() : Number
        {
            return _height;
        }

        public function set height(value : Number) : void
        {
            _height = value;
        }

        /**
		 * The depth of the terrain plane.
		 */
		public function get depth() : Number
		{
			return _depth;
		}

		public function set depth(value : Number) : void
		{
			_depth = value;
			invalidateGeometry();
		}
		
		
		public function getHeightAt(x:Number, y:Number):Number {
			
			var colorHeight:uint = getColorHeightAt(x, y);
			var hgt:Number = (colorHeight / 0xFF) * (Number(_seamlessElevationData.height)) * (_seamlessElevationData.height / _seamlessElevationData.width);
			return hgt;
			
		}
		
		public function getColorHeightAt(x : Number, y : Number) : Number
		{
			var col : Number
			var colHeight:Number = _heightMapData[ uint(x) +  uint(y)*(_segmentsW + 1)];
			col = ((colHeight >> 16) & 0xff) * 256;
			col += ((colHeight >> 8) & 0xff);
			
			return col;
		}
		
		public function getMaxDistanceFromCenter():Number {
			
			var _h:Number = Number(_height) / Number(_width) * 2;
			var _h1:Number = 255 / 0xff * _h;
			var _hH1:Number = (_baseExpand + _h1)*_width;
			
			return _hH1;
		}
		
		/**
		 * Returns a steepness percentage. 0 is parallel and 1 is perpendicular.
		 */
		public function getNormalSteepnessFromUV(u:Number, v:Number):Number {
			
			var normal:Vector3D = getNormalFromUV(u, v);
			normal.normalize();
			
			var verticalNormal:Vector3D = new Vector3D(0, 1, 0);
			
			return normal.dotProduct(verticalNormal);
			
		}
		
		/**
		 * Returns a vertex normal based upon uv coordinates.
		 */
		public function getNormalFromUV(u:Number, v:Number):Vector3D {
			if (u >= 1) u = 0.99999;
			if (v >= 1) v = 0.99999;
			if (u <= 0) u = 0;
			if (v <= 0) v = 0;
			
			var uPosition:Number = u * _visiblePoints;
			var vPosition:Number = v * _visiblePoints;
			var minXPos:uint = uint(uPosition);
			var minYPos:uint = uint(_visiblePoints - vPosition);
			
			var normals:Vector.<Number> = this.geometry.subGeometries[0].vertexNormalData;
			var sqrt:uint = Math.sqrt(normals.length / 3);
			
			var xyPosition:Point = new Point(minXPos, minYPos);
			var xyPositionX3:Number = xyPosition.x * 3;
			var xyPositionY3:Number = sqrt*xyPosition.y * 3;
			var sqrt3:Number = sqrt * 3;
			
			var index1:uint = xyPosition.x * 3 + xyPositionY3; //current index
			var index2:uint = (xyPosition.x + 1) * 3 + xyPositionY3; //index to the right
			var index3:uint = xyPosition.x * 3 + xyPositionY3 + sqrt3; //index above
			var index4:uint = (xyPosition.x + 1) * 3 + xyPositionY3 + sqrt3; //index above and to right
			
			var vec3D1x:Number = normals[index1];
			var vec3D1y:Number = normals[index1 + 1];
			var vec3D1z:Number = normals[index1 + 2];
			var vec3D2x:Number = normals[index2];
			var vec3D2y:Number = normals[index2 + 1];
			var vec3D2z:Number = normals[index2 + 2];
			var vec3D3x:Number = normals[index3];
			var vec3D3y:Number = normals[index3 + 1];
			var vec3D3z:Number = normals[index3 + 2];
			var vec3D4x:Number = normals[index4];
			var vec3D4y:Number = normals[index4 + 1];
			var vec3D4z:Number = normals[index4 + 2];
			
			var uvXRatio:Number = 1 - (uPosition - Math.floor(uPosition));
			var uvYRatio:Number = 1 - (vPosition - Math.floor(vPosition));
			
			var horizontalCrossVec1x:Number;
			var horizontalCrossVec1y:Number;
			var horizontalCrossVec1z:Number;
			
			
			if (uvXRatio >= uvYRatio) { //x >= y triangle on right
				horizontalCrossVec1x = vec3D2x + ((vec3D1x - vec3D2x) * uvXRatio) + ((vec3D4x - vec3D2x) * uvYRatio);
				horizontalCrossVec1y = vec3D2y + ((vec3D1y - vec3D2y) * uvXRatio) + ((vec3D4y - vec3D2y) * uvYRatio);
				horizontalCrossVec1z = vec3D2z + ((vec3D1z - vec3D2z) * uvXRatio) + ((vec3D4z - vec3D2z) * uvYRatio);
			} else { //y > x triangle on left
				horizontalCrossVec1x = vec3D2x + ((vec3D1x - vec3D2x) * uvXRatio) + ((vec3D4x - vec3D2x) * uvYRatio);
				horizontalCrossVec1y = vec3D2y + ((vec3D1y - vec3D2y) * uvXRatio) + ((vec3D4y - vec3D2y) * uvYRatio);
				horizontalCrossVec1z = vec3D2z + ((vec3D1z - vec3D2z) * uvXRatio) + ((vec3D4z - vec3D2z) * uvYRatio);
			}
			
			var finalVerticalCrossVec:Vector3D = new Vector3D(horizontalCrossVec1x, horizontalCrossVec1y, horizontalCrossVec1z);
			
			return finalVerticalCrossVec;
		}
		
		public function getHeightFromUV(u:Number, v:Number):Number {
			
			if (u >= 1) u = 0.99999;
			if (v >= 1) v = 0.99999;
			if (u <= 0) u = 0;
			if (v <= 0) v = 0;
			
			var uPosition:Number = u * _visiblePoints;
			var vPosition:Number = v * _visiblePoints;
			var minXPos:uint = uint(uPosition);
			var minYPos:uint = uint(_visiblePoints - vPosition);
			
			var verts:Vector.<Number> = this.geometry.subGeometries[0].vertexData;
			var sqrt:uint = Math.sqrt(verts.length / 3);
			
			var xyPosition:Point = new Point(minXPos, minYPos);
			var xyPositionX3:Number = xyPosition.x * 3;
			var xyPositionY3:Number = sqrt*xyPosition.y * 3;
			var sqrt3:Number = sqrt * 3;
			
			var index1:uint = xyPosition.x * 3 + xyPositionY3; //current index
			var index2:uint = (xyPosition.x + 1) * 3 + xyPositionY3; //index to the right
			var index3:uint = xyPosition.x * 3 + xyPositionY3 + sqrt3; //index above
			var index4:uint = (xyPosition.x + 1) * 3 + xyPositionY3 + sqrt3; //index above and to right
			
			var vec3D1y:Number = verts[index1 + 1];
			var vec3D2y:Number = verts[index2 + 1];
			var vec3D3y:Number = verts[index3 + 1];
			var vec3D4y:Number = verts[index4 + 1];
			
			var uvXRatio:Number = 1 - (uPosition - Math.floor(uPosition));
			var uvYRatio:Number = 1 - (vPosition - Math.floor(vPosition));
			
			var horizontalCrossVec1x:Number;
			var horizontalCrossVec1y:Number;
			var horizontalCrossVec1z:Number;
			
			
			if (uvXRatio >= uvYRatio) { //x >= y triangle on right
				horizontalCrossVec1y = vec3D2y + ((vec3D1y - vec3D2y) * uvXRatio) + ((vec3D4y - vec3D2y) * uvYRatio);
			} else { //y > x triangle on left
				horizontalCrossVec1y = vec3D2y + ((vec3D1y - vec3D2y) * uvXRatio) + ((vec3D4y - vec3D2y) * uvYRatio);
			}
			
			var finalVerticalCrossVec:Vector3D = new Vector3D(horizontalCrossVec1x, horizontalCrossVec1y, horizontalCrossVec1z);
			
			return horizontalCrossVec1y;
		}
		
		public function getCoordinatesFromUV(u:Number, v:Number):Vector3D {
			if (u >= 1) u = 0.99999;
			if (v >= 1) v = 0.99999;
			if (u <= 0) u = 0;
			if (v <= 0) v = 0;
			
			var uPosition:Number = u * _visiblePoints;
			var vPosition:Number = v * _visiblePoints;
			var minXPos:uint = uint(uPosition);
			var minYPos:uint = uint(_visiblePoints - vPosition);
			
			var verts:Vector.<Number> = this.geometry.subGeometries[0].vertexData;
			var sqrt:uint = Math.sqrt(verts.length / 3);
			
			var xyPosition:Point = new Point(minXPos, minYPos);
			var xyPositionX3:Number = xyPosition.x * 3;
			var xyPositionY3:Number = sqrt*xyPosition.y * 3;
			var sqrt3:Number = sqrt * 3;
			
			var index1:uint = xyPosition.x * 3 + xyPositionY3; //current index
			var index2:uint = (xyPosition.x + 1) * 3 + xyPositionY3; //index to the right
			var index3:uint = xyPosition.x * 3 + xyPositionY3 + sqrt3; //index above
			var index4:uint = (xyPosition.x + 1) * 3 + xyPositionY3 + sqrt3; //index above and to right
			
			var vec3D1x:Number = verts[index1];
			var vec3D1y:Number = verts[index1 + 1];
			var vec3D1z:Number = verts[index1 + 2];
			var vec3D2x:Number = verts[index2];
			var vec3D2y:Number = verts[index2 + 1];
			var vec3D2z:Number = verts[index2 + 2];
			var vec3D3x:Number = verts[index3];
			var vec3D3y:Number = verts[index3 + 1];
			var vec3D3z:Number = verts[index3 + 2];
			var vec3D4x:Number = verts[index4];
			var vec3D4y:Number = verts[index4 + 1];
			var vec3D4z:Number = verts[index4 + 2];
			
			var uvXRatio:Number = 1 - (uPosition - Math.floor(uPosition));
			var uvYRatio:Number = 1 - (vPosition - Math.floor(vPosition));
			
			var horizontalCrossVec1x:Number;
			var horizontalCrossVec1y:Number;
			var horizontalCrossVec1z:Number;
			
			
			if (uvXRatio >= uvYRatio) { //x >= y triangle on right
				horizontalCrossVec1x = vec3D2x + ((vec3D1x - vec3D2x) * uvXRatio) + ((vec3D4x - vec3D2x) * uvYRatio);
				horizontalCrossVec1y = vec3D2y + ((vec3D1y - vec3D2y) * uvXRatio) + ((vec3D4y - vec3D2y) * uvYRatio);
				horizontalCrossVec1z = vec3D2z + ((vec3D1z - vec3D2z) * uvXRatio) + ((vec3D4z - vec3D2z) * uvYRatio);
			} else { //y > x triangle on left
				horizontalCrossVec1x = vec3D2x + ((vec3D1x - vec3D2x) * uvXRatio) + ((vec3D4x - vec3D2x) * uvYRatio);
				horizontalCrossVec1y = vec3D2y + ((vec3D1y - vec3D2y) * uvXRatio) + ((vec3D4y - vec3D2y) * uvYRatio);
				horizontalCrossVec1z = vec3D2z + ((vec3D1z - vec3D2z) * uvXRatio) + ((vec3D4z - vec3D2z) * uvYRatio);
			}
			
			var finalVerticalCrossVec:Vector3D = new Vector3D(horizontalCrossVec1x, horizontalCrossVec1y, horizontalCrossVec1z);
			
			return finalVerticalCrossVec;
		}

		private function buildUVs() : void
		{
			var uvs : Vector.<Number> = new Vector.<Number>();
			var numUvs : uint = (_segmentsH - 1) * (_segmentsW - 1) * 2;
			
			if (_subGeometry.UVData && numUvs == _subGeometry.UVData.length) {
				uvs = _subGeometry.UVData;
			} else {
				uvs = new Vector.<Number>(numUvs, true);
			}
			
			numUvs = 0;
			var yi : uint;
			var xi : uint;
			var segH:uint = _segmentsH - 2;
			var segW:uint = _segmentsW - 2;
			for (yi = 0; yi <= segH; ++yi) {
				for (xi = 0; xi <= segW; ++xi) {
					uvs[numUvs++] = Number(xi)/Number(segW + 0);
					uvs[numUvs++] = 1 - Number(yi)/Number(segH + 0);
				}
			}
			_uvs = uvs;
		}
 
		public function updateHeights(rect:Rectangle):void {
			
			
			var numVerts:uint = 0;
			var actualNumVerts:uint = 0;
			var col:uint;
			var count:uint = 0;
			var _h1:Number;
			var _hH1:Number;
			var _h:Number = Number(_height) / Number(_width) * 1;
			
			fullVertices ||= baseVertices.concat();
			
			for (var zi:uint = 0; zi <= _segmentsH; ++zi) {
				for (var xi:uint = 0; xi <= _segmentsW; ++xi) {
					
					
					var colHeight:Number = _heightMapData[xi + zi*(_segmentsW + 1)];
					col = ((colHeight >> 16) & 0xff) * 256;
					col += ((colHeight >> 8) & 0xff);
					
					
					if (!_isOcean) { 
						_h1 = (col > _maxElevation)? (_maxElevation / 256) * _h : ((col < _minElevation)?(_minElevation / 256) * _h :  (col / 256) * _h);
					} else {
						_h1 = ((col - .5) > _maxElevation)? (_maxElevation / 256) * _h : (((col - .5) < _minElevation)?(_minElevation / 256) * _h :  ((col - .5) / 256) * _h);
					}
					
					_hH1 = (_baseExpand + _h1)*_width;
					
					fullVertices[numVerts+1] = _h1 * _height;
					numVerts += 3;
					
					if (xi !== 0 && zi !== 0 && xi < _segmentsW && zi < _segmentsH) {
						
						if (col > _highestColor) {
							_highestColor = col;
							
							_highestPoint.x = fullVertices[numVerts-3];
							_highestPoint.y = fullVertices[numVerts-2];
							_highestPoint.z = fullVertices[numVerts-1];
						}
						if (col < _lowestColor) {
							_lowestColor = col;
							_seamlessElevationData.lowestColor = _lowestColor;
						}
						
						actualVertices[actualNumVerts+1] = fullVertices[numVerts-2];//ny;
						actualNumVerts+=3;
					}
					
				}
			}
			
			_subGeometry.updateVertexData(actualVertices);
			
		}
		
		public function updateGeometry(rect:Rectangle, updateVertexBuffer:Boolean = true, updateNormals:Boolean = false, updateVertexNormalBuffer:Boolean = true):void {
			
			var xOffset:Number = seamlessElevationData.width*(seamlessElevationData.worldGridPosition.x - (seamlessElevationData.tilesWide/2)) + 0.5*seamlessElevationData.width;
			var zOffset:Number = seamlessElevationData.width*(seamlessElevationData.worldGridPosition.y - (seamlessElevationData.tilesHigh/2)) + 0.5*seamlessElevationData.width;
			
			baseVertices ||= _seamlessElevationData.baseVertices.concat();
			fullVertices ||= _seamlessElevationData.fullVertices.concat();
			_vertices ||= _seamlessElevationData.vertices.concat()

			var numVerts:uint = 0;
			var actualNumVerts:uint = 0;
			var col:uint;
			var _hH1:Number;
			var _h1:Number;
			var _h:Number = Number(_height) / Number(_width) * 1;
			var _segW3:uint = (_segmentsW + 1)*3;
			var _segMin3:uint = (_segmentsW - 1)*3;
			
			if (rect.y >= _segmentsH) return;
			if (rect.x >= _segmentsW) return;
			
			var sz:int = rect.y < 0 ? 0 : rect.y;
			var sx:int = rect.x < 0 ? 0 : rect.x;
			var ez:int = rect.y + rect.height > (_segmentsH + 1)  ? _segmentsH + 1 : rect.y + rect.height;
			var ex:int = rect.x + rect.width > (_segmentsW + 1)  ? _segmentsW + 1 : rect.x + rect.width;

			for (var zi:uint = sz; zi < ez; zi++) {
				for (var xi:uint = sx; xi < ex; xi++) {

					var colHeight:Number = _heightMapData[xi + zi*(_segmentsW + 1)];
					col = ((colHeight >> 16) & 0xff) * 256;
					col += ((colHeight >> 8) & 0xff);
					
					if (!_isOcean) { 
						_h1 = (col > _maxElevation)? (_maxElevation / 256) * _h : ((col < _minElevation)?(_minElevation / 256) * _h :  (col / 256) * _h);
					} else {
						_h1 = ((col - .5) > _maxElevation)? (_maxElevation / 256) * _h : (((col - .5) < _minElevation)?(_minElevation / 256) * _h :  ((col - .5) / 256) * _h);
					}
					
					_hH1 = (_baseExpand + _h1)*_width;
					
					numVerts = zi*_segW3 + xi*3;
					
					fullVertices ||= new Vector.<Number>(baseVertices.length, true);
					fullVertices[numVerts+0] = baseVertices[numVerts+0] *_width;
					fullVertices[numVerts+1] = _h1 * _height;
					fullVertices[numVerts+2] = baseVertices[numVerts+2] *_depth;

					if (xi !== 0 && zi !== 0 && xi < _segmentsW && zi < _segmentsH) {
						
						actualNumVerts = (zi - 1)*_segMin3 + (xi - 1)*3;
						
						actualVertices[actualNumVerts++] = baseVertices[numVerts+0] *_width + xOffset;
						actualVertices[actualNumVerts++] = _h1 * _height;
						actualVertices[actualNumVerts++] = baseVertices[numVerts+2] *_depth + zOffset;
						
						if (col > _highestColor) {
							_highestColor = col;
						}
						if (col < _lowestColor) {
							_lowestColor = col;
							_seamlessElevationData.lowestColor = _lowestColor;
						}
						
					}
					
					numVerts += 3;
					
				}
			}
			
			_seamlessElevationData.actualVertices = actualVertices;
			_seamlessElevationData.heightMapData = _heightMapData;
			
			if (!updateVertexBuffer && !updateNormals) return; 
			
			if (updateVertexBuffer) {
				_subGeometry.updateVertexData(_seamlessElevationData.actualVertices);
				_subGeometry.autoDeriveVertexNormals = false;
				_subGeometry.autoDeriveVertexTangents = false;
			}
			
			if (!updateNormals) return;
			
			var width:Number = 2 * (_width / (_segments - 2));

			numVerts = 0;
			actualNumVerts = 0;

			actualNormals = _seamlessElevationData.actualNormals;
			
			var c1X:Number; var c1Y:Number; var c1Z:Number;
			var c2X:Number; var c2Y:Number; var c2Z:Number;
			var c3X:Number; var c3Y:Number; var c3Z:Number;
			var c4X:Number; var c4Y:Number; var c4Z:Number;
			
			var crs1X:Number; var crs1Y:Number; var crs1Z:Number;
			var crs2X:Number; var crs2Y:Number; var crs2Z:Number;
			
			
			for (zi = sz; zi < ez; zi++) {
				for (xi = sx; xi < ex; xi++) {
					
					if (xi !== 0 && zi !== 0 && xi < _segmentsW && zi < _segmentsH) {
						
						numVerts = zi*_segW3 + xi*3;
						
						actualNumVerts = (zi - 1)*_segMin3 + (xi - 1)*3;

						c1X = width;
						c1Y = 0;
						c2X = 0;
						c2Y = width;
						c3X = width;
						c3Y = 0;
						c4X = 0;
						c4Y = width;
						
						c1Z = fullVertices[numVerts + 4] - fullVertices[numVerts - 2];
						c2Z = fullVertices[numVerts + 1 + _segW3] - fullVertices[numVerts + 1 - _segW3];
						c3Z = fullVertices[numVerts + 4 + _segW3] - fullVertices[numVerts - 2 - _segW3];
						c4Z = fullVertices[numVerts - 2 + _segW3] - fullVertices[numVerts + 4 - _segW3];
						
						//CROSS PRODUCT OF VECTOR 1 and 2
						crs1X = c1Y * c2Z - c1Z * c2Y;
						crs1Y = c1Z * c2X - c1X * c2Z;
						crs1Z = c1X * c2Y - c1Y * c2X;
						
						//CROSS PRODUCT OF VECTOR 3 and 4
						crs2X = c3Y * c4Z - c3Z * c4Y;
						crs2Y = c3Z * c4X - c3X * c4Z;
						crs2Z = c3X * c4Y - c3Y * c4X;
						
						//AVERAGE NORMALS
						crs1X = (crs1X + crs2X) / 2;
						crs1Y = (crs1Y + crs2Y) / 2;
						crs1Z = (crs1Z + crs2Z) / 2;
						
						actualNormals[actualNumVerts++] = crs1X;
						actualNormals[actualNumVerts++] = crs1Z;
						actualNormals[actualNumVerts++] = crs1Y;
						
						numVerts += 3;
					}
				}
			}
			
			_seamlessElevationData.actualNormals = actualNormals;
			
			if (updateVertexNormalBuffer) {
				_subGeometry.updateVertexNormalData(_seamlessElevationData.actualNormals);
			}
		}
		
		public function buildGeometry() : void
		{

			var indices : Vector.<uint>;
			var actualIndices : Vector.<uint>;
			var baseIndices : Vector.<uint>;
			var numInds : uint = 0;
			var actualNumInds : uint = 0;
			var baseNumInds : uint = 0;
			var leftInds:uint = 0;
			var rightInds:uint = 0;
			var topInds:uint = 0;
			var bottomInds:uint = 0;
			var leftActualInds:uint = 0;
			var rightActualInds:uint = 0;
			var topActualInds:uint = 0;
			var bottomActualInds:uint = 0;
			var base : uint;
			var base1:uint;
			var base2:uint;
			var tw : uint = _segmentsW + 1;
			var baseTw:uint;
			var baseTw1:uint;
			var baseTw2:uint;
			var base2Tw:uint;
			var base2Tw1:uint;
			var atw : uint = (_segmentsW - 1);
			var numVerts : uint = (_segmentsH + 1) * tw;
			var actualNumVerts : uint = (_segmentsH - 1) * (_segmentsW - 1);
			var uDiv : Number = (_heightMapWidth-1)/_segmentsW;
			var vDiv : Number = (_heightMapHeight-1)/_segmentsH;
			var u : Number, v : Number;
			var x : Number, z : Number, y : Number;
			var nx : Number, nz : Number, ny : Number;
			
			var vCount:uint = 0;

			_highestColor = 0;
			
			fullVertices = new Vector.<Number>(numVerts * 3, true);
			indices = new Vector.<uint>(_segmentsH * _segmentsW * 6, true);
			
			actualVertices = new Vector.<Number>(actualNumVerts * 3, true);
			actualIndices = new Vector.<uint>((_segmentsH - 2) * (_segmentsW - 2) * 6, true);
			baseIndices = new Vector.<uint>((_segmentsH - 4) * (_segmentsW - 4) * 6, true);
			_leftIndices = new Vector.<uint>((_segmentsH - 2) * 6, true);
			_rightIndices = new Vector.<uint>((_segmentsH - 2) * 6, true);
			_topIndices = new Vector.<uint>((_segmentsW - 2) * 6, true);
			_bottomIndices = new Vector.<uint>((_segmentsW - 2) * 6, true);
			_leftSkippedIndices = new Vector.<uint>();
			_rightSkippedIndices = new Vector.<uint>();
			_topSkippedIndices = new Vector.<uint>();
			_bottomSkippedIndices = new Vector.<uint>();
			
			_highestPoint = new Vector3D();
			
			numVerts = 0;
			actualNumVerts = 0;
			var col:uint;
			var count:uint = 0;
			var _w:Number = 1;
			var _d:Number = 1;
			var _h:Number = Number(_height) / Number(_width) * 1;
			y = 1;
			var tempX:Number;
			var tempY:Number;
			
			var tx:Number;
			var tx2:Number;
			var tx25:Number;
			var y2:Number;
			var z2:Number;
			var z25:Number;
			var y25:Number;
			var tz:Number;
			var tz2:Number;
			var tz25:Number;
			var x2:Number;
			var x25:Number;
			var p:Vector3D;
			var zi : int;
			var xi : int;
			var _hH1:Number;
			var _h1:Number;
			var _segW2:Number = _segmentsW - 2;
			var _segH2:Number = _segmentsH - 2;
			var _maxElH:uint = uint(_maxElevation / 256) * _h;
			var _minElH:uint = uint(_minElevation / 256) * _h;
			
			var firstX:Number = 0;
			var secondX:Number = 0;
			
			if (baseVertices.length == 0) {
			
				for (zi = 0; zi <= _segmentsH; ++zi) {
					for (xi = 0; xi <= _segmentsW; ++xi) {
						
						tempX = ((xi - 1)/(_segmentsW - 2) - .5);
						tempY = ((zi - 1)/(_segmentsH - 2) - .5);
						
						x = tempX*_w;
						z = tempY*_d;
						
						u = xi*uDiv;
						v = (_segmentsH - zi) * vDiv;
						
						var colHeight:Number = _heightMapData[xi + zi*(_segmentsW + 1)];
						col = ((colHeight >> 16) & 0xff) * 256;
						col += ((colHeight >> 8) & 0xff);
						
						if (col < _lowestColor) {
							_lowestColor = col;
							_seamlessElevationData.lowestColor = _lowestColor;
						}
						
						rotDegrees = 0;
						axis = Vector3D.Z_AXIS;	
						
						x2 = x * x;
						y2 = 1;
						z2 = z * z;
						x25 = x2 * 0.5;
						z25 = z2 * 0.5;
						y25 = 0.5;
						
						rotVec.x = x;
						rotVec.y = y;
						rotVec.z = z;
						
						if (!_isOcean) { 
							_h1 = (col > _maxElevation)? (_maxElevation / 256) * _h : ((col < _minElevation)?(_minElevation / 256) * _h :  (col / 256) * _h);
						} else {
							_h1 = ((col - .5) > _maxElevation)? (_maxElevation / 256) * _h : (((col - .5) < _minElevation)?(_minElevation / 256) * _h :  ((col - .5) / 256) * _h);
						}
						
						_hH1 = (_baseExpand + _h1)*_width;

						rotPoint = rotVec;
						
						fullVertices[numVerts++] = rotPoint.x;
						fullVertices[numVerts++] = rotPoint.y;
						fullVertices[numVerts++] = rotPoint.z;

						if (xi != _segmentsW && zi != _segmentsH) {
							base = xi + zi*tw;
							indices[numInds++] = base;
							indices[numInds++] = base + tw;
							indices[numInds++] = base + tw + 1;
							indices[numInds++] = base;
							indices[numInds++] = base + tw + 1;
							indices[numInds++] = base + 1;
						}
						
					}
				}
			}
			
			if (baseActualVertices.length == 0) { baseActualVertices = baseActualVertices.concat(actualVertices); }
			if (baseVertices.length == 0) { 
				
				baseVertices = baseVertices.concat(fullVertices); 
				_seamlessElevationData.baseVertices = baseVertices.concat();
			}
			
			numVerts = 0;
			actualNumVerts = 0;
			
			for (zi = 0; zi <= _segmentsH; ++zi) {
				for (xi = 0; xi <= _segmentsW; ++xi) {
					
					colHeight = _heightMapData[xi + zi*(_segmentsW + 1)];
					col = ((colHeight >> 16) & 0xff) * 256;
					col += ((colHeight >> 8) & 0xff);
					
					if (!_isOcean) { 
						_h1 = (col > _maxElevation)? (_maxElevation / 256) * _h : ((col < _minElevation)?(_minElevation / 256) * _h :  (col / 256) * _h);
					} else {
						_h1 = ((col - .5) > _maxElevation)? (_maxElevation / 256) * _h : (((col - .5) < _minElevation)?(_minElevation / 256) * _h :  ((col - .5) / 256) * _h);
					}
					
					_hH1 = (_baseExpand + _h1)*_width;
					
					fullVertices[numVerts+0] = baseVertices[numVerts+0] *_width;
					fullVertices[numVerts+1] = _h1 * _height;
					fullVertices[numVerts+2] = baseVertices[numVerts+2] *_depth;
					
					numVerts += 3;
					
					if (xi !== 0 && zi !== 0 && xi < _segmentsW && zi < _segmentsH) {
						
						if (col > _highestColor) {
							_highestColor = col;
							
							
							_highestPoint.x = fullVertices[numVerts-3];
							_highestPoint.y = fullVertices[numVerts-2];
							_highestPoint.z = fullVertices[numVerts-1];
						}
						if (col < _lowestColor) {
							_lowestColor = col;
							_seamlessElevationData.lowestColor = _lowestColor;
						}
						
						actualVertices[actualNumVerts++] = fullVertices[numVerts-3];//nx;
						actualVertices[actualNumVerts++] = fullVertices[numVerts-2];//ny;
						actualVertices[actualNumVerts++] = fullVertices[numVerts-1];//nz;
					}
					
				}
			}

			if (!indicesList) {

				indicesList = new Vector.<Vector.<uint>>(_LODs, true);
				baseIndicesList = new Vector.<Vector.<uint>>(_LODs, true);
				leftIndicesList = new Vector.<Vector.<uint>>(_LODs, true);
				rightIndicesList = new Vector.<Vector.<uint>>(_LODs, true);
				topIndicesList = new Vector.<Vector.<uint>>(_LODs, true);
				bottomIndicesList = new Vector.<Vector.<uint>>(_LODs, true);
				leftSkippedIndicesList = new Vector.<Vector.<uint>>(_LODs, true);
				rightSkippedIndicesList = new Vector.<Vector.<uint>>(_LODs, true);
				topSkippedIndicesList = new Vector.<Vector.<uint>>(_LODs, true);
				bottomSkippedIndicesList = new Vector.<Vector.<uint>>(_LODs, true);
				
				var i:uint, j:uint, k:uint, divs:uint;
				var newInds:Vector.<uint>;
				var newBaseInds:Vector.<uint>;
				var newBaseLeftInds:Vector.<uint>;
				var newBaseRightInds:Vector.<uint>;
				var newBaseTopInds:Vector.<uint>;
				var newBaseBottomInds:Vector.<uint>;
				var newBaseSkippedLeftInds:Vector.<uint>;
				var newBaseSkippedRightInds:Vector.<uint>;
				var newBaseSkippedTopInds:Vector.<uint>;
				var newBaseSkippedBottomInds:Vector.<uint>;
				
				
				var baseLeftNumInds:uint;
				var baseRightNumInds:uint;
				var baseTopNumInds:uint;
				var baseBottomNumInds:uint;
				var pointsW:uint;
				var pointsW1:uint;
				var inds:Vector.<uint>;
				var n:uint = 0;
				var j2:uint;
				var k2:uint;
				
				for (i = 0; i<_LODs; i++) {
					
					divs = 2 << (i-1);
					if (i == 0) divs = 1;
					
					pointsW = uint(_segW2 / divs);
					pointsW1 = pointsW - 1;		
					tw = divs * (_segmentsW - 1);
					n = 0;
					leftInds = 0;
					rightInds = 0;
					topInds = 0;
					bottomInds = 0;
					baseNumInds = 0;
					
					inds = new Vector.<uint>(pointsW * pointsW * 6, true);
					newBaseInds = new Vector.<uint>((pointsW-2) * (pointsW-2) * 6, true);
					newBaseLeftInds = new Vector.<uint>(pointsW * 6, true);
					newBaseRightInds = new Vector.<uint>(pointsW * 6, true);
					newBaseTopInds = new Vector.<uint>(pointsW * 6, true);
					newBaseBottomInds = new Vector.<uint>(pointsW * 6, true);
					
					newBaseSkippedLeftInds = new Vector.<uint>();
					newBaseSkippedRightInds = new Vector.<uint>();
					newBaseSkippedTopInds = new Vector.<uint>();
					newBaseSkippedBottomInds = new Vector.<uint>();
					
					for (j = 0; j <= pointsW; j++) {
						for (k = 0; k <= pointsW; k++) {
							if (k !== pointsW && j !== pointsW) {
								
								base = k*divs + (j)*tw;
				
								base1 = base + divs;
								baseTw = base + tw;
								baseTw1 = baseTw + divs;
								
								if (k == 0 && j == pointsW - 1) {
									inds[n++] = base;
									inds[n++] = baseTw;
									inds[n++] = base1;
									inds[n++] = base1;
									inds[n++] = baseTw;
									inds[n++] = baseTw1;
								} else if (k == pointsW - 1 && j == 0) {
									inds[n++] = base;
									inds[n++] = baseTw;
									inds[n++] = base1;
									inds[n++] = base1;
									inds[n++] = baseTw;
									inds[n++] = baseTw1;
								} else {
									inds[n++] = base;
									inds[n++] = baseTw;
									inds[n++] = baseTw1;
									inds[n++] = base;
									inds[n++] = baseTw1;
									inds[n++] = base1;
								}
								
								if (k !== 0 && j !==0 && k < pointsW1 && j < pointsW1) {
	
									newBaseInds[baseNumInds++] = inds[n - 6];
									newBaseInds[baseNumInds++] = inds[n - 5];
									newBaseInds[baseNumInds++] = inds[n - 4];
									newBaseInds[baseNumInds++] = inds[n - 3];
									newBaseInds[baseNumInds++] = inds[n - 2];
									newBaseInds[baseNumInds++] = inds[n - 1];
									
								} 
								if (k == 0) {
									if (j == 0 || j == pointsW1) {
										newBaseLeftInds[leftInds++] = inds[n - 6];
										newBaseLeftInds[leftInds++] = inds[n - 5];
										newBaseLeftInds[leftInds++] = inds[n - 4];
									} else {
										newBaseLeftInds[leftInds++] = inds[n - 6];
										newBaseLeftInds[leftInds++] = inds[n - 5];
										newBaseLeftInds[leftInds++] = inds[n - 4];
										newBaseLeftInds[leftInds++] = inds[n - 3];
										newBaseLeftInds[leftInds++] = inds[n - 2];
										newBaseLeftInds[leftInds++] = inds[n - 1];
									}
									
								} else if (k == pointsW1) {
									if (j == 0 || j == pointsW1) {
										newBaseRightInds[rightInds++] = inds[n - 3];
										newBaseRightInds[rightInds++] = inds[n - 2];
										newBaseRightInds[rightInds++] = inds[n - 1];
									} else {
										newBaseRightInds[rightInds++] = inds[n - 6];
										newBaseRightInds[rightInds++] = inds[n - 5];
										newBaseRightInds[rightInds++] = inds[n - 4];
										newBaseRightInds[rightInds++] = inds[n - 3];
										newBaseRightInds[rightInds++] = inds[n - 2];
										newBaseRightInds[rightInds++] = inds[n - 1];
									}
								} 
								if (j == pointsW1) {
									if (k == 0) {
										newBaseTopInds[topInds++] = inds[n - 3];
										newBaseTopInds[topInds++] = inds[n - 2];
										newBaseTopInds[topInds++] = inds[n - 1];
									} else if (k == pointsW1) {
										newBaseTopInds[topInds++] = inds[n - 6];
										newBaseTopInds[topInds++] = inds[n - 5];
										newBaseTopInds[topInds++] = inds[n - 4];
									} else {
										newBaseTopInds[topInds++] = inds[n - 6];
										newBaseTopInds[topInds++] = inds[n - 5];
										newBaseTopInds[topInds++] = inds[n - 4];
										newBaseTopInds[topInds++] = inds[n - 3];
										newBaseTopInds[topInds++] = inds[n - 2];
										newBaseTopInds[topInds++] = inds[n - 1];
									}
									
								} else if (j == 0) {
									if (k == 0) {
										newBaseBottomInds[bottomInds++] = inds[n - 3];
										newBaseBottomInds[bottomInds++] = inds[n - 2];
										newBaseBottomInds[bottomInds++] = inds[n - 1];
									} else if (k == pointsW1) {
										newBaseBottomInds[bottomInds++] = inds[n - 6];
										newBaseBottomInds[bottomInds++] = inds[n - 5];
										newBaseBottomInds[bottomInds++] = inds[n - 4];
									} else {
										newBaseBottomInds[bottomInds++] = inds[n - 6];
										newBaseBottomInds[bottomInds++] = inds[n - 5];
										newBaseBottomInds[bottomInds++] = inds[n - 4];
										newBaseBottomInds[bottomInds++] = inds[n - 3];
										newBaseBottomInds[bottomInds++] = inds[n - 2];
										newBaseBottomInds[bottomInds++] = inds[n - 1];
									}
								}
								
								if (k == 0 && j < pointsW) {
									
									j2 = j % 2;
							
									base = (j - j2) * tw;
									base1 = base + divs;
									baseTw = base + tw;
									baseTw1 = baseTw + divs;
									base2Tw = base + 2*tw;
									base2Tw1 = base2Tw + divs;
									
									if (j2 == 0) {
										newBaseSkippedLeftInds.push(base);
										newBaseSkippedLeftInds.push(base2Tw);
										newBaseSkippedLeftInds.push(baseTw1);
										if (j !== pointsW1 - 1) {
											newBaseSkippedLeftInds.push(baseTw1);
											newBaseSkippedLeftInds.push(base2Tw);
											newBaseSkippedLeftInds.push(base2Tw1);
										}
										
									} else {
										if (j !== 1) {
											newBaseSkippedLeftInds.push(base);
											newBaseSkippedLeftInds.push(baseTw1);
											newBaseSkippedLeftInds.push(base1);
										}
										
									}
									
								}
								if (k == pointsW1 && j < pointsW) {
									
									j2 = j % 2;
									
									base = k*divs + (j - j2) * tw;
									base1 = base + divs;
									baseTw = base + tw;
									base2Tw = base + 2*tw;
									base2Tw1 = base2Tw + divs;
									
									if (j2 == 0) {
										if (j !== 0) {
											newBaseSkippedRightInds.push(base);
											newBaseSkippedRightInds.push(baseTw);
											newBaseSkippedRightInds.push(base1);
										}
										newBaseSkippedRightInds.push(base1);
										newBaseSkippedRightInds.push(baseTw);
										newBaseSkippedRightInds.push(base2Tw1);
										
									} else {
										if (j !== pointsW1) {
											newBaseSkippedRightInds.push(baseTw);
											newBaseSkippedRightInds.push(base2Tw);
											newBaseSkippedRightInds.push(base2Tw1);
										}
									}
									
								}
								if (j == pointsW1 && k < pointsW) {
									
									k2 = k % 2;
								
									base = (k*divs - k2) + (j)*tw - k2*(divs-1);
									base1 = base + divs;
									base2 = base + 2*divs;
	
									baseTw = base + tw;
									baseTw2 = baseTw + 2*divs;
	
									if (k2 == 0) {
										if (k !== 0) {
											newBaseSkippedTopInds.push(base);
											newBaseSkippedTopInds.push(baseTw);
											newBaseSkippedTopInds.push(base1);
										}
										newBaseSkippedTopInds.push(base1);
										newBaseSkippedTopInds.push(baseTw);
										newBaseSkippedTopInds.push(baseTw2);
									} else {
										if (k !== pointsW1) {
											newBaseSkippedTopInds.push(base1);
											newBaseSkippedTopInds.push(baseTw2);
											newBaseSkippedTopInds.push(base2);
										}
									}
								}
								if (j == 0 && k < pointsW) {
	
									k2 = k % 2;
									
									base = (k*divs - k2) - k2*(divs-1);
									base2 = base + 2*divs;
									baseTw = base + tw;
									baseTw1 = baseTw + divs;
									baseTw2 = baseTw + 2*divs;
									
									if (k2 == 0) {
										if (k !== 0) {
											newBaseSkippedBottomInds.push(base);
											newBaseSkippedBottomInds.push(baseTw);
											newBaseSkippedBottomInds.push(baseTw1);
										}
										newBaseSkippedBottomInds.push(base);
										newBaseSkippedBottomInds.push(baseTw1);
										newBaseSkippedBottomInds.push(base2);
										
									} else {
										if (k !== pointsW1) {
											newBaseSkippedBottomInds.push(base2);
											newBaseSkippedBottomInds.push(baseTw1);
											newBaseSkippedBottomInds.push(baseTw2);
										}
									}	
								}
								
							}
						}
					}
					
					indicesList[(_LODs - 1) - i] = inds;
					baseIndicesList[(_LODs - 1) - i] = newBaseInds;
					leftIndicesList[(_LODs - 1) - i] = newBaseLeftInds;
					rightIndicesList[(_LODs - 1) - i] = newBaseRightInds;
					topIndicesList[(_LODs - 1) - i] = newBaseTopInds;
					bottomIndicesList[(_LODs - 1) - i] = newBaseBottomInds;
					leftSkippedIndicesList[(_LODs - 1) - i] = newBaseSkippedLeftInds;
					rightSkippedIndicesList[(_LODs - 1) - i] = newBaseSkippedRightInds;
					topSkippedIndicesList[(_LODs - 1) - i] = newBaseSkippedTopInds;
					bottomSkippedIndicesList[(_LODs - 1) - i] = newBaseSkippedBottomInds;

					
				}
				
				var indicesTypes:Vector.<Vector.<Vector.<uint>>> = new Vector.<Vector.<Vector.<uint>>>();
				indicesTypes.push(leftIndicesList);
				indicesTypes.push(rightIndicesList);
				indicesTypes.push(topIndicesList);
				indicesTypes.push(bottomIndicesList);
				indicesTypes.push(leftSkippedIndicesList);
				indicesTypes.push(rightSkippedIndicesList);
				indicesTypes.push(topSkippedIndicesList);
				indicesTypes.push(bottomSkippedIndicesList);
				
				indicesCombinations = new Vector.<Vector.<Vector.<uint>>>(_LODs, true);
				for (var m:uint = 0; m<indicesCombinations.length; m++) {
					var combinationListPerLOD:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>();
					indicesCombinations[m] = combinationListPerLOD;
				}
				
				for (m = 0; m<_LODs; m++) {
		
					for (var i1:uint = 3; i1<indicesTypes.length; i1++) {
						for (var i2:uint = 2; i2<indicesTypes.length; i2++) {
							for (var i3:uint = 1; i3<indicesTypes.length; i3++) {
								for (var i4:uint = 0; i4<indicesTypes.length; i4++) {
									if (i1 <= i2) continue;
									if (i1 <= i3) continue;
									if (i1 <= i4) continue;
									if (i2 <= i3) continue;
									if (i2 <= i4) continue;
									if (i3 <= i4) continue;
									if (i1 % 4 == i2 % 4) continue;
									if (i1 % 4 == i3 % 4) continue;
									if (i1 % 4 == i4 % 4) continue;
									if (i2 % 4 == i3 % 4) continue;
									if (i2 % 4 == i4 % 4) continue;
									if (i3 % 4 == i4 % 4) continue;
									
									var l:String = i1 == 0 || i2 == 0 || i3 == 0 || i4 == 0 ? "L" : "SL";
									var r:String = i1 == 1 || i2 == 1 || i3 == 1 || i4 == 1 ? "R" : "SR";
									var t:String = i1 == 2 || i2 == 2 || i3 == 2 || i4 == 2 ? "T" : "ST";
									var b:String = i1 == 3 || i2 == 3 || i3 == 3 || i4 == 3 ? "B" : "SB";
									
									var combo:Vector.<uint> = baseIndicesList[m].concat(indicesTypes[i4][m]).concat(indicesTypes[i3][m]).concat(indicesTypes[i2][m]).concat(indicesTypes[i1][m]);
									
									indicesCombinations[m].push(combo);

								}
							}
						}
					}
				}
				
				
				
				_seamlessElevationData.baseIndicesList = baseIndicesList;
				_seamlessElevationData.leftIndicesList = leftIndicesList;
				_seamlessElevationData.rightIndicesList = rightIndicesList;
				_seamlessElevationData.topIndicesList = topIndicesList;
				_seamlessElevationData.bottomIndicesList = bottomIndicesList;
				_seamlessElevationData.leftSkippedIndicesList = leftSkippedIndicesList;
				_seamlessElevationData.rightSkippedIndicesList = rightSkippedIndicesList;
				_seamlessElevationData.topSkippedIndicesList = topSkippedIndicesList;
				_seamlessElevationData.bottomSkippedIndicesList = bottomSkippedIndicesList;
				_seamlessElevationData.indicesCombinations = indicesCombinations;
				
				
			} else {
				baseIndicesList = _seamlessElevationData.baseIndicesList;
				leftIndicesList = _seamlessElevationData.leftIndicesList;
				rightIndicesList = _seamlessElevationData.rightIndicesList;
				topIndicesList = _seamlessElevationData.topIndicesList;
				bottomIndicesList = _seamlessElevationData.bottomIndicesList;
				leftSkippedIndicesList = _seamlessElevationData.leftSkippedIndicesList;
				rightSkippedIndicesList = _seamlessElevationData.rightSkippedIndicesList;
				topSkippedIndicesList = _seamlessElevationData.topSkippedIndicesList;
				bottomSkippedIndicesList = _seamlessElevationData.bottomSkippedIndicesList;
				indicesCombinations = _seamlessElevationData.indicesCombinations;
			}
			
			
			_vertices = fullVertices;
			_indices = indices;

			_seamlessElevationData.uvs = _uvs.concat();
			_seamlessElevationData.actualVertices = actualVertices.concat();
			_seamlessElevationData.indicesList = indicesList.concat();
			
			
			_seamlessElevationData.fullVertices = fullVertices.concat();
			_seamlessElevationData.vertices = _seamlessElevationData.fullVertices;
			
			_subGeometry.updateUVData(_seamlessElevationData.uvs);
			_subGeometry.updateVertexData(_seamlessElevationData.actualVertices);
			_subGeometry.updateIndexData(_seamlessElevationData.indicesList[_LODs - 1]);

			
			setForRender();
		}
		
		private function computeNormals(topVecHeight:Number, bottomVecHeight:Number, leftVecHeight:Number, rightVecHeight:Number, width:Number, heightScale:Number):Vector3D {
			
			
			var rightHeight:Number = rightVecHeight;
			var leftHeight:Number = leftVecHeight;
			var bottomHeight:Number = bottomVecHeight;
			var topHeight:Number = topVecHeight;
			
			var pointWidth:Number = _width / _segments;
			
			var c1:Vector3D = new Vector3D(pointWidth, 0, _height*(rightHeight - leftHeight));
			var c2:Vector3D = new Vector3D(0, pointWidth, _height*(bottomHeight - topHeight));	
			c1.normalize();
			c2.normalize();
			
			var cross1:Vector3D = c1.crossProduct(c2);
			cross1.normalize();
			
			var swizZ:Number = cross1.z;
			var swizY:Number = cross1.y;
			
			cross1.y = swizZ;
			cross1.z = swizY;

			return cross1;
		}
		
		public function setForRender():void {
			
			_updateNormalsByGPU = false;
			
			if (_updateNormalsByGPU == false || actualNormals == null) {
			
			updateVertexNormals();
			
			actualNormals = new Vector.<Number>(actualVertices.length, true);
			normalCount = 0;
			
			sqrootNorms = (Math.sqrt(_vertexNormals.length / 3) - 1);

			vertNum = 0;
			var index:uint;
			
			for (var i:uint = 0; i<_segmentsH + 1; i++) {
				for (var j:uint = 0; j<_segmentsW + 1; j++) {
					
					if (i !== 0 && j !== 0 && i !== sqrootNorms && j !== sqrootNorms) {
						
						vertNum = j*3 + i*(_segmentsH + 1)*3;
						
						actualNormals[normalCount++] = _vertexNormals[vertNum ++];
						actualNormals[normalCount++] = _vertexNormals[vertNum ++];
						actualNormals[normalCount++] = _vertexNormals[vertNum ++];
					
					}
				}
			}
			
			_seamlessElevationData.actualNormals = actualNormals.concat();
			_subGeometry.updateVertexNormalData(_seamlessElevationData.actualNormals);
			}
			normal = _seamlessElevationData.actualNormals;
			_vertices = _seamlessElevationData.actualVertices;
			_indices = _seamlessElevationData.indicesList[_LODs - 1];
			
			_subGeometry.autoDeriveVertexNormals = false;
			_subGeometry.updateVertexTangentData(_subGeometry.vertexTangentData);
			_subGeometry.autoDeriveVertexTangents = false;
			
		}

		private function rotatePointByAxis(point:Vector3D, degrees:Number, axis:Vector3D):Vector3D {
			
			
			if (degrees == 270  && axis == Vector3D.X_AXIS) {rotatedPoint.x = point.x; rotatedPoint.y = point.z; rotatedPoint.z = -point.y;}
			else if (degrees == 90  && axis == Vector3D.X_AXIS) {rotatedPoint.x = point.x; rotatedPoint.y = -point.z; rotatedPoint.z = point.y;}
			else if (degrees == 90  && axis == Vector3D.Z_AXIS) {rotatedPoint.x = -point.y; rotatedPoint.y = point.x; rotatedPoint.z = point.z;}
			else if (degrees == 270  && axis == Vector3D.Z_AXIS) {rotatedPoint.x = point.y; rotatedPoint.y = -point.x; rotatedPoint.z = point.z;}
			else {rotatedPoint = point;}
			return rotatedPoint;
			
		}
		
		private function rotatePointByFace(point:Vector3D):Vector3D {

			if (_faceNum == 0) {rotatedPoint = point;}
			else if (_faceNum == 1) {rotatedPoint.x = point.x; rotatedPoint.y = point.z; rotatedPoint.z = -point.y;}
			else if (_faceNum == 2) {rotatedPoint.x = point.x; rotatedPoint.y = -point.y; rotatedPoint.z = -point.z;}
			else if (_faceNum == 3) {rotatedPoint.x = point.x; rotatedPoint.y = -point.z; rotatedPoint.z = point.y;}
			else if (_faceNum == 4) {rotatedPoint.x = -point.y; rotatedPoint.y = point.x; rotatedPoint.z = point.z;}
			else {rotatedPoint.x = point.y; rotatedPoint.y = -point.x; rotatedPoint.z = point.z;}
			return rotatedPoint;

			
		}
		
		private function updateFaceNormals() : void
		{
			var i : uint, j : uint, k : uint;
			var index : uint;
			var len : uint = _indices.length;
			var x1 : Number, x2 : Number, x3 : Number;
			var y1 : Number, y2 : Number, y3 : Number;
			var z1 : Number, z2 : Number, z3 : Number;
			var dx1 : Number, dy1 : Number, dz1 : Number;
			var dx2 : Number, dy2 : Number, dz2 : Number;
			var cx : Number, cy : Number, cz : Number;
			var d : Number;
			
			_faceNormalsData = new Vector.<Number>(len, true);
			
			
			while (i < len) {
				index = _indices[i++]*3;
				x1 = _vertices[index++];
				y1 = _vertices[index++];
				z1 = _vertices[index];
				index = _indices[i++]*3;
				x2 = _vertices[index++];
				y2 = _vertices[index++];
				z2 = _vertices[index];
				index = _indices[i++]*3;
				x3 = _vertices[index++];
				y3 = _vertices[index++];
				z3 = _vertices[index];
				dx1 = x3-x1;
				dy1 = y3-y1;
				dz1 = z3-z1;
				dx2 = x2-x1;
				dy2 = y2-y1;
				dz2 = z2-z1;
				cx = dz1*dy2 - dy1*dz2;
				cy = dx1*dz2 - dz1*dx2;
				cz = dy1*dx2 - dx1*dy2;
				d = Math.sqrt(cx*cx+cy*cy+cz*cz);
				
				d = d == 0 ? d = 0.0000001 : d;
				d = 1/d;
				
				_faceNormalsData[j++] = cx*d;
				_faceNormalsData[j++] = cy*d;
				_faceNormalsData[j++] = cz*d;
			}

		}
		
		private function updateVertexNormals() : void
		{
			
			updateFaceNormals();
			
			var v1 : uint, v2 : uint, v3 : uint;
			var f1 : uint = 0, f2 : uint = 1, f3 : uint = 2;
			var lenV : uint = _vertices.length;
			
			_vertexNormals = new Vector.<Number>(_vertices.length, true);
			
			var i : uint, k : uint;
			var lenI : uint = _indices.length;
			var index : uint;
			
			while (i < lenI) {
				
				index = _indices[i++]*3;
				_vertexNormals[index++] += _faceNormalsData[f1];
				_vertexNormals[index++] += _faceNormalsData[f2];
				_vertexNormals[index] += _faceNormalsData[f3];
				
				index = _indices[i++]*3;
				_vertexNormals[index++] += _faceNormalsData[f1];
				_vertexNormals[index++] += _faceNormalsData[f2];
				_vertexNormals[index] += _faceNormalsData[f3];
				
				index = _indices[i++]*3;
				_vertexNormals[index++] += _faceNormalsData[f1];
				_vertexNormals[index++] += _faceNormalsData[f2];
				_vertexNormals[index] += _faceNormalsData[f3];
				
				f1 += 3;
				f2 += 3;
				f3 += 3;
			}
			
			v1 = 0; v2 = 1; v3 = 2;
			var vx : Number;
			var vy : Number;
			var vz : Number;
			var d : Number;
			
			while (v1 < lenV) {
				vx = _vertexNormals[v1];
				vy = _vertexNormals[v2];
				vz = _vertexNormals[v3];
				d = 1.0/Math.sqrt(vx*vx+vy*vy+vz*vz);
				_vertexNormals[v1] *= d;
				_vertexNormals[v2] *= d;
				_vertexNormals[v3] *= d;
				
				v1 += 3;
				v2 += 3;
				v3 += 3;
			}
			
		}
		private function updateFaceTangents() : void
		{
			var i : uint, j : uint;
			var index1 : uint, index2 : uint, index3 : uint;
			var len : uint = indicesList[_LODs - 1].length;
			var ui : uint, vi : uint;
			var v0 : Number;
			var dv1 : Number, dv2 : Number;
			var denom : Number;
			var x0 : Number, y0 : Number, z0 : Number;
			var dx1 : Number, dy1 : Number, dz1 : Number;
			var dx2 : Number, dy2 : Number, dz2 : Number;
			var cx : Number, cy : Number, cz : Number;
			var invScale : Number = 1;
			
			_faceTangents = new Vector.<Number>(indicesList[_LODs - 1].length, true);
			
			while (i < len) {
				index1 = _indices[i++];
				index2 = _indices[i++];
				index3 = _indices[i++];
				
				v0 = _uvs[uint((index1 << 1) + 1)];
				ui = index2 << 1;
				dv1 = (_uvs[uint((index2 << 1) + 1)] - v0)*invScale;
				ui = index3 << 1;
				dv2 = (_uvs[uint((index3 << 1) + 1)] - v0)*invScale;
				
				vi = index1*3;
				x0 = _vertices[vi];
				y0 = _vertices[uint(vi+1)];
				z0 = _vertices[uint(vi+2)];
				vi = index2*3;
				dx1 = _vertices[uint(vi)] - x0;
				dy1 = _vertices[uint(vi+1)] - y0;
				dz1 = _vertices[uint(vi+2)] - z0;
				vi = index3*3;
				dx2 = _vertices[uint(vi)] - x0;
				dy2 = _vertices[uint(vi+1)] - y0;
				dz2 = _vertices[uint(vi+2)] - z0;
				
				cx = dv2*dx1 - dv1*dx2;
				cy = dv2*dy1 - dv1*dy2;
				cz = dv2*dz1 - dv1*dz2;
				denom = 1/Math.sqrt(cx*cx + cy*cy + cz*cz);
				
				_faceTangents[j++] = denom*cx;
				_faceTangents[j++] = denom*cy;
				_faceTangents[j++] = denom*cz;
			}

		}
		
		private function updateVertexTangents() : void
		{

			updateFaceTangents();
			
			var v1 : uint, v2 : uint, v3 : uint;
			var f1 : uint = 0, f2 : uint = 1, f3 : uint = 2;
			var lenV : uint = _vertices.length;
			
			_vertexTangents = new Vector.<Number>(_vertices.length, true);
			
			var i : uint, k : uint;
			var lenI : uint = _indices.length;
			var index : uint;
			var weight : uint;
			
			while (i < lenI) {
				weight = _useFaceWeights? _faceWeights[k++] : 1;
				index = _indices[i++]*3;
				_vertexTangents[index++] += _faceTangents[f1]*weight;
				_vertexTangents[index++] += _faceTangents[f2]*weight;
				_vertexTangents[index] += _faceTangents[f3]*weight;
				index = _indices[i++]*3;
				_vertexTangents[index++] += _faceTangents[f1]*weight;
				_vertexTangents[index++] += _faceTangents[f2]*weight;
				_vertexTangents[index] += _faceTangents[f3]*weight;
				index = _indices[i++]*3;
				_vertexTangents[index++] += _faceTangents[f1]*weight;
				_vertexTangents[index++] += _faceTangents[f2]*weight;
				_vertexTangents[index] += _faceTangents[f3]*weight;
				f1 += 3;
				f2 += 3;
				f3 += 3;
			}
			
			v1 = 0; v2 = 1; v3 = 2;
			while (v1 < lenV) {
				var vx : Number = _vertexTangents[v1];
				var vy : Number = _vertexTangents[v2];
				var vz : Number = _vertexTangents[v3];
				var d : Number = 1.0/Math.sqrt(vx*vx+vy*vy+vz*vz);
				_vertexTangents[v1] *= d;
				_vertexTangents[v2] *= d;
				_vertexTangents[v3] *= d;
				v1 += 3;
				v2 += 3;
				v3 += 3;
			}

		}
		
		public function determineIndices():Vector.<uint> {
			
			if (!_edgeFormation) _edgeFormation = new Vector.<Boolean>(4, true);
			
			_lastEdgeFormation = new Vector.<Boolean>();
			_lastEdgeFormation = _lastEdgeFormation.concat(_edgeFormation);
			
			_edgeFormation[0] = _leftSector && _leftSector.LOD < _LOD;
			_edgeFormation[1] = _rightSector && _rightSector.LOD < _LOD;
			_edgeFormation[2] = _topSector && _topSector.LOD < _LOD;
			_edgeFormation[3] = _bottomSector && _bottomSector.LOD < _LOD;
			
			var index:uint = 0;
			
			if (_edgeFormation[3] == true) { index += 8; }
			if (_edgeFormation[2] == true) { index += 4; }
			if (_edgeFormation[1] == true) { index += 2; }
			if (_edgeFormation[0] == true) { index += 1; }
			
			return seamlessElevationData.indicesCombinations[_LOD][index];
			
		}
		public function updateLOD():void {
			
			var inds:Vector.<uint> = determineIndices();
			
			_indices = inds;
			
			_subGeometry.autoDeriveVertexNormals = false;
			_subGeometry.updateIndexData(inds);

			_LODDirty = false;
			_indicesDirty = false;
		}
		
		public function set LOD(value:uint):void {

			_LOD = value;
			_LODDirty = true;
			_indicesDirty = true;
			
			if (_leftSector) _leftSector.indicesDirty = true;
			if (_rightSector) _rightSector.indicesDirty = true;
			if (_topSector) _topSector.indicesDirty = true;
			if (_bottomSector) _bottomSector.indicesDirty = true;

		}
		
		 
		/**
		 * Invalidates the primitive's geometry, causing it to be updated when requested.
		 */
		protected function invalidateGeometry() : void
		{
			_geomDirty = true;
			invalidateBounds();
		}

		/**
		 * Invalidates the primitive's uv coordinates, causing them to be updated when requested.
		 */
		protected function invalidateUVs() : void
		{
			_uvDirty = true;
		}

		public function get heightMap() : BitmapData
		{
			var bmd:BitmapData = new BitmapData(_heightMapWidth, _heightMapHeight, false, 0);
			bmd.setVector(new Rectangle(0, 0, _heightMapWidth, _heightMapHeight), _heightMapData);
			
			return bmd;
		}
		
		public function get heightMapData():Vector.<uint> {
			return _heightMapData;
		}
		
		public function set heightMap(value : BitmapData) : void
		{
			_heightMap = value;
			_heightMapWidth = _heightMap.width;
			_heightMapHeight = _heightMap.height;
			_heightMapData = _heightMap.getVector(new Rectangle(0, 0, _heightMap.width, _heightMap.height));
			_seamlessElevationData.heightMap = value;
			_heightMap.dispose();
		}
		public function get vertices() : Vector.<Number>
		{
			return _vertices;
		}
		
		public function get sectorPosition() : Point
		{
			return _sectorPosition;
		}
		public function get segments() : uint
		{
			return _segments;
		}
		public function get size() : Number
		{
			return _size;
		}
		public function get LOD():uint {
			return _LOD;
		}
		public function get LODs():uint {
			return _LODs;
		}
		public function get highestPoint():Vector3D {
			return _highestPoint;
		}
		public function get leftSector():SeamlessElevation {
			return _leftSector;
		}
		public function set leftSector(value:SeamlessElevation):void {
			_leftSector = value;
		}
		public function get rightSector():SeamlessElevation {
			return _rightSector;
		}
		public function set rightSector(value:SeamlessElevation):void {
			_rightSector = value;
		}
		public function get topSector():SeamlessElevation {
			return _topSector;
		}
		public function set topSector(value:SeamlessElevation):void {
			_topSector = value;
		}
		public function get bottomSector():SeamlessElevation {
			return _bottomSector;
		}
		public function set bottomSector(value:SeamlessElevation):void {
			_bottomSector = value;
		}
		public function get faceNum():uint {
			return _faceNum;
		}
		public function get lowestColor():uint {
			return _lowestColor;
		}
		public function get highestColor():uint {
			return _highestColor;
		}
		public function get lowestElevation():Number {
			
			var cR:Number = _lowestColor >> 16 & 0xFF;
			var cG:Number = _lowestColor >> 8 & 0xFF;
			var h:Number = ((cR*256 + cG) / 0xFF) * (Number(_seamlessElevationData.height)) * (_seamlessElevationData.height / _seamlessElevationData.width);
			return h;
		}
		
		
		public function get points() : uint
		{
			return _visiblePoints;
		}
		public function get LODDirty():Boolean {
			return _LODDirty;
		}
		public function set LODDirty(value:Boolean):void {
			_LODDirty = value;
		}
		public function get indicesDirty():Boolean {
			return _indicesDirty;
		}
		public function set indicesDirty(value:Boolean):void {
			_indicesDirty = value;
		}
		public function get renderMaterial():MaterialBase {
			return _renderMaterial;
		}
		public function get seamlessElevationData():SeamlessElevationData { return _seamlessElevationData; }
		
		public function get uvs():Vector.<Number> { return _uvs; }
		public function set uvs(value:Vector.<Number>):void { _uvs = uvs; }
		
		public override function dispose():void {
			super.dispose();
			
			if (indicesList) indicesList = null;
			if (baseIndicesList) baseIndicesList = null;
			if (leftIndicesList) leftIndicesList = null;
			if (rightIndicesList) rightIndicesList = null;
			if (topIndicesList) topIndicesList = null;
			if (bottomIndicesList) bottomIndicesList = null;
			if (leftSkippedIndicesList) leftSkippedIndicesList = null;
			if (rightSkippedIndicesList) rightSkippedIndicesList = null;
			if (topSkippedIndicesList) topSkippedIndicesList = null;
			if (bottomSkippedIndicesList) bottomSkippedIndicesList = null;
			if (normal) normal = null;
			if (actualVertices) actualVertices = null;
			if (fullVertices) fullVertices = null;
			if (baseActualVertices) baseActualVertices = null;
			if (baseVertices) baseVertices = null;

			if (_heightMap) _heightMap = null;
			if (_heightMapData) _heightMapData = null;
			if (_activeMap) _activeMap = null;

			if (_vertices) _vertices = null;
			if (_vertexTangents) _vertexTangents = null;
			if (_faceTangents) _faceTangents = null;
			if ( _tangents) _tangents = null;
			if (_indices) _indices = null;
			if (_normals) _normals = null;

			if (_sectorPosition) _sectorPosition = null;
			if (_largeUVs) _largeUVs = null;
			if (_uvs) _uvs = null;
			if (_leftIndices) _leftIndices = null;
			if (_rightIndices) _rightIndices = null;
			if (_topIndices) _topIndices = null;
			if (_bottomIndices) _bottomIndices = null;
			if (_leftSkippedIndices) _leftSkippedIndices = null;
			if (_rightSkippedIndices) _rightSkippedIndices = null;
			if (_topSkippedIndices) _topSkippedIndices = null;
			if (_bottomSkippedIndices) _bottomSkippedIndices = null;
			if (_leftVertices) _leftVertices = null;
			if (_rightVertices) _rightVertices = null;
			if (_topVertices) _topVertices = null;
			if (_bottomVertices) _bottomVertices = null;
			if (_highestPoint) _highestPoint = null;
			if (_vertexNormals) _vertexNormals = null;
			if ( _faceWeights) _faceWeights = null;
			if (_faceNormalsData) _faceNormalsData = null;
			if (_leftSector) _leftSector = null;
			if (_rightSector) _rightSector = null;
			if ( _topSector) _topSector = null;
			if (_bottomSector) _bottomSector = null;
			if (_edgeFormation) _edgeFormation = null;
			if (_lastEdgeFormation) _lastEdgeFormation = null;
			if (actualNormals) actualNormals = null;
			
			if (rotPoint) rotPoint = null;
			if (rotVec) rotVec = null;
			if (rotVec2) rotVec2 = null;
			if (rotatedPoint) rotatedPoint = null;
			if (m) m = null;
			if (axis) axis = null;
			if (_renderMaterial) _renderMaterial = null;
			if (_seamlessElevationData) _seamlessElevationData = null;
			if (indicesCombinations) indicesCombinations = null;
			
		}
    }
}
