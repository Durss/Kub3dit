package com.muxxu.kub3dit.engin3d.map {
	import apparat.memory.Memory;
	import com.muxxu.kub3dit.engin3d.camera.Camera3D;
	import com.muxxu.kub3dit.engin3d.chunks.ChunkData;
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;
	import com.muxxu.kub3dit.engin3d.events.MapEvent;
	import com.nurun.structure.environnement.configuration.Config;

	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;

	
	[Event(name="mapProgress", type="com.muxxu.kub3dit.engin3d.events.MapEvent")]
	[Event(name="mapComplete", type="com.muxxu.kub3dit.engin3d.events.MapEvent")]
	[Event(name="mapLoad", type="com.muxxu.kub3dit.engin3d.events.MapEvent")]
	
	/**
	 * 
	 * @author Francois
	 * @date 10 nov. 2011;
	 */
	public class Map extends EventDispatcher {
		
		private var _mapSizeX:int;
		private var _mapSizeY:int;
		private var _mapSizeZ:int;
		private var _map:ByteArray;
		private var _adaptSizes:Boolean;
		private var _cameraPaths:Array;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Map</code>.
		 */
		public function Map(adaptSizes:Boolean = true) {
			_adaptSizes = adaptSizes;
			super();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		
		public function get data():ByteArray {
			return _map;
		}

		public function get mapSizeX():int {
			return _mapSizeX;
		}

		public function get mapSizeY():int {
			return _mapSizeY;
		}

		public function get mapSizeZ():int {
			return _mapSizeZ;
		}
		
		public function get cameraPaths():Array {
			return _cameraPaths == null? [] : _cameraPaths;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */

		public function generateEmptyMap(mapSizeX:int, mapSizeY:int, mapSizeZ:int):void {
			_mapSizeX=mapSizeX;
			_mapSizeY=mapSizeY;
			_mapSizeZ=mapSizeZ;
			
			_map = new ByteArray();
			_map.length = _mapSizeX * _mapSizeY * _mapSizeZ;
			Memory.select(_map);
		}
		
		/**
		 * Updates a specific tile
		 */
		public function updateTile(xloc:int, yloc:int, zloc:int, value:uint):void {
			if(xloc * yloc * zloc < _map.length) {
				_map.position = xloc + yloc * _mapSizeX + zloc * _mapSizeX * _mapSizeY;
				_map.writeByte(value);
				Memory.writeByte(value, xloc + yloc * _mapSizeX + zloc * _mapSizeX * _mapSizeY);
			}
		}
		
		/**
		 * Gets a specific tile
		 */
		public function getTile(xloc:int, yloc:int, zloc:int):uint {
			if (zloc >= 0 && zloc < _mapSizeZ && yloc >= 0 && yloc < _mapSizeY && xloc >= 0 && xloc < _mapSizeX) {
//				_map.position = xloc + yloc * _mapSizeX + zloc * _mapSizeX * _mapSizeY;
//				return _map.readUnsignedByte();
				return Memory.readUnsignedByte(xloc + yloc * _mapSizeX + zloc * _mapSizeX * _mapSizeY);
			}
			return 0;
		}
		
		/**
		 * Gets the tile that should be displayed on the radar (ray casting from the top)
		 */
		public function getRadarTile(xloc:int, yloc:int):int {
			if (yloc >= 0 && yloc < _mapSizeY && xloc >= 0 && xloc < _mapSizeX) {
				var z:int = _mapSizeZ-1, tile:int;
				do {
//					_map.position = xloc + yloc * _mapSizeX + z * _mapSizeX * _mapSizeY;
//					tile = _map.readUnsignedByte();
					tile = Memory.readUnsignedByte(xloc + yloc * _mapSizeX + z * _mapSizeX * _mapSizeY);
					z--;
				}while(z>0 && tile == 0);
				return tile;
			}
			return 0;
		}
		
		/**
		 * Copies a specific part of the data
		 */
		public function copyData(chunkSize:int, startx:int, starty:int):ChunkData {
			var chunk:ChunkData=new ChunkData(chunkSize, chunkSize, _mapSizeZ, this);
			chunk._x=startx;
			chunk._y=starty;
			var xloc:int=0;
			var yloc:int=0;
			var xmaploc:int;
			var ymaploc:int;
			var zloc:int;
			var endX:int=startx + chunkSize;
			var endY:int=starty + chunkSize;
			if (endX > _mapSizeX) {
				endX=_mapSizeX;
			}
			if (endY > _mapSizeY) {
				endY=_mapSizeY;
			}
			chunk._data = [];
			for (zloc=0; zloc < _mapSizeZ; zloc++) {
				if (!chunk._data[zloc]) {
					chunk._data[zloc]=[];
				}
				for (ymaploc=starty; ymaploc < endY; ymaploc++) {
					if (!chunk._data[zloc][yloc]) {
						chunk._data[zloc][yloc]=[];
					}
					for (xmaploc=startx; xmaploc < endX; xmaploc++) {
						chunk._data[zloc][yloc][xloc] = getTile(xmaploc, ymaploc, zloc);
						xloc++;
						if (xloc >= chunkSize) {
							xloc=0;
							yloc++;
							if (yloc >= chunkSize) {
								yloc=0;
							}
						}
					}
				}
			}
			return chunk;
		}
		
		/**
		 * Loads a map
		 */
		public function load(data:ByteArray):void {
			var diffX:int, diffY:int, diffZ:int, value:int, ox:int, oy:int, oz:int;
			//FIXME Memory breaks the loading.
			_mapSizeX = ox = data.readShort();
			_mapSizeY = oy = data.readShort();
			_mapSizeZ = oz = data.readShort();
			_map = new ByteArray();
			
			//here we round the map's size to the nearest chunk size multiple.
			//if chunk size is 16 and map size is 14, we round the map' size to 16 and center the content on it.
			if(_adaptSizes) {
				//Check if a resize is needed
				if(_mapSizeX % ChunksManager.CHUNK_SIZE != 0) {
					value = Math.ceil(_mapSizeX/ChunksManager.CHUNK_SIZE) * ChunksManager.CHUNK_SIZE;
					diffX = value - _mapSizeX;
					_mapSizeX = value;
				}
				if(_mapSizeY % ChunksManager.CHUNK_SIZE != 0) {
					value = Math.ceil(_mapSizeY/ChunksManager.CHUNK_SIZE) * ChunksManager.CHUNK_SIZE;
					diffY = value - _mapSizeY;
					_mapSizeY = value;
				}
				if(_mapSizeZ < Config.getNumVariable("mapSizeHeight")) {
					value = Config.getNumVariable("mapSizeHeight");
					diffZ = value - _mapSizeZ;
					_mapSizeZ = value;
				}
				
				//If a resize is needed, center the content on it.
				if(diffX > 0 || diffY > 0 || diffZ > 0) {
					adaptMapSizesData(data, diffX, diffY, ox, oy);
				}else{
					loadData(data);
				}
			}else{
				loadData(data);
			}
			
			dispatchEvent(new MapEvent(MapEvent.LOAD));
		}
		
		/**
		 * Adds a camera's path to the map.
		 */
		public function addCameraPath(path:Array, name:String):void {
			if(_cameraPaths == null) _cameraPaths = [];
			var id:int = 0;
			var i:int, len:int;
			len = _cameraPaths.length;
			for(i = 0; i < len; ++i) {
				id = Math.max(_cameraPaths[i]["id"], id);
			}
			_cameraPaths.push({name:name, path:path, id:id+1});
		}
		
		/**
		 * Sets the camera's paths registered on the map.
		 */
		public function setCameraPaths(value:Array):void {
			_cameraPaths = value;
		}
		
		/**
		 * Starts the following of a path by its ID
		 */
		public function followPathById(value:int):void {
			var i:int, len:int;
			len = _cameraPaths.length;
			for(i = 0; i < len; ++i) {
				if(_cameraPaths[i]["id"] == value) {
					Camera3D.path = _cameraPaths[i]["path"];
					Camera3D.followCurrentPath();
					break;
				}
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
		/**
		 * Loads a map's data.
		 */
		private function adaptMapSizesData(data:ByteArray, diffX:int, diffY:int, ox:int, oy:int):void {
			var px:int, py:int, pz:int, i:int;
			_map.length = _mapSizeX*_mapSizeY*_mapSizeZ;
			Memory.select(_map);
			
			//write loaded map on the bottom center.
			while(data.bytesAvailable) {
				px = diffX * .5 + i%ox;
				py = diffY * .5 + Math.floor(i/ox)%oy;
				pz = Math.floor(i/(ox*oy));
//				_map.position = px + py * _mapSizeX + pz * _mapSizeX * _mapSizeY;
//				_map.writeByte(data.readByte());
				Memory.writeByte(data.readByte(), px + py * _mapSizeX + pz * _mapSizeX * _mapSizeY);
				i++;
			}
		}
		
		/**
		 * Loads a map's data.
		 */
		private function loadData(data:ByteArray):void {
			var i:int =0;
			_map.length = data.length - data.position;
			_map.position = 0;
			Memory.select(_map);
			while(data.bytesAvailable) {
				Memory.writeByte(data.readByte(), i++);
			}
//			data.readBytes(_map);
//			_map.position = 0;
		}

	}
}