package com.muxxu.kub3dit.engin3d.background {
	import com.muxxu.kub3dit.engin3d.camera.Camera3D;
	import com.muxxu.kub3dit.engin3d.molehill.BackgroundFragmentShader;
	import com.muxxu.kub3dit.engin3d.molehill.BackgroundVertexShader;
	import com.muxxu.kub3dit.graphics.BackgroundGraphic;

	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix3D;



	
	/**
	 * 
	 * @author Francois
	 * @date 30 sept. 2011;
	 */
	public class Background {
		
		private var _context3D:Context3D;
		private var _texture:Texture;
		private var _vertexBuffer:Vector.<Number>;
		private var _indexBuffer:Vector.<uint>;
		private var _projection:Matrix3D;
		private var _shaderProgram:Program3D;
		private var _bitmapData:BitmapData;
		private var _red:Number;
		private var _green:Number;
		private var _blue:Number;
		
		
		

		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Background</code>.
		 */
		public function Background(context3D:Context3D) {
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
		 * Creates the background's buffers
		 */
		public function setSizes(width:int, height:int):void {
			var z:int = 10000000;//Put the background FAR behind. Probably dirty way to do it but that's only way I found... :/
			var ratio:Number = 2;
			var ry:Number = Camera3D.rotationY<-90? -90 : Camera3D.rotationY>90? 90 : Camera3D.rotationY;
			var offsetY:int = (ry + 90)/180 * (height*ratio - height);
			_projection = new Matrix3D();
			_projection.appendScale(width, height * ratio, 1);
			_projection.appendTranslation(-width * .5, -height * .5 - offsetY, -z);
			_projection.appendScale(1, -1, 1);

			var orthoProjection:Matrix3D = new Matrix3D(Vector.<Number> ([2/width, 0, 0, 0,	0, 2/height, 0, 0,	0, 0, 1/(-z-1), -0/(z-1),	0, 0, 0, 1 ]));
			_projection.append(orthoProjection);
		}
		
		/**
		 * Renders the background's buffer
		 */
		public function render():void {
			_vertexBuffer[3] = _vertexBuffer[9]  = (Math.cos(_red)+1)*.5;
			_vertexBuffer[4] = _vertexBuffer[10] = (Math.sin(_green)+1)*.5;
			_vertexBuffer[5] = _vertexBuffer[11] = (Math.cos(_blue)+1)*.5;
			
			_context3D.setTextureAt(0, null);
			_context3D.setProgram(_shaderProgram);
			
			var buffer:VertexBuffer3D = _context3D.createVertexBuffer(_vertexBuffer.length / 6, 6);
			var indexBuffer:IndexBuffer3D = _context3D.createIndexBuffer(_indexBuffer.length);
			buffer.uploadFromVector(_vertexBuffer, 0, _vertexBuffer.length / 6);
			indexBuffer.uploadFromVector(_indexBuffer, 0, _indexBuffer.length);
			
			_context3D.setVertexBufferAt(0, buffer, 0, Context3DVertexBufferFormat.FLOAT_3); //xyz
			_context3D.setVertexBufferAt(1, buffer, 3, Context3DVertexBufferFormat.FLOAT_3); //color
			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _projection, true);
			_context3D.drawTriangles(indexBuffer);
			_context3D.setVertexBufferAt(0, null); //clean the buffers
			_context3D.setVertexBufferAt(1, null); //clean the buffers
			
			//Change color smoothly
			var pi2:Number = Math.PI * 2;
			_red = (_red + .0005)%pi2;
			_green = (_green + .0005)%pi2;
			_blue = (_blue - .0005)%pi2;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			var pi2:Number = Math.PI * 2;
			_red = Math.random() * pi2;
			_green = Math.random() * pi2;
			_blue = Math.random() * pi2;
			//Init shader
			var vs:BackgroundVertexShader = new BackgroundVertexShader();
			var fs:BackgroundFragmentShader = new BackgroundFragmentShader(_context3D);
			_shaderProgram = _context3D.createProgram();
			_shaderProgram.upload(vs.agalcode, fs.agalcode);
				
			//init background texture
			var back:BackgroundGraphic = new BackgroundGraphic();
			_bitmapData = new BitmapData(back.width, back.height, false);
			_bitmapData.draw(back);
			_texture = _context3D.createTexture(_bitmapData.width, _bitmapData.height, Context3DTextureFormat.BGRA, true);
			
			//Init vertices
			var index:int = 0;
			_vertexBuffer = new Vector.<Number>();
			_vertexBuffer[index++] = 0;//X
			_vertexBuffer[index++] = 0;//Y
			_vertexBuffer[index++] = 0;//Z
			_vertexBuffer[index++] = 0;//R
			_vertexBuffer[index++] = 0;//G
			_vertexBuffer[index++] = 0;//B
			
			_vertexBuffer[index++] = 1;
			_vertexBuffer[index++] = 0;
			_vertexBuffer[index++] = 0;
			_vertexBuffer[index++] = 0;
			_vertexBuffer[index++] = 0;
			_vertexBuffer[index++] = 0;
			
			_vertexBuffer[index++] = 1;
			_vertexBuffer[index++] = 1;
			_vertexBuffer[index++] = 0;
			_vertexBuffer[index++] = 1.75;
			_vertexBuffer[index++] = 1.75;
			_vertexBuffer[index++] = 1.75;
			
			_vertexBuffer[index++] = 0;
			_vertexBuffer[index++] = 1;
			_vertexBuffer[index++] = 0;
			_vertexBuffer[index++] = 1.75;
			_vertexBuffer[index++] = 1.75;
			_vertexBuffer[index++] = 1.75;
			
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