package com.muxxu.kub3dit.engin3d.chunks {
	import com.muxxu.kub3dit.engin3d.map.Map;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;


	
	/**
	 * 
	 * @author Francois
	 * @date 4 sept. 2011;
	 */
	public class Chunk  {
		
		private var _xloc:int;
		private var _yloc:int;
		private var _chunkSize:int;
		private var _map:Map;
		private var _data:ChunkData;
		private var _context3D:Context3D;
		private var _buffer:VertexBuffer3D;
		private var _indexBuffer:IndexBuffer3D;
		private var _texture:Texture;
		private var _updating:Boolean;
		private var _originX:int;
		private var _originY:int;
		
		
		

		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Chunk</code>.
		 */
		public function Chunk(originX:int, originY:int, chunkSize:int, map:Map, context3D:Context3D, texture:Texture) {
			_originY = originY;
			_originX = originX;
			_texture = texture;
			_context3D = context3D;
			_map = map;
			_chunkSize = chunkSize;
			update(-1, -1);//-1 to be sure that first chunk at 0/0 will be updated the first time
			_updating = false;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets if the chunk is ready to be used
		 */
		public function get isReady():Boolean {
			return _data != null && _data._bufferArray != null && _data._bufferArray.length > 0;
		}
		
		/**
		 * Gets if the chunk is updating or not
		 */
		public function get updating():Boolean { return _updating; }
		
		/**
		 * Gets the X origin of the chunk in the array
		 */
		public function get originX():int { return _originX; }
		
		/**
		 * Gets the Y origin of the chunk in the array
		 */
		public function get originY():int { return _originY; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Updates the chunk
		 */
		public function update(xloc:int, yloc:int):void {
			_updating = true;
			_yloc = yloc;
			_xloc = xloc;
		}
		
		/**
		 * Draws the chunk
		 */
		public function renderBuffer():void {
			if (_data._indexesArray.length > 0 && _data._bufferArray.length > 0) {
				_context3D.setVertexBufferAt(0, _buffer, 0, Context3DVertexBufferFormat.FLOAT_3); //xyz
				_context3D.setVertexBufferAt(1, _buffer, 3, Context3DVertexBufferFormat.FLOAT_2); //uv
				_context3D.setVertexBufferAt(2, _buffer, 5, Context3DVertexBufferFormat.FLOAT_1); //alpha
				_context3D.setVertexBufferAt(3, _buffer, 6, Context3DVertexBufferFormat.FLOAT_1); //brightness
				
				_context3D.drawTriangles(_indexBuffer);
				
				_context3D.setVertexBufferAt(0, null); //clean the buffers
				_context3D.setVertexBufferAt(1, null); //clean the buffers
				_context3D.setVertexBufferAt(2, null); //clean the buffers
				_context3D.setVertexBufferAt(3, null); //clean the buffers
			}
		}
		
		/**
		 * Creates the chunk's vertex buffer
		 */
		public function createBuffers():void {
			_data = _map.copyData(_chunkSize, _xloc, _yloc);
			_data.createArrays();
			if(_data._bufferArray.length > 0) {
				_buffer = _context3D.createVertexBuffer(_data._bufferArray.length / 7, 7);
				_indexBuffer = _context3D.createIndexBuffer(_data._indexesArray.length);
				_buffer.uploadFromVector(_data._bufferArray, 0, _data._bufferArray.length / 7);
				_indexBuffer.uploadFromVector(_data._indexesArray, 0, _data._indexesArray.length);
			}
			_updating = false;
		}
		
		/**
		 * Makes the chunk garbage collectable.
		 */
		public function dispose():void {
			_data.dispose();
			_map = null;
			_data = null;
			_context3D = null;
			_buffer = null;
			_indexBuffer = null;
			_texture = null;
		}
		
		/**
		 * Sets the chunk's position.
		 * 
		 * @param px	 new X position
		 * @param py	 new Y position
		 * 
		 * @return if the chunk updating state has changed
		 */
		public function setPosition(px:int, py:int):Boolean {
			if(_xloc != px || _yloc !=py) {
				_xloc = px;
				_yloc = py;
				if(_updating) return false;
				_updating = true;
				return true;
			}
			return false;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}