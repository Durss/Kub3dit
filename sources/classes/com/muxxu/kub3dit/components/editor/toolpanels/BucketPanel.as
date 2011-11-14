package com.muxxu.kub3dit.components.editor.toolpanels {
	import flash.utils.ByteArray;
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;
	import com.muxxu.kub3dit.engin3d.map.Map;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.nurun.core.lang.Disposable;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	/**
	 * 
	 * @author Francois
	 * @date 11 nov. 2011;
	 */
	public class BucketPanel extends Sprite implements IToolPanel {
		private var _landMark:Shape;
		private var _eraseMode:Boolean;
		private var _lastSize:int;
		private var _bmd:BitmapData;
		private var _colors:Array;
		private var _chunksManager:ChunksManager;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>BucketPanel</code>.
		 */
		public function BucketPanel() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		public function get landmark():Shape {
			return _landMark;
		}

		/**
		 * @inheritDoc
		 */
		public function set eraseMode(value:Boolean):void {
			_eraseMode = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set chunksManager(value:ChunksManager):void {
			_chunksManager = value;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
		}

		/**
		 * @inheritDoc
		 */
		public function draw(ox:int, oy:int, oz:int, kubeID:int, gridSize:int, gridOffset:Point):void {
			if(_lastSize != gridSize) {
				_lastSize = gridSize;
				if(_bmd!=null) _bmd.dispose();
				_bmd = new BitmapData(gridSize, gridSize, true, 0);
				addChild(new Bitmap(_bmd));
			}
			
			var i:int, len:int, px:int, py:int, tile:int, map:Map;
			map = _chunksManager.map;
			len = gridSize*gridSize;
			var floodMark:uint = 0x55ff5454;
			var emptyMark:uint = 0x8800ff00;
			
			_bmd.fillRect(_bmd.rect, 0);
			for(i = 0; i < len; ++i) {
				py = Math.floor(i/gridSize);
				px = i - py*gridSize;
				if(gridOffset.x+px < 0 || gridOffset.y+py < 0
				|| gridOffset.x+px > map.mapSizeX || gridOffset.y+py > map.mapSizeY) {
					_bmd.setPixel32(px, py, emptyMark);
					continue;
				}
				tile = map.getTile(gridOffset.x+px, gridOffset.y+py, oz);
				if(tile > 0) {
					_bmd.setPixel32(px, py, _colors[tile][oz]);
					continue;
				}
			}
			if(_bmd.getPixel32(ox - gridOffset.x, oy - gridOffset.y) != emptyMark) {
				
				_bmd.floodFill(ox - gridOffset.x, oy - gridOffset.y, floodMark);
				
				var pixel:uint;
				var pixels:ByteArray = _bmd.getPixels(_bmd.rect);
				pixels.position = 0;
				while(pixels.bytesAvailable) {
					i = pixels.position/4;
					pixel = pixels.readUnsignedInt();
					if(pixel == floodMark) {
						px = i%gridSize + gridOffset.x;
						py = Math.floor(i/gridSize) + gridOffset.y;
						_chunksManager.update(px, py, oz, _eraseMode? 0 :kubeID);
					}
				}
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_lastSize = -1;
			_landMark = new Shape();
			_landMark.graphics.beginFill(0xffffff, .2);
			_landMark.graphics.drawRect(0, 0, 1, 1);
			
			_colors = Textures.getInstance().levelColors;
		}
		
	}
}