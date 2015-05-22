/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.materials.passes
{
	import com.terrainbuilder.materials.objs.TerrainMethodData;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Matrix3D;
	
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.core.base.IRenderable;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.passes.MaterialPassBase;

	use namespace arcane;

	/**
	 * TrivialColorPass is a pass rendering a flat unshaded colour
	 */
	public class FogPass extends MaterialPassBase
	{
		
		private var _minDistance : Number = 0;
		private var _maxDistance : Number = 1000;
		private var _fogColor : uint;
		private var _fogA : Number;
		private var _fogR : Number;
		private var _fogG : Number;
		private var _fogB : Number;
		private var _terrainMethodData:TerrainMethodData;
		
		private var _matrix : Matrix3D = new Matrix3D();
		private var _globalMatrix : Matrix3D = new Matrix3D();
		private var _fragmentData : Vector.<Number>;
		
		private var _vertexData : Vector.<Number>;
		
		public function FogPass(minDistance : Number, maxDistance : Number, fogColor : uint = 0x808080)
		{
			super();
			this.minDistance = minDistance;
			this.maxDistance = maxDistance;
			this.fogColor = fogColor;
			
			_numUsedStreams = 3;	// vertex position, uv coords and normals
			_numUsedTextures = 0;
			
			
			_fragmentData = new Vector.<Number>(68, false);
			
			_vertexData = new Vector.<Number>(8);	
		}
		
		
		/**
		 * Get the vertex shader code for this shader
		 */
		override arcane function getVertexCode() : String
		{
			
			var code:String = "";
			
			code += "mov vt0, va0\n";
			
			code += "m44 vt1, vt0, vc0 \n"; //global position
			code += "m44 op, vt0, vc0 \n";
			code += "m44 v2, vt0, vc4\n";
			code += "mov v0, va1\n"; //uvs
			
			code += "mov vt0, va2\n"; // normals
			code += "nrm vt0.xyz, vt0.xyz\n";
			code += "mov v1, vt0\n"; // normals
			
			code += "mov v1, va0\n";
			
			return code;
		}

		/**
		 * Get the fragment shader code for this shader
		 * @param fragmentAnimatorCode Any additional fragment animation code imposed by the framework, used by some animators. Ignore this for now, since we're not using them.
		 */
		override arcane function getFragmentCode(fragmentAnimatorCode : String) : String
		{
			// simply set colour as output value
			var code:String = "";
			
			code += "mov ft2, v0\n"; //set xyzw
			code += "mov ft0, fc0.w\n";
			code += "mov ft0.w, fc2.z\n";
			code += "mov ft1.xyz, v2.xyz\n";
			
			code += "sub ft1.xyz, fc1.xyz, ft1.xyz\n";
			code += "dp3 ft1.w, ft1.xyz, ft1.xyz\n";
			code += "sqt ft1.w, ft1.w										\n"; 	// dist
			code += "sub ft1.w, ft1.w, fc2.x					\n";
			code += "mul ft1.w, ft1.w, fc2.y					\n";
			code += "sat ft1.w, ft1.w										\n";
			code += "sub ft2.xyz, fc0.xyz, ft0.xyz\n"; 			// (fogColor- col)
			code += "mul ft2.xyz, ft2.xyz, ft1.w					\n";			// (fogColor- col)*fogRatio
			code += "add ft0.xyz, ft0.xyz, ft2.xyz\n"; 
			
			code += "mul ft0.w, ft0.w, ft1.w\n";
			
			code += "mov oc, ft0\n";
		
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
			
			_fragmentData[index + 0] = _fogR;
			_fragmentData[index + 1] = _fogG;
			_fragmentData[index + 2] = _fogB;
			_fragmentData[index + 3] = 0;
			_fragmentData[index + 4] = camera.x;
			_fragmentData[index + 5] = camera.y;
			_fragmentData[index + 6] = camera.z;
			_fragmentData[index + 7] = 2;
			_fragmentData[index + 8] = _maxDistance >= _minDistance ? _minDistance : _maxDistance;
			_fragmentData[index + 9] = 1 / (_maxDistance - _minDistance);
			_fragmentData[index + 10] = 1;
			_fragmentData[index + 11] = 0;
			_fragmentData[index + 12] = 0;
			_fragmentData[index + 13] = 1;
			
			_fragmentData[index + 16] = renderable.inverseSceneTransform.rawData[12]; //x position
			_fragmentData[index + 17] = renderable.inverseSceneTransform.rawData[13]; //y position;
			_fragmentData[index + 18] = renderable.inverseSceneTransform.rawData[14]; //z position
			_fragmentData[index + 19] = 0;
			
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentData, uint(_fragmentData.length / 4));
			
			// upload the world-view-projection matrix
			_matrix.copyFrom(renderable.sceneTransform);
			_matrix.append(viewProjection);
			
			_globalMatrix.copyFrom(renderable.sceneTransform);
			
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _matrix, true);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, _globalMatrix, true);
			
			renderable.activateVertexBuffer(0, stage3DProxy);
			renderable.activateUVBuffer(1, stage3DProxy);
			renderable.activateVertexNormalBuffer(2, stage3DProxy);
			
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
		
		public function get minDistance():Number { return _minDistance; }
		public function set minDistance(value:Number):void { _minDistance = value; }
		
		public function get maxDistance():Number { return _maxDistance; }
		public function set maxDistance(value:Number):void { _maxDistance = value; }
		
		public function get fogColor():uint { return _fogColor; }
		public function set fogColor(value:uint):void {
			_fogColor = value;
			_fogA = ((value >> 24) & 0xff)/0xff;
			_fogR = ((value >> 16) & 0xff)/0xff;
			_fogG = ((value >> 8) & 0xff)/0xff;
			_fogB = (value & 0xff)/0xff;

		}
		
		public function set terrainMethodData(value:TerrainMethodData):void { _terrainMethodData = value; }
		public function get terrainMethodData():TerrainMethodData { return _terrainMethodData; }
		
		private function roundDec(numIn:Number, decimalPlaces:int):Number {
			var nExp:int = Math.pow(10,decimalPlaces) ; 
			var nRetVal:Number = Math.round(numIn * nExp) / nExp
			return nRetVal;
		}
		
	}
}