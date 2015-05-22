/*

Copyright 2015 Michael Gouwens and The Yellow Thorn. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package com.terrainbuilder.materials
{
	import com.terrainbuilder.materials.passes.AlphaEnabledSuperShaderPass;
	
	import away3d.arcane;
	import away3d.materials.TextureMaterial;
	import away3d.textures.Texture2DBase;
	
	use namespace arcane;
	
	/**
	 * AlphaEnabledTextureMaterial is a single-pass material that uses a texture to define the surface's diffuse reflection colour (albedo).
	 */
	public class AlphaEnabledTextureMaterial extends TextureMaterial
	{
		/**
		 * Creates a new AlphaEnabledTextureMaterial that allows for alpha masking.
		 * @param texture The texture used for the material's albedo color.
		 * @param smooth Indicates whether the texture should be filtered when sampled. Defaults to true.
		 * @param repeat Indicates whether the texture should be tiled when sampled. Defaults to true.
		 * @param mipmap Indicates whether or not any used textures should use mipmapping. Defaults to true.
		 */
		public function AlphaEnabledTextureMaterial(texture:Texture2DBase = null, smooth:Boolean = true, repeat:Boolean = false, mipmap:Boolean = true)
		{
			super();
			_screenPass = new AlphaEnabledSuperShaderPass(this);
			
			this.texture = texture;
			this.smooth = smooth;
			this.repeat = repeat;
			this.mipmap = mipmap;
		}

		
	}
}
