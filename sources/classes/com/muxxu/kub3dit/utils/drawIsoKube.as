package com.muxxu.kub3dit.utils {
	import com.nurun.utils.math.MathUtils;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;

	/**
	 * Creates an ISO image of a kube.
	 * 
	 * @param top			top texture
	 * @param side			side texture
	 * @param smooth		smooth the image or not
	 * @param sizeCoeff		scale coefficent
	 * 
	 * @return a shape with the cube drawn on it.
	 *  
	 * @author Francois
	 */
	public function drawIsoKube(top:BitmapData, side:BitmapData, smooth:Boolean = false, scaleCoeff:Number = 1, asBitmapData:Boolean = false):* {
			var vertices:Vector.<Number> = Vector.<Number>([
        							//TOP FACE
        							scaleCoeff*19, 0,
        							scaleCoeff*39, scaleCoeff*10,
        							scaleCoeff*19, scaleCoeff*19,
        							0, scaleCoeff*10,
        							//LEFT FACE
        							0, scaleCoeff*10,
        							scaleCoeff*19, scaleCoeff*19,
        							scaleCoeff*19, scaleCoeff*41,
        							0, scaleCoeff*32,
        							//RIGHT FACE
        							scaleCoeff*19, scaleCoeff*19,
        							scaleCoeff*39, scaleCoeff*10,
        							scaleCoeff*39, scaleCoeff*32,
        							scaleCoeff*19, scaleCoeff*41
        							]);

			var UVData:Vector.<Number> = Vector.<Number>([
            						//TOP FACE
									1, 1,
									0, 1,
									0, 0,
									1, 0,
									//LEFT FACE
									1, 0,
									0, 0,
									0, 1,
									1, 1,
									//RIGHT FACE
									1, 1,
									1, 0,
									0, 0,
									0, 1,
									]);

			var indicesTop:Vector.<int> = Vector.<int>([0, 1, 3, 3, 1, 2]);
			var indicesLeft:Vector.<int> = Vector.<int>([4, 5, 6, 6, 7, 4]);
			var indicesRight:Vector.<int> = Vector.<int>([8, 9, 11, 11, 9, 10]);
  
			var m:Matrix = new Matrix();
			m.rotate(90 * MathUtils.DEG2RAD);
			m.translate(top.width,0);
			m.scale(1, -1);
			m.translate(0, top.height);
  			
  			var shadow:int = -40;
			var right:BitmapData = side.clone();
			right.fillRect(right.rect, 0);
			right.draw(side, m);
			right.applyFilter(right, right.rect, new Point(0,0), new ColorMatrixFilter([1,0,0,0,shadow, 0,1,0,0,shadow, 0,0,1,0,shadow, 0,0,0,1,0]));
			
  			shadow = -30;
			var left:BitmapData = side.clone();
			left.applyFilter(left, left.rect, new Point(0,0), new ColorMatrixFilter([1,0,0,0,shadow, 0,1,0,0,shadow, 0,0,1,0,shadow, 0,0,0,1,0]));

			var shape:Shape = new Shape();
			
			shape.graphics.clear();
			shape.graphics.beginBitmapFill(top, null, false, smooth);
			shape.graphics.drawTriangles(vertices, indicesTop, UVData);
			shape.graphics.beginBitmapFill(left, null, false, smooth);
			shape.graphics.drawTriangles(vertices, indicesLeft, UVData);
			shape.graphics.beginBitmapFill(right, null, false, smooth);
			shape.graphics.drawTriangles(vertices, indicesRight, UVData);
			shape.graphics.endFill();
			
			if(asBitmapData) {
				var bmd:BitmapData = new BitmapData(shape.width, shape.height, true, 0);
				bmd.draw(shape);
				return bmd;
			}
			return shape;
	}
}
