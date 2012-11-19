package com.muxxu.kub3dit.engin3d.chunks {
	import com.muxxu.kub3dit.engin3d.camera.Camera3D;
	import com.muxxu.kub3dit.engin3d.events.ManagerEvent;
	import com.muxxu.kub3dit.engin3d.events.MapEvent;
	import com.muxxu.kub3dit.engin3d.map.Map;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.engin3d.molehill.CubeFragmentShader;
	import com.muxxu.kub3dit.engin3d.molehill.CubeVertexShader;
	import com.muxxu.kub3dit.events.LightModelEvent;
	import com.muxxu.kub3dit.events.TextureEvent;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.math.MathUtils;

	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	[Event(name="renderProgress", type="com.muxxu.kub3dit.engin3d.events.ManagerEvent")]
	[Event(name="renderComplete", type="com.muxxu.kub3dit.engin3d.events.ManagerEvent")]
	[Event(name="internalUpdate", type="com.muxxu.kub3dit.engin3d.events.ManagerEvent")]

	
	/**
	 * Manages the chunks.
	 * Moves them and update them depending on the camera's position.
	 * 
	 * @author Francois
	 * @date 4 sept. 2011;
	 */
	public class ChunksManager extends EventDispatcher {
		
		public static const CHUNK_SIZE:int = 16;
		
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
		private var _invalidateStack:Array;
		private var _visibleCubes:int;
		private var _visibleChunksX:Number;
		private var _visibleChunksY:Number;
		private var _bounds:Rectangle;
		private var _historyUndo:Vector.<Array>;
		private var _currentHistory:Array;
		private var _currentHistoryCoordsDone:Object;
		private var _historyUndoPointer:int;
		private var _historyRedo : Vector.<Array>;
		private var _lockHistorySave:Boolean;
		private var _shaderProgramTransparent:Program3D;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ChunksManager</code>.
		 */
		public function ChunksManager(map:Map) {
			_map = map;
			_historyUndo = new Vector.<Array>();
			_historyRedo = new Vector.<Array>();
			_currentHistory = [];
			_currentHistoryCoordsDone = {};
			_historyUndoPointer = 0;
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

		public function get visibleCubes():int { return _visibleCubes; }

		public function get visibleChunksX():Number { return _visibleChunksX; }
		
		public function get visibleChunksY():Number { return _visibleChunksY; }
		
		public function get bounds():Rectangle { return _bounds; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Initializes the chunks manager
		 */
		public function initialize(context3D:Context3D, accelerated:Boolean):void {
			// okay this function should set up and dispose any buffers
			// this is only ever called once at the start of the program
			if(!_intialized) {
				_toUpdate = [];
				_intialized = true;
				_context3D = context3D;
				_mapSizeW = _map.mapSizeX;
				_mapSizeH = _map.mapSizeY;
				_accelerated = accelerated;
				_bounds = new Rectangle();
				_chunkSize = CHUNK_SIZE;//Number of cubes to compose a chunk of
				_visibleCubes = _accelerated? 160 : 16;//Number of visible cubes before fog
				_visibleChunksX = MathUtils.restrict(Math.ceil(_visibleCubes/_chunkSize)+2, 2, Math.max(2, Math.ceil(_mapSizeW/_chunkSize)));//Number of visible chunks around us
				_visibleChunksY = MathUtils.restrict(Math.ceil(_visibleCubes/_chunkSize)+2, 2, Math.max(2, Math.ceil(_mapSizeH/_chunkSize)));//Number of visible chunks around us
				_efTarget = new Shape();
				
				//Init cubes textures
				updateTexture();
				
				var vs:CubeVertexShader = new CubeVertexShader();
				var fs:CubeFragmentShader = new CubeFragmentShader(_context3D, _accelerated, false);
				_shaderProgram = _context3D.createProgram();
				_shaderProgram.upload(vs.agalcode, fs.agalcode);
				
				fs = new CubeFragmentShader(_context3D, _accelerated, true);
				_shaderProgramTransparent = _context3D.createProgram();
				_shaderProgramTransparent.upload(vs.agalcode, fs.agalcode);
				_map.addEventListener(MapEvent.LOAD, loadMapHandler);
				updateVisibleChunks();
			} else {
				throw new Error("ChunksManager is already initialized!");
			}
			Textures.getInstance().addEventListener(TextureEvent.CHANGE_SPRITESHEET, updateTexture);
			ViewLocator.getInstance().addEventListener(LightModelEvent.KUBE_ADD_COMPLETE, updateTexture);
		}

		/**
		 * Updates the texture.
		 */
		private function updateTexture(event:Event = null):void {
			var bitmapData:BitmapData = Textures.getInstance().spriteSheet;
			_textureCubes = _context3D.createTexture(bitmapData.width, bitmapData.height, Context3DTextureFormat.BGRA, false);
			_textureCubes.uploadFromBitmapData(bitmapData);
		}
		
		/**
		 * Adds a cube to the invalidate stack.
		 * Adding a cube in this stack won't make it appear in the 3D world.
		 * You'll have to call "invalidate" method to process all the invalidable
		 * cubes added to the stack. Or clearInvalidateStack to cancel the process.
		 */
		public function addInvalidableCube(x:int, y:int, z:int, tile:int):void {
			_invalidateStack.push(new InvalidatableCube(x, y, z, tile));
		}
		
		/**
		 * Clears all the invalite stack
		 */
		public function clearInvalidateStack():void {
			_invalidateStack = [];
		}

		
		/**
		 * Adds all the invalidable cubes to the data
		 */
		public function invalidate():void {
			var cube:InvalidatableCube;
			var s:int = getTimer();
			while(_invalidateStack.length > 0 && getTimer()-s < 10) {
				cube = _invalidateStack.pop();
				update(cube.px, cube.py, cube.pz, cube.tile);
			}
			dispatchEvent(new ManagerEvent(ManagerEvent.INTERNAL_UPDATE));
			if(_invalidateStack.length > 0) {
				setTimeout(invalidate, 20);
			}
		}
		
		/**
		 * Savec the current modification history
		 */
		public function saveCurrentHistory():void {
			//If nothing has changed, ignore.
			if(_currentHistory.length == 0) return;
			
			//remove all the histories from the pointer's position to the end
			if(_historyUndoPointer < _historyUndo.length) {
				var i:int, len:int;
				len = _historyUndo.length;
				for(i = _historyUndoPointer; i < len; ++i) {
					_historyUndo.pop();
				}
				//Clear redo history
				while(_historyRedo.length > 0) _historyRedo.pop();
			}
			
			_historyUndo.push(_currentHistory);
			if(_historyUndo.length > 50) _historyUndo.shift();
			_historyUndoPointer = _historyUndo.length;
			_currentHistory = [];
			_currentHistoryCoordsDone = {};
		}
		
		/**
		 * Undo a modification
		 */
		public function undo():void {
			setHistory(_historyUndoPointer - 1);
		}
		
		/**
		 * Redo the last undone action
		 */
		public function redo():void {
			setHistory(_historyUndoPointer + 1, true);
		}
		
		private function setHistory(index:int, isRedo:Boolean = false):void {
			if((!isRedo && (index < 0 || index >= _historyUndo.length))
				|| (isRedo && _historyRedo.length == 0)) return;
			
			_currentHistory = [];
			_currentHistoryCoordsDone = {};
			_historyUndoPointer = index;
			
			var i:int, len:int, entry:Object, x:int, y:int, z:int;
			var history:Array = isRedo? _historyRedo[_historyRedo.length-1] : _historyUndo[_historyUndoPointer];
			len = history.length;
			for(i = 0; i < len; ++i) {
				entry = history[i];
				x = entry["x"];
				y = entry["y"];
				z = entry["z"];
				if(!isRedo) _currentHistory.push({x:x, y:y, z:z, t:_map.getTile(x, y, z)});
				_invalidateStack.push(new InvalidatableCube(x, y, z, entry["t"]));
			}
			if(!isRedo) {
				_historyRedo.push(_currentHistory);
				_currentHistory = [];
			}else{
				_historyRedo.pop();
			}
			_lockHistorySave = true;
			invalidate();
			_lockHistorySave = false;
		}
		
		/**
		 * Updates a specific cube.
		 * Automatically detects which chunk needs to be updated.
		 */
		public function update(x:int, y:int, z:int, value:int):void {
			if(x < 0 || x > _map.mapSizeX-1
			|| y < 0 || y > _map.mapSizeY-1
			|| z < 0 || z > _map.mapSizeZ-1) return;
			
			//Save previous state if not saved yet
			if(_currentHistoryCoordsDone[x+","+y+","+z] == undefined && !_lockHistorySave && value != _map.getTile(x, y, z)) {
				_currentHistoryCoordsDone[x+","+y+","+z] = true;
				_currentHistory.push({x:x,y:y,z:z,t:_map.getTile(x, y, z)});
			}
			
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
			while (_map.getTile(x, y, z) == 0 && z > -1) z--;
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
			_invalidateStack = [];
			
			if(_chunksH <= 0 || _chunksW <= 0) {
				throw new IllegalOperationError("Please define the number of visible chunks first. Must be greater than 0 on both width and height.");
				return;
			}
			var i:int, len:int;
			var j:int, lenJ:int;
			len = _chunks.length;
			for(i = 0; i < len; ++i) {
				lenJ = (_chunks[i] as Array).length;
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
			_offsetX = Math.floor((-Camera3D.locX/ChunkData.CUBE_SIZE_RATIO-(_chunkSize*_chunksW*.5))/_chunkSize)+viewXShift;
			_offsetY = Math.floor((Camera3D.locY/ChunkData.CUBE_SIZE_RATIO-(_chunkSize*_chunksH*.5))/_chunkSize)+viewYShift;
			//max limit
			_offsetX = Math.min(Math.floor(_mapSizeW/_chunkSize - _chunksW), _offsetX);
			_offsetY = Math.min(Math.floor(_mapSizeH/_chunkSize - _chunksH), _offsetY);
			//min limit
			_offsetX = Math.max(0, _offsetX);
			_offsetY = Math.max(0, _offsetY);
			
			_bounds.x = -_offsetX * _chunkSize;
			_bounds.y = -_offsetY * _chunkSize;
			_bounds.width = _chunksW * _chunkSize;
			_bounds.height = _chunksH * _chunkSize;
			
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
			
			//Draw opaque cubes
			_context3D.setDepthTest(true, Context3DCompareMode.LESS);
			var i:int, len:int;
			len = drawArray.length;
			for (i = 0; i < len; ++i) {
				Chunk(drawArray[i]["chunk"]).renderBuffer(0);
			}
			
			//Draw transparent cubes over opaque
			for (i = 0; i < len; ++i) {
				Chunk(drawArray[i]["chunk"]).renderBuffer(1);
			}
			
			if(_accelerated) {
				//Draw translucides (first pass)
				_context3D.setDepthTest(true, Context3DCompareMode.LESS);
				_context3D.setBlendFactors(Context3DBlendFactor.ZERO, Context3DBlendFactor.ONE);
				for (i = 0; i < len; ++i) {
					Chunk(drawArray[i]["chunk"]).renderBuffer(2);
				}
				
				//Draw translucides (second pass)
				_context3D.setDepthTest(true, Context3DCompareMode.EQUAL);
				_context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
				for (i = 0; i < len; ++i) {
					Chunk(drawArray[i]["chunk"]).renderBuffer(2);
				}
			}else{
				for (i = 0; i < len; ++i) {
					Chunk(drawArray[i]["chunk"]).renderBuffer(2);
				}
			}
			
			_prevOffsetX = _offsetX;
			_prevOffsetY = _offsetY;
		}
		
		/**
		 * Changes the rendering distance.
		 * 
		 * @param sign	+1 to enhance the distance, -1 to reduce it.
		 */
		public function changeRenderingDistance(sign:int):void {
			_visibleCubes += _chunkSize * MathUtils.sign(sign);
			_visibleCubes = Math.max(_visibleCubes, _chunkSize);
			_visibleChunksX = MathUtils.restrict(Math.ceil(_visibleCubes/_chunkSize)+2, 2, _mapSizeW/_chunkSize);
			_visibleChunksY = MathUtils.restrict(Math.ceil(_visibleCubes/_chunkSize)+2, 2, _mapSizeH/_chunkSize);
			updateVisibleChunks();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Defines the number of visible chunks
		 */
		private function updateVisibleChunks():void {
			_chunksW = Math.max(1, Math.min(_visibleChunksX, _mapSizeW/_chunkSize));
			_chunksH = Math.max(1, Math.min(_visibleChunksY, _mapSizeH/_chunkSize));
			_toUpdate = [];
			create();
		}
		
		/**
		 * Called when a new map is loaded
		 */
		private function loadMapHandler(event:MapEvent):void {
			_mapSizeW = _map.mapSizeX;
			_mapSizeH = _map.mapSizeY;
			_visibleChunksX = MathUtils.restrict(Math.ceil(_visibleCubes/_chunkSize)+2, 2, _mapSizeW/_chunkSize);
			_visibleChunksY = MathUtils.restrict(Math.ceil(_visibleCubes/_chunkSize)+2, 2, _mapSizeH/_chunkSize);
			updateVisibleChunks();
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
			while(_toUpdate[0]["pz"] < -ChunkData.CUBE_SIZE_RATIO*3 && i < len) {
				_toUpdate.push(_toUpdate.shift()); // Put it at the end
				i++; 
			}
			//Renders all the possible chunks. If it's taking too much time, wait for next frame
			while(len > 0 && getTimer()-s < 7) {
				Chunk(_toUpdate[0]["chunk"]).createBuffers(0);
				Chunk(_toUpdate[0]["chunk"]).createBuffers(1);
				Chunk(_toUpdate[0]["chunk"]).createBuffers(2);
				_toUpdate.splice(0, 1);
				len--;
			}
		}
		
		/**
		 * Create a group of chunks
		 */
		private function createChunksStepHandler(event:Event):void {
			var i:int, len:int, chunk:Chunk;
			
			len = 200;//Number of chunks instance to create per cycle
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

internal class InvalidatableCube {
	public var px:int;
	public var py:int;
	public var pz:int;
	public var tile:int;

	public function InvalidatableCube(p_px:int, p_py:int, p_pz:int, p_tile:int):void {
		tile = p_tile;
		pz = p_pz;
		py = p_py;
		px = p_px;
	}
}