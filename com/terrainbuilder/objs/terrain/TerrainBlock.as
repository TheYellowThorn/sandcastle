/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.objs.terrain
{
	import com.terrainbuilder.dynamicterrain.utils.HeightMap16BitTools;
	import com.terrainbuilder.effects.WaterMaskMethod;
	import com.terrainbuilder.events.TerrainBlockEvent;
	import com.terrainbuilder.tools.BitmapUtils;
	
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.events.ProgressEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.materials.MaterialBase;
	import away3d.textures.BitmapTexture;

	public class TerrainBlock extends ObjectContainer3D
	{ 
		private var _elevations:Vector.<SeamlessElevation>;
		private var _waterElevations:Vector.<SeamlessElevation>;
		private var _elevationPoints:Vector.<Point>;
		private var _waterElevationPoints:Vector.<Point>;
		private var _tilesWide:uint;
		private var _tilesHigh:uint;
		private var _heightMapBitmapData:BitmapData;
		private var _waterMaskBitmapData:BitmapData;
		private var _material:MaterialBase;
		private var _waterMaterial:MaterialBase;
		private var _foamBitmapData:BitmapData;
		private var _hasWater:Boolean = false;
		public var heightMap16BitTools:HeightMap16BitTools = new HeightMap16BitTools();
		public var waterMaskMethod:WaterMaskMethod;
		public var eventDispatcher:TerrainBlockDispatcher = new TerrainBlockDispatcher();
		private var _waterHeight:uint;
		private var progressEvent:ProgressEvent;
		private var _usePerlinNoise:Boolean;
		private var _elevationData:SeamlessElevationData;
		private var _waterElevationData:SeamlessElevationData;
		private var _defaultTerrainHeight:uint;
		private var _defaultWaterHeight:uint;
		private var _perlinSeed:uint;
		private var _currentElevationCreationIndex:uint = 0;
		private var _currentWaterElevationCreationIndex:uint = 0;
		private var seamlessHeightMap:BitmapData;
		private var _lastElevationComplete:Boolean = true;
		private var _lastWaterElevationComplete:Boolean = true;
		private var _loading:Boolean = false;
		private var _elevationsInView:Vector.<SeamlessElevation> = new Vector.<SeamlessElevation>();
		public var maxDisplayedSeamlessElevationTiles:uint;
		public var LODDistances:Vector.<Number> = Vector.<Number>([1280*40, 1280*20, 1280*12, 1280*8, 1280*1.5, 1280/2]);
 
		public function TerrainBlock(material:MaterialBase, waterMaterial:MaterialBase, tilesWide:uint, tilesHigh:uint)
		{
			_material = material;
			_waterMaterial = waterMaterial;
			_tilesWide = tilesWide;
			_tilesHigh = tilesHigh;
			
			eventDispatcher.parent = this;
			eventDispatcher.addEventListener(TerrainBlockEvent.ON_ELEVATION_COMPLETE, onElevationComplete);
			eventDispatcher.addEventListener(TerrainBlockEvent.ON_WATER_ELEVATION_COMPLETE, onWaterElevationComplete);
			
		}
		
		public function createTerrain(elevationData:SeamlessElevationData, defaultTerrainHeight:uint = 16451, waterElevationData:SeamlessElevationData = null, defaultWaterHeight:uint = 16384, usePerlinNoise:Boolean = false, perlinSeed:uint = 100, sharedHeightMapBitmapData:BitmapData = null):void {
			
			_loading = true;
			
			_elevationData = elevationData;
			_waterElevationData = waterElevationData;
			_defaultTerrainHeight = defaultTerrainHeight;
			_defaultWaterHeight = defaultWaterHeight;
			_usePerlinNoise = usePerlinNoise;
			_perlinSeed = perlinSeed;
			_elevations = new Vector.<SeamlessElevation>();
			_waterElevations = new Vector.<SeamlessElevation>();
			_elevationPoints = new Vector.<Point>();
			_waterElevationPoints = new Vector.<Point>();
			
			if (waterElevationData) { _hasWater = true; }
			
			
			var seamlessElevation:SeamlessElevation;
			var seamlessElevationData:SeamlessElevationData = _elevationData;
			var tempHeightMap:BitmapData;
			
			seamlessHeightMap = new BitmapData(131, 131, true, 0xFF404040);

			for (var i:uint = 0; i<_tilesHigh; i++) {
				for (var j:uint = 0; j<_tilesWide; j++) {
					_elevationPoints.push(new Point(j, i));
				}
			}
			
			if (waterElevationData) {
				for (i = 0; i<tilesHigh; i++) {
					for (j = 0; j<tilesWide; j++) {
						_waterElevationPoints.push(new Point(j, i));
					}
				}
			}
			
			progressEvent = new ProgressEvent(ProgressEvent.PROGRESS, false, false, 0, 1);
			eventDispatcher.dispatchEvent(progressEvent);
			
			_currentElevationCreationIndex = 0;
			createElevation(sharedHeightMapBitmapData);
		}
		
		public function createElevation(sharedHeightMapBitmapData:BitmapData = null):void {
			
			_lastElevationComplete = false;
			
			var point:Point = _elevationPoints[_currentElevationCreationIndex];
			var j:uint = point.x;
			var i:uint = point.y;
			
			if (i == 0 && j == 0) {
				_elevationData.heightMap = new BitmapData(131, 131, true, 0xFF400000);
				_elevationData.tilesWide = _tilesWide;
				_elevationData.tilesHigh = _tilesHigh;
				_elevationData.currentLOD = 6;
				_elevationData.maxElevation = 256*256 - 1;
				_elevationData.minElevation = 0;
				_elevationData.buildGeometryOnInit = true;
				_elevationData.updateGeometryOnInit = false;
				_elevationData.lowestYPosition = -_elevationData.width*0.35;
				_elevationData.positionOffsetX = 0; //NEEDED FOR TERRAIN SHADER BLEND MAPPING
				_elevationData.positionOffsetZ = 0; //NEEDED FOR TERRAIN SHADER BLEND MAPPING
				
				var r:uint = _defaultTerrainHeight >> 8;
				var g:uint = _defaultTerrainHeight - r * 256;
				var heightMapColor:uint = 0xFF << 24 | r << 16 | g << 8 | 0;
	
				if (!sharedHeightMapBitmapData) {
					_heightMapBitmapData = new BitmapData(tilesWide * 128 + 3, tilesWide * 128 + 3, true, heightMapColor);
				} else {
					_heightMapBitmapData = sharedHeightMapBitmapData;
				}
				_waterMaskBitmapData = new BitmapData(tilesWide * 128, tilesWide * 128, true, 0xFF000000);
				_elevationData.sharedHeightMapBitmapData = _heightMapBitmapData;
				_elevationData.sharedWaterMaskBitmapData = _waterMaskBitmapData;
			}
			
			var seamlessElevation:SeamlessElevation;
			var seamlessElevationData:SeamlessElevationData;
			var tempHeightMap:BitmapData;
			
			
			if (i == 0 && j == 0) {
				seamlessElevationData = _elevationData;
				seamlessHeightMap = new BitmapData(131, 131, true, 0xFF404040);
			
				if (!sharedHeightMapBitmapData && _usePerlinNoise) {
					var offsets:Array = null;
					var bmd:BitmapData = new BitmapData(tilesWide * 128 + 3, tilesWide * 128 + 3, true, 0);
					bmd.perlinNoise(64, 64, 6, _perlinSeed, false, true, BitmapDataChannel.GREEN, false, offsets);
					_elevationData.sharedHeightMapBitmapData.copyChannel(bmd, bmd.rect, new Point(), BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);
					bmd.dispose();
				}
			
				var tempWaterMaskBitmapData:BitmapData = new BitmapData(_elevationData.sharedHeightMapBitmapData.width - 2, _elevationData.sharedHeightMapBitmapData.height - 2, true, 0xFF000000);
				tempWaterMaskBitmapData.copyPixels(_elevationData.sharedHeightMapBitmapData, new Rectangle(1, 1, tempWaterMaskBitmapData.width, tempWaterMaskBitmapData.height), new Point());
				_elevationData.sharedWaterMaskBitmapData = heightMap16BitTools.createAveraged16BitBitmapData(tempWaterMaskBitmapData);
				tempWaterMaskBitmapData.dispose();
				
			}
			
			
			if (!(i == 0 && j == 0)) {
				seamlessElevation = _elevations[_currentElevationCreationIndex - 1];
				seamlessElevationData = seamlessElevation.seamlessElevationData.clone();
				seamlessElevationData.updateGeometryOnInit = true;
				
				seamlessElevationData.worldGridPosition = new Point(j, i);
				seamlessElevationData.material = _material;	
			}
			
			
			
			tempHeightMap = new BitmapData(seamlessHeightMap.width, seamlessHeightMap.height, true, 0xFF000000);
			tempHeightMap.copyPixels(_elevationData.sharedHeightMapBitmapData, new Rectangle(j*128, (tilesHigh - 1 - i)*128, tempHeightMap.width, tempHeightMap.height), new Point());
			tempHeightMap = BitmapUtils.flipBitmap(tempHeightMap.clone(), false, true,  true, StageQuality.HIGH);
			seamlessElevationData.heightMap = tempHeightMap;
			
			seamlessElevation = new SeamlessElevation(seamlessElevationData); 
			seamlessElevation.x = 0;
			seamlessElevation.y = seamlessElevationData.lowestYPosition;
			seamlessElevation.z = 0;
			seamlessElevation.castsShadows = true;
			seamlessElevation.rotationX = 0;
			
			seamlessElevation.updateGeometry(seamlessElevation.heightMap.rect, true, true, true);
			
			addChild(seamlessElevation);
			
			seamlessElevation.material = _material;

			_elevations.push(seamlessElevation);
			
			if (j > 0) {
				seamlessElevation.leftSector = _elevations[_elevations.length - 2];
				_elevations[_elevations.length - 2].rightSector = seamlessElevation;
			}
			if (i > 0) {
				seamlessElevation.bottomSector = _elevations[_elevations.length - 1 - tilesHigh];
				_elevations[_elevations.length - 1 - tilesHigh].topSector = seamlessElevation;
			}

			var elevationCompleteEvent:TerrainBlockEvent = new TerrainBlockEvent(TerrainBlockEvent.ON_ELEVATION_COMPLETE);
			eventDispatcher.dispatchEvent(elevationCompleteEvent);

		}
		
		public function createWaterElevation():void {
			
			_lastWaterElevationComplete = false;
			
			var point:Point = _waterElevationPoints[_currentWaterElevationCreationIndex];
			var j:uint = point.x;
			var i:uint = point.y;
			
			var seamlessElevation:SeamlessElevation;
			var seamlessElevationData:SeamlessElevationData;
			var tempHeightMap:BitmapData;
			
			_waterHeight = _defaultWaterHeight;
			
			var r:uint = _defaultWaterHeight >> 8;
			var g:uint = _defaultWaterHeight - r * 256;
			var waterMapColor:uint = 0xFF << 24 | r << 16 | g << 8 | 0;
			var seamlessOceanHeightMap:BitmapData = new BitmapData(seamlessHeightMap.width, seamlessHeightMap.height, true, waterMapColor);
			
			if (i == 0 && j == 0) {
				
				_waterElevationData.isOcean = true;
				_waterElevationData.tilesWide = _tilesWide;
				_waterElevationData.tilesHigh = _tilesHigh;
				_waterElevationData.material = _waterMaterial;
				_waterElevationData.heightMap = seamlessOceanHeightMap.clone();
				_waterElevationData.currentLOD = 6;
				_waterElevationData.maxElevation = 256*256 - 1;
				_waterElevationData.minElevation = 0;
				_waterElevationData.buildGeometryOnInit = true;
				_waterElevationData.updateGeometryOnInit = false;
				_waterElevationData.lowestYPosition = -_waterElevationData.width*0.35;
				_waterElevationData.sharedHeightMapBitmapData = _elevations[0].seamlessElevationData.sharedHeightMapBitmapData;
				_waterElevationData.sharedWaterMaskBitmapData = _elevations[0].seamlessElevationData.sharedWaterMaskBitmapData;
				
				seamlessElevationData = _waterElevationData;
			}
					
			if (!(i == 0 && j == 0)) {  
				seamlessElevation = _waterElevations[_currentWaterElevationCreationIndex - 1];
				seamlessElevationData = seamlessElevation.seamlessElevationData.clone();
				seamlessElevationData.updateGeometryOnInit = true;
				seamlessElevationData.worldGridPosition = new Point(j, i);
				seamlessElevationData.material = _waterMaterial;
				seamlessElevationData.heightMap = seamlessOceanHeightMap.clone();
			}
					
			seamlessElevation = new SeamlessElevation(seamlessElevationData);
			seamlessElevation.x = 0;
			seamlessElevation.y = seamlessElevationData.lowestYPosition;
			seamlessElevation.z = 0;
			seamlessElevation.castsShadows = false;
			seamlessElevation.rotationX = 0;
					
			seamlessElevation.updateGeometry(seamlessElevation.heightMap.rect, true, true, true);
			
			addChild(seamlessElevation);
			
			_waterElevations.push(seamlessElevation);
					
			seamlessElevation.LOD = 2;
			seamlessElevation.updateLOD();
					
			seamlessElevation.bounds.fromExtremes(seamlessElevation.bounds.min.x, seamlessElevation.bounds.min.y, seamlessElevation.bounds.min.z, seamlessElevation.bounds.max.x, seamlessElevation.bounds.max.y + 100 + 100, seamlessElevation.bounds.max.z);
					
			var elevationCompleteEvent:TerrainBlockEvent = new TerrainBlockEvent(TerrainBlockEvent.ON_WATER_ELEVATION_COMPLETE);
			eventDispatcher.dispatchEvent(elevationCompleteEvent);
	
		}
		
		private function onElevationComplete(e:TerrainBlockEvent):void {
			
			_lastElevationComplete = true;
			
			progressEvent = new ProgressEvent(ProgressEvent.PROGRESS, false, false, getProgress(), 1);
			eventDispatcher.dispatchEvent(progressEvent);
			
			_currentElevationCreationIndex++;
			if (_currentElevationCreationIndex >= _elevationPoints.length) {
				if (!_hasWater) { _loading = false; }
				else if (_currentWaterElevationCreationIndex >= _waterElevationPoints.length) {
					_loading = false;
				}
			}
			
		}
		
		private function onWaterElevationComplete(e:TerrainBlockEvent):void {
			
			_lastWaterElevationComplete = true;
			
			progressEvent = new ProgressEvent(ProgressEvent.PROGRESS, false, false, getProgress(), 1);
			eventDispatcher.dispatchEvent(progressEvent);
			
			_currentWaterElevationCreationIndex++;
			if (_currentWaterElevationCreationIndex >= _waterElevationPoints.length) {
				_loading = false;
			}
			
		}
		
		public function update(view:View3D, stage:Stage, forceUpdate:Boolean = true):void {
			
			var distanceElevations:Array = new Array();
			var elevationsInView:Vector.<SeamlessElevation> = new Vector.<SeamlessElevation>();
			var elevationsNotInView:Vector.<SeamlessElevation> = new Vector.<SeamlessElevation>();
			for (var i:uint = 0; i<_elevations.length; i++) {
				
				var bottomLeftPosition:Vector3D = getElevationWorldPositionVertex(_elevations[i], 0, 0);
				var topRightPosition:Vector3D = getElevationWorldPositionVertex(_elevations[i], _elevations[i].indicesList[0].length - 2, 0);
				var topLeftPosition:Vector3D = getElevationWorldPositionVertex(_elevations[i], _elevations[i].indicesList[0].length - 23, 0);
				var bottomRightPosition:Vector3D = getElevationWorldPositionVertex(_elevations[i], 21, 0);
				
				var stage2DPos1:Vector3D = view.project(bottomLeftPosition); //BOTTOM LEFT CORNER
				var stage2DPos2:Vector3D = view.project(topRightPosition); //TOP RIGHT CORNER
				var stage2DPos3:Vector3D = view.project(topLeftPosition); //TOP LEFT CORNER
				var stage2DPos4:Vector3D = view.project(bottomRightPosition); //BOTTOM RIGHT CORNER
				var insideStageRect:Rectangle = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
				
				var positionVec:Vector.<Vector3D> = new Vector.<Vector3D>();
				positionVec.push(stage2DPos2);
				positionVec.push(stage2DPos3);
				positionVec.push(stage2DPos4);
				
				var minX:Number = stage2DPos1.x;
				var maxX:Number = stage2DPos1.x;
				var minY:Number = stage2DPos1.y;
				var maxY:Number = stage2DPos1.y;
				
				for (var j:uint = 0; j<positionVec.length; j++) {
					if (positionVec[j].x < minX) {minX = positionVec[j].x;}
					else if (positionVec[j].x > maxX) {maxX = positionVec[j].x;}
					if (positionVec[j].y < minY) {minY = positionVec[j].y;}
					else if (positionVec[j].y > maxY) {maxY = positionVec[j].y;}
				}
				
				if (maxX < insideStageRect.x || maxY < insideStageRect.y || minX > insideStageRect.width || minY > insideStageRect.height) {
					elevationsNotInView.push(_elevations[i]);
				} else {
					elevationsInView.push(_elevations[i]);
					
					var minDistanceFromCamera:Number; 
					var minDistance1:Number = Math.sqrt(Math.pow(bottomLeftPosition.x - view.camera.scenePosition.x, 2) + Math.pow(bottomLeftPosition.y - view.camera.scenePosition.y, 2) + Math.pow(bottomLeftPosition.z - view.camera.scenePosition.z, 2));
					var minDistance2:Number = Math.sqrt(Math.pow(topRightPosition.x - view.camera.scenePosition.x, 2) + Math.pow(topRightPosition.y - view.camera.scenePosition.y, 2) + Math.pow(topRightPosition.z - view.camera.scenePosition.z, 2));
					var minDistance3:Number = Math.sqrt(Math.pow(topLeftPosition.x - view.camera.scenePosition.x, 2) + Math.pow(topLeftPosition.y - view.camera.scenePosition.y, 2) + Math.pow(topLeftPosition.z - view.camera.scenePosition.z, 2));
					var minDistance4:Number = Math.sqrt(Math.pow(bottomRightPosition.x - view.camera.scenePosition.x, 2) + Math.pow(bottomRightPosition.y - view.camera.scenePosition.y, 2) + Math.pow(bottomRightPosition.z - view.camera.scenePosition.z, 2));
					
					minDistanceFromCamera = minDistance1 < minDistance2 ? minDistance1 : minDistance2;
					minDistanceFromCamera = minDistanceFromCamera < minDistance3 ? minDistanceFromCamera : minDistance3;
					minDistanceFromCamera = minDistanceFromCamera < minDistance4 ? minDistanceFromCamera : minDistance4;
					distanceElevations.push({ "distance" : minDistanceFromCamera, "seamlessElevation" : _elevations[i]});
				}
				
				
			}
			
			distanceElevations.sortOn("distance", Array.NUMERIC);
			
			if ((this.loading) || forceUpdate) {			
				
				_elevationsInView = new Vector.<SeamlessElevation>();
				var elevationsToChange:Vector.<SeamlessElevation> = new Vector.<SeamlessElevation>();
		
				for (i = 0; i<_elevations.length; i++) {
					var seamlessElevation:SeamlessElevation = _elevations[i];
					
					if (elevationsInView.indexOf(_elevations[i]) !== -1) { //Only update LOD for elevations on screen
						
						var avgBounds:Vector3D = new Vector3D((seamlessElevation.bounds.min.x + seamlessElevation.bounds.max.x) / 2, (seamlessElevation.bounds.min.y + seamlessElevation.bounds.max.y) / 2, (seamlessElevation.bounds.min.z + seamlessElevation.bounds.max.z) / 2);
						var cameraDistance:Number;
						
						cameraDistance = Math.sqrt(Math.pow(view.camera.x - (avgBounds.x + _elevations[i].position.x), 2) + Math.pow(view.camera.y - (avgBounds.y + _elevations[i].position.y), 2) + Math.pow(view.camera.z - (avgBounds.z + _elevations[i].position.z), 2));
						
						var lod:uint = seamlessElevation.LOD;
						for (j = 0; j<LODDistances.length; j++) {
							if (cameraDistance >= LODDistances[j]) {
								lod = j;
								break;
							}
						}
						if (seamlessElevation.LOD !== lod) {
							seamlessElevation.LOD = lod;
							elevationsToChange.push(seamlessElevation);
						}
					}
				}
				
				var elevationsToChangeClone:Vector.<SeamlessElevation> = elevationsToChange.concat();
				
				for (i = 0; i<elevationsToChangeClone.length; i++) {
					if (elevationsToChange[i].leftSector && elevationsToChange.indexOf(elevationsToChange[i].leftSector) == -1) { elevationsToChange.push(elevationsToChangeClone[i].leftSector); }//updateWireframe(elevationsToChange[i]); }
					if (elevationsToChange[i].rightSector && elevationsToChange.indexOf(elevationsToChange[i].rightSector) == -1) { elevationsToChange.push(elevationsToChangeClone[i].rightSector); }//updateWireframe(elevationsToChange[i]); }
					if (elevationsToChange[i].topSector && elevationsToChange.indexOf(elevationsToChange[i].topSector) == -1) { elevationsToChange.push(elevationsToChangeClone[i].topSector); }//updateWireframe(elevationsToChange[i]); }
					if (elevationsToChange[i].bottomSector && elevationsToChange.indexOf(elevationsToChange[i].bottomSector) == -1) { elevationsToChange.push(elevationsToChangeClone[i].bottomSector); }//updateWireframe(elevationsToChange[i]); }
				}
				for (i = 0; i<elevationsToChange.length; i++) {
					elevationsToChange[i].updateLOD();
				}
				
				var count:uint = 0;
				for (i = 0; i<distanceElevations.length; i++) {
					var index:int = _elevations.indexOf(distanceElevations[i].seamlessElevation);
					var notInViewIndex:int = elevationsNotInView.indexOf(distanceElevations[i].seamlessElevation);
					
					if (notInViewIndex == -1 && count < this.maxDisplayedSeamlessElevationTiles) {
						
						_elevationsInView.push(_elevations[index]);
						_elevations[index].visible = true;
						if (_waterElevations && _waterElevations.length > index) { 
							_waterElevations[index].visible = _elevations[index].lowestElevation < _waterElevations[index].lowestElevation;
						}
						
						count++;
					} else {
						_elevations[index].visible = false;
						if (_waterElevations && _waterElevations.length > index) _waterElevations[index].visible = false;
					}
				}
					
				
			}
			
			var terrainBlockUpdatedEvent:TerrainBlockEvent = new TerrainBlockEvent(TerrainBlockEvent.ON_TERRAIN_BLOCK_UPDATED);
			eventDispatcher.dispatchEvent(terrainBlockUpdatedEvent);
			
		}
		
		private function getElevationWorldPositionVertex(mesh:SeamlessElevation, vtxIndex:uint, subgIndex:uint = 0): Vector3D
		{
			var iData:Vector.<uint> = mesh.indicesList[0];
			var vData:Vector.<Number> = mesh.geometry.subGeometries[subgIndex].vertexData;
			var vtx:Vector3D = new Vector3D(vData[iData[vtxIndex]*3], vData[iData[vtxIndex]*3 + 1], vData[iData[vtxIndex]*3 + 2]);
			vtx =  mesh.sceneTransform.transformVector(vtx)
			return vtx;
		} 
		
		public function autoLoad(scene:Scene3D):void {
			
			if (this.loading && this.lastElevationComplete && this.lastWaterElevationComplete) {
				
				if (this.hasWater) {
					
					if (this.currentWaterElevationCreationIndex < this.waterElevationPoints.length) {
						
						if (this.currentWaterElevationCreationIndex == 1) {
							scene.addChild(this);
						}
						
						this.createWaterElevation();
					}
				}
				
				
				if (this.currentElevationCreationIndex < this.elevationPoints.length) {
					this.createElevation();
				}
				
			}
		}
		
		public function getProgress():Number {
			var progress:Number;
			progress = _hasWater ? (_elevations.length + _waterElevations.length) / (2 * _tilesHigh * _tilesWide) : _elevations.length / (_tilesHigh * _tilesWide);
			return progress;
		}
		
		public function get hasWater():Boolean { return _hasWater; }
		
		public function get material():MaterialBase { return _material; }
		public function set material(value:MaterialBase):void { 
			_material = value;
			for (var i:uint = 0; i<_elevations.length; i++) {
				_elevations[i].material = _material;
			}
		}
		public function get waterMaterial():MaterialBase { return _waterMaterial; }
		public function set waterMaterial(value:MaterialBase):void { 
			_waterMaterial = value;
			for (var i:uint = 0; i<_waterElevations.length; i++) {
				_waterElevations[i].material = _material;
			}
		}
		public function get tilesWide():uint { return _tilesWide; }
		public function get tilesHigh():uint { return _tilesHigh; }
		public function get elevations():Vector.<SeamlessElevation> { return _elevations; }
		public function get waterElevations():Vector.<SeamlessElevation> { return _waterElevations; }
		public function get foamBitmapData():BitmapData { return _foamBitmapData; }
		public function set foamBitmapData(value:BitmapData):void { 
			_foamBitmapData = value; 
			if (waterMaskMethod) { waterMaskMethod.whiteCapTexture = new BitmapTexture(_foamBitmapData); }
		}
		public function get waterHeight():uint { return _waterHeight; }
		public function get currentElevationCreationIndex():uint { return _currentElevationCreationIndex; }
		public function get currentWaterElevationCreationIndex():uint { return _currentWaterElevationCreationIndex; }
		public function get elevationPoints():Vector.<Point> { return _elevationPoints; }
		public function get waterElevationPoints():Vector.<Point> { return _waterElevationPoints; }
		public function get lastElevationComplete():Boolean { return _lastElevationComplete; }
		public function get lastWaterElevationComplete():Boolean { return _lastWaterElevationComplete; }
		public function get loading():Boolean { return _loading; }
		
		public function get defaultTerrainHeight():uint { return _defaultTerrainHeight; }
		public function get defaultWaterHeight():uint { return _defaultWaterHeight; }
		
		public function get elevationsInView():Vector.<SeamlessElevation> { return _elevationsInView; }
		
		public override function dispose():void {
			super.dispose();
			
			for (var i:uint = 0; i<_elevations.length; i++) {
				if (this.contains(_elevations[i])) { removeChild(_elevations[i]); }
				_elevations[i].dispose();
				
				if (_waterElevations.length > i) {
					if (this.contains(_waterElevations[i])) { removeChild(_waterElevations[i]); }
					_waterElevations[i].dispose();
				}
			}
			
			_elevations = null;
			_waterElevations = null;
			_elevationPoints = null;
			_waterElevationPoints = null;
			_heightMapBitmapData = null;
			_waterMaskBitmapData = null;
			_material = null;
			_waterMaterial = null;
			if (_foamBitmapData) _foamBitmapData.dispose();
			heightMap16BitTools = null;
			waterMaskMethod = null;
			eventDispatcher = null;
			if (_elevationData) _elevationData = null;
			if (_waterElevationData) _waterElevationData = null;
			if (seamlessHeightMap) seamlessHeightMap = null;
			_elevationsInView = null;
			LODDistances = null;
		}
		
	}
}