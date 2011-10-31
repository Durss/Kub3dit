package com.muxxu.kub3dit.components {
	import flash.geom.Rectangle;
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * Creates a window's background.
	 * 
	 * @author  Francois
	 */
	public class BackWindow extends Sprite {
		
		public static const CELL_WIDTH:int	= 4;
		protected const SHADOW_ALPHA:Number	= .2;
		protected const BORDER_COLORS:Array	= [randColor(), randColor(), randColor(), randColor(), randColor(), randColor(), randColor(), randColor(), randColor(), randColor(), randColor()];
		protected const CELL_SIZES:Array	= [randSize(), randSize(), randSize(), randSize(), randSize(), randSize(), randSize(), randSize(), randSize(), randSize(), randSize(), randSize(), randSize(), randSize(), randSize(), randSize(), randSize(), randSize(), randSize()];
		protected var _width:int;
		protected var _height:int;

		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>BackWindow</code>.
		 */
		public function BackWindow() { }

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Sets the component's width without simply scaling it.
		 */
		override public function set width(value:Number):void {
			_width = value;
			computePositions();
		}
		
		/**
		 * Sets the component's height without simply scaling it.
		 */
		override public function set height(value:Number):void {
			_height = value;
			computePositions();
		}
		
		/**
		 * Gets the virtual component's width.
		 */
		override public function get width():Number { return _width + 1; }
		
		/**
		 * Gets the virtual component's hright.
		 */
		override public function get height():Number { return _height + 1; }

		
		
		
		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
		/**
		 * Resize and replace the elements.<br>
		 */
		protected function computePositions(e:Event = null):void {
			graphics.clear();
			var h:int, w:int, pointer:int, py:int, px:int, offset:int, colors:Array, len:int;
			
			pointer = 0;
			colors = BORDER_COLORS;
			len = colors.length;
			
			do{
				graphics.lineStyle(0,0,0);
				h = CELL_SIZES[pointer % CELL_SIZES.length];
				graphics.beginFill(colors[pointer % len], 1);
				graphics.drawRect(0, py, CELL_WIDTH, h);
				if(py + h < _height - CELL_WIDTH) {
					graphics.beginFill(0, SHADOW_ALPHA);
					graphics.drawRect(0, py + h - 1, CELL_WIDTH, 1);
				}
				if(py > 0) {
					graphics.lineStyle(0,0,.5);
					graphics.moveTo(0,py);
					graphics.lineTo(CELL_WIDTH,py);
				}
				py += h;
				pointer ++;
			}while(py < _height - CELL_WIDTH);
			
			offset = (py - CELL_WIDTH) - _height;
			pointer --;
			do{
				graphics.lineStyle(0,0,0);
				w = Math.max(CELL_WIDTH, CELL_SIZES[pointer % CELL_SIZES.length] + offset);
				graphics.beginFill(colors[pointer % len], 1);
				graphics.drawRect(px, _height - CELL_WIDTH, w, CELL_WIDTH);
				if(px + w < _width - CELL_WIDTH && px > 0) {
					graphics.beginFill(0, SHADOW_ALPHA);
					graphics.drawRect(px + 1, _height - CELL_WIDTH, 1, CELL_WIDTH);
				}
				if(px > 0) {
					graphics.lineStyle(0,0,.5);
					graphics.moveTo(px ,_height - CELL_WIDTH);
					graphics.lineTo(px ,_height);
				}
				px += w;
				pointer ++;
				offset = 0;
			}while(px < _width -CELL_WIDTH);
			
			
			offset = (px - CELL_WIDTH) - _width;
			pointer --;
			py = _height;
			do{
				graphics.lineStyle(0,0,0);
				h = Math.max(CELL_WIDTH, CELL_SIZES[pointer % CELL_SIZES.length] + offset);
				graphics.beginFill(colors[pointer % len], 1);
				graphics.drawRect(_width-CELL_WIDTH, py - h, CELL_WIDTH, h);
				if(py < _height) {
					graphics.beginFill(0, SHADOW_ALPHA);
					graphics.drawRect(_width - CELL_WIDTH, py - 1, CELL_WIDTH, 1);
					graphics.lineStyle(0,0,.5);
					graphics.moveTo(_width-CELL_WIDTH, py);
					graphics.lineTo(_width, py);
				}
				py -= h;
				pointer ++;
				offset = 0;
			}while(py > CELL_WIDTH);
			
			offset = -py - CELL_WIDTH;
			pointer --;
			px = _width;
			do{
				graphics.lineStyle(0,0,0);
				w = Math.max(CELL_WIDTH, CELL_SIZES[pointer % CELL_SIZES.length] + offset);
				if(px - w < CELL_WIDTH){
					graphics.beginFill(colors[0], 1);
				}else{
					graphics.beginFill(colors[pointer % len], 1);
				}
				graphics.drawRect(px - w, 0, w, CELL_WIDTH);
				if(px > CELL_WIDTH) {
					graphics.beginFill(0, SHADOW_ALPHA);
					graphics.drawRect(px + 1, 0, 1, CELL_WIDTH);
					graphics.lineStyle(0,0,.5);
					graphics.moveTo(px, 0);
					graphics.lineTo(px, CELL_WIDTH);
				}
				pointer ++;
				px -= w;
				offset = 0;
			}while(px > CELL_WIDTH);
			
			graphics.beginFill(0x4CA5CD,1);
			graphics.drawRect(CELL_WIDTH, CELL_WIDTH, _width-(CELL_WIDTH*2), _height-(CELL_WIDTH*2));
			
			graphics.lineStyle(0,0,0);
			graphics.beginFill(0, SHADOW_ALPHA);
			graphics.drawRect(0, 0, 1, _height - 1);
			graphics.drawRect(_width - CELL_WIDTH + 1, CELL_WIDTH - 1, 1, _height - CELL_WIDTH * 2 + 2);
			graphics.drawRect(0, _height - 1, _width, 1);
			graphics.drawRect(CELL_WIDTH, CELL_WIDTH - 1, _width - CELL_WIDTH * 2 + 1, 1);
			
			scrollRect = new Rectangle(0,0,_width,_height);
		}
		
		/**
		 * Computes a random cell size.
		 */
		private function randSize():int {
			return Math.random()*(CELL_WIDTH*3) + CELL_WIDTH * 2;
		}
		
		/**
		 * Gets a random color in a palette.
		 */
		private function randColor():Number {
			var c:Array = [0x87DBEF, 0xB3E4F5, 0xA4D9EE, 0x96BFD2, 0xCBF3F8, 0x9CE3EB, 0x76ADC5];
			return c[Math.floor(Math.random() * c.length)];
		}
		
	}
}
