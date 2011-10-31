package com.muxxu.kub3dit.engin3d.utils {
	import flash.display.BitmapData;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	/**
	 * @author Francois
	 */
	public function uploadTextureWithMipmaps(dest:Texture, src:BitmapData):void {
		var ws:int = src.width;
	    var hs:int = src.height;
	    var level:int = 0;
	    var tmp:BitmapData;
	    var transform:Matrix = new Matrix();
	
	    tmp = new BitmapData(src.width, src.height, true, 0);
	
	    while ( ws >= 1 && hs >= 1 ) { 
	        tmp.draw(src, transform, null, null, null, true); 
	        dest.uploadFromBitmapData(tmp, level);
	        transform.scale(.5, .5);
	        level++;
	        ws >>= 1;
	        hs >>= 1;
	        if (hs>0 && ws>0) {
	            tmp.dispose();
	            tmp = new BitmapData(ws, hs, true, 0);
	        }
	    }
	    tmp.dispose();
	}
}
