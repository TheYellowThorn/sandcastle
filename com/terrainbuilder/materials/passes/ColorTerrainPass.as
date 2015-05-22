/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.materials.passes
{
	import com.terrainbuilder.effects.objs.ColoredSplatData;
	import com.terrainbuilder.materials.objs.TerrainMethodData;
	
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.core.base.IRenderable;
	import away3d.core.managers.Stage3DProxy;
	import away3d.lights.DirectionalLight;
	import away3d.materials.passes.MaterialPassBase;
	import away3d.textures.BitmapTexture;
	import away3d.textures.Texture2DBase;

	use namespace arcane;

	/**
	 * ColorTerrainPass is a pass rendering a colored grey scale image for ColorTerrainMaterial
	 */
	public class ColorTerrainPass extends MaterialPassBase
	{
		private var _coloredSplatDatas:Vector.<ColoredSplatData>;
		private var _terrainMethodData:TerrainMethodData;
		
		private var _matrix : Matrix3D = new Matrix3D();
		private var _globalMatrix : Matrix3D = new Matrix3D();
		private var _fragmentData : Vector.<Number>;
		private var _normalTextures:Vector.<Texture2DBase>;
		private var _useOverlayBlend:Boolean;
		
		private var _blendTextureSize:uint;
		private var _textureSize:uint;
		private var _splats:Vector.<BitmapData>;
		private var _blendingBitmapDatas:Vector.<BitmapData>;
		private var _splatColors:Vector.<uint>;
		private var _tileData:Number;
		private var _heightMapSplatRanges:Vector.<Array>;
		
		private var _compositeSplatBitmapDatas:Vector.<BitmapData>;
		private var _compositeSplatTextures:Vector.<Texture2DBase>;
		private var _compositeBlendingBitmapDatas:Vector.<BitmapData>;
		private var _compositeBlendingTextures:Vector.<Texture2DBase>;
		
		private var _splatTexture:BitmapTexture;
		private var _splatTexture2:BitmapTexture;
		private var _splatTexture3:BitmapTexture;
		private var _splatBitmapData:BitmapData;
		private var _splatBitmapData2:BitmapData;
		private var _splatBitmapData3:BitmapData;
		private var _blendingTexture:BitmapTexture;
		private var _blendingTexture2:BitmapTexture;
		private var _blendingTexture3:BitmapTexture;
		private var _blendingBitmapData:BitmapData;
		private var _blendingBitmapData2:BitmapData;
		private var _blendingBitmapData3:BitmapData;
		
		private var _vertexData : Vector.<Number>;
		private var _amplitudeX:Number = 0;
		private var _frequencyX:Number = 0;
		private var _offsetX:Number = 0;
		
		private var _amplitudeY:Number = 0;
		private var _frequencyY:Number = 0;
		private var _offsetY:Number = 0;
		private var _hasNormalMaps:Boolean = false;
		private var _useNormalMaps:Boolean;
		private var _addFog:Boolean;
		private var _directionalLights:Vector.<DirectionalLight> = new Vector.<DirectionalLight>();
		
		public function ColorTerrainPass(coloredSplatDatas:Vector.<ColoredSplatData>, terrainMethodData:TerrainMethodData, useOverlayBlend:Boolean = true, useNormalMaps:Boolean = true, addFog:Boolean = false)
		{
			super();
			
			_coloredSplatDatas = coloredSplatDatas;
			_terrainMethodData = terrainMethodData;
			_useNormalMaps = useNormalMaps;
			_addFog = addFog;
			
			_normalTextures = new Vector.<Texture2DBase>();
			for (var i:uint = 0; i<coloredSplatDatas.length; i++) {
				var normalMapTexture:BitmapTexture = coloredSplatDatas[i].normalMap && _useNormalMaps ? new BitmapTexture(coloredSplatDatas[i].normalMap) : null;
				if (normalMapTexture !== null) { 
					_hasNormalMaps = true; 
					_normalTextures.push(normalMapTexture);
				}
			}
			_useOverlayBlend = useOverlayBlend;
			
			var splats:Vector.<BitmapData> = new Vector.<BitmapData>();
			var blendingBitmapDatas:Vector.<BitmapData> = new Vector.<BitmapData>();
			var splatColors:Vector.<uint> = new Vector.<uint>();
			var heightMapSplatRanges:Vector.<Array> = new Vector.<Array>();
			
			for (i = 0; i<_coloredSplatDatas.length; i++) {
				splats.push(_coloredSplatDatas[i].splat);
				splatColors.push(_coloredSplatDatas[i].color);
				blendingBitmapDatas.push(_coloredSplatDatas[i].blend);
				heightMapSplatRanges.push(_coloredSplatDatas[i].heightMapRange);
				
			}
			
			_blendTextureSize = _coloredSplatDatas[0].blend.width;
			_textureSize = _coloredSplatDatas[0].splat.width;
			_splats = splats;
			_splatColors = splatColors;
			_blendingBitmapDatas = blendingBitmapDatas;
			_tileData = terrainMethodData.tileData;
			_heightMapSplatRanges = heightMapSplatRanges;
			
			if (_splatColors.length !== _splats.length) throw new Error("EACH TEXTURE SPLAT MUST HAVE A CORRESPONDING COLOR");
			if (_heightMapSplatRanges.length !== _splats.length) throw new Error("HEIGHT MAP TILING DATA DOES NOT MATCH THE AMOUNT OF TEXTURES");
			
			_compositeSplatBitmapDatas = new Vector.<BitmapData>();
			_compositeSplatTextures = new Vector.<Texture2DBase>();
			_compositeBlendingBitmapDatas = new Vector.<BitmapData>();
			_compositeBlendingTextures = new Vector.<Texture2DBase>();
			
			createSplatTextures();
			createBlendingTextures();
			
			_numUsedStreams = 3;	// vertex position, uv coords and normals
			_numUsedTextures = _normalTextures.length + _compositeSplatTextures.length + _compositeBlendingTextures.length;//(Math.ceil(_splats.length / 3) + 1)* 2;	// splat and blending textures added
			
			_fragmentData = new Vector.<Number>(112, false);
			
			_vertexData = new Vector.<Number>(8);
			updateVertexData();
			
		}
		
		private function createSplatTextures():void {
			
			for (var i:uint = 0; i<Math.ceil(_splats.length / 3); i++) {
				_splatBitmapData = new BitmapData(_textureSize, _textureSize, true, 0xFF990000);
				_compositeSplatBitmapDatas.push(_splatBitmapData);
			}
			
			for (i = 0; i<_splats.length; i++) {
				updateSplat(i, _splats[i]);
			}
			
			for (i = 0; i<Math.ceil(_splats.length / 3); i++) {
				_splatTexture = new BitmapTexture(_compositeSplatBitmapDatas[i]);
				_compositeSplatTextures.push(_splatTexture);
			}

		}
		
		public function updateSplat(splatIndex:uint, splat:BitmapData):void {
			
			var tempSplat:BitmapData = splat;
			var fromChannel:uint = BitmapDataChannel.RED;
			var currentChannel:uint;
			
			if (splatIndex % 3 == 0) { currentChannel = BitmapDataChannel.RED; }
			if (splatIndex % 3 == 1) { currentChannel = BitmapDataChannel.GREEN; }
			if (splatIndex % 3 == 2) { currentChannel = BitmapDataChannel.BLUE; }
			if (splatIndex % 3 == 3) { currentChannel = BitmapDataChannel.ALPHA; }
			
			var i:uint = uint(splatIndex / 3);
			_compositeSplatBitmapDatas[i].copyChannel(tempSplat, tempSplat.rect, new Point(), fromChannel, currentChannel);
			
			if (_compositeBlendingTextures.length > 0 && _compositeSplatBitmapDatas[i]) {
				BitmapTexture(_compositeSplatBitmapDatas[i]).invalidateContent();
			}

		}
		
		public override function dispose():void {
			
			clearTextures();
			
			super.dispose();
		}
		
		public function clearTextures():void {
			
			for (var i:uint = 0; i<_compositeSplatTextures.length; i++) {
				
				if (_compositeSplatTextures[i]) {
					BitmapTexture(_compositeSplatTextures[i]).bitmapData.dispose();
					_compositeSplatTextures[i].dispose();
					_compositeSplatTextures[i] = null;
				}
			}
			for (i = 0; i<_compositeBlendingTextures.length; i++) {
				if (_compositeBlendingTextures[i]) {
					BitmapTexture(_compositeBlendingTextures[i]).bitmapData.dispose();
					_compositeBlendingTextures[i].dispose();
					_compositeBlendingTextures[i] = null;
				}
			}
			for (i = 0; i<_compositeSplatBitmapDatas.length; i++) {
				if (_compositeSplatBitmapDatas[i]) {
					_compositeSplatBitmapDatas[i].dispose();
					_compositeSplatBitmapDatas[i] = null;
				}
			}
			for (i = 0; i<_compositeBlendingBitmapDatas.length; i++) {
				if (_compositeBlendingBitmapDatas[i]) {
					_compositeBlendingBitmapDatas[i].dispose();
					_compositeBlendingBitmapDatas[i] = null;
				}
			}
			for (i = 0; i<_normalTextures.length; i++) {
				if (_normalTextures[i]) {
					_normalTextures[i].dispose();
					_normalTextures[i] = null;
				}
			}

		}
		
		private function createBlendingTextures():void {
			
			for (var i:uint = 0; i<Math.ceil(_splats.length / 3); i++) {
				_blendingBitmapData = new BitmapData(_blendTextureSize, _blendTextureSize, true, 0xFF000000);
				_compositeBlendingBitmapDatas.push(_blendingBitmapData);
			}
			
			for (i = 0; i<_blendingBitmapDatas.length; i++) {
				updateBlend(i, _blendingBitmapDatas[i]);
			}
			
			for (i = 0; i<Math.ceil(_splats.length / 3); i++) {
				_blendingTexture = new BitmapTexture(_compositeBlendingBitmapDatas[i]);
				_compositeBlendingTextures.push(_blendingTexture);
			}
			
		}
		
		public function updateBlend(blendIndex:uint, blend:BitmapData):void {
			
			var tempBlend:BitmapData = blend;
			var fromChannel:uint = BitmapDataChannel.RED;
			var currentChannel:uint;
			
			if (blendIndex % 3 == 0) { currentChannel = BitmapDataChannel.RED; }
			if (blendIndex % 3 == 1) { currentChannel = BitmapDataChannel.GREEN; }
			if (blendIndex % 3 == 2) { currentChannel = BitmapDataChannel.BLUE; }
			if (blendIndex % 3 == 3) { currentChannel = BitmapDataChannel.ALPHA; }
			
			var i:uint = uint(blendIndex / 3);
			_compositeBlendingBitmapDatas[i].copyChannel(tempBlend, tempBlend.rect, new Point(), fromChannel, currentChannel);
			
			if (_compositeBlendingTextures.length > 0 && _compositeBlendingTextures[i]) {
				BitmapTexture(_compositeBlendingTextures[i]).invalidateContent();
			}
			
		}

		public function get useOverlayBlend():Boolean { return _useOverlayBlend; }
		
		
		public function get amplitudeX():Number 
		{
			return _amplitudeX;
		}
		
		public function set amplitudeX(value:Number):void 
		{
			_amplitudeX = value;
			updateVertexData();
		}
		
		public function get frequencyX():Number 
		{
			return _frequencyX;
		}
		
		public function set frequencyX(value:Number):void 
		{
			_frequencyX = (value * 100);
			updateVertexData();
		}
		
		public function get offsetX():Number 
		{
			return _offsetX;
		}
		
		public function set offsetX(value:Number):void 
		{
			_offsetX = value;
			updateVertexData();
		}
		
		public function get amplitudeY():Number 
		{
			return _amplitudeY;
		}
		
		public function set amplitudeY(value:Number):void 
		{
			_amplitudeY = value;
			updateVertexData();
		}
		
		public function get frequencyY():Number 
		{
			return _frequencyY;
		}
		
		public function set frequencyY(value:Number):void 
		{
			_frequencyY = (value * 100);
			updateVertexData();
		}
		
		public function get offsetY():Number 
		{
			return _offsetY;
		}
		
		public function set offsetY(value:Number):void 
		{
			_offsetY = value;
			updateVertexData();
		}
		
		private function updateVertexData():void
		{
			_vertexData[0] = offsetX;
			_vertexData[1] = amplitudeX;
			_vertexData[2] = frequencyX;
			
			_vertexData[4] = offsetY;
			_vertexData[5] = amplitudeY;
			_vertexData[6] = frequencyY;
		}
		
		/**
		 * Get the vertex shader code for this shader
		 */
		override arcane function getVertexCode() : String
		{
			
			var code:String = "";
			
			code += "mov vt0, va0\n";
			
			code += "m44 op, vt0, vc0 \n";
			
			code += "mov v2, va0\n";
			code += "m44 v3, vt0, vc4\n";
			
			code += "mov v0, va1\n"; //uvs
			
			code += "mov vt0, va2\n"; // normals
			code += "nrm vt0.xyz, vt0.xyz\n";
			code += "mov v1, vt0\n"; // normals
			
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
			
			var specularRegisters:uint = 1;
			var terrainConstantIndex:uint = _terrainMethodData.numLights * 2 + specularRegisters; //diffuse + ambient
		
			for (var i:uint = 0; i<_compositeSplatTextures.length; i++) {
				
				
				code += "mov ft2, v0\n"; //set xyzw
				code += "mul ft2.xyz, v0.xyz, fc" + (terrainConstantIndex).toString() + ".x\n"; //multiply uvs by tiles
				code += "tex ft0, ft2, fs"+ (2*i).toString() +" <2d, repeat, linear, miplinear>\n"; // store splat texture
				
				code += "mov ft2, v0\n"; //set xyzw
				code += "add ft2.xxzz, v2.xxzz, fc" + (terrainConstantIndex + 2).toString() + ".wwww\n"; //OFFSET POSITION (TILES ARE POSITIONED -1 to 1, not 0 to 2) USING GLOBAL POSITION
				code += "div ft2.xxzz, ft2.xxzz, fc" + (terrainConstantIndex + 2).toString() + ".zzzz\n"; //DIVIDE BY TILE SIZE
				code += "sub ft2.y, fc" + (terrainConstantIndex + 3).toString() + ".z, ft2.z\n";
				
				code += "tex ft1, ft2, fs"+ (2*i+1).toString() +" <2d,linear,miplinear,wrap>\n"; //store blend texture
				
				var comps : Array = [ "x","y","z","w" ];
				
				var coloredSplatStartIndex:uint = i * 3;
				var coloredSplatEndIndex:uint = _coloredSplatDatas.length - coloredSplatStartIndex > 3 ? 3 : _coloredSplatDatas.length;
				for (var j:uint = coloredSplatStartIndex; j<coloredSplatEndIndex; j++) {
					
					if (_hasNormalMaps) {
						if (j == 0) {
							code += "mul ft2.xyz, v0.xyz, fc" + (terrainConstantIndex).toString() + ".x\n"; //multiply uvs by tiles
							code += "tex ft6, ft2, fs"+ (2*i + 2 + j).toString() +" <2d,linear,miplinear,wrap>\n"; //store blend texture
						} else {
							code += "mul ft2.xyz, v0.xyz, fc" + (terrainConstantIndex).toString() + ".x\n"; //multiply uvs by tiles
							code += "tex ft7, ft2, fs"+ (2*i + 2 + j).toString() +" <2d,linear,miplinear,wrap>\n"; //store blend texture
							code += "sub ft7.xyz, ft7.xyz, ft6.xyz\n";
						}
					}
					
					var comp:String = comps[j % 3];
					var colorRegister:String = "fc" + (i + (terrainConstantIndex + 7)).toString();

					code += "mov ft2.xyz, ft0." + comp + comp + comp + "\n";
					code += "mov ft3.xyz, " + colorRegister + "." + comp + comp + comp + "\n";
					
					code += "mul ft3.xyz, ft3.xyz, fc" + (terrainConstantIndex + 1).toString() + ".xyz\n";
					code += "frc ft3.xyz, ft3.xyz\n";
					code += "mul ft3.xyz, ft3.xyz, fc" + (terrainConstantIndex).toString() + ".yyy\n";
					
					code += "mul ft2.xyz, ft2.xyz, ft3.xyz\n"; //SATURATE WITH COLOR
					code += "add ft2.xyz, ft2.xyz, ft3.xyz\n"; //SATURATE WITH COLOR
					
					if (j == 0) {
						code += "mov ft5.xyz, ft2.xyz\n";
					} else {
						code += "sub ft2.xyz, ft2.xyz, ft5.xyz\n";
					}
					
					var currLowHeightRegister:String = "fc" + (i + (terrainConstantIndex + 10)).toString();
					var currHighHeightRegister:String = "fc" + (i + (terrainConstantIndex + 13)).toString();
					var currSlopeRegister:String = "fc" + (i + (terrainConstantIndex + 16)).toString();
					
					if (_coloredSplatDatas[j].useSlopeBlend == true) { 
						
						code += "mov ft4.xyzw, fc" + (terrainConstantIndex + 3).toString() + ".zzzz\n";
						code += "mov ft4.xyz, fc" + (terrainConstantIndex + 3).toString() + ".yzy\n";
						code += "dp3 ft4.w, v1.xyz, ft4.xyz\n"; //RETURNS THE PERCENTAGE OF THE ANGLE BETWEEN 0 and 1
						
						code += "mov ft4.xz, " + currSlopeRegister + "." + comp + "\n";
						code += "mul ft4.xz, ft4.xz, fc" + (terrainConstantIndex + 1).toString() + ".xz\n";
						code += "frc ft4.xz, ft4.xz\n";
						
						code += "sub ft4.w, ft4.w, ft4.x\n";
						code += "div ft4.w, ft4.w, ft4.z\n"; //MULTIPLY BY INVERSE OF DIFFERENCE TO EXPAND RANGE
						code += "sat ft4.w, ft4.w\n";
						code += "sub ft4.w, fc" + (terrainConstantIndex + 3).toString() + ".z, ft4.w\n";
						
						code += "mul " + "ft1." + comp + ", "  + "ft1." + comp + ", ft4.w\n"; //MULTIPY BLEND BY VISIBLE HEIGHTMAP COLOR

					}
					if (_heightMapSplatRanges[j]) {
						
						code += "mov ft3.xyzw, fc" + (terrainConstantIndex + 3).toString() + ".zzzz\n";
						code += "div ft3.w, v2.y, fc" + (terrainConstantIndex + 3).toString() + ".x\n";
						code += "sub ft3.w, ft3.w, " + currLowHeightRegister + "." + comp + "\n"; //SUBTRACT LOW COLOR VALUE
						code += "mul ft3.w, ft3.w, " + currHighHeightRegister + "." + comp + "\n"; //MULTIPLY BY INVERSE OF DIFFERENCE TO EXPAND RANGE
						code += "sat ft3.w, ft3.w\n";
						
						code += "mul " + "ft1." + comp + ", "  + "ft1." + comp + ", ft3.w\n"; //MULTIPY BLEND BY VISIBLE HEIGHTMAP COLOR
						
					}
					
					
					
					if (j == 0) {
						
						code += "mul ft2.xyz, ft2.xyz, " + "ft1." + comp + "\n";
						code += "mov ft5.xyz, ft2.xyz\n";
						code += "mov ft5.w, ft1." + comp + "\n";
						
						if (_hasNormalMaps) {
							code += "mov ft6.w, ft1." + comp + "\n";
						}
					} else {
						code += "mul ft2.xyz, ft2.xyz, " + "ft1." + comp + "\n";
						code += "add ft5.xyz, ft5.xyz, ft2.xyz\n";
						code += "add ft5.w, ft5.w, " + "ft1." + comp + "\n"; //ADD ALPHAS FOR CORRECT OVERLAP
						
						if (_hasNormalMaps) {
							code += "mul ft7.xyz, ft7.xyz, " + "ft1." + comp + "\n";
							code += "add ft6.xyz, ft6.xyz, ft7.xyz\n";
							code += "add ft6.w, ft6.w, " + "ft1." + comp + "\n"; //ADD ALPHAS FOR CORRECT OVERLAP
						}
					}
					
						
				}
					
				
			}
			
			code += "mov ft0, ft5\n";
			code += "nrm ft2.xyz, v1\n";     // renormalize interpolated normal since attribute interpolation changes lengths
			
			if (_hasNormalMaps) {
				
				code += "sub ft6.xy, ft6.xy, fc" + (terrainConstantIndex + 1).toString() + ".ww\n";
				code += "sub ft6.z, ft6.z, fc" + (terrainConstantIndex + 1).toString() + ".w\n";
				code += "nrm ft6.xyz, ft6.xyz\n";
					
				code += "add ft2.xy, ft2.xy, ft6.xy\n";
				code += "nrm ft2.xyz, ft2.xyz\n";
					
			} 
			
			for (i = 0; i<_terrainMethodData.numLights; i++) {
				var lightIndex:uint = i * 2 + specularRegisters;
				comp = comps[i % 4];
				code += "dp3 ft3." + comp + ", fc" + lightIndex + ".xyz, ft2.xyz\n"; // standard dot3 lambert shading: d = max(0, dot3(light, normal))
				code += "max ft3." + comp + ", ft3." + comp + ", fc" + (terrainConstantIndex + 3).toString() + ".y\n";  // fc0.w contains 0, so this clamps to 0
				
				if (i == 0) { code += "mov ft5.xyz, ft0.xyz\n"; }
				
				//CALCULATE DIFFUSE
				code += "mov ft4.xyz, fc" + (lightIndex).toString() + ".www\n";
				code += "mul ft4.xyz, ft4.xyz, fc" + (terrainConstantIndex + 1).toString() + ".xyz\n";
				code += "frc ft4.xyz, ft4.xyz\n";
				code += "mul ft4.xyz, ft4.xyz, fc" + (terrainConstantIndex).toString() + ".y\n";
				code += "mul ft4.xyz, ft4.xyz, fc" + (terrainConstantIndex + 2).toString() + ".x\n"; //Diffuse Strength
				
				code += "mul ft4.xyz, ft4.xyz, ft3." + comp + "\n";
				
				if (i == 0) { code += "mov ft1.xyz, ft0.xyz\n"; }
				else { code += "mov ft1.xyz, ft5.xyz\n"; }
				
				code += "mul ft1.xyz, ft1.xyz, ft4.xyz\n";
				code += "add ft1.xyz, ft1.xyz, fc" + (lightIndex + 1).toString() + ".xyz\n";
				
				if (i == 0) { code += "mov ft0.xyz, ft1.xyz\n"; }
				else {  code += "add ft0.xyz, ft0.xyz, ft1.xyz\n"; }
				
			}
			
			//START SPECULAR
			lightIndex = 0 + specularRegisters;
			code += "dp3 ft3.x, fc" + lightIndex + ".xyz, ft2.xyz\n"; // standard dot3 lambert shading: d = max(0, dot3(light, normal))
			code += "sat ft3.x, ft3.x\n";
			code += "pow ft3.x, ft3.x, fc0.x\n";
			code += "mov ft2.xyz, fc0.www\n";
			code += "mul ft2.xyz, ft2.xyz, fc" + (terrainConstantIndex + 1).toString() + ".xyz\n";
			code += "frc ft2.xyz, ft2.xyz\n";
			code += "mul ft2.xyz, ft2.xyz, fc" + (terrainConstantIndex).toString() + ".yyy\n";
			code += "mul ft2.xyz, ft2.xyz, ft3.x\n";
			code += "mul ft2.xyz, ft2.xyz, fc0.y\n";
			code += "add ft0.xyz, ft0.xyz, ft2.xyz\n";
			//END SPECULAR
			
			// START FOG SHADER
			if (_addFog) {
				
				code += "mov ft1.xyz, v3.xyz\n";
				
				code += "sub ft1.xyz, fc" + (terrainConstantIndex + 5).toString() + ".xyz, ft1.xyz\n";
				code += "dp3 ft1.w, ft1.xyz, ft1.xyz\n";
				code += "sqt ft1.w, ft1.w										\n"; 	// dist
				code += "sub ft1.w, ft1.w, fc" + (terrainConstantIndex + 6).toString() + ".x					\n";
				code += "mul ft1.w, ft1.w, fc" + (terrainConstantIndex + 6).toString() + ".y					\n";
				code += "sat ft1.w, ft1.w										\n";
				
				
				code += "sub ft2.xyz, fc" + (terrainConstantIndex + 4).toString() + ".xyz, ft0.xyz\n"; 			// (fogColor- col)
				code += "mul ft2.xyz, ft2.xyz, ft1.w					\n";			// (fogColor- col)*fogRatio
				code += "add ft0.xyz, ft0.xyz, ft2.xyz\n"; 
				
				code += "max ft0.w, ft0.w, ft1.w\n"; //MAX ALPHA FOR SECOND+ PASS
				
			}
			// END FOG SHADER 
			
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
			var totalDirectionalLights:uint = _lightPicker.castingDirectionalLights.length > 0 ? _lightPicker.castingDirectionalLights.length : _lightPicker.directionalLights.length;
			
			for (var i:uint = 0; i<_lightPicker.castingDirectionalLights.length; i++) {
				if (_directionalLights.length < 2) {
					if (_directionalLights.indexOf(_lightPicker.castingDirectionalLights[i]) == -1) {
						_directionalLights.push(_lightPicker.castingDirectionalLights[i]);
					}
				}
			}
			for (i = 0; i<_lightPicker.directionalLights.length; i++) {
				if (_directionalLights.length < 2) {
					if (_directionalLights.indexOf(_lightPicker.directionalLights[i]) == -1) {
						_directionalLights.push(_lightPicker.directionalLights[i]);
					}
				}
			}
			
			_terrainMethodData.numLights = _directionalLights.length;
			
			if (_useOverlayBlend) {
				_blendFactorSource = Context3DBlendFactor.SOURCE_ALPHA;
				_blendFactorDest = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
				_enableBlending = true;
			}
			
			super.activate(stage3DProxy, camera);
			
			for (i = 0; i<_compositeSplatTextures.length; i++) {
				
				stage3DProxy._context3D.setTextureAt(2*i, _compositeSplatTextures[uint((i + 1)/2)].getTextureForStage3D(stage3DProxy));
				stage3DProxy._context3D.setTextureAt(2*i + 1, _compositeBlendingTextures[uint((i + 1)/2)].getTextureForStage3D(stage3DProxy));

			}
			for (var j:uint = 0; j<_normalTextures.length; j++) {
				if (_normalTextures[j]) { stage3DProxy._context3D.setTextureAt(2*(i - 1) + 2 + j, _normalTextures[j].getTextureForStage3D(stage3DProxy)); }
			}
			
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, _vertexData, 2);
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
			
			// expect a directional light to be assigned
			var specularIndex:uint = 0;
			var specularRegisters:uint = 1;
			
			_fragmentData[specularIndex + 0] = _terrainMethodData.gloss;
			_fragmentData[specularIndex + 1] = _terrainMethodData.specular;
			_fragmentData[specularIndex + 2] = 0;
			_fragmentData[specularIndex + 3] = ((_terrainMethodData.specularColor >> 16) & 0xFF) * 1000000 + ((_terrainMethodData.specularColor >> 8) & 0xFF) * 1000 + (_terrainMethodData.specularColor & 0xFF);
			
			var light1:DirectionalLight;
			
			for (var i:uint = 0; i<_terrainMethodData.numLights; i++) {
				
				var light:DirectionalLight = _directionalLights[i];
				if (i == 0) { light1 = light; }
				
				// the light direction relative to the renderable object (model space)
				var objectSpaceDir:Vector3D = renderable.inverseSceneTransform.transformVector(light.direction);
				objectSpaceDir.normalize();
				
				var lightIndex:uint = i * 8 + (specularRegisters * 4);
				_fragmentData[lightIndex + 0] = -objectSpaceDir.x;
				_fragmentData[lightIndex + 1] = -objectSpaceDir.y;
				_fragmentData[lightIndex + 2] = -objectSpaceDir.z;
				_fragmentData[lightIndex + 3] = ((light.color >> 16) & 0xFF) * 1000000 + ((light.color >> 8) & 0xFF) * 1000 + (light.color & 0xFF);
				
				_fragmentData[lightIndex + 4] = ((_terrainMethodData.ambientColor >> 16) & 0xff)/0xff * _terrainMethodData.ambient * ((light.ambientColor >> 16) & 0xFF)/0xff * light.ambient;
				_fragmentData[lightIndex + 5] = ((_terrainMethodData.ambientColor >> 8) & 0xff)/0xff * _terrainMethodData.ambient * ((light.ambientColor >> 8) & 0xFF)/0xff * light.ambient;
				_fragmentData[lightIndex + 6] = (_terrainMethodData.ambientColor & 0xff)/0xff * _terrainMethodData.ambient * (light.ambientColor & 0xFF)/0xff * light.ambient;
				_fragmentData[lightIndex + 7] = _terrainMethodData.normalMapStrength;//0.5;
			}
			
			
			var index:uint = _terrainMethodData.numLights*8 + (specularRegisters * 4);
			
			_fragmentData[index + 0] = _terrainMethodData.tileData;
			_fragmentData[index + 1] = 1000 / 0xFF;
			_fragmentData[index + 2] = _terrainMethodData.worldGridPosition.x * (1 / _terrainMethodData.squaredTiles);
			_fragmentData[index + 3] = _terrainMethodData.worldGridPosition.y * (1 / _terrainMethodData.squaredTiles);
			
			_fragmentData[index + 4] = 1 / 1000000000;
			_fragmentData[index + 5] = 1 / 1000000;
			_fragmentData[index + 6] = 1 / 1000;
			_fragmentData[index + 7] = _terrainMethodData.normalMapStrength < 0 ? 0 : _terrainMethodData.normalMapStrength;
			
			_fragmentData[index + 8] = light1.diffuse;
			_fragmentData[index + 9] = _terrainMethodData.squaredTiles;
			_fragmentData[index + 10] = _terrainMethodData.tileSize * _terrainMethodData.squaredTiles;
			_fragmentData[index + 11] = _terrainMethodData.tileSize * (_terrainMethodData.squaredTiles / 2);//_terrainMethodData.squaredTiles * _terrainMethodData.tileSize / 2;
			
			_fragmentData[index + 12] = _terrainMethodData.maxHeight;
			_fragmentData[index + 13] = 0;
			_fragmentData[index + 14] = 1;
			_fragmentData[index + 15] = _terrainMethodData.anchorYPosition;
			
			_fragmentData[index + 16] = ((_terrainMethodData.fogColor >> 16) & 0xff)/0xff;
			_fragmentData[index + 17] = ((_terrainMethodData.fogColor >> 8) & 0xff)/0xff;
			_fragmentData[index + 18] = ((_terrainMethodData.fogColor) & 0xff)/0xff;
			_fragmentData[index + 19] = 0;
			_fragmentData[index + 20] = camera.x;
			_fragmentData[index + 21] = camera.y;
			_fragmentData[index + 22] = camera.z;
			_fragmentData[index + 23] = 2;
			_fragmentData[index + 24] = _terrainMethodData.maximumFogDistance >= _terrainMethodData.minimumFogDistance ? _terrainMethodData.minimumFogDistance : _terrainMethodData.maximumFogDistance;
			_fragmentData[index + 25] = 1 / (_terrainMethodData.maximumFogDistance - _terrainMethodData.minimumFogDistance);
			_fragmentData[index + 26] = 1;
			_fragmentData[index + 27] = 0;
			
			for (i = 0; i<Math.ceil(_splatColors.length / 3); i++) {
				var startIndex:uint = index + 28;
				var colInd:uint = i*3;
				var addInd:uint = i*4;
				
				var splatRangStartIndex:uint = index + 40;
				var splatRangEndIndex:uint = index + 52;
				var splatSlopeIndex:uint = index + 64;
				
				var coloredSplatStartIndex:uint = i * 3;
				var coloredSplatEndIndex:uint = _coloredSplatDatas.length - coloredSplatStartIndex > 3 ? 3 : _coloredSplatDatas.length;
				
				for (var j:uint = coloredSplatStartIndex; j<coloredSplatEndIndex; j++) {
					
					var j3:uint = j % 3;
				
					_splatColors[colInd + j3] = _coloredSplatDatas[colInd + j3].color;
					
					if (colInd + j3 < _splatColors.length) {
						
						_fragmentData[startIndex + addInd + j3] = ((_splatColors[colInd + j3] >> 16) & 0xFF) * 1000000 + ((_splatColors[colInd + j3] >> 8) & 0xFF) * 1000 + (_splatColors[colInd + j3] & 0xFF) + ((_splatColors[colInd + j3] >> 24) & 0xFF)  / 1000;
						
						_fragmentData[splatRangStartIndex + addInd + j3] = _heightMapSplatRanges[colInd + j3][0] ? _heightMapSplatRanges[colInd + j3][0] / _terrainMethodData.maxHeight : 0;
						_fragmentData[splatRangEndIndex + addInd + j3] = _heightMapSplatRanges[colInd + j3][1] ? _terrainMethodData.maxHeight / (_heightMapSplatRanges[colInd + j3][1] - _heightMapSplatRanges[colInd + j3][0]) : 0;
						_fragmentData[splatSlopeIndex + addInd + j3] = roundDec(_coloredSplatDatas[colInd + j3].maxOpacityAngle, 2)*1000000000 + roundDec(_coloredSplatDatas[colInd + j3].opacityAngleSpreadRange, 2)*1000;
						
					}
				}
			}
			
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentData, uint(_fragmentData.length / 4));
			
			// upload the world-view-projection matrix
			_matrix.copyFrom(renderable.sceneTransform);
			_matrix.append(viewProjection);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _matrix, true);
			
			_globalMatrix.copyFrom(renderable.sceneTransform);
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
			
			for (var i:uint = 0; i<_numUsedTextures; i++) {
				context.setTextureAt(i, null);
			}
			context.setVertexBufferAt(1, null);
		}
		
		private function roundDec(numIn:Number, decimalPlaces:int):Number {
			var nExp:int = Math.pow(10,decimalPlaces) ; 
			var nRetVal:Number = Math.round(numIn * nExp) / nExp
			return nRetVal;
		}
		
		public function get hasNormalMaps():Boolean { return _hasNormalMaps; }
		public function get coloredSplatDatas():Vector.<ColoredSplatData> { return _coloredSplatDatas; }
	}
}