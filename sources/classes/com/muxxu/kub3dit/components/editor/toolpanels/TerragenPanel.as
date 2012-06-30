package com.muxxu.kub3dit.components.editor.toolpanels {
	import flash.events.MouseEvent;
	import com.muxxu.kub3dit.components.form.input.InputKube;
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * 
	 * @author Francois
	 * @date 1 juil. 2012;
	 */
	public class TerragenPanel extends Sprite implements IToolPanel {
		private var _bmp:Bitmap;
		private var _seedInput:InputKube;
		private var _threshold:InputKube;
		private var _widthInput:InputKube;
		private var _heightInput:InputKube;
		private var _hit:Sprite;
		private var _offset:Point;
		private var _mouseOffset:Point;
		private var _dragOffset:Point;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>TerragenPanel</code>.
		 */
		public function TerragenPanel() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function set eraseMode(value:Boolean):void {
		}

		public function get eraseMode():Boolean {
			return false;
		}

		public function set level(value:int):void {
		}

		public function get fixedLandmark():Boolean {
			return false;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */

		public function dispose():void {
		}

		public function draw(ox:int, oy:int, oz:int, kubeID:int, gridSize:int, gridOffset:Point):void {
		}

		public function set chunksManager(value:ChunksManager):void {
		}

		public function get landmark():Shape {
			return null;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_seedInput = addChild(new InputKube("42", false, true, 0, 9999999999)) as InputKube;
			_threshold = addChild(new InputKube("176", false, true, 0, 255)) as InputKube;
			_widthInput = addChild(new InputKube("64", false, true, 1, 1600)) as InputKube;
			_heightInput = addChild(new InputKube("64", false, true, 1, 1600)) as InputKube;
			_bmp = addChild(new Bitmap()) as Bitmap;
			_hit = addChild(new Sprite()) as Sprite;
			
			_offset = new Point();
			_dragOffset = new Point();
			_mouseOffset = new Point();
			
			computePositions();
			
			updateBitmap();
			_seedInput.addEventListener(Event.CHANGE, changeHandler);
			_threshold.addEventListener(Event.CHANGE, changeHandler);
			_widthInput.addEventListener(Event.CHANGE, changeHandler);
			_heightInput.addEventListener(Event.CHANGE, changeHandler);
			_hit.addEventListener(MouseEvent.MOUSE_DOWN, pressHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, releaseHandler);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_seedInput.width = 100;
			_threshold.width = 40;
			_widthInput.width = 50;
			_heightInput.width = 50;
			_threshold.x = _seedInput.width + 10;
			_widthInput.x = _threshold.x + _threshold.width + 10;
			_heightInput.x = _widthInput.x + _widthInput.width + 10;
			_bmp.y = _seedInput.height;
		}
		
		/**
		 * Called when an input's value changes
		 */
		private function changeHandler(event:Event):void {
			updateBitmap();
		}

		private function updateBitmap():void {
			var v:int = parseInt(_threshold.text);
			var threshold:int = v | (v<<8) | (v<<16);
			var bmd:BitmapData = new BitmapData(parseInt(_widthInput.text), parseInt(_heightInput.text), true, 0);
			bmd.perlinNoise(100,100, 7, parseInt(_seedInput.text), false, true, 1, true, [_offset,_offset,_offset,_offset,_offset,_offset,_offset]);
//			_bmdSource.applyFilter(_bmdSource, _drawRect, _emptyPoint, _contrast);
			bmd.threshold(bmd, bmd.rect, new Point(), "<", threshold, 0, 0xffffff);
			
			_bmp.bitmapData = bmd;
			_bmp.scaleY = _bmp.scaleX = Math.min(300/bmd.width, 300/bmd.height);
			
			_hit.graphics.beginFill(0xff0000, 0);
			_hit.graphics.drawRect(_bmp.x, _bmp.y, _bmp.width, _bmp.height);
			_hit.graphics.endFill();
		}

		private function releaseHandler(event:MouseEvent):void {
			removeEventListener(Event.ENTER_FRAME, moveHandler);
		}

		private function pressHandler(event:MouseEvent):void {
			_mouseOffset.x = mouseX;
			_mouseOffset.y = mouseY;
			_dragOffset.x = _offset.x;
			_dragOffset.y = _offset.y;
			addEventListener(Event.ENTER_FRAME, moveHandler);
		}

		private function moveHandler(event:Event):void {
			_offset.x = _dragOffset.x + (_mouseOffset.x - mouseX);
			_offset.y = _dragOffset.y + (_mouseOffset.y - mouseY);
			updateBitmap();
		}
		
	}
}