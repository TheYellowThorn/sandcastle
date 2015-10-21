/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.materials.passes
{	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.FreeMatrixLens;
	import away3d.core.base.IRenderable;
	import away3d.core.managers.Stage3DProxy;
	import away3d.lights.LightBase;
	import away3d.lights.shadowmaps.CascadeShadowMapper;
	import away3d.lights.shadowmaps.DirectionalShadowMapper;
	import away3d.lights.shadowmaps.ShadowMapperBase;
	import away3d.materials.passes.MaterialPassBase;

	use namespace arcane;

	/**
	 * TrivialColorPass is a pass rendering a flat unshaded colour
	 */
	public class ShadowPass extends MaterialPassBase
	{
		private var _overallDepthLens:FreeMatrixLens = new FreeMatrixLens();
		private var _overallDepthCamera:Camera3D = new Camera3D(_overallDepthLens);
		
		private var _matrix : Matrix3D = new Matrix3D();
		private var _globalMatrix : Matrix3D = new Matrix3D();
		private var _fragmentData : Vector.<Number>;
		
		private var _vertexData : Vector.<Number>;
		private var _usePoint:Boolean = false;
		protected var _castingLight:LightBase;
		protected var _shadowMapper:ShadowMapperBase;
		
		protected var _epsilon:Number = .02;
		protected var _alpha:Number = 1;
		private var _depthMapCoordVaryings:Vector.<String>;
		private var _cascadeProjections:Vector.<String>;
		private var _textureSampleType:String = "nearest";
		
		public function ShadowPass(castingLight:LightBase)
		{
			super();
			
			_overallDepthLens = new FreeMatrixLens();
			_overallDepthCamera = new Camera3D(_overallDepthLens);
			_overallDepthCamera.transform = castingLight.sceneTransform;
			
			_numUsedStreams = 3;	// vertex position, uv coords and normals
			_numUsedTextures = 1;
			
			_castingLight = castingLight;
			_castingLight.castsShadows = true;
			
			_shadowMapper = _castingLight.shadowMapper;
			_fragmentData = new Vector.<Number>(68, false);
			
			_vertexData = new Vector.<Number>(112);	
			
			if (_shadowMapper is CascadeShadowMapper) {
				CascadeShadowMapper(_shadowMapper).addEventListener(Event.CHANGE, onCascadeChange, false, 0, true);
			}
		}
		
		
		/**
		 * Get the vertex shader code for this shader
		 */
		override arcane function getVertexCode() : String
		{
			
			var code:String = "";
			
			initProjectionsRegs();
			
			code += "mov vt0, va0\n";
			
			code += "m44 op, vt0, vc0 \n";
			code += "m44 v2, vt0, vc4\n";
			code += "mov v0, va1\n"; //uvs
			code += "m44 v3, va0, vc0\n";
			
			code += "mov vt0, va2\n"; // normals
			code += "nrm vt0.xyz, vt0.xyz\n";
			code += "mov v1, vt0\n"; // normals
			
			var numCascades:int = _shadowMapper is CascadeShadowMapper ? CascadeShadowMapper(_shadowMapper).numCascades : 1;
			var temp:String = "vt1";
			var globalPositionVertex:String = "vt2";
			var dataReg:String = "vc12";
			
			code += "m44 vt2, va0, vc4\n"; //Set global position to vt2
			for (var i:int = 0; i < numCascades; ++i) {
				code += "m44 " + temp + ", " + globalPositionVertex + ", " + _cascadeProjections[i] + "\n";
				code += "add " + _depthMapCoordVaryings[i] + ", " + temp + ", " + dataReg + ".zzwz\n";
			}

			return code;
			
		}
		
		/**
		 * Creates the registers for the cascades' projection coordinates.
		 */
		private function initProjectionsRegs():void
		{
			
			var numCascades:int = _shadowMapper is CascadeShadowMapper ? CascadeShadowMapper(_shadowMapper).numCascades : 1;
			
			_cascadeProjections = new Vector.<String>(numCascades);
			_depthMapCoordVaryings = new Vector.<String>(numCascades);
			
			for (var i:int = 0; i < numCascades; ++i) {
				_depthMapCoordVaryings[i] = "v" + (i + 4).toString();
				_cascadeProjections[i] = "vc" + (13 + i * 4).toString();
			}
		}
		
		/**
		 * Get the fragment shader code for this shader
		 * @param fragmentAnimatorCode Any additional fragment animation code imposed by the framework, used by some animators. Ignore this for now, since we're not using them.
		 */
		override arcane function getFragmentCode(fragmentAnimatorCode : String) : String
		{
			
			var code:String = "";
			var numCascades:int = _shadowMapper is CascadeShadowMapper ? CascadeShadowMapper(_shadowMapper).numCascades : 1;
			var depthMapRegister:String = "fs0";
			var decReg:String = "fc0";
			var dataReg:String = "fc1";
			var depthReg:String = "fc2";
			var planeDistanceReg:String = "fc3";
			var planeDistances:Vector.<String> = new <String>[ planeDistanceReg + ".x", planeDistanceReg + ".y", planeDistanceReg + ".z", planeDistanceReg + ".w" ];
			var targetReg:String = "ft0";
			var inQuad:String = "ft1";
			var uvCoord:String = "ft2";
			var projectionFragment:String = "v3";
			var temp:String = "ft3";

			code += "mov " + targetReg + ", fc0.wwwx\n";
			
			// assume lowest partition is selected, will be overwritten later otherwise
			code += "mov " + uvCoord + ", " + _depthMapCoordVaryings[numCascades - 1] + "\n";
			
			for (var i:int = numCascades - 2; i >= 0; --i) {
				var uvProjection:String = _depthMapCoordVaryings[i];
				
				// calculate if in texturemap (result == 0 or 1, only 1 for a single partition)
				code += "slt " + inQuad + ".z, " + projectionFragment + ".z, " + planeDistances[i] + "\n"; // z = x > minX, w = y > minY
				
				temp = "ft3";
				
				// linearly interpolate between old and new uv coords using predicate value == conditional toggle to new value if predicate == 1 (true)
				code += "sub " + temp + ", " + uvProjection + ", " + uvCoord + "\n" +
					"mul " + temp + ", " + temp + ", " + inQuad + ".z\n" +
					"add " + uvCoord + ", " + uvCoord + ", " + temp + "\n";
			}
			
			code += "div " + uvCoord + ", " + uvCoord + ", " + uvCoord + ".w\n" +
				"mul " + uvCoord + ".xy, " + uvCoord + ".xy, fc1.zw\n" +
				"add " + uvCoord + ".xy, " + uvCoord + ".xy, fc1.zz\n";
			
			
			code += getCascadeFragmentCode(decReg, depthMapRegister, uvCoord, targetReg);
			
			code +=	"add " + targetReg + ".w, " + targetReg + ".w, " + dataReg + ".y\n";
			
			code += "sub " + targetReg + ".w, " + decReg + ".x, " + targetReg + ".w\n"; //1 - alpha = shadow
			
			code += "mov oc, " + targetReg + "\n";
		
			return code;
			
		}
		
		protected function activateForCascade():void
		{
			var size:int = _castingLight.shadowMapper.depthMapSize;
			var index:int = 8;
			var data:Vector.<Number> = _fragmentData;
			data[index] = size;
			data[index + 1] = 1/size;
			
		}
		
		private function getCascadeFragmentCode(decodeRegister:String, depthTexture:String, depthProjection:String, targetReg:String):String
		{
			
			
			var code:String = "";
			var dataReg:String = "fc1";
			var tempString:String = "ft1";
			var predicate:String = "ft3";
			
			code += "tex " + tempString + ", " + depthProjection + ", " + depthTexture + " <2d, " + _textureSampleType + ", clamp>\n";// +
			
			code += "dp4 " + tempString + ".z, " + tempString + ", " + decodeRegister + "\n";
			code += "slt " + predicate + ".x, " + depthProjection + ".z, " + tempString + ".z\n";
			
			code += "add " + depthProjection + ".x, " + depthProjection + ".x, " + dataReg + ".y\n";
			code += "tex " + tempString + ", " + depthProjection + ", " + depthTexture + " <2d, " + _textureSampleType + ", clamp>\n";
			code += "dp4 " + tempString + ".z, " + tempString + ", " + decodeRegister + "\n";
			code += "slt " + predicate + ".z, " + depthProjection + ".z, " + tempString + ".z\n";
			
			code += "add " + depthProjection + ".y, " + depthProjection + ".y, " + dataReg + ".y\n";
			code += "tex " + tempString + ", " + depthProjection + ", " + depthTexture + " <2d, " + _textureSampleType + ", clamp>\n";
			code += "dp4 " + tempString + ".z, " + tempString + ", " + decodeRegister + "\n";
			code += "slt " + predicate + ".w, " + depthProjection + ".z, " + tempString + ".z\n";
			
			code += "sub " + depthProjection + ".x, " + depthProjection + ".x, " + dataReg + ".y\n";
			code += "tex " + tempString + ", " + depthProjection + ", " + depthTexture + " <2d, " + _textureSampleType + ", clamp>\n";
			code += "dp4 " + tempString + ".z, " + tempString + ", " + decodeRegister + "\n";
			code += "slt " + predicate + ".y, " + depthProjection + ".z, " + tempString + ".z\n";
			
			code += "mul " + tempString + ".xy, " + depthProjection + ".xy, " + dataReg + ".x\n";
			code += "frc " + tempString + ".xy, " + tempString + ".xy\n";
			
			// some strange register juggling to prevent agal bugging out
			code += "sub " + depthProjection + ", " + predicate + ".xyzw, " + predicate + ".zwxy\n";
			code += "mul " + depthProjection + ", " + depthProjection + ", " + tempString + ".x\n";
			
			code += "add " + predicate + ".xy, " + predicate + ".xy, " + depthProjection + ".zw\n";
			
			code += "sub " + predicate + ".y, " + predicate + ".y, " + predicate + ".x\n";
			code += "mul " + predicate + ".y, " + predicate + ".y, " + tempString + ".y\n";
			code += "add " + targetReg + ".w, " + predicate + ".x, " + predicate + ".y\n";
		
			return code;
		}

		/**
		 * Sets the render state which is constant for this pass
		 * @param stage3DProxy The stage3DProxy used for the current render pass
		 * @param camera The camera currently used for rendering
		 */
		override arcane function activate(stage3DProxy : Stage3DProxy, camera : Camera3D) : void
		{

			_blendFactorSource = Context3DBlendFactor.SOURCE_ALPHA;
			_blendFactorDest = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			_enableBlending = true;
			
			stage3DProxy._context3D.setTextureAt(0, _castingLight.shadowMapper.depthMap.getTextureForStage3D(stage3DProxy));
			
			super.activate(stage3DProxy, camera);
			
		}
		

		/**
		 * Set render state for the current renderable and draw the triangles.
		 * @param renderable The renderable that needs to be drawn.
		 * @param stage3DProxy The stage3DProxy used for the current render pass.
		 * @param camera The camera currently used for rendering.
		 * @param viewProjection The matrix that transforms world space to screen space.
		 */
		
		
		override arcane function render(renderable : IRenderable, stage3DProxy : Stage3DProxy, camera : Camera3D, viewProjection : Matrix3D) : void
		{
			
			
			var context : Context3D = stage3DProxy._context3D;
			context.setDepthTest(true, Context3DCompareMode.LESS_EQUAL);
			
			var index : int = 0;
			
			//Decode Register
			_fragmentData[index] = 1.0;
			_fragmentData[index + 1] = 1/255.0;
			_fragmentData[index + 2] = 1/65025.0;
			_fragmentData[index + 3] = 1/16581375.0;
			
			_fragmentData[index + 5] = 1 - _alpha;
			_fragmentData[index + 6] = .5;
			_fragmentData[index + 7] = -.5;
			
			var nearPlaneDistances:Vector.<Number> = _shadowMapper is CascadeShadowMapper ? CascadeShadowMapper(_shadowMapper).nearPlaneDistances : new <Number>[camera.lens.far];
	
			index += 12;
			
			var numCascades:int = _shadowMapper is CascadeShadowMapper ? CascadeShadowMapper(_shadowMapper).numCascades : 1;
			for (var i:uint = 0; i < numCascades; ++i) {
				_fragmentData[uint(index + i)] = nearPlaneDistances[i];
				activateForCascade();
			}
			
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentData, uint(_fragmentData.length / 4));
			
			// upload the world-view-projection matrix
			_matrix.copyFrom(renderable.sceneTransform);
			_matrix.append(viewProjection);
		
			_globalMatrix.copyFrom(renderable.sceneTransform);
	
			_matrix.copyRawDataTo(_vertexData, 0, true);
			_globalMatrix.copyRawDataTo(_vertexData, 16, true);
			
			if (!_usePoint)
				DirectionalShadowMapper(_shadowMapper).depthProjection.copyRawDataTo(_vertexData, 8*4, true);
			
			var indx:int = 12*4;
			_vertexData[indx] = .5;
			_vertexData[indx + 1] = -.5;
			_vertexData[indx + 2] = 0.0;
			_vertexData[indx + 3] = 1.0;
			
			if (!_usePoint) {
				_vertexData[indx + 3] = -1/(DirectionalShadowMapper(_shadowMapper).depth*_epsilon);
			}
			
			indx += 4;
			
			for (var k:int = 0; k < numCascades; ++k) {
				if (_shadowMapper is CascadeShadowMapper) {
					CascadeShadowMapper(_shadowMapper).getDepthProjections(k).copyRawDataTo(_vertexData, indx, true);
				} else {
					DirectionalShadowMapper(_shadowMapper).depthProjection.copyRawDataTo(_vertexData, indx, true);
				}
				indx += 16;
			}
			
			renderable.activateVertexBuffer(0, stage3DProxy);
			renderable.activateUVBuffer(1, stage3DProxy);
			renderable.activateVertexNormalBuffer(2, stage3DProxy);
			
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _vertexData);//
			context.drawTriangles(renderable.getIndexBuffer(stage3DProxy), 0, renderable.numTriangles);
			
			
		}

		/**
		 * Clear render state for the next pass.
		 * @param stage3DProxy The stage3DProxy used for the current render pass.
		 */
		override arcane function deactivate(stage3DProxy : Stage3DProxy) : void
		{
			super.deactivate(stage3DProxy);

			var context : Context3D = stage3DProxy._context3D;

			// clear the texture and stream we set before
			// no need to clear attribute stream at slot 0, since it's always used
			context.setTextureAt(0, null);
			context.setVertexBufferAt(1, null);
		}
		
		public function set alpha(value:Number):void { _alpha = value; }
		public function get alpha():Number { return _alpha; }
		
		private function roundDec(numIn:Number, decimalPlaces:int):Number {
			var nExp:int = Math.pow(10,decimalPlaces) ; 
			var nRetVal:Number = Math.round(numIn * nExp) / nExp
			return nRetVal;
		}
		
		/**
		 * Called when the shadow mappers cascade configuration changes.
		 */
		private function onCascadeChange(event:Event):void
		{
			invalidateShaderProgram();
		}
		
		public function get textureSampleType():String { return _textureSampleType; }
		public function set textureSampleType(value:String):void { 
			if (value !== "linear") { value = "nearest"; }
			_textureSampleType = value; 
			invalidateShaderProgram();
		}
		
	}
}