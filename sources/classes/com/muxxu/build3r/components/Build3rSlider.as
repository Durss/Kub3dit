package com.muxxu.build3r.components {
	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.graphics.LevelSelectorIcon;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.button.events.NurunButtonEvent;
	import com.nurun.components.vo.Margin;
	import com.nurun.utils.math.MathUtils;
	import com.nurun.utils.pos.roundPos;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * 
	 * @author Francois
	 * @date 20 feb. 2012;
	 */
	public class Build3rSlider extends Sprite {
		
		private var _width:Number;
		private var _button:ButtonKube;
		private var _bar:Sprite;
		private var _pressed:Boolean;
		private var _offsetDrag:int;
		private var _max:Number;
		private var _min:int;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Build3rSlider</code>.
		 */
		public function Build3rSlider(min:int = 0, max:int = 31) {
			_min = min;
			_max = max;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Sets the width of the component without simply scaling it.
		 */
		override public function set width(value:Number):void {
			_width = value;
			computePositions();
		}
		
		/**
		 * Gets the current's value
		 */
		public function get value():Number {
			return parseInt(_button.text);
		}
		
		/**
		 * Sets the current level
		 */
		public function set value(value:Number):void {
			updateButtonState(value);
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
		private function initialize():void {
			_bar = addChild(new Sprite()) as Sprite;
			_button = addChild(new ButtonKube("0", false, new LevelSelectorIcon(), true)) as ButtonKube;
			
			_button.contentMargin = new Margin(0, 1, 0, 1);
			_button.iconAlign = IconAlign.CENTER;
			_button.textAlign = TextAlign.CENTER;
			_button.style = "levelSliderButton";
			_button.validate();
			
			_width = 100;
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			_button.addEventListener(NurunButtonEvent.PRESS, pressHandler);
			_button.addEventListener(NurunButtonEvent.RELEASE, releaseHandler);
			_button.addEventListener(NurunButtonEvent.RELEASE_OUTSIDE, releaseHandler);
			_bar.addEventListener(MouseEvent.CLICK, clickButtonHandler);
			
			value = _min;
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_bar.graphics.clear();
			var i:int, len:int, inc:Number;
			len = _max - _min + 1;
			inc = _width / len;
			_bar.graphics.beginFill(0xff0000, .1);
			_bar.graphics.drawRect(0, 0, _width, 5);
			for(i = 0; i < len; ++i) {
				_bar.graphics.beginFill(0xffffff, .5 + i%2*.25);
				_bar.graphics.drawRect(i * inc, 0, inc, 5);
				_bar.graphics.endFill();
			}	
			
			_bar.y = Math.round((_button.height - _bar.height) * .5);
		}
		
		/**
		 * Updates the button's state.
		 */
		private function updateButtonState(v:Number):void {
			v = MathUtils.restrict(v, _min, _max);
			_button.text = v.toString();
			_button.validate();
			_button.x = Math.round((v-_min)/(_max-_min) * (_width - _button.width));
			
			computePositions();
		}
		
		/**
		 * Update sthe current level and fires an update if it has changed
		 */
		private function updateLevel(v:int):void {
			v = MathUtils.restrict(v, _min, _max);
			var oldL:Number = value;
			if(v != oldL) {
				_button.text = v.toString();
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		/**
		 * Called on enter frame event
		 */
		private function enterFrameHandler(event:Event):void {
			if(_pressed) {
				_button.x = mouseX - _offsetDrag;
				if(_button.x < 0) _button.x = 0;
				if(_button.x > Math.round(_width - _button.width)) _button.x = Math.round(_width - _button.width);
				roundPos(_button);

				var lvl:Number = Math.round(_button.x / (_width - _button.width) * ((_max - 1))) + _min;
				updateLevel( lvl );
			}
		}
		
		
		
		
		//__________________________________________________________ EVENTS HANDLERS
		
		/**
		 * Called when te button is pressed
		 */
		private function pressHandler(event:NurunButtonEvent):void {
			_pressed = true;
			_offsetDrag = _button.mouseX;
		}
		
		/**
		 * Called when te button is released
		 */

		private function releaseHandler(event:NurunButtonEvent):void {
			_pressed = false;
		}
		
		/**
		 * Called when move cam button is clicked
		 */
		private function clickButtonHandler(event:MouseEvent):void {
			var lvl:Number = Math.floor((_bar.mouseX / _width) * _max) + _min;
			updateLevel( lvl );
			updateButtonState( lvl );
		}
		
	}
}
