package com.muxxu.kub3dit.engin3d.campath {
	import com.muxxu.kub3dit.engin3d.camera.Camera3D;
	import com.muxxu.kub3dit.engin3d.molehill.CameraPathFragmentShader;
	import com.muxxu.kub3dit.engin3d.molehill.CameraPathVertexShader;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	
	/**
	 * 
	 * @author Francois
	 * @date 23 juin 2012;
	 */
	public class CameraPath {
		
		private var _context3D:Context3D;
		private var _vertexBuffer:Vector.<Number>;
		private var _indexBuffer:Vector.<uint>;
		private var _shaderProgram:Program3D;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>CameraPath</code>.
		 */
		public function CameraPath(context3D:Context3D) {
			_context3D = context3D;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */

		public function render():void {
			var rx:Number, ry:Number, deg2rad:Number;
			var path:Array = Camera3D.path;
			
			if(path == null || path.length == 0) return;
			
			_context3D.setTextureAt(0, null);
			_context3D.setProgram(_shaderProgram);
			
			deg2rad = 0.017453292519943295;
			
			_indexBuffer = new Vector.<uint>();
			_vertexBuffer = new Vector.<Number>();
			
			var vIndex:int, iIndex:int;
			var i:int, len:int, point:Object;
			len = path.length;
			for(i = 0; i < len; ++i) {
				point = path[i];
				rx = (point['rotationX']-90) * deg2rad;
				ry = (point['rotationY']+90) * deg2rad;
				_vertexBuffer[vIndex++] = -point['px'] - 100 * Math.cos(rx) * Math.sin(ry);//X
				_vertexBuffer[vIndex++] = point['py'] - 100 * Math.sin(rx) * Math.sin(ry);//Y
				_vertexBuffer[vIndex++] = -point['pz'] - Math.cos(ry) * 100;//Z
				_vertexBuffer[vIndex++] = 1-i/len;//R
				_vertexBuffer[vIndex++] = .5;//G
				_vertexBuffer[vIndex++] = i/len;//B
				
				_vertexBuffer[vIndex++] = -point['px'] + 25 * Math.cos(rx+Math.PI*.5);
				_vertexBuffer[vIndex++] = point['py'] + 25 * Math.sin(rx+Math.PI*.5);
				_vertexBuffer[vIndex++] = -point['pz'];
				_vertexBuffer[vIndex++] = 1-i/len;//R
				_vertexBuffer[vIndex++] = 0;//G
				_vertexBuffer[vIndex++] = i/len;//B
				
				_vertexBuffer[vIndex++] = -point['px'] + 25 *  Math.cos(rx-Math.PI*.5);
				_vertexBuffer[vIndex++] = point['py'] + 25 * Math.sin(rx-Math.PI*.5);
				_vertexBuffer[vIndex++] = -point['pz'];
				_vertexBuffer[vIndex++] = 1-i/len;//R
				_vertexBuffer[vIndex++] = 0;//G
				_vertexBuffer[vIndex++] = i/len;//B
				
				_indexBuffer[iIndex++] = 0 + i*3;
				_indexBuffer[iIndex++] = 1 + i*3;
				_indexBuffer[iIndex++] = 2 + i*3;
			}
			
			var buffer:VertexBuffer3D = _context3D.createVertexBuffer(_vertexBuffer.length / 6, 6);
			var indexBuffer:IndexBuffer3D = _context3D.createIndexBuffer(_indexBuffer.length);
			buffer.uploadFromVector(_vertexBuffer, 0, _vertexBuffer.length / 6);
			indexBuffer.uploadFromVector(_indexBuffer, 0, _indexBuffer.length);
			
			_context3D.setVertexBufferAt(0, buffer, 0, Context3DVertexBufferFormat.FLOAT_3); //xyz
			_context3D.setVertexBufferAt(1, buffer, 3, Context3DVertexBufferFormat.FLOAT_3); //rgb
			
			_context3D.drawTriangles(indexBuffer);
			_context3D.setVertexBufferAt(0, null); //clean the buffers
			_context3D.setVertexBufferAt(1, null); //clean the buffers
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			//Init shader
			var vs:CameraPathVertexShader = new CameraPathVertexShader();
			var fs:CameraPathFragmentShader = new CameraPathFragmentShader(_context3D);
			_shaderProgram = _context3D.createProgram();
			_shaderProgram.upload(vs.agalcode, fs.agalcode);
		}
		
	}
}