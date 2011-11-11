package com.muxxu.kub3dit.components.editor.toolpanels {
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
		public function draw(ox:int, oy:int, oz:int, kubeID:int, chunksManagerRef:ChunksManager, gridSize:int, gridOffset:Point):void {
			if(_lastSize != gridSize) {
				_lastSize = gridSize;
				if(_bmd!=null) _bmd.dispose();
				_bmd = new BitmapData(gridSize, gridSize, true, 0);
				addChild(new Bitmap(_bmd));
			}
			
			var i:int, len:int, px:int, py:int, tile:int, map:Map;
			map = chunksManagerRef.map;
			len = gridSize*gridSize;
			
			for(i = 0; i < len; ++i) {
				py = Math.floor(i/gridSize);
				px = i - py*gridSize;
				tile = map.getTile(ox+px, oy+py, oz);
				if(tile > 0) {
					_bmd.setPixel32(px, py, _colors[tile][oz]);
				}
			}
			kubeID;
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
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			
		}
		
	}
}