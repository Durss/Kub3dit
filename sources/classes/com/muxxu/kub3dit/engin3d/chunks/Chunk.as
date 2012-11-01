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
		private var _texture:Texture;
		private var _updating:Boolean;
		private var _originX:int;
		private var _originY:int;
		private var _vertexBuffersOpaque:Vector.<VertexBuffer3D>;
		private var _indexBuffersOpaque:Vector.<IndexBuffer3D>;
		private var _vertexBuffersTransparent:Vector.<VertexBuffer3D>;
		private var _indexBuffersTransparent:Vector.<IndexBuffer3D>;
		private var _vertexBuffersTranslucide:Vector.<VertexBuffer3D>;
		private var _indexBuffersTranslucide:Vector.<IndexBuffer3D>;
		
		
		

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
			return _data != null && ( (_data._buffersOpaque != null && _data._buffersOpaque.length > 0) || (_data._buffersTransparent != null && _data._buffersTransparent.length > 0) || (_data._buffersTranslucide != null && _data._buffersTranslucide.length > 0) );
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
		 * 
		 * @param type	1=opaque, 2=transparent, 3=translucide
		 */
		public function renderBuffer(type:int):void {
			var buffer:Vector.<Vector.<Number>> = type == 0? _data._buffersOpaque : type == 1? _data._buffersTransparent : _data._buffersTranslucide;
			var indexes:Vector.<Vector.<uint>> = type == 0? _data._indexesOpaque : type == 1? _data._indexesTransparent : _data._indexesTranslucide;
			var vBuffer:Vector.<VertexBuffer3D> = type==0? _vertexBuffersOpaque : type == 1? _vertexBuffersTransparent : _vertexBuffersTranslucide;
			var iBuffer:Vector.<IndexBuffer3D> = type==0? _indexBuffersOpaque : type == 1? _indexBuffersTransparent : _indexBuffersTranslucide;
			
			if (indexes.length > 0 && buffer.length > 0) {
				var i:int, len:int;
				len = vBuffer.length;
				for(i = 0; i < len; ++i) {
					if(vBuffer[i] == null) continue;
					
					_context3D.setVertexBufferAt(0, vBuffer[i], 0, Context3DVertexBufferFormat.FLOAT_3); //xyz
					_context3D.setVertexBufferAt(1, vBuffer[i], 3, Context3DVertexBufferFormat.FLOAT_2); //uv
					_context3D.setVertexBufferAt(2, vBuffer[i], 5, Context3DVertexBufferFormat.FLOAT_1); //brightness
					
					_context3D.drawTriangles(iBuffer[i]);
					
					_context3D.setVertexBufferAt(0, null); //clean the buffers
					_context3D.setVertexBufferAt(1, null); //clean the buffers
					_context3D.setVertexBufferAt(2, null); //clean the buffers
				}
			}
		}
		
		/**
		 * Creates the chunk's vertex buffer
		 * 
		 * @param type	1=opaque, 2=transparent, 3=translucide
		 */
		public function createBuffers(type:int):void {
			_data = _map.copyData(_chunkSize, _xloc, _yloc);
			_data.createArrays();
			var buffer:Vector.<Vector.<Number>> = type == 0? _data._buffersOpaque : type == 1? _data._buffersTransparent : _data._buffersTranslucide;
			var indexes:Vector.<Vector.<uint>> = type == 0? _data._indexesOpaque : type == 1? _data._indexesTransparent : _data._indexesTranslucide;
			if(buffer.length > 0) {
				var i:int, len:int, vertex:VertexBuffer3D, index:IndexBuffer3D;
				len = indexes.length;
				var vBuffer:Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(len, true);
				var iBuffer:Vector.<IndexBuffer3D> = new Vector.<IndexBuffer3D>(len, true);
				for(i = 0; i < len; ++i) {
					if(buffer[i].length == 0) continue;
					
					vertex = _context3D.createVertexBuffer(buffer[i].length / 6, 6);
					index = _context3D.createIndexBuffer(indexes[i].length);
					vertex.uploadFromVector(buffer[i], 0, buffer[i].length / 6);
					index.uploadFromVector(indexes[i], 0, indexes[i].length);
					vBuffer[i] = vertex;
					iBuffer[i] = index;
				}
				
				if(type == 0) {
					_vertexBuffersOpaque = vBuffer;
					_indexBuffersOpaque = iBuffer;
				}else if(type == 1) {
					_vertexBuffersTransparent = vBuffer;
					_indexBuffersTransparent= iBuffer;
				}else{
					_vertexBuffersTranslucide = vBuffer;
					_indexBuffersTranslucide = iBuffer;
				}
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
			_vertexBuffersOpaque = null;
			_indexBuffersOpaque = null;
			_vertexBuffersTransparent = null;
			_indexBuffersTransparent = null;
			_vertexBuffersTranslucide= null;
			_indexBuffersTranslucide= null;
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