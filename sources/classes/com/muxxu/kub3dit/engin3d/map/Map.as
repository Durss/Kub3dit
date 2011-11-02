package com.muxxu.kub3dit.engin3d.map {
	import com.muxxu.kub3dit.engin3d.chunks.ChunkData;

	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;


	
	[Event(name="mapProgress", type="com.muxxu.kub3dit.engin3d.events.MapEvent")]
	[Event(name="mapComplete", type="com.muxxu.kub3dit.engin3d.events.MapEvent")]

	/**
	 * ...
	 * @author andre
	 */
	public class Map extends EventDispatcher {
		
		private var _mapSizeX:int;
		private var _mapSizeY:int;
		private var _mapSizeZ:int;
		private var _map:ByteArray;

		public function Map(mapSizeX:int, mapSizeY:int, mapSizeZ:int) {
			generateFlatMap(mapSizeX, mapSizeY, mapSizeZ);
		}

		public function updateTile(xloc:int, yloc:int, zloc:int, value:int):void {
			if(xloc * yloc * zloc < _map.length) {
				_map.position = xloc + yloc * _mapSizeX + zloc * _mapSizeX * _mapSizeY;
				_map.writeByte(value);
			}
		}

		public function getTile(xloc:int, yloc:int, zloc:int):int {
			if (zloc >= 0 && zloc < _mapSizeZ && yloc >= 0 && yloc < _mapSizeY && xloc >= 0 && xloc < _mapSizeX) {
				_map.position = xloc + yloc * _mapSizeX + zloc * _mapSizeX * _mapSizeY;
				return _map.readByte();
			}
			return 0;
		}

		private function generateFlatMap(mapSizeX:int, mapSizeY:int, mapSizeZ:int):void {
			_mapSizeX=mapSizeX;
			_mapSizeY=mapSizeY;
			_mapSizeZ=mapSizeZ;
			
			_map = new ByteArray();
			_map.length = _mapSizeX * _mapSizeY * _mapSizeZ;
			
			return;
			var i:int, len:int;//, radius:int;
			len = _mapSizeX * _mapSizeY * _mapSizeZ;
			for(i = 0; i < len; ++i) {
//				_map.writeByte(i < _mapSizeX * _mapSizeY? 2 : 0);
//				_map.writeByte(i < _mapSizeX * _mapSizeY? Math.floor(i%12+10) : 0);
//				_map.writeByte(0);
//				if(i < _mapSizeX * _mapSizeY) {
//					var zIndex:int = Math.floor(i/(_mapSizeX*_mapSizeY));
//					var pz:int = zIndex * (_mapSizeX*_mapSizeY);
//					var py:int = Math.floor((i-pz)/_mapSizeX);
//					var px:int = i-pz-py*_mapSizeX;
//					var d:int = Math.sqrt(Math.pow(_mapSizeX*.5 - px, 2) + Math.pow(_mapSizeY*.5 - py, 2));
//					radius = 80 - zIndex*2;
//					if(d <= radius) {
//						_map.writeByte((zIndex==0)? 21 : (d<=radius && d>=radius-1)? (zIndex%6==0)? 13 : 16 : 0);
//					}else{
//						_map.writeByte(px==_mapSizeX-1? 1 : 0);
//					}
//				}else{
					_map.writeByte(0);
//				}
			}
//			_map.position = 6 + _mapSizeX * _mapSizeY;
//			_map.writeByte(71);
//			_map.writeByte(71);
//			_map.writeByte(71);
//			_map.writeByte(71);
//			trace(getSize(_map))
		}
		
		public function get data():ByteArray {
			return _map;
		}
		
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

		public function get mapSizeX():int {
			return _mapSizeX;
		}

		public function get mapSizeY():int {
			return _mapSizeY;
		}

		public function get mapSizeZ():int {
			return _mapSizeZ;
		}
	}
}