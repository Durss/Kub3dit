package com.muxxu.kub3dit.components.form {
	import com.nurun.utils.math.MathUtils;
	import com.muxxu.kub3dit.vo.KubeSelecorItemData;
	import com.muxxu.kub3dit.components.window.BackWindow;
	import flash.display.DisplayObject;
	import gs.TweenLite;
	import flash.events.MouseEvent;
	import com.muxxu.kub3dit.components.buttons.KubeSelectorItem;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.events.TextureEvent;
	import com.muxxu.kub3dit.utils.drawIsoKube;
	import com.nurun.components.tile.TileEngine2DSwipeWrapper;
	import com.nurun.utils.touch.SwipeManager;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	/**
	 * 
	 * @author Francois
	 * @date 10 mai 2012;
	 */
	public class KubeSelectorInput extends Sprite {
		
		private var _engine:TileEngine2DSwipeWrapper;
		private var _swiper:SwipeManager;
		private var _smallViewport:Rectangle;
		private var _largeViewport:Rectangle;
		private var _holder : Sprite;
		private var _pressed:Boolean;
		private var _opened:Boolean;
		private var _lastScrollX:int;
		private var _back:BackWindow;
		private var _selectedItem:KubeSelecorItemData;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>KubeSelectorInput</code>.
		 */
		public function KubeSelectorInput() {
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the selected kube ID
		 */
		public function get kubeID():int {
			return parseInt(_selectedItem.id);
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			_back = addChild(new BackWindow(false)) as BackWindow;
			_holder = addChild(new Sprite()) as Sprite;
			var empty:BitmapData = new BitmapData(16, 16, true, 0);
			var bmdRef:BitmapData = drawIsoKube(empty, empty, true, .75, true);
			
			_smallViewport = new Rectangle();
			_smallViewport.width = bmdRef.width;
			_smallViewport.height = bmdRef.height;
			
			_largeViewport = new Rectangle();
			_largeViewport.width = (bmdRef.width+5) * 10 - 5;
			_largeViewport.height = bmdRef.height;
			
			_engine = _holder.addChild(new TileEngine2DSwipeWrapper(KubeSelectorItem, _smallViewport.width, _smallViewport.height, bmdRef.width, bmdRef.height, 5, 5)) as TileEngine2DSwipeWrapper;
			_engine.lockY = true;
			_swiper = new SwipeManager(_engine, _largeViewport);
			_swiper.roundXValue = bmdRef.width + 5;
			_swiper.roundYValue = bmdRef.height + 5;
			_swiper.lockXExtremes = false;
			
			_holder.y = BackWindow.CELL_WIDTH;
			_holder.x = BackWindow.CELL_WIDTH;
			
			_back.width = _engine.visibleWidth + BackWindow.CELL_WIDTH * 2;
			_back.height = _engine.visibleHeight + BackWindow.CELL_WIDTH * 2;
			
			Textures.getInstance().addEventListener(TextureEvent.CHANGE_SPRITESHEET, updateList);
			
			updateList();
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mousePressHandler);
			_engine.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mousePressHandler);
		}

		private function mouseWheelHandler(event:MouseEvent):void {
			var inc:int = (_smallViewport.width + 5);
			_swiper.x += inc * MathUtils.sign(event.delta);
		}

		private function mousePressHandler(event:MouseEvent):void {
			if(_opened && !_pressed && event.type == MouseEvent.MOUSE_UP && !contains(event.target as DisplayObject)) {
				rollOutHandler(event);
			}
			_pressed = event.type == MouseEvent.MOUSE_DOWN && contains(event.target as DisplayObject);
		}

		private function rollOverHandler(event:MouseEvent):void {
			if(_opened) return;
			
			_opened = true;
			var endX:int = (_smallViewport.width-_largeViewport.width)*.5;
			var moveX:int = (_engine.visibleWidth-_largeViewport.width)*.5;
			
			TweenLite.killTweensOf(_engine);
			TweenLite.killTweensOf(_holder);
			
			TweenLite.to(_engine, .25, {visibleWidth:_largeViewport.width,
										visibleHeight:_largeViewport.height,
										onComplete:restartSwiper,
										scrollX:Math.round((_engine.scrollX+moveX)/(_smallViewport.width+5))*(_smallViewport.width+5),
										onUpdate:_engine.validate});
			TweenLite.to(_holder, .25, {x:endX+BackWindow.CELL_WIDTH});
			TweenLite.to(_back, .25, {width:_largeViewport.width + BackWindow.CELL_WIDTH * 2, x:endX});
		}

		private function rollOutHandler(event:MouseEvent):void {
			if(_pressed) return;
			_opened = false;
			_swiper.stop();
			
			TweenLite.killTweensOf(_engine);
			TweenLite.killTweensOf(_holder);
			
			TweenLite.to(_engine, .25, {visibleWidth:_smallViewport.width,
										visibleHeight:_smallViewport.height,
										scrollX:_lastScrollX,
										onUpdate:_engine.validate});
			TweenLite.to(_holder, .25, {x:BackWindow.CELL_WIDTH});
			TweenLite.to(_back, .25, {width:_smallViewport.width + BackWindow.CELL_WIDTH * 2, x:0});
		}

		private function restartSwiper():void {
			_swiper.syncWithContent();
			_swiper.start(false, false);
		}

		
		/**
		 * Called when a kube is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target is KubeSelectorItem && !_swiper.hasMoveMoreThan()) {
				_selectedItem = KubeSelectorItem(event.target).data;
				_lastScrollX = _engine.scrollX +  KubeSelectorItem(event.target).x;
				rollOutHandler(event);;
			}
		}
		
		/**
		 * Updates the list
		 */
		private function updateList(event:TextureEvent = null):void {
			_engine.clear();
			var frames:Array = Textures.getInstance().cubesFrames;
			var bitmaps:Array = Textures.getInstance().bitmapDatas;
			var top:BitmapData, side:BitmapData, empty:BitmapData, kubes:Array;
			empty = new BitmapData(16, 16, true, 0);
			kubes = [];
			for (var k:String in frames) {
				top = bitmaps[k][0] == null ? empty : bitmaps[k][0];
				side = bitmaps[k][1] == null? empty : bitmaps[k][1];
				kubes.push(new KubeSelecorItemData(k, drawIsoKube(top, side, true, .75, true)));
			}
			
			_selectedItem = kubes[0];
			
			_engine.addLine(kubes);
		}
		
	}
}