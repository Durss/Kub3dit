package com.muxxu.kub3dit.engin3d.chunks {
	import com.muxxu.kub3dit.engin3d.camera.Camera3D;
	import com.muxxu.kub3dit.engin3d.events.ManagerEvent;
	import com.muxxu.kub3dit.engin3d.events.MapEvent;
	import com.muxxu.kub3dit.engin3d.map.Map;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.engin3d.molehill.CubeFragmentShader;
	import com.muxxu.kub3dit.engin3d.molehill.CubeVertexShader;
	import com.muxxu.kub3dit.engin3d.utils.uploadTextureWithMipmaps;

	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;

	
	/**
	 * Manages the chunks.
	 * Moves them and update them depending on the camera's position.
	 * 
	 * @author Francois
	 * @date 4 sept. 2011;
	 */
	public class ChunksManager extends EventDispatcher {
		
		private var _intialized:Boolean;
		private var _chunkSize:int;
		private var _context3D:Context3D;
		private var _map:Map;
		private var _textureCubes:Texture;
		private var _chunks:Array;
		private var _progressX:int;
		private var _progressY:int;
		private var _efTarget:Shape;
		private var _toUpdate:Array;
		private var _lastProjection:Matrix3D;
		private var _chunksW:int;
		private var _chunksH:int;
		private var _offsetX:int;
		private var _offsetY:int;
		private var _prevOffsetX:int;
		private var _prevOffsetY:int;
		private var _sceneWidth:int;
		private var _sceneHeight:int;
		private var _shaderProgram:Program3D;
		private var _mapSizeW:int;
		private var _posToChunk:Array;
		private var _mapSizeH:int;
		private var _accelerated:Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ChunksManager</code>.
		 */
		public function ChunksManager(map:Map) {
			_map = map;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		public function get chunksW():int { return _chunksW; }
		
		public function get chunksH():int { return _chunksH; }
		
		public function get chunkSize():int { return _chunkSize; }

		public function get offsetX():int { return _offsetX; }

		public function get offsetY():int { return _offsetY; }

		public function get map():Map { return _map; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Initializes the chunks manager
		 */
		public function initialize(context3D:Context3D, chunkSize:int, accelerated:Boolean):void {
			_accelerated = accelerated;
			// okay this function should set up and dispose any buffers
			// this is only ever called once at the start of the program
			if(!_intialized) {
				_toUpdate = [];
				_intialized = true;
				_chunkSize = chunkSize;
				_context3D = context3D;
				_mapSizeW = _map.mapSizeX;
				_mapSizeH = _map.mapSizeY;
				
				_efTarget = new Shape();
				
				//Init cubes textures
				var bitmapData:BitmapData = Textures.getInstance().bitmapData;
				_textureCubes = _context3D.createTexture(bitmapData.width, bitmapData.height, Context3DTextureFormat.BGRA, false);
				uploadTextureWithMipmaps(_textureCubes, bitmapData);
				
				var vs:CubeVertexShader = new CubeVertexShader();
				var fs:CubeFragmentShader = new CubeFragmentShader(_context3D, _accelerated);
				_shaderProgram = _context3D.createProgram();
				_shaderProgram.upload(vs.agalcode, fs.agalcode);
				_map.addEventListener(MapEvent.LOAD, loadMapHandler);
			} else {
				throw new Error("ChunksManager is already initialized!");
			}
		}
		
		/**
		 * Updates a specific cube.
		 * Automatically detects which chunk needs to be updated.
		 */
		public function update(x:int, y:int, z:int, value:int):void {
			if(x < 0 || x > _map.mapSizeX-1
			|| y < 0 || y > _map.mapSizeY-1
			|| z < 0 || z > _map.mapSizeZ-1) return;
			
			_map.updateTile(x, y, z, value);
			var px:int = Math.floor(x / _chunkSize)*_chunkSize;
			var py:int = Math.floor(y / _chunkSize)*_chunkSize;
			
			var chunk:Chunk = _posToChunk[px+"-"+py] as Chunk;
			if(chunk!=null) {
				if(!chunk.updating) {
					chunk.update(px, py);
					_toUpdate.push({chunk:chunk, pz:_lastProjection.transformVector(new Vector3D(px, py, 0)).z});
				}
				//Update left
				if(x % _chunkSize == 0 && x > 0) {
					px -= _chunkSize;
					chunk = _posToChunk[px+"-"+py] as Chunk;
					if(chunk != null && !chunk.updating) {
						chunk.update(px, py);
						_toUpdate.push({chunk:chunk, pz:_lastProjection.transformVector(new Vector3D(px, py, 0)).z});
					}
				}
				
				//Update right
				if(x % _chunkSize == _chunkSize - 1 && x <_map.mapSizeX-1) {
					px += _chunkSize;
					chunk = _posToChunk[px+"-"+py] as Chunk;
					if(chunk != null && !chunk.updating) {
						chunk.update(px, py);
						_toUpdate.push({chunk:chunk, pz:_lastProjection.transformVector(new Vector3D(px, py, 0)).z});
					}
				}
				
				//Update top
				if(y % _chunkSize == 0 && y > 0) {
					py -= _chunkSize;
					chunk = _posToChunk[px+"-"+py] as Chunk;
					if(chunk != null && !chunk.updating) {
						chunk.update(px, py);
						_toUpdate.push({chunk:chunk, pz:_lastProjection.transformVector(new Vector3D(px, py, 0)).z});
					}
				}
				
				//Update bottom
				if(y % _chunkSize == _chunkSize - 1 && y <_map.mapSizeY-1) {
					py += _chunkSize;
					chunk = _posToChunk[px+"-"+py] as Chunk;
					if(chunk != null && !chunk.updating) {
						chunk.update(px, py);
						_toUpdate.push({chunk:chunk, pz:_lastProjection.transformVector(new Vector3D(px, py, 0)).z});
					}
				}
			}
		}

		/**
		 * Drops a cube 
		 */
		public function drop(x:int, y:int, id:int):void {
			var z:int = 30;
			while (_map.getTile(x, y, z) == 0 && z > 0) z--;
			update(x, y, Math.min(30, ++z), id);
		}
		
		/**
		 * Creates the chunks depending on the map data
		 */
		public function create():void {
			_progressX = 0;
			_progressY = 0;
			_chunks = [];
			_posToChunk = [];
			
			if(_chunksH <= 0 || _chunksW <= 0) {
				throw new IllegalOperationError("Please define the number of visible chunks first. Must be greater than 0 on both width and height.");
				return;
			}
			var i:int, len:int;
			var j:int, lenJ:int;
			len = _chunks.length;
			for(i = 0; i < len; ++i) {
				lenJ = _chunks[i].length;
				for(j = 0; j < lenJ; ++j) {
					Chunk(_chunks[i][j]).dispose();
				}
			}
			
			_efTarget.addEventListener(Event.ENTER_FRAME, createChunksStepHandler);
			createChunksStepHandler(null);
		}
		
		/**
		 * To call when creation completes to build the vertex buffer.
		 */
		public function createBuffers():void {
			_progressX = _progressY = 0;
			_efTarget.addEventListener(Event.ENTER_FRAME, createBuffersStepHandler);
		}
		
		/**
		 * Renders the chunks
		 */
		public function render(projection:Matrix3D, sceneWidth:int, sceneHeight:int):void {
			var xloc:int;
			var yloc:int;
			var chunk:Chunk;
			_lastProjection = projection;
			_sceneWidth = sceneWidth;
			_sceneHeight = sceneHeight;
			
			if(_chunks == null) return;
			
			_context3D.setProgram(_shaderProgram);
			_context3D.setTextureAt(0, _textureCubes);
			
			//Compute scroll offsets
			var viewXShift:int = Camera3D.rotationX>180 && Camera3D.rotationX<360? 1 : 0;
			var viewYShift:int = Camera3D.rotationX>90 && Camera3D.rotationX<270? 0 : 1;
			_offsetX = Math.floor((-Camera3D.locX-(_chunkSize*_chunksW*.5))/_chunkSize)+viewXShift;
			_offsetY = Math.floor((Camera3D.locY-(_chunkSize*_chunksH*.5))/_chunkSize)+viewYShift;
			//max limit
			_offsetX = Math.min(Math.floor(_mapSizeW/_chunkSize - _chunksW), _offsetX);
			_offsetY = Math.min(Math.floor(_mapSizeH/_chunkSize - _chunksH), _offsetY);
			//min limit
			_offsetX = Math.max(0, _offsetX);
			_offsetY = Math.max(0, _offsetY);
			
			//Move, flag and sort the chunks
			var drawArray:Array = [];
			var px:int, py:int;
			for (yloc = _chunksH-1; yloc >= 0; yloc --) {
				for (xloc = _chunksW-1; xloc >= 0; xloc --) {
					if(_chunks[yloc] == null) break;
					chunk = _chunks[yloc][xloc];
					if(chunk == null) continue;
					
					px = (Math.ceil((_offsetX-xloc)/_chunksW)*_chunksW+xloc) * _chunkSize;
					py = (Math.ceil((_offsetY-yloc)/_chunksH)*_chunksH+yloc) * _chunkSize;
					_posToChunk[px+"-"+py] = chunk;
					if(chunk.setPosition(px, py)) {
						_toUpdate.push({chunk:chunk, pz:projection.transformVector(new Vector3D(px, py, 0)).z});
					}
					
					if(!chunk.isReady) continue;
					var matrix3D:Matrix3D = projection.clone();
					drawArray.push( { chunk:chunk, sort:projection.transformVector(new Vector3D(px, py, 0)).z, matrix3D:matrix3D } );
				}
			}
			drawArray.sortOn("sort", Array.NUMERIC | Array.DESCENDING);
			
			//Draw the chunks
			var i:int, len:int;
			len = drawArray.length;
			for (i = 0; i < len; ++i) {
				Chunk(drawArray[i].chunk).renderBuffer();
			}
			
			_prevOffsetX = _offsetX;
			_prevOffsetY = _offsetY;
		}
		
		/**
		 * Defines the number of visible chunks
		 */
		public function setVisibleChunks(width:int=10, height:int=10):void {
			_chunksW = width;
			_chunksH = height;
			_toUpdate = [];
			create();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Called when a new map is loaded
		 */
		private function loadMapHandler(event:MapEvent):void {
			var i:int, len:int;
			var j:int, lenJ:int, chunk:Chunk;
			len = _chunks.length;
			for(i = 0; i < len; ++i) {
				lenJ = _chunks[i].length;
				for(j = 0; j < lenJ; ++j) {
					chunk = Chunk(_chunks[i][j]);
					if(!chunk.updating) {
						//TODO not sure it works well... the originX/Y thing
						_toUpdate.push({chunk:chunk, pz:_lastProjection.transformVector(new Vector3D(chunk.originX, chunk.originY, 0)).z});
					}
				}
			}
		}
		
		/**
		 * Create a group of chunk's buffer
		 */
		private function createBuffersStepHandler(event:Event):void {
			if(_toUpdate.length == 0) return;
			var i:int, len:int, s:Number;
			s = getTimer();
			_toUpdate.sortOn("pz", Array.NUMERIC);
			//place all the chunks that are Z negative to the end
			len = _toUpdate.length;
			while(_toUpdate[0].pz < -3 && i < len) {
				_toUpdate.push(_toUpdate.shift()); // Put it at the end
				i++; 
			}
			//Renders all the possible chunks. If it's taking too much time, stop
			while(len > 0 && getTimer()-s < 20) {
				Chunk(_toUpdate[0].chunk).createBuffers();
				_toUpdate.splice(0, 1);
				len--;
			}
		}
		
		/**
		 * Create a group of chunks
		 */
		private function createChunksStepHandler(event:Event):void {
			var i:int, len:int, chunk:Chunk;
			
			len = 60;//Number of chunks instance to create per cycle
			for(i = 0; i < len; ++i) {
				if(_progressX == 0) _chunks[_progressY] = [];
				//Create chunk
				chunk = new Chunk(_progressX, _progressY, _chunkSize, _map, _context3D, _textureCubes);
				_chunks[_progressY][_progressX] = chunk;
//				_toUpdate.push({chunk:chunk, pz:_lastProjection.transformVector(new Vector3D(_progressX, _progressY, 0)).z});
				
				_progressX ++;
				
				if(_progressX >= _chunksW) {
					_progressX = 0;
					_progressY ++;
					
					if(_progressY >= _chunksH) {
						dispatchEvent(new ManagerEvent(ManagerEvent.PROGRESS, 1));
						dispatchEvent(new ManagerEvent(ManagerEvent.COMPLETE, 1));
						_efTarget.removeEventListener(Event.ENTER_FRAME, createChunksStepHandler);
						return;
					}
				}
			}
			var done:Number = _progressX + _progressY * _chunksW;
			var p:Number = done / (_chunksW * _chunksH);
			dispatchEvent(new ManagerEvent(ManagerEvent.PROGRESS, p));
		}
		
	}
}