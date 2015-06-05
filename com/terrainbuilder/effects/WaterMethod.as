/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.effects
{
	import com.terrainbuilder.materials.methods.BasicDiffuseMethodProxy;
	
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.geom.Point;
	
	import away3d.arcane;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;
	import away3d.materials.methods.MethodVO;
	import away3d.textures.BitmapTexture;
	
	use namespace arcane;

	public class WaterMethod extends BasicDiffuseMethodProxy
	{
		private var _textureSize:uint;
		private var _perlinTexture:BitmapTexture;
		private var _perlinBitmapData:BitmapData;
		private var _perlinTexture2:BitmapTexture;
		private var _perlinBitmapData2:BitmapData;
		private var _overlayTexture:BitmapTexture;
		private var _overlayBitmapData:BitmapData;
		
		private var _data : Vector.<Number>;
		private var offsetX1:Number = 0;
		private var offsetY1:Number = 0;
		private var offsetX2:Number = 0;
		private var offsetY2:Number = 0;
		public var offsetX1Speed:Number = 5;
		public var offsetY1Speed:Number = 5;
		public var offsetX2Speed:Number = -5;
		public var offsetY2Speed:Number = -5;
		public var colorMax:Number = 0xFF999999;
		public var colorMin:Number = 0xFF696969;
		public var waterColorHighlight:uint = 0xFFF0F0F0;
		public var waterColorShadow:uint = 0xFF666666;
		public var overlayTiles:uint;
		public var overlayBlendAmount:Number;
		private var _flowTowardsCenter:Boolean;
		private var _shimmer1BaseSize:uint;
		private var _shimmer2BaseSize:uint;
		
		/**
		 *
		 * @param splatTextures An array of Texture2DProxyBase containing the detailed textures to be tiled.
		 * @param blendData The texture containing the blending data. The red, green, and blue channels contain the blending values for each of the textures in splatTextures, respectively.
		 * @param tileData The amount of times each splat texture needs to be tiled. The first entry in the array applies to the base texture, the others to the splats. If omitted, the default value of 50 is assumed for each.
		 */
		public function WaterMethod(textureSize:uint = 512, perlinBaseSize1:uint = 16, perlinBaseSize2:uint = 64, _overlayBitmapData = null, overlayTiles:uint = 8, overlayBlendAmount:Number = 0.5, flowTowardsCenter:Boolean = true)
		{
			super();
			
			_textureSize = textureSize;
			_shimmer1BaseSize = perlinBaseSize1;
			_shimmer2BaseSize = perlinBaseSize2;
			
			_perlinBitmapData = new BitmapData(_textureSize, _textureSize, true, 0xFF990000);
			_perlinBitmapData.perlinNoise(_shimmer1BaseSize, _shimmer1BaseSize, 8, 100, true, true, 7, true, null);
			
			_perlinBitmapData2 = new BitmapData(_textureSize, _textureSize, true, 0xFF990000);
			_perlinBitmapData2.perlinNoise(_shimmer2BaseSize, _shimmer2BaseSize, 8, 102, true, true, 7, true, null);
			
			_perlinBitmapData.copyChannel(_perlinBitmapData2, _perlinBitmapData2.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.GREEN);
			_perlinBitmapData2.dispose();
			
			_perlinTexture = new BitmapTexture(_perlinBitmapData);
			
			this.overlayTiles = overlayTiles;
			this.overlayBlendAmount = overlayBlendAmount;
			_flowTowardsCenter = flowTowardsCenter;
	
			this.overlayBitmapData = _overlayBitmapData;
			
			
		}
		
		override arcane function initConstants(vo : MethodVO) : void
		{
			
			var data : Vector.<Number> = vo.fragmentData;
			var index : int = vo.fragmentConstantsIndex;
			
			data[index + 0] = offsetX1 += (offsetX1Speed / 100000);
			data[index + 1] = offsetY1 += (offsetY1Speed / 100000);
			data[index + 2] = offsetX2 += (offsetX2Speed / 100000);
			data[index + 3] = offsetY2 += (offsetY2Speed / 100000);
			data[index + 4] = 2;
			data[index + 5] = 0.5;
			data[index + 6] = colorMax;
			data[index + 7] = colorMin;
		
		}
		
		arcane override function getFragmentPostLightingCode(vo : MethodVO, regCache : ShaderRegisterCache, targetReg : ShaderRegisterElement) : String
		{
			
			var code : String = "";
			
			var blendMapStored:Boolean = false;
			
			var constRegister : ShaderRegisterElement = regCache.getFreeFragmentConstant();
			vo.fragmentConstantsIndex = constRegister.index*4;
			var constRegister2 : ShaderRegisterElement = regCache.getFreeFragmentConstant();
			var highlightConstRegister : ShaderRegisterElement = regCache.getFreeFragmentConstant();
			var shadowConstRegister : ShaderRegisterElement = regCache.getFreeFragmentConstant();
			var overlayConstRegister : ShaderRegisterElement = regCache.getFreeFragmentConstant();

			var perlinTexReg : ShaderRegisterElement = regCache.getFreeTextureReg();
			vo.texturesIndex = perlinTexReg.index;
			
			var heightMapTexReg : ShaderRegisterElement;
			
			var overlayTexReg : ShaderRegisterElement;
			if (_overlayTexture) { overlayTexReg = regCache.getFreeTextureReg(); }
			
			var albedo : ShaderRegisterElement;
			var temp : ShaderRegisterElement;
			var temp2 : ShaderRegisterElement;
			
			if (vo.numLights > 0) {
				
				
				if (_shadowRegister)
					code += "mul " + _totalLightColorReg + ".xyz, " + _totalLightColorReg + ".xyz, " + _shadowRegister + ".w\n";
				
				code += "add " + targetReg + ".xyz, " + _totalLightColorReg + ".xyz, " + targetReg + ".xyz\n" +
					"sat " + targetReg + ".xyz, " + targetReg + ".xyz\n";
				
				regCache.removeFragmentTempUsage(_totalLightColorReg);

				albedo = regCache.getFreeFragmentVectorTemp();
				regCache.addFragmentTempUsages(albedo, 1);
				
			}
			else {
				albedo = targetReg;
			}
			
			var uv : ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();
			regCache.addFragmentTempUsages(uv, 1);
			
			temp = regCache.getFreeFragmentVectorTemp();
			regCache.addFragmentTempUsages(temp, 1);
			
			temp2 = regCache.getFreeFragmentVectorTemp();
			regCache.addFragmentTempUsages(temp2, 1);
			
			var comps : Array = [ "x","y","z","w" ];
			
				code += "mov " + uv + ", " + _sharedRegisters.uvVarying + "\n";
				
				if (_flowTowardsCenter) {
					code += "sub " + uv + ", " + uv + ", " + constRegister2 + ".yyyy" + "\n";
					code += "abs " + uv + ", " + uv + "\n";
					code += "mul " + uv + ", " + uv + ", " + constRegister2 + ".xxxx" + "\n";
				}
				
				code += "add " + uv + ".xy, " + uv + ".xy, " +  constRegister + ".xy " + "\n";
				
				code += getSplatSampleCode(vo, temp, perlinTexReg, uv);
				
				code += "mov " + uv + ", " + _sharedRegisters.uvVarying + "\n";
				code += "add " + uv + ".xy, " + uv + ".xy, " +  constRegister + ".zw " + "\n";
				code += getSplatSampleCode(vo, temp2, perlinTexReg, uv);
				
				code += "add " + temp + ".xyz, " + temp + ".xxx, " + temp2 + ".yyy" + "\n";
				code += "div " + temp + ".xyz, " + temp + ".xyz, " + constRegister2 + ".xxx" + "\n";

				//CREATE HIGHLIGHT
				code += "sge " + temp2 + ".xyz, " + temp + ".xyz, " + constRegister2 + ".zzz" + "\n";
				code += "mul " + uv + ".xyz, " + temp2 + ".xyz, " + temp + ".xyz" + "\n";
				code += "sub " + uv + ".xyz, " + temp + ".xyz, " + uv + ".xyz" + "\n";
				code += "mul " + temp2 + ".xyz " + temp2 + ".xyz, " + highlightConstRegister + ".xyz" + "\n";
				code += "add " + temp + ".xyz, " + temp2 + ".xyz, " + uv + ".xyz" + "\n";
				
				//CREATE SHADOW
				code += "slt " + temp2 + ".xyz, " + temp + ".xyz, " + constRegister2 + ".www" + "\n";
				code += "mul " + uv + ".xyz, " + temp2 + ".xyz, " + temp + ".xyz" + "\n";
				code += "sub " + uv + ".xyz, " + temp + ".xyz, " + uv + ".xyz" + "\n";
				code += "mul " + temp2 + ".xyz " + temp2 + ".xyz, " + shadowConstRegister + ".xyz" + "\n";
				code += "add " + temp + ".xyz, " + temp2 + ".xyz, " + uv + ".xyz" + "\n";
			
				if (_overlayTexture) {
					
					code += "mul " + uv + ", " + overlayConstRegister + ".xxxx, " + _sharedRegisters.uvVarying + "\n";

					if (_flowTowardsCenter) {
						code += "sub " + uv + ", " + uv + ", " + constRegister2 + ".yyyy" + "\n";
						code += "abs " + uv + ", " + uv + "\n";
						code += "mul " + uv + ", " + uv + ", " + constRegister2 + ".xxxx" + "\n";
					}
					
					code += "mov " + uv + ".zw, " + constRegister + ".xy\n";
					code += "mul " + uv + ".zw, " + uv + ".zw, " + overlayConstRegister + ".xx" + "\n";
					code += "add " + uv + ".xy, " + uv + ".xy, " +  uv + ".zw " + "\n";
					code += getSplatSampleCode(vo, temp2, overlayTexReg, uv);
					
					code += "sub " + temp + ".xyz, " + temp + ".xyz, " + temp2 + ".xyz\n";
					
					code += "mul " + temp + ".xyz, " + temp + ".xyz, " + overlayConstRegister + ".yyy" + "\n";
					code += "add " + temp2 + ".xyz, " + temp2 + ".xyz, " + temp + ".xyz\n";
					
				}
			
			if (vo.numLights > 0) {
				code += "mul " + targetReg + ".xyz, " + temp2 + ".xyz, " + targetReg + ".xyz\n";// +
			} else {
				code += "add " + targetReg + ".xyz, " + temp2 + ".xyz, " + targetReg + ".xyz\n";// +
			}
			code +=	"mov " + targetReg + ".w, " + temp + ".w\n";// + 
			
			if (uv) regCache.removeFragmentTempUsage(uv);
			if (temp) regCache.removeFragmentTempUsage(temp);
			if (temp2) regCache.removeFragmentTempUsage(temp2);
			
			return code;
		}
		
		arcane override function activate(vo : MethodVO, stage3DProxy : Stage3DProxy) : void
		{
			var i : int;
			var texIndex : int = vo.texturesIndex;
			super.activate(vo, stage3DProxy);

			texIndex += 0;
			
			var data : Vector.<Number> = vo.fragmentData;
			var index : int = vo.fragmentConstantsIndex;
			
			data[index + 0] = offsetX1 += (offsetX1Speed / 100000);
			data[index + 1] = offsetY1 += (offsetY1Speed / 100000);
			data[index + 2] = offsetX2 += (offsetX2Speed / 100000);
			data[index + 3] = offsetY2 += (offsetY2Speed / 100000);
			data[index + 4] = 2;
			data[index + 5] = 0.5;
			data[index + 6] = (colorMax & 0xFF) / 0xFF;
			data[index + 7] = (colorMin & 0xFF) / 0xFF;
			data[index + 8] = ((waterColorHighlight >> 16) & 0xFF) / 0xFF; //r
			data[index + 9] = ((waterColorHighlight >> 8) & 0xFF) / 0xFF; //g
			data[index + 10] = (waterColorHighlight & 0xFF) / 0xFF; //b
			data[index + 11] = ((waterColorHighlight >> 24) & 0xFF) / 0xFF; //a
			data[index + 12] = ((waterColorShadow >> 16) & 0xFF) / 0xFF; //r
			data[index + 13] = ((waterColorShadow >> 8) & 0xFF) / 0xFF; //g
			data[index + 14] = (waterColorShadow & 0xFF) / 0xFF; //b
			data[index + 15] = ((waterColorShadow >> 24) & 0xFF) / 0xFF; //a
			data[index + 16] = this.overlayTiles;
			data[index + 17] = this.overlayBlendAmount;
			data[index + 18] = 1;
			data[index + 19] = 0;
			
			stage3DProxy._context3D.setTextureAt(texIndex++, _perlinTexture.getTextureForStage3D(stage3DProxy));
			
			if (_overlayTexture) stage3DProxy._context3D.setTextureAt(texIndex++, _overlayTexture.getTextureForStage3D(stage3DProxy));
		}
		
		
		protected function getSplatSampleCode(vo : MethodVO, targetReg : ShaderRegisterElement, inputReg : ShaderRegisterElement, uvReg : ShaderRegisterElement = null) : String
		{
			
			var filter : String;
			
			if (vo.useSmoothTextures) filter = "linear, nomip";
			else filter = "nearest, nomip";
			
			uvReg ||= _sharedRegisters.uvVarying;
			
			return "tex " + targetReg + ", " + uvReg + ", " + inputReg + " <2d," + filter + ",wrap>\n";
			
		}
		
		public function get overlayBitmapData():BitmapData { return _overlayBitmapData; }
		public function set overlayBitmapData(value:BitmapData):void {
			_overlayBitmapData = value;
			if (_overlayBitmapData) {
				_overlayTexture = new BitmapTexture(_overlayBitmapData);
			} else {
				_overlayTexture = null;
			}
			this.invalidateShaderProgram();
		}
		
		public function get flowTowardsCenter():Boolean { return _flowTowardsCenter; }
		public function set flowTowardsCenter(value:Boolean):void {
			_flowTowardsCenter = value;
			this.invalidateShaderProgram();
		}
		
		public function get shimmer1BaseSize():uint { return _shimmer1BaseSize; }
		public function set shimmer1BaseSize(value:uint):void {
			
			_shimmer1BaseSize = value;
			
			_perlinBitmapData = new BitmapData(_textureSize, _textureSize, true, 0xFF990000);
			_perlinBitmapData.perlinNoise(_shimmer1BaseSize, _shimmer1BaseSize, 8, 100, true, true, 7, true, null);
			
			_perlinBitmapData2 = new BitmapData(_textureSize, _textureSize, true, 0xFF990000);
			_perlinBitmapData2.perlinNoise(_shimmer2BaseSize, _shimmer2BaseSize, 8, 102, true, true, 7, true, null);
			
			_perlinBitmapData.copyChannel(_perlinBitmapData2, _perlinBitmapData2.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.GREEN);
			_perlinBitmapData2.dispose();
			
			_perlinTexture = new BitmapTexture(_perlinBitmapData);
		}
		
		public function get shimmer2BaseSize():uint { return _shimmer2BaseSize; }
		public function set shimmer2BaseSize(value:uint):void {
			
			_shimmer2BaseSize = value;
			
			_perlinBitmapData = new BitmapData(_textureSize, _textureSize, true, 0xFF990000);
			_perlinBitmapData.perlinNoise(_shimmer1BaseSize, _shimmer1BaseSize, 8, 100, true, true, 7, true, null);
			
			_perlinBitmapData2 = new BitmapData(_textureSize, _textureSize, true, 0xFF990000);
			_perlinBitmapData2.perlinNoise(_shimmer2BaseSize, _shimmer2BaseSize, 8, 102, true, true, 7, true, null);
			
			_perlinBitmapData.copyChannel(_perlinBitmapData2, _perlinBitmapData2.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.GREEN);
			_perlinBitmapData2.dispose();
			
			_perlinTexture = new BitmapTexture(_perlinBitmapData);
		}
		
		public function get textureSize():uint { return _textureSize; }
		
		public override function dispose():void {
			super.dispose();
			
			if (_perlinBitmapData) _perlinBitmapData.dispose();
			if (_perlinBitmapData2) _perlinBitmapData2.dispose();
			
			if (_perlinTexture) _perlinTexture.dispose();
			if (_perlinTexture2) _perlinTexture2.dispose();
			
			if (_overlayBitmapData) _overlayBitmapData.dispose();
			if (_overlayTexture) _overlayTexture.dispose();
		}
		public function invalidateShader():void {
			this.invalidateShaderProgram();
		}
	}
}


