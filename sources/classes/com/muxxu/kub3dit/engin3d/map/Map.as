package com.muxxu.kub3dit.engin3d.map {
	import com.muxxu.kub3dit.engin3d.events.MapEvent;
	import com.muxxu.kub3dit.engin3d.chunks.ChunkData;

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
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Map</code>.
		 */
		public function Map(mapSizeX:int, mapSizeY:int, mapSizeZ:int) {
			_mapSizeX=mapSizeX;
			_mapSizeY=mapSizeY;
			_mapSizeZ=mapSizeZ;
			
			_map = new ByteArray();
			_map.length = _mapSizeX * _mapSizeY * _mapSizeZ;
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



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Updates a specific tile
		 */
		public function updateTile(xloc:int, yloc:int, zloc:int, value:uint):void {
			if(xloc * yloc * zloc < _map.length) {
				_map.position = xloc + yloc * _mapSizeX + zloc * _mapSizeX * _mapSizeY;
				_map.writeByte(value);
			}
		}
		
		/**
		 * Gets a specific tile
		 */
		public function getTile(xloc:int, yloc:int, zloc:int):uint {
			if (zloc >= 0 && zloc < _mapSizeZ && yloc >= 0 && yloc < _mapSizeY && xloc >= 0 && xloc < _mapSizeX) {
				_map.position = xloc + yloc * _mapSizeX + zloc * _mapSizeX * _mapSizeY;
				return _map.readUnsignedByte();
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
					_map.position = xloc + yloc * _mapSizeX + z * _mapSizeX * _mapSizeY;
					tile = _map.readUnsignedByte();
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
			var voxelData:ChunkData=new ChunkData(chunkSize, chunkSize, _mapSizeZ, this);
			voxelData._x=startx;
			voxelData._y=starty;
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
			voxelData._data=[];
			for (zloc=0; zloc < _mapSizeZ; zloc++) {
				if (!voxelData._data[zloc]) {
					voxelData._data[zloc]=[];
				}
				for (ymaploc=starty; ymaploc < endY; ymaploc++) {
					if (!voxelData._data[zloc][yloc]) {
						voxelData._data[zloc][yloc]=[];
					}
					for (xmaploc=startx; xmaploc < endX; xmaploc++) {
						voxelData._data[zloc][yloc][xloc] = getTile(xmaploc, ymaploc, zloc);
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
			return voxelData;
		}
		
		/**
		 * Loads a map
		 */
		public function load(data:ByteArray):void {
			data.position = 1;//skip file type
			_mapSizeX = data.readShort();
			_mapSizeY = data.readShort();
			_mapSizeZ = data.readShort();
			data.readBytes(_map);
			dispatchEvent(new MapEvent(MapEvent.LOAD));
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */

	}
}