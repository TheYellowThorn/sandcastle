/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.effects {
	
	import com.terrainbuilder.objs.terrain.SeamlessElevationData;
	
	import flash.display.BitmapData;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.core.base.IRenderable;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;
	import away3d.materials.methods.MethodVO;
	import away3d.textures.Texture2DBase;

	use namespace arcane;
	
	public class OceanWaveMethod extends VertexMethodBase {
		
		private var _matrix : Matrix3D = new Matrix3D();
		private var _texture : Texture2DBase;
		
		private var _vertexData : Vector.<Number>;
		private var _amplitudeX:Number = 10;
		private var _frequencyX:Number = 1;
		private var _offsetX:Number = 0;
		
		private var _amplitudeY:Number = 10;
		private var _frequencyY:Number = 1;
		private var _offsetY:Number = 0;
		private var _lastOffsetX:Number;
		private var _lastOffsetY:Number;
		private var _displacementMultiplier:Number;
		
		private var data:Vector.<Number>;
		
		private var _oceanBitmapData:BitmapData;
		private var _oceanByteArray:ByteArray;
		private var waveHeightAttribute:ShaderRegisterElement;
		private var _waveHeightBuffer:VertexBuffer3D;
		private var _waveHeightIndex:int;
		private var _seamlessElevationData:SeamlessElevationData;
		public var waveXSpeed:Number = 0.25;
		public var waveYSpeed:Number = 0.2;
		
		/**
		 * oceanBitmapData acts as a wave displacement map
		 */
		public function OceanWaveMethod(seamlessElevationData:SeamlessElevationData, oceanBitmapData:BitmapData = null, displacementMultiplier:Number = 10) {
			
			super();
			
			_seamlessElevationData = seamlessElevationData;
			_oceanBitmapData = oceanBitmapData;
			_displacementMultiplier = displacementMultiplier;
			if (_oceanBitmapData) { 
				_oceanByteArray = new ByteArray();
				_oceanByteArray.endian = Endian.LITTLE_ENDIAN;
				_oceanBitmapData.copyPixelsToByteArray(_oceanBitmapData.rect, _oceanByteArray); 
			}
			_vertexData = new Vector.<Number>(8);
			
		}
		
		
		
		override arcane function initConstants(vo : MethodVO) : void
		{
			
		}
		override arcane function initVO(vo:MethodVO):void
		{
			vo.needsGlobalVertexPos = true;
		}
		
		
		
		
		
		override arcane function getVertexCode(vo : MethodVO, regCache : ShaderRegisterCache) : String
		{
			
			var vertexConstant : ShaderRegisterElement = regCache.getFreeVertexConstant();
			var vertexConstant2 : ShaderRegisterElement = regCache.getFreeVertexConstant();
			var vertexConstant3 : ShaderRegisterElement = regCache.getFreeVertexConstant();
			var vertexConstant4 : ShaderRegisterElement = regCache.getFreeVertexConstant();
			
			var temp : ShaderRegisterElement = regCache.getFreeVertexVectorTemp();
			regCache.addVertexTempUsages(temp, 1);
			var temp2 : ShaderRegisterElement = regCache.getFreeVertexVectorTemp();
			regCache.addVertexTempUsages(temp2, 1);
			var temp3 : ShaderRegisterElement = regCache.getFreeVertexVectorTemp();
			regCache.addVertexTempUsages(temp3, 1);
			var temp4 : ShaderRegisterElement;
			var temp5 : ShaderRegisterElement;
			var temp6 : ShaderRegisterElement;
			
			var code : String = "";
			
			if (_oceanBitmapData) {
				waveHeightAttribute = regCache.getFreeVertexAttribute();
				_waveHeightIndex = waveHeightAttribute.index;
				temp4 = regCache.getFreeVertexVectorTemp();
				regCache.addVertexTempUsages(temp4, 1);
			
				code += "mov " + temp4 + ", " + waveHeightAttribute + "\n";
				
			}
			
			temp5 = regCache.getFreeVertexVectorTemp();
			temp6 = regCache.getFreeVertexVectorTemp();
			
			regCache.addVertexTempUsages(temp5, 1);
			regCache.addVertexTempUsages(temp6, 1);
			
			
			code += "mov " + temp + ", " + _sharedRegisters.globalPositionVertex + "\n";
			code += "mov " + temp5 + ", " + _sharedRegisters.globalPositionVertex + "\n";
			code += "mov " + temp5 + ", " + _sharedRegisters.globalPositionVertex + "\n";
			code += "mov " + temp6 + ", " + _sharedRegisters.globalPositionVertex + "\n";
			
			code += "mov " + temp2 + ", " + _sharedRegisters.globalPositionVertex + "\n"; // Move offset value into temp
			
			code += "div " + temp2 + ".yyzz, " + temp + ".xxzz, " + vertexConstant2 + ".xxyy\n"; // Mul frequency by x position offset
			code += "add " + temp2 + ".yyzz, " + temp2 + ".yyzz, " + vertexConstant + ".xxyy\n"; // Add x position offset
			code += "sin " + temp2 + ".yyzz, " + temp2 + ".yyzz\n"; // Sin offset value
			code += "mul " + temp2 + ".yyzz, " + temp2 + ".yyzz, " + vertexConstant + ".zzww\n"; // Mul by amplitude
			code += "add " + temp2 + ".yyyy, " + temp2 + ".yyyy, " + temp2 + ".zzzz\n"; // add x and y axis together
			
			code += "mov " + temp + ", " + _sharedRegisters.globalPositionVertex + "\n";
			code += "add " + temp + ".y, " + temp + ".y, " + temp2 + ".y\n"; // Add offset to base vertex
			
			code += "m44 op, " + temp + ", vc0 \n";
			code += "mov " + _sharedRegisters.globalPositionVarying + ", " + temp + "\n"; //SEND NEW GLOBAL POSITION
			
			/** START NORMALS **/
			code += "div " + temp2 + ".xyzw, " + _sharedRegisters.globalPositionVertex + ".xxxx, " + vertexConstant2 + ".xxxx\n"; // Mul frequency by x position offset
			code += "div " + temp3 + ".xyzw, " + _sharedRegisters.globalPositionVertex + ".zzzz, " + vertexConstant2 + ".yyyy\n"; // Mul frequency by y position offset
			
			/** START ADD OFFSETS **/
			code += "sub " + temp2 + ".xy, " + temp2 + ".xy, " + vertexConstant3 + ".xy\n"; //RIGHT / LEFT
			code += "add " + temp3 + ".xy, " + temp3 + ".xy, " + vertexConstant3 + ".xy\n"; //TOP / BOTTOM
			
			/** END ADD OFFSETS **/
			code += "add " + temp2 + ".xyzw, " + temp2 + ".xyzw, " + vertexConstant + ".xxxx\n"; // Add x position offset
			code += "add " + temp3 + ".xyzw, " + temp3 + ".xyzw, " + vertexConstant + ".yyyy\n"; // Add x position offset
			
			code += "sin " + temp2 + ".x, " + temp2 + ".x\n"; // Sin offset value
			code += "sin " + temp3 + ".x, " + temp3 + ".x\n"; // Sin offset value
			code += "sin " + temp2 + ".y, " + temp2 + ".y\n"; // Sin offset value
			code += "sin " + temp3 + ".y, " + temp3 + ".y\n"; // Sin offset value
			code += "sin " + temp2 + ".z, " + temp2 + ".z\n"; // Sin offset value
			code += "sin " + temp3 + ".z, " + temp3 + ".z\n"; // Sin offset value
			code += "sin " + temp2 + ".w, " + temp2 + ".w\n"; // Sin offset value
			code += "sin " + temp3 + ".w, " + temp3 + ".w\n"; // Sin offset value
			
			code += "mul " + temp2 + ".xyzw, " + temp2 + ".xyzw, " + vertexConstant + ".zzzz\n"; // Mul by amplitude
			code += "mul " + temp3 + ".xyzw, " + temp3 + ".xyzw, " + vertexConstant + ".wwww\n"; // Mul by amplitude
			
			code += "add " + temp2 + ".xyzw, " + temp2 + ".xyzw, " + temp3 + ".xyzw\n"; // add x and y axis together
			
			/** END NORMALS **/
			
			//NORMALS
			code += "mov " + temp + ".xyz, " + vertexConstant3 + ".zww\n"; //width, 0, 0
			code += "mov " + temp3 + ".xyz, " + vertexConstant3 + ".wzw\n"; //0, width, 0
			
			code += "sub " + temp + ".z, " + temp2 + ".y, " + temp2 + ".x\n"; //width, 0, rightHeight - leftHeight
			code += "sub " + temp3 + ".z, " + temp2 + ".z, " + temp2 + ".w\n"; //0, width, bottomHeight - topHeight
			
			code += "nrm " + temp + ".xyz, " + temp + ".xyz\n"; //normalize
			code += "nrm " + temp3 + ".xyz, " + temp3 + ".xyz\n"; //normalize
			
			code += "crs " + temp2 + ".xyz, " + temp + ".xyz, " + temp3 + ".xyz\n";
			code += "nrm " + temp2 + ".xyz, " + temp2 + ".xyz\n";
			code += "mov " + temp + ".xyz, " + temp2 + ".xzy\n";

			code += "m33 " + temp + ".xyz, " + temp + ".xyz, vc8\n";
			
			code += "mov " + _sharedRegisters.normalVarying + ".xyz, " + temp + ".xyz\n";
			
			regCache.removeVertexTempUsage(temp);
			regCache.removeVertexTempUsage(temp2);
			regCache.removeVertexTempUsage(temp3);
			if (temp4) regCache.removeVertexTempUsage(temp4);
			if (temp5) regCache.removeVertexTempUsage(temp5);
			if (temp6) regCache.removeVertexTempUsage(temp6);
			
			return code;
			
		}

		override arcane function setRenderState(vo : MethodVO, renderable : IRenderable, stage3DProxy : Stage3DProxy, camera : Camera3D):void {
			
			data = vo.vertexData;
			
			data[vo.vertexData.length - 16] = _offsetX += (waveXSpeed / 180 * Math.PI);
			data[vo.vertexData.length - 15] = _offsetY += (waveYSpeed / 180 * Math.PI);
			data[vo.vertexData.length - 14] = _amplitudeX;
			data[vo.vertexData.length - 13] = _amplitudeY;
			data[vo.vertexData.length - 12] = _frequencyX * 100;
			data[vo.vertexData.length - 11] = _frequencyY * 100;
			data[vo.vertexData.length - 10] = _displacementMultiplier * (_seamlessElevationData.width / (_seamlessElevationData.heightMap.width - 3));
			data[vo.vertexData.length - 9] = 0;
			data[vo.vertexData.length - 8] = (_seamlessElevationData.width / (_seamlessElevationData.heightMap.width - 3));
			data[vo.vertexData.length - 7] = -(_seamlessElevationData.width / (_seamlessElevationData.heightMap.width - 3));
			data[vo.vertexData.length - 6] = 2*(_seamlessElevationData.width / (_seamlessElevationData.heightMap.width - 3));
			data[vo.vertexData.length - 5] = 0;
			data[vo.vertexData.length - 4] = _lastOffsetX;
			data[vo.vertexData.length - 3] = _lastOffsetY;
			data[vo.vertexData.length - 2] = (_seamlessElevationData.width / (_seamlessElevationData.heightMap.width - 3))*128;
			data[vo.vertexData.length - 1] = (_seamlessElevationData.width / (_seamlessElevationData.heightMap.width - 3))*128;
			
			_lastOffsetX = _offsetX;
			_lastOffsetY = _offsetY;
			
			super.setRenderState(vo, renderable, stage3DProxy, camera);
		}
		
		override arcane function activate(vo : MethodVO, stage3DProxy : Stage3DProxy) : void
		{
			super.activate(vo, stage3DProxy);
		}
		override arcane function deactivate(vo : MethodVO, stage3DProxy : Stage3DProxy) : void
		{
			super.deactivate(vo, stage3DProxy);
			
		}
		
		public function get amplitudeX():Number 
		{
			return _amplitudeX;
		}
		
		public function set amplitudeX(value:Number):void 
		{
			_amplitudeX = value;
		}
		
		public function get frequencyX():Number 
		{
			return _frequencyX;
		}
		
		public function set frequencyX(value:Number):void 
		{
			_frequencyX = value;
		}
		
		public function get offsetX():Number 
		{
			return _offsetX;
		}
		
		public function set offsetX(value:Number):void 
		{
			_lastOffsetX = _offsetX;
			_offsetX = value;
		}
		
		public function get amplitudeY():Number 
		{
			return _amplitudeY;
		}
		
		public function set amplitudeY(value:Number):void 
		{
			_amplitudeY = value;
		}
		
		public function get frequencyY():Number 
		{
			return _frequencyY;
		}
		
		public function set frequencyY(value:Number):void 
		{
			_frequencyY = value;
		}
		
		public function get offsetY():Number 
		{
			return _offsetY;
		}
		
		public function set offsetY(value:Number):void 
		{
			_lastOffsetY = _offsetY;
			_offsetY = value;
		}
		
		public function get seamlessElevationData():SeamlessElevationData { return _seamlessElevationData; }
		public function set seamlessElevationData(value:SeamlessElevationData):void { _seamlessElevationData = value; }
		public function get displacementMultiplier():Number { return _displacementMultiplier; }
		public function set displacementMultiplier(value:Number):void { _displacementMultiplier = value; }
		
		public override function dispose():void {
			super.dispose();
			
			_matrix = null;
			if (_texture) _texture.dispose();
			
			_vertexData = null;
			data = null;
			
			if (_oceanBitmapData) _oceanBitmapData = null;
			_oceanByteArray = null;
			_seamlessElevationData = null;
		}
		
	}
}