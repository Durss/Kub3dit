package com.muxxu.build3r.vo {
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * @author Francois
	 * @date 20 févr. 2012;
	 */
	public class LightMapData {
		
		private var _width:int;
		private var _height:int;
		private var _depth:int;
		private var _map:ByteArray;
		
		
		

		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>LightMapData</code>.
		 */
		public function LightMapData(width:int, height:int, depth:int, data:ByteArray) {
			_width = width;
			_height = height;
			_depth = depth;
			_map = new ByteArray();
			data.readBytes(_map);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get depth():int {
			return _depth;
		}

		public function get height():int {
			return _height;
		}

		public function get width():int {
			return _width;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		
		/**
		 * Gets a specific tile
		 */
		public function getTile(xloc:int, yloc:int, zloc:int):uint {
			if (zloc >= 0 && zloc < _depth && yloc >= 0 && yloc < _height && xloc >= 0 && xloc < _width) {
				_map.position = xloc + yloc * _width + zloc * _width * _height;
				return _map.readUnsignedByte();
			}
			return 0;
		}
		
		/**
		 * Gets the tile that should be displayed on the radar (ray casting from the top)
		 */
		public function getRadarTile(xloc:int, yloc:int):int {
			if (yloc >= 0 && yloc < _height && xloc >= 0 && xloc < _width) {
				var z:int = _depth-1, tile:int;
				do {
					_map.position = xloc + yloc * _width + z * _width * _height;
					tile = _map.readUnsignedByte();
					z--;
				}while(z>0 && tile == 0);
				return tile;
			}
			return 0;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}