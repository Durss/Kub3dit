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
	public class LevelSlider extends Sprite {
		
		private var _width:Number;
		private var _button:ButtonKube;
		private var _bar:Sprite;
		private var _pressed:Boolean;
		private var _offsetDrag:int;
		private var _levels:Number;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>LevelsSlider</code>.
		 */
		public function LevelSlider() {
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
		 * Gets the current level
		 */
		public function get level():Number {
			return parseInt(_button.text)-1;
		}
		
		/**
		 * Sets the current level
		 */
		public function set level(value:Number):void {
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
			
			_levels = 31;
			_button.validate();
			
			_width = 100;
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			_button.addEventListener(NurunButtonEvent.PRESS, pressHandler);
			_button.addEventListener(NurunButtonEvent.RELEASE, releaseHandler);
			_button.addEventListener(NurunButtonEvent.RELEASE_OUTSIDE, releaseHandler);
			_bar.addEventListener(MouseEvent.CLICK, clickButtonHandler);
			
			level = 0;
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_bar.graphics.clear();
			var i:int, len:int, inc:Number;
			len = _levels;
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
		private function updateButtonState(value:Number):void {
			value = MathUtils.restrict(value, 0, _levels-1);
			_button.text = (value+1).toString();
			_button.x = Math.round(value/30 * (_width - _button.width));
			
			computePositions();
		}
		
		/**
		 * Update sthe current level and fires an update if it has changed
		 */
		private function updateLevel(value:int):void {
			value = MathUtils.restrict(value, 0, _levels-1);
			var oldL:Number = level;
			if(value != oldL) {
				_button.text = (value+1).toString();
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

				var lvl:Number = Math.round(_button.x / (_width - _button.width) * ((_levels - 1)));
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
			var lvl:Number = Math.floor((_bar.mouseX / _width) * _levels);
			updateLevel( lvl );
			updateButtonState(level);
		}
		
	}
}
