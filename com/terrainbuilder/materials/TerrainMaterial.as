/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.materials
{
	import com.terrainbuilder.effects.objs.SplatData;
	import com.terrainbuilder.materials.objs.TerrainMethodData;
	import com.terrainbuilder.materials.passes.FogPass;
	import com.terrainbuilder.materials.passes.TerrainPass;
	import com.terrainbuilder.objs.terrain.SeamlessElevationData;
	
	import flash.display.BitmapData;
	
	import away3d.materials.MaterialBase;
	import away3d.materials.passes.MaterialPassBase;

	public class TerrainMaterial extends MaterialBase
	{
		private var _textureSplatDatas:Vector.<SplatData>;
		private var _splatDatas:Vector.<SplatData>;
		private var _splatDataGroups:Vector.<Vector.<SplatData>> = new Vector.<Vector.<SplatData>>();
		private var _maxSplatDatasPerPass:uint = 3;
		private var _terrainMethodData:TerrainMethodData;
		private var _normalMapStrength:Number = 0.5;
		private var _useNormalMaps:Boolean = true;
		private var _fogEnabled:Boolean = false;
		private var _minimumFogDistance:Number = 2500;
		private var _maximumFogDistance:Number = 5000;
		private var _fogColor:uint = 0x9FBFCF;
		private var _showShadows:Boolean = false;
		
		private var _customPasses:Vector.<MaterialPassBase> = new Vector.<MaterialPassBase>();
		private var _selectorPass:MaterialPassBase;
		private var _fogPass:FogPass;
		
		
		public function TerrainMaterial(squaredTiles:uint, seamlessElevationData:SeamlessElevationData, anchorYPosition:Number, splatDatas:Vector.<SplatData>, tileData:Number = 4, smooth:Boolean = true, repeat:Boolean = false, mipmap:Boolean = true)
		{
			
			_textureSplatDatas = splatDatas;
			
			for (var i:uint = 0; i<_textureSplatDatas.length; i++) {
				
				if (_textureSplatDatas[i].normalMap !== null) {
					_maxSplatDatasPerPass = 3;
					break;
				}
				
			}
			
			_terrainMethodData = new TerrainMethodData();
			_terrainMethodData.heightMapSize = Math.sqrt(seamlessElevationData.heightMapData.length);
			_terrainMethodData.tileData = tileData;
			_terrainMethodData.squaredTiles = squaredTiles;
			_terrainMethodData.tileSize = seamlessElevationData.width;
			_terrainMethodData.height = seamlessElevationData.height;
			_terrainMethodData.maxHeight = (seamlessElevationData.maxElevation / 256) * seamlessElevationData.height;
			_terrainMethodData.anchorYPosition = anchorYPosition;
			_terrainMethodData.positionOffsetX = seamlessElevationData.positionOffsetX;
			_terrainMethodData.positionOffsetZ = seamlessElevationData.positionOffsetZ;
			_terrainMethodData.worldGridPosition = seamlessElevationData.worldGridPosition;
			_terrainMethodData.normalMapStrength = _normalMapStrength;
			_terrainMethodData.fogEnabled = _fogEnabled;
			_terrainMethodData.minimumFogDistance = _minimumFogDistance;
			_terrainMethodData.maximumFogDistance = _maximumFogDistance;
			_terrainMethodData.fogColor = _fogColor
			
			if (splatDatas.length < 1) throw Error("ColorMultiPassTerrain material requires at least one splat");
			
			for (i = 0; i<_textureSplatDatas.length; i++) {
				
				if (i % _maxSplatDatasPerPass == 0) {
					_splatDatas = new Vector.<SplatData>();
					_splatDataGroups.push(_splatDatas);
				}
				
				_splatDatas.push(_textureSplatDatas[i]);
			}
			
			for (i = 0; i<_splatDataGroups.length; i++) {
				
				var blendingRequired:Boolean = i == 0 ? false : true;
				
				addPass(new TerrainPass(_splatDataGroups[i], _terrainMethodData, blendingRequired));
			}
		}
		
		public function updateBlend(blend:BitmapData):void {
			
			var passIndex:int;
			
			for (var i:uint = 0; i<_passes.length; i++) {
				if (_passes[i] is TerrainPass) {
					var pass:TerrainPass = TerrainPass(_passes[i]);
					for (var j:uint = 0; j<pass.splatDatas.length; j++) {
						if (pass.splatDatas[j].blend == blend) {
							pass.updateBlend(j, blend);
						}
					}
				}
			}
		}
		
		public function updatePasses(clearTextures:Boolean = true):void {
			
			if (clearTextures) {
				for (var i:uint = 0; i<_passes.length; i++) {
					_passes[i].dispose();
				}
			}
			
			clearPasses();
			
			_passes = new Vector.<MaterialPassBase>();
			
			if (_useNormalMaps) {
				
				for (i = 0; i<_textureSplatDatas.length; i++) {
					
					if (_textureSplatDatas[i].normalMap !== null) {
						_maxSplatDatasPerPass = 3;
						break;
					}
					
				}
				
				var visibleSplatDatas:Vector.<SplatData> = new Vector.<SplatData>();
				for (i = 0; i<_textureSplatDatas.length; i++) {
					if (_textureSplatDatas[i].visible) {
						visibleSplatDatas.push(_textureSplatDatas[i]);
					}
				}
				
				_splatDataGroups = new Vector.<Vector.<SplatData>>();
				for (i = 0; i<visibleSplatDatas.length; i++) {
					
					if (i % _maxSplatDatasPerPass == 0) {
						_splatDatas = new Vector.<SplatData>();
						_splatDataGroups.push(_splatDatas);
					}
					
					_splatDatas.push(visibleSplatDatas[i]);
				}
				
				for (i = 0; i<_splatDataGroups.length; i++) {
					
					var blendingRequired:Boolean = i == 0 ? false : true;
					var fogInPass:Boolean = this.fogEnabled && this.addFogInFinalTerrainPass && (i == _splatDataGroups.length - 1);
					addPass(new TerrainPass(_splatDataGroups[i], _terrainMethodData, blendingRequired, true, fogInPass));
				}
			} else {
				_maxSplatDatasPerPass = 6;
				
				visibleSplatDatas = new Vector.<SplatData>();
				for (i = 0; i<_textureSplatDatas.length; i++) {
					if (_textureSplatDatas[i].visible) {
						visibleSplatDatas.push(_textureSplatDatas[i]);
					}
				}
				
				var useSlopeCount:uint = 0;
				if (this.fogEnabled && this.addFogInFinalTerrainPass) { useSlopeCount++; }
				for (i = 0; i<visibleSplatDatas.length; i++) {
					if (visibleSplatDatas[i].useSlopeBlend) {
						useSlopeCount++;
						if (useSlopeCount == 3) { 
							_maxSplatDatasPerPass = 5; //REMOVE A SPLAT FROM PASS TO NOT EXCEED AGAL INSTRUCTION LIMIT
							break;
						} 
					}
				}
				
				_splatDataGroups = new Vector.<Vector.<SplatData>>();
				for (i = 0; i<visibleSplatDatas.length; i++) {
					
					if (i % _maxSplatDatasPerPass == 0) {
						_splatDatas = new Vector.<SplatData>();
						_splatDataGroups.push(_splatDatas);
					}
					
					_splatDatas.push(visibleSplatDatas[i]);
				}
				
				for (i = 0; i<_splatDataGroups.length; i++) {
					
					blendingRequired = i == 0 ? false : true;
					
					fogInPass = this.fogEnabled && this.addFogInFinalTerrainPass && (i == _splatDataGroups.length - 1);
					addPass(new TerrainPass(_splatDataGroups[i], _terrainMethodData, blendingRequired, false, fogInPass));
				}
			}
			
			if (this.fogEnabled && !this.addFogInFinalTerrainPass) {
				_fogPass ||= new FogPass(_terrainMethodData.minimumFogDistance, _terrainMethodData.maximumFogDistance, _terrainMethodData.fogColor);
				_fogPass.fogColor = this.fogColor;
				addPass(_fogPass);
			}
			
			if (_customPasses && _customPasses.length > 0) {
				for (i = 0; i<_customPasses.length; i++) {
					addPass(_customPasses[i]);
				}
			}
		}
		
		public function get useNormalMaps():Boolean { return _useNormalMaps; }
		public function set useNormalMaps(value:Boolean):void {
			_useNormalMaps = value;
			updatePasses();
		}
		
		public function addCustomPassAt(pass:MaterialPassBase, index:uint):void {
			
			_customPasses.splice(index, 0, pass);
			updatePasses();
		}
		public function removeCustomPassAt(index:uint):void {
			
			_customPasses.splice(index, 1);
			updatePasses();
		}
		public function addCustomPass(pass:MaterialPassBase):void {
			
			_customPasses.push(pass);
			updatePasses();
		}
		public function removeCustomPass(pass:MaterialPassBase):void {
		
			var passIndex:int = _customPasses.indexOf(pass);
			if (passIndex !== -1) {
				_customPasses.splice(passIndex, 1);
				updatePasses();
			}
		}
		
		public function hasCustomPass(pass:MaterialPassBase):Boolean {

			return _customPasses.indexOf(pass) !== -1;

		}
		public function set customPasses(value:Vector.<MaterialPassBase>):void {
			
			var customHasLen:Boolean = _customPasses.length !== 0;
			var valHasLen:Boolean = value.length !== 0;
			_customPasses = value;
			if (customHasLen || valHasLen) updatePasses();
		}
		public function get customPasses():Vector.<MaterialPassBase> { return _customPasses; }
	
		public function get terrainMethodData():TerrainMethodData { return _terrainMethodData; }
		
		public function get splatDatas():Vector.<SplatData> { return _textureSplatDatas; }
		public function set splatDatas(value:Vector.<SplatData>):void { _textureSplatDatas = value; }
		
		public function get ambientColor():uint { return _terrainMethodData.ambientColor; }
		public function set ambientColor(value:uint):void { _terrainMethodData.ambientColor = value; }
		
		public function get ambient():Number { return _terrainMethodData.ambient; }
		public function set ambient(value:Number):void { _terrainMethodData.ambient = value; }
		
		public function get specularColor():uint { return _terrainMethodData.specularColor; }
		public function set specularColor(value:uint):void { _terrainMethodData.specularColor = value; }
		
		public function get specular():Number { return _terrainMethodData.specular; }
		public function set specular(value:Number):void { _terrainMethodData.specular = value; }
		
		public function get gloss():Number { return _terrainMethodData.gloss; }
		public function set gloss(value:Number):void { _terrainMethodData.gloss = value; }
		
		
		public function get fogEnabled():Boolean { return  _terrainMethodData.fogEnabled; }
		public function set fogEnabled(value:Boolean):void {  
			_terrainMethodData.fogEnabled = value; 
			updatePasses();
		}
		
		public function get minimumFogDistance():Number { return _terrainMethodData.minimumFogDistance; }
		public function set minimumFogDistance(value:Number):void { 
			_terrainMethodData.minimumFogDistance = value; 
			if (_fogPass) _fogPass.minDistance = value;
		}
		
		public function get maximumFogDistance():Number { return _terrainMethodData.maximumFogDistance; }
		public function set maximumFogDistance(value:Number):void { 
			_terrainMethodData.maximumFogDistance = value; 
			if (_fogPass) _fogPass.maxDistance = value;
		}
		
		public function get fogColor():uint { return _terrainMethodData.fogColor; }
		public function set fogColor(value:uint):void { 
			_terrainMethodData.fogColor = value; 
			if (_fogPass) _fogPass.fogColor = value;
		}
		
		public function get showShadows():Boolean { return _terrainMethodData.showShadows; }
		public function set showShadows(value:Boolean):void {
			_terrainMethodData.showShadows = value;
			updatePasses();
		}
		
		public function get shadowAlpha():Number { return _terrainMethodData.shadowAlpha; }
		public function set shadowAlpha(value:Number):void { _terrainMethodData.shadowAlpha = value; }
		/**
		 * The strength of the normal map from 0 to 1
		 */
		public function get normalMapStrength():Number { return _terrainMethodData.normalMapStrength; }
		public function set normalMapStrength(value:Number):void { _terrainMethodData.normalMapStrength = value; }
		
		public function get addFogInFinalTerrainPass():Boolean { return _terrainMethodData.addFogInFinalTerrainPass; }
		public function set addFogInFinalTerrainPass(value:Boolean):void { 
			_terrainMethodData.addFogInFinalTerrainPass = value; 
			updatePasses();
		}
	}
}