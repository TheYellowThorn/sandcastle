/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.effects
{
	import com.terrainbuilder.objs.terrain.SeamlessElevationData;
	
	import flash.display.BitmapData;
	import flash.geom.Vector3D;
	
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.core.base.IRenderable;
	import away3d.core.managers.Stage3DProxy;
	import away3d.lights.DirectionalLight;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.EffectMethodBase;
	import away3d.materials.methods.MethodVO;
	import away3d.textures.BitmapTexture;
	import away3d.textures.Texture2DBase;
	
	use namespace arcane;
	
	/**
	 * WaterMaskMethod allows the use of an additional texture to specify the alpha value of the material. When used
	 * with the secondary uv set, it allows for a tiled main texture with independently varying alpha (useful for water
	 * etc).
	 */
	public class WaterMaskMethod extends EffectMethodBase
	{
		private var _texture:Texture2DBase;
		private var _useSecondaryUV:Boolean;
		private var _whiteCapHeight:Number;
		private var _maxHeightDifferenceWithoutFade:Number;
		private var _whiteCapSpread:Number;
		public var waterHeightColor:uint;
		public var shallowFadeHeightColor:uint;
		
		private var _heightMap:BitmapData;
		
		private var _squaredTiles:uint;
		private var _tilesHigh:uint;
		private var _tileSize:Number;
		private var _anchorYPosition:Number;
		private var _maxHeight:Number;
		private var _positionOffsetX:Number;
		private var _positionOffsetZ:Number;
		private var _waterHeight:Number;
		private var _seamlessElevationData:SeamlessElevationData;
		private var _countX:Number = 0;
		private var _whiteCapTexture:BitmapTexture;
		private var _whiteCapFoamTileData:Number;
		private var _minimumAlpha:Number;
		private var _whiteCapTextureBitmapData:BitmapData;
		private var localVarying:ShaderRegisterElement;
		private var _lightPicker:StaticLightPicker;

		/**
		 * Creates a new WaterMaskMethod object
		 * @param texture The texture to use as the alpha mask.
		 */
		public function WaterMaskMethod(heightMap:BitmapData, squaredTiles:uint, seamlessElevationData:SeamlessElevationData, anchorYPosition:Number, whiteCapHeight:Number, whiteCapSpread:Number, whiteCapTexture:BitmapTexture = null, whiteCapFoamTileData:Number = 8, minimumAlpha:Number = 0) {
			
			super();
			
			_seamlessElevationData = seamlessElevationData;
			_waterHeight = seamlessElevationData.waterHeight;
			_squaredTiles = squaredTiles;
			_tileSize = seamlessElevationData.width;
			_maxHeight = (seamlessElevationData.maxElevation / 255) * seamlessElevationData.height * (seamlessElevationData.height / seamlessElevationData.width);
			_anchorYPosition = anchorYPosition;
			_positionOffsetX = seamlessElevationData.positionOffsetX;
			_positionOffsetZ = seamlessElevationData.positionOffsetZ;
			if (whiteCapTexture) {
				_whiteCapTextureBitmapData = whiteCapTexture.bitmapData;
			}
			_whiteCapTexture = whiteCapTexture;
			_whiteCapFoamTileData = whiteCapFoamTileData;
			_minimumAlpha = minimumAlpha;
			
			_texture = new BitmapTexture(heightMap);
			
			_whiteCapHeight = whiteCapHeight;
			_whiteCapSpread = whiteCapSpread;

			_useSecondaryUV = useSecondaryUV;
		}

		/**
		 * @inheritDoc
		 */
		override arcane function initVO(vo:MethodVO):void
		{
			vo.needsSecondaryUV = _useSecondaryUV;
			vo.needsUV = !_useSecondaryUV;
			vo.needsGlobalFragmentPos = true;
			vo.needsGlobalVertexPos = true;
			vo.needsProjection = true;
			vo.needsView = true;
			vo.needsTangents = true;
		}

		/**
		 * Indicated whether or not the secondary uv set for the mask. This allows mapping alpha independently, for
		 * instance to tile the main texture and normal map while providing untiled alpha, for example to define the
		 * transparency over a tiled water surface.
		 */
		public function get useSecondaryUV():Boolean
		{
			return _useSecondaryUV;
		}
		
		public function set useSecondaryUV(value:Boolean):void
		{
			if (_useSecondaryUV == value)
				return;
			_useSecondaryUV = value;
			invalidateShaderProgram();
		}

		/**
		 * The texture to use as the alpha mask.
		 */
		public function get texture():Texture2DBase
		{
			return _texture;
		}
		
		public function set texture(value:Texture2DBase):void
		{
			_texture = value;
		}

		arcane override function setRenderState(vo:MethodVO, renderable:IRenderable, stage3DProxy:Stage3DProxy, camera:Camera3D):void
		{
			super.setRenderState(vo, renderable, stage3DProxy, camera);
			
			
			var light:DirectionalLight;
			var objectSpaceDir:Vector3D;
			if (_lightPicker) {
				light = _lightPicker.castingDirectionalLights.length > 0 ? _lightPicker.castingDirectionalLights[0] : _lightPicker.directionalLights[0];
				objectSpaceDir = renderable.inverseSceneTransform.transformVector(light.direction);
				objectSpaceDir.normalize();
			}
			
			var data : Vector.<Number> = vo.fragmentData;
			var index : int = vo.fragmentConstantsIndex;

			data[index + 20] = light ? -objectSpaceDir.x : 0;
			data[index + 21] = light ? -objectSpaceDir.y : -1;
			data[index + 22] = light ? -objectSpaceDir.z : 0;
			data[index + 23] = 0;

		}
		/**
		 * @inheritDoc
		 */
		arcane override function activate(vo:MethodVO, stage3DProxy:Stage3DProxy):void
		{
			_countX += 1 / 720 * Math.PI;
			
			var data : Vector.<Number> = vo.fragmentData;
			var index : int = vo.fragmentConstantsIndex;
			
			data[index + 0] = 0;
			data[index + 1] = 1;
			data[index + 2] = (64 / 65);
			data[index + 3] = (1 - data[index + 2]) / 2;
			data[index + 4] = 0;
			data[index + 5] = _seamlessElevationData.height * (seamlessElevationData.height / seamlessElevationData.width);
			data[index + 6] = 255;
			data[index + 7] = 256;
			data[index + 8] = _anchorYPosition;
			data[index + 9] = _squaredTiles * _tileSize;
			data[index + 10] = _tileSize;
			data[index + 11] = _squaredTiles * _tileSize / 2;
			data[index + 12] = 1/68;
			data[index + 13] = 34;
			data[index + 14] = _whiteCapSpread;
			data[index + 15] = _whiteCapHeight - _whiteCapSpread;
			data[index + 16] = _whiteCapFoamTileData;
			data[index + 17] = _minimumAlpha;
			data[index + 18] = 0;
			data[index + 19] = 0;
			
			var texIndex : int = vo.texturesIndex;
			stage3DProxy._context3D.setTextureAt(texIndex, _texture.getTextureForStage3D(stage3DProxy));
			
			if (_whiteCapTexture) {
				stage3DProxy._context3D.setTextureAt(texIndex+1, _whiteCapTexture.getTextureForStage3D(stage3DProxy));
			}
			
		}
		
		arcane override function getVertexCode(vo:MethodVO, regCache:ShaderRegisterCache):String {
			
			localVarying = regCache.getFreeVarying();
			
			var code:String = super.getVertexCode(vo, regCache);
			
			code += "mov " + localVarying + ", va0\n";
			
			return code;
		}

		/**
		 * @inheritDoc
		 */
		arcane override function getFragmentCode(vo:MethodVO, regCache:ShaderRegisterCache, targetReg:ShaderRegisterElement):String
		{
			var constRegister : ShaderRegisterElement = regCache.getFreeFragmentConstant();
			vo.fragmentConstantsIndex = constRegister.index*4;
			var constRegister2 : ShaderRegisterElement = regCache.getFreeFragmentConstant();
			var constRegister3 : ShaderRegisterElement = regCache.getFreeFragmentConstant();
			var constRegister4 : ShaderRegisterElement = regCache.getFreeFragmentConstant();
			var constRegister5 : ShaderRegisterElement = regCache.getFreeFragmentConstant();
			var constRegister6 : ShaderRegisterElement = regCache.getFreeFragmentConstant();
			
			var textureReg:ShaderRegisterElement = regCache.getFreeTextureReg();
			vo.texturesIndex = textureReg.index;
			if (_whiteCapTexture) { var whiteCapTextureReg:ShaderRegisterElement = regCache.getFreeTextureReg(); }
			
			var temp:ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();
			regCache.addFragmentTempUsages(temp, 1);
			var temp2:ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();
			regCache.addFragmentTempUsages(temp2, 1);
			var temp3:ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();
			regCache.addFragmentTempUsages(temp3, 1);
			var uvReg:ShaderRegisterElement = _useSecondaryUV? _sharedRegisters.secondaryUVVarying : _sharedRegisters.uvVarying;

			var code:String = "";

			code += "mov " + temp3 + ", " + localVarying + "\n";
			
			code += "add " + temp + ".xxzz, " + temp3 + ".xxzz, " + constRegister3 + ".wwww\n";
			code += "div " + temp + ".xxzz, " + temp + ".xxzz, " + constRegister3 + ".yyyy\n"; //DIVIDE BY (TILES WIDE AND HIGH * TILE SIZE)
			code += "sub " + temp + ".y, " + constRegister + ".y, " + temp + ".z\n";
			
			code += "mul " + temp + ".xy, " + temp + ".xy, " + constRegister + ".z\n";
			code += "add " + temp + ".xy, " + temp + ".xy, " + constRegister + ".w\n";
			code += "sat " + temp + ".xy, " + temp + ".xy\n";
			
			code += "tex " + temp + ", " + temp + ", " + textureReg +" <2d,linear,miplinear,repeat>\n";
			code += "mul " + temp + ".x, " + temp + ".x, " + constRegister2 + ".w\n";
			code += "add " + temp + ".z, " + temp + ".x, " + temp + ".y\n";
			code += "mul " + temp + ".z, " + temp + ".z, " + constRegister2 + ".y\n";
			code += "mov " + temp2 + ".z, " + temp + ".z\n";
			code += "sub " + temp2 + ".y, " + temp2 + ".y, " + temp + ".z\n"; //STORE HEIGHT FOR WHITE CAPS
			
			code += "sub " + temp2 + ".xzw, " + temp2 + ".zzz, " + constRegister4 + ".www\n";
			code += "slt " + temp3 + ".www, " + temp2 + ".xxx, " + constRegister + ".xxx\n";
			code += "div " + temp2 + ".xzw, " + temp2 + ".xzw, " + constRegister4 + ".z\n";
			code += "sat " + temp2 + ".xzw, " + temp2 + ".xzw\n";
			
			if (_whiteCapTexture) {
				code += "mul " + temp + ", " + _sharedRegisters.uvVarying + ", " + constRegister5 + ".x\n";
				code += "tex " + temp + ", " + temp + ", " + whiteCapTextureReg + " <2d,linear,miplinear,repeat>\n";
			} else {
				code += "mov " + temp + ".xyzw, " + constRegister + ".yyyy\n"; //DEFAULT WHITE FOR WHITE CAPS
			}
			
			code += "mov " + temp3 + ".xyz, " + targetReg + ".xyz\n";
			code += "sub " + temp + ".xyz, " + temp + ".xyz, " + temp3 + ".xyz\n";
			code += "mul " + temp + ".xyz, " + temp + ".xyz, " + temp2 + ".x\n";

			
			code += "dp3 " + temp2 + ".z, " + constRegister6 + ".xyz, " + _sharedRegisters.normalVarying + ".xyz\n"; // standard dot3 lambert shading: d = max(0, dot3(light, normal))
			code += "mul " + temp + ".xyz, " + temp + ".xyz, " + temp2 + ".z\n";
			
			code += "add " + targetReg + ".xyz, " + targetReg + ".xyz, " + temp + ".xyz\n";
			
			code += "sub " + temp2 + ".x, " + constRegister + ".y, " + temp2 + ".x\n";
			code += "sub " + temp2 + ".x, " + temp2 + ".x, " + constRegister5 + ".y\n";
			code += "sat " + temp2 + ".x, " + temp2 + ".x\n";
			code += "add " + temp2 + ".y, " + temp2 + ".x, " + constRegister5 + ".y\n";
			
			
			code += "mul " + targetReg + ".w, " + targetReg + ".w, " + temp2 + ".y\n"; 
			
			if (temp) regCache.removeFragmentTempUsage(temp);
			if (temp2) regCache.removeFragmentTempUsage(temp2);
			if (temp3) regCache.removeFragmentTempUsage(temp3);

			return code;
				
		}
		
		public function set whiteCapHeight(value:Number):void {	_whiteCapHeight = value; }
		public function get whiteCapHeight():Number { return _whiteCapHeight; }
		public function set whiteCapSpread(value:Number):void {	_whiteCapSpread = value; }
		public function get whiteCapSpread():Number { return _whiteCapSpread; }
		public function set whiteCapTexture(value:BitmapTexture):void {
			_whiteCapTexture = value;
			_whiteCapTextureBitmapData = _whiteCapTexture ? _whiteCapTexture.bitmapData : null;
			this.invalidateShaderProgram();
		}
		public function get whiteCapTexture():BitmapTexture { return _whiteCapTexture; }
		
		public function set whiteCapTextureBitmapData(value:BitmapData):void {
			_whiteCapTextureBitmapData = value;
			this.whiteCapTexture = _whiteCapTextureBitmapData ? new BitmapTexture(_whiteCapTextureBitmapData) : null;
			this.invalidateShaderProgram();
		}
		public function get whiteCapTextureBitmapData():BitmapData { return _whiteCapTextureBitmapData; }
		
		public function set whiteCapFoamTileData(value:Number):void {	_whiteCapFoamTileData = value; }
		public function get whiteCapFoamTileData():Number { return _whiteCapFoamTileData; }
		public function set minimumAlpha(value:Number):void {	_minimumAlpha = value; }
		public function get minimumAlpha():Number { return _minimumAlpha; }
		
		public function get seamlessElevationData():SeamlessElevationData {
			return _seamlessElevationData;
		}
		public function set seamlessElevationData(value:SeamlessElevationData):void {
			_seamlessElevationData = value;
			_waterHeight = _seamlessElevationData.waterHeight;
			_tileSize = _seamlessElevationData.width;
			_maxHeight = (_seamlessElevationData.maxElevation / 255) * _seamlessElevationData.height;
			_positionOffsetX = _seamlessElevationData.positionOffsetX;
			_positionOffsetZ = _seamlessElevationData.positionOffsetZ;
		}
		public function set lightPicker(value:StaticLightPicker):void { _lightPicker = value; }
		public function get lightPicker():StaticLightPicker { return _lightPicker; }
		
		public override function dispose():void {
			
			if (_texture) _texture.dispose();
			if (_heightMap) _heightMap.dispose();
			_seamlessElevationData = null;
			if (_whiteCapTextureBitmapData) _whiteCapTextureBitmapData.dispose();
			if (_whiteCapTexture) _whiteCapTexture.dispose();

		}
	}
}
