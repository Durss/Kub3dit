package com.muxxu.kub3dit.components.editor.toolpanels.terragen {
	import com.muxxu.kub3dit.components.form.input.InputKube;
	import com.muxxu.kub3dit.events.ToolTipEvent;
	import com.muxxu.kub3dit.graphics.HeightIcon;
	import com.muxxu.kub3dit.graphics.SeedIcon;
	import com.muxxu.kub3dit.graphics.ThresholdIcon;
	import com.muxxu.kub3dit.graphics.WidthIcon;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Dictionary;
	
	/**
	 * 
	 * @author Francois
	 * @date 1 juil. 2012;
	 */
	public class PerlinNoiseMapStep extends Sprite {
		
		private var _bmp:Bitmap;
		private var _seedInput:InputKube;
		private var _threshold:InputKube;
		private var _widthInput:InputKube;
		private var _heightInput:InputKube;
		private var _hit:Sprite;
		private var _offset:Point;
		private var _mouseOffset:Point;
		private var _dragOffset:Point;
		private var _seedIcon:SeedIcon;
		private var _threshIcon:ThresholdIcon;
		private var _widthIcon:WidthIcon;
		private var _heightIcon:HeightIcon;
		private var _targetToText:Dictionary;
		private var _contrast:ColorMatrixFilter;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>PerlinNoiseMapStep</code>.
		 */
		public function PerlinNoiseMapStep(contrast:ColorMatrixFilter) {
			_contrast = contrast;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		public function get mapWidth():int { return parseInt(_widthInput.text); }
		public function get mapHeight():int { return parseInt(_heightInput.text); }
		public function get threshold():int { return parseInt(_threshold.text); }
		public function get seed():int { return parseInt(_seedInput.text); }
		public function get scrollOffset():Point { return _offset; }



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_seedIcon = addChild(new SeedIcon()) as SeedIcon;
			_threshIcon = addChild(new ThresholdIcon()) as ThresholdIcon;
			_widthIcon = addChild(new WidthIcon()) as WidthIcon;
			_heightIcon = addChild(new HeightIcon()) as HeightIcon;
			
			_seedInput = addChild(new InputKube("0", false, true, 0, 9999999999)) as InputKube;
			_threshold = addChild(new InputKube("0", false, true, 0, 255)) as InputKube;
			_widthInput = addChild(new InputKube("1", false, true, 1, 1600)) as InputKube;
			_heightInput = addChild(new InputKube("1", false, true, 1, 1600)) as InputKube;
			_bmp = addChild(new Bitmap()) as Bitmap;
			_hit = addChild(new Sprite()) as Sprite;
			
			_offset = new Point();
			_dragOffset = new Point();
			_mouseOffset = new Point();
			
			_seedInput.text = "42";
			_threshold.text = "176";
			_widthInput.text = "64";
			_heightInput.text = "64";
			
			_targetToText = new Dictionary();
			_targetToText[_seedIcon] = _targetToText[_seedInput] = "Forme du terrain";
			_targetToText[_threshIcon] = _targetToText[_threshold] = "Niveau de l'océan";
			_targetToText[_widthIcon] = _targetToText[_widthInput] = "Largeur du terrain";
			_targetToText[_heightIcon] = _targetToText[_heightInput] = "Hauteur du terrain";
			
			computePositions();
			
			updateBitmap();
			_seedInput.addEventListener(Event.CHANGE, changeHandler);
			_threshold.addEventListener(Event.CHANGE, changeHandler);
			_widthInput.addEventListener(Event.CHANGE, changeHandler);
			_heightInput.addEventListener(Event.CHANGE, changeHandler);
			_hit.addEventListener(MouseEvent.MOUSE_DOWN, pressHandler);
			_hit.addEventListener(MouseEvent.ROLL_OUT, outHitHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
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
			_seedInput.width = 50;
			_threshold.width = 40;
			_widthInput.width = 50;
			_heightInput.width = 50;
			_seedInput.x = _seedIcon.width + 3;
			
			_threshIcon.x = _seedInput.x + _seedInput.width + 10;
			_threshold.x = _threshIcon.x + _threshIcon.width + 3;
			
			_widthIcon.x = _threshold.x + _threshold.width + 10;
			_widthInput.x = _widthIcon.x + _widthIcon.width + 3;
			
			_heightIcon.x = _widthInput.x + _widthInput.width + 10;
			_heightInput.x = _heightIcon.x + _heightIcon.width + 3;
			
			PosUtils.vAlign(PosUtils.V_ALIGN_CENTER, 0, _seedIcon, _seedInput, _threshIcon, _threshold, _widthIcon, _widthInput, _heightIcon, _heightInput);
			
			_bmp.y = _seedInput.height + 10;
		}
		
		/**
		 * Called when an input's value changes
		 */
		private function changeHandler(event:Event):void {
			updateBitmap();
		}
		
		/**
		 * Updates the bitmap's rendering
		 */
		private function updateBitmap():void {
			if(_bmp.bitmapData != null) _bmp.bitmapData.dispose();
			
			var v:int = parseInt(_threshold.text);
			var threshold:int = v | (v<<8) | (v<<16);
			var w:int = parseInt(_widthInput.text);
			var h:int = parseInt(_heightInput.text);
			var ratio:Number = Math.max(w,h) > 200? 200/Math.max(w,h) : 1;
			var bmd:BitmapData = new BitmapData(Math.max(1, w * ratio), Math.max(1, h * ratio), true, 0);
			var offset:Point = _offset.clone();
			offset.x *= ratio;
			offset.y *= ratio;
			bmd.perlinNoise(100 * ratio,100 * ratio, 7, parseInt(_seedInput.text), false, true, 1, true, [offset,offset,offset,offset,offset,offset,offset]);
			bmd.applyFilter(bmd, bmd.rect, new Point(), _contrast);
			bmd.threshold(bmd, bmd.rect, new Point(), "<", threshold, 0, 0xffffff);
			
			_bmp.bitmapData = bmd;
			_bmp.scaleY = _bmp.scaleX = Math.min(300/bmd.width, 300/bmd.height);
			
			_hit.graphics.clear();
			_hit.graphics.lineStyle(0, 0x265367, 1);
			_hit.graphics.beginFill(0xff0000, 0);
			_hit.graphics.drawRect(_bmp.x, _bmp.y, _bmp.width, _bmp.height);
			_hit.graphics.endFill();
			
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		
		
		
		//__________________________________________________________ MOUSE EVENTS

		/**
		 * Called when a component is released
		 */
		private function releaseHandler(event:MouseEvent):void {
			removeEventListener(Event.ENTER_FRAME, moveHandler);
		}
		
		/**
		 * Called when the perlin noise is pressed
		 */
		private function pressHandler(event:MouseEvent):void {
			_mouseOffset.x = mouseX;
			_mouseOffset.y = mouseY;
			_dragOffset.x = _offset.x;
			_dragOffset.y = _offset.y;
			addEventListener(Event.ENTER_FRAME, moveHandler);
		}
		
		/**
		 * Called to move the perlin noise
		 */
		private function moveHandler(event:Event):void {
			_offset.x = _dragOffset.x + (_mouseOffset.x - mouseX);
			_offset.y = _dragOffset.y + (_mouseOffset.y - mouseY);
			updateBitmap();
		}
		
		/**
		 * Called when a component is rolled over.
		 */
		private function overHandler(event:MouseEvent):void {
			var target:Sprite = event.target as Sprite;
			if(target == _hit) {
				Mouse.cursor = MouseCursor.HAND;
			}
			if (_targetToText[target] != null) {
				target.dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, _targetToText[target]));
			}
		}
		
		/**
		 * Called when hit zne is rolled out
		 */
		private function outHitHandler(event:MouseEvent):void {
			Mouse.cursor = MouseCursor.AUTO;
		}
		
	}
}