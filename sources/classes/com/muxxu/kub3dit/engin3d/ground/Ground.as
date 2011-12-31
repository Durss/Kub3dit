package com.muxxu.kub3dit.engin3d.ground {
	import com.muxxu.kub3dit.engin3d.chunks.ChunkData;
	import com.muxxu.kub3dit.engin3d.camera.Camera3D;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.engin3d.molehill.CubeFragmentShader;
	import com.muxxu.kub3dit.engin3d.molehill.CubeVertexShader;
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Point;
	import flash.geom.Rectangle;




	
	/**
	 * 
	 * @author Francois
	 * @date 30 sept. 2011;
	 */
	public class Ground {
		
		private var _context3D:Context3D;
		private var _texture:Texture;
		private var _vertexBuffer:Vector.<Number>;
		private var _indexBuffer:Vector.<uint>;
		private var _shaderProgram:Program3D;
		private var _inc:Number;
		private var _bmd:BitmapData;
		private var _timer:int;
		private var _accelerated:Boolean;
		
		
		

		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Background</code>.
		 */
		public function Ground(context3D:Context3D, accelerated:Boolean) {
			_accelerated = accelerated;
			_context3D = context3D;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		
		/**
		 * Renders the background's buffer
		 */
		public function render(size:int):void {
			var cubeSizeRatio:Number = ChunkData.CUBE_SIZE_RATIO;
			
			if(_timer == 0)_inc += 1/16;
			_timer = (_timer+1)%(16/2);
			_inc = _inc%16;
			size = (Math.max(size, 2) + 4) * 16;
			
			//Init vertices
			var index:int = 0;
			var offsetX:Number = -(size * cubeSizeRatio * .5)-Math.floor(Camera3D.locX/(16*cubeSizeRatio))*(16*cubeSizeRatio);
			var offsetY:Number = -(size * cubeSizeRatio * .5)+Math.floor(Camera3D.locY/(16*cubeSizeRatio))*(16*cubeSizeRatio);
			
			_vertexBuffer = new Vector.<Number>();
			_vertexBuffer[index++] = offsetX;//X
			_vertexBuffer[index++] = offsetY;//Y
			_vertexBuffer[index++] = .5 * cubeSizeRatio;//Z
			_vertexBuffer[index++] = 0;//U
			_vertexBuffer[index++] = _inc;//V
			_vertexBuffer[index++] = 1;//alpha
			_vertexBuffer[index++] = 1;//brightness
			
			_vertexBuffer[index++] = offsetX+size * cubeSizeRatio;
			_vertexBuffer[index++] = offsetY;
			_vertexBuffer[index++] = .5 * cubeSizeRatio;
			_vertexBuffer[index++] = size;
			_vertexBuffer[index++] = _inc;
			_vertexBuffer[index++] = 1;//alpha
			_vertexBuffer[index++] = 1;//brightness
			
			_vertexBuffer[index++] = offsetX+size * cubeSizeRatio;
			_vertexBuffer[index++] = offsetY+size * cubeSizeRatio;
			_vertexBuffer[index++] = .5 * cubeSizeRatio;
			_vertexBuffer[index++] = size;
			_vertexBuffer[index++] = size+_inc;
			_vertexBuffer[index++] = 1;//alpha
			_vertexBuffer[index++] = 1;//brightness
			
			_vertexBuffer[index++] = offsetX;
			_vertexBuffer[index++] = offsetY+size * cubeSizeRatio;
			_vertexBuffer[index++] = .5 * cubeSizeRatio;
			_vertexBuffer[index++] = 0;
			_vertexBuffer[index++] = size+_inc;
			_vertexBuffer[index++] = 1;//alpha
			_vertexBuffer[index++] = 1;//brightness
			
			_context3D.setTextureAt(0, _texture);
			_context3D.setProgram(_shaderProgram);
			
			var buffer:VertexBuffer3D = _context3D.createVertexBuffer(_vertexBuffer.length / 7, 7);
			var indexBuffer:IndexBuffer3D = _context3D.createIndexBuffer(_indexBuffer.length);
			buffer.uploadFromVector(_vertexBuffer, 0, _vertexBuffer.length / 7);
			indexBuffer.uploadFromVector(_indexBuffer, 0, _indexBuffer.length);
			
			_context3D.setVertexBufferAt(0, buffer, 0, Context3DVertexBufferFormat.FLOAT_3); //xyz
			_context3D.setVertexBufferAt(1, buffer, 3, Context3DVertexBufferFormat.FLOAT_2); //uv
			_context3D.setVertexBufferAt(2, buffer, 5, Context3DVertexBufferFormat.FLOAT_1); //alpha
			_context3D.setVertexBufferAt(3, buffer, 6, Context3DVertexBufferFormat.FLOAT_1); //brightness
			
			_context3D.drawTriangles(indexBuffer);
			_context3D.setVertexBufferAt(0, null); //clean the buffers
			_context3D.setVertexBufferAt(1, null); //clean the buffers
			_context3D.setVertexBufferAt(2, null); //clean the buffers
			_context3D.setVertexBufferAt(3, null); //clean the buffers
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_inc = 0;
			_timer = 0;
			//Init shader
			var vs:CubeVertexShader = new CubeVertexShader();
			var fs:CubeFragmentShader = new CubeFragmentShader(_context3D, _accelerated);
			_shaderProgram = _context3D.createProgram();
			_shaderProgram.upload(vs.agalcode, fs.agalcode);

			var index:int = 0;
			var bmd:BitmapData	= Textures.getInstance().spriteSheet;
			var tileTop:Point	= Textures.getInstance().cubesFrames[2][0];
			
			_bmd = new BitmapData(16, 16);
			var rect:Rectangle = new Rectangle(tileTop.x, tileTop.y, 16, 16);
			_bmd.copyPixels(bmd, rect, new Point(0,0));
				
			//init texture
			_texture = _context3D.createTexture(_bmd.width, _bmd.height, Context3DTextureFormat.BGRA, true);
			_texture.uploadFromBitmapData(_bmd, 0);
			
			index = 0;
			_indexBuffer = new Vector.<uint>();
			_indexBuffer[index++] = 0;
			_indexBuffer[index++] = 1;
			_indexBuffer[index++] = 2;
			
			_indexBuffer[index++] = 0;
			_indexBuffer[index++] = 2;
			_indexBuffer[index++] = 3;
		}
		
	}
}