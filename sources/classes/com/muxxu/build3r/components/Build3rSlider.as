package com.muxxu.build3r.components {
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.components.text.CssTextField;
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
		private var _labelStr:String;
		private var _labeltxt:CssTextField;
		private var _step:Number;
		private var _value:Number;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Build3rSlider</code>.
		 */
		public function Build3rSlider(min:int = 0, max:int = 31, label:String = null, step:Number = 1) {
			_step = step;
			_labelStr = label;
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
			var prevValue:Number = _value;
			computePositions();
			updateButtonState(prevValue);
		}
		
		/**
		 * Gets the current's value
		 */
		public function get value():Number {
			return _value;
		}
		
		/**
		 * Sets the current level
		 */
		public function set value(v:Number):void {
			updateButtonState(v);
		}
		
		/**
		 * Updates the max value
		 */
		public function set maxValue(value:Number):void {
			_max = value;
			computePositions();
		}

		/**
		 * Gets the max value
		 */
		public function get maxValue():Number {
			return _max;
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
			if(_labelStr != null) {
				_labeltxt = addChild(new CssTextField("b-sliderLabel")) as CssTextField;
				_labeltxt.text = _labelStr;
			}
			
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
			var i:int, len:int, inc:Number, availW:int;
			availW = _labeltxt == null? _width : _width - _labeltxt.width;
			len = (_max - _min + 1)/_step;
			inc = availW / len;
			_bar.graphics.beginFill(0xff0000, .1);
			_bar.graphics.drawRect(0, 0, availW, 5);
			for(i = 0; i < len; ++i) {
				_bar.graphics.beginFill(0xffffff, .5 + i%2*.25);
				_bar.graphics.drawRect(i * inc, 0, inc, 5);
				_bar.graphics.endFill();
			}	
			
			_bar.y = Math.round((_button.height - _bar.height) * .5);
			if(_labeltxt != null) {
				_bar.x = Math.round(_labeltxt.width);
				PosUtils.vAlign(PosUtils.V_ALIGN_CENTER, 0, _labeltxt, _bar);
			}
		}
		
		/**
		 * Updates the button's state.
		 */
		private function updateButtonState(v:Number):void {
			v = MathUtils.restrict(Math.round(v/_step)*_step, _min, _max);
			
			_value = v;
			_button.text = Math.round(v).toString();
			_button.validate();
			_button.x = Math.round((v-_min)/(_max-_min) * (_width - _bar.x - _button.width)) + _bar.x;
			
			computePositions();
		}
		
		/**
		 * Update sthe current level and fires an update if it has changed
		 */
		private function updateLevel(v:Number):void {
			v = MathUtils.restrict(Math.round(v/_step)*_step, _min, _max);
			var oldL:Number = value;
			if(v != oldL) {
				_value = v;
				_button.text = Math.round(v).toString();
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		/**
		 * Called on enter frame event
		 */
		private function enterFrameHandler(event:Event):void {
			if(_pressed) {
				_button.x = mouseX - _offsetDrag;
				if(_button.x < _bar.x) _button.x = _bar.x;
				if(_button.x > Math.round(_width - _button.width)) _button.x = Math.round(_width - _button.width);
				roundPos(_button);

				var lvl:Number = Math.round((_button.x-_bar.x) / (_width - _bar.x - _button.width) * ((_max - 1))) + _min;
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
			var lvl:Number = Math.round((Math.floor((_bar.mouseX / _width) * _max) + _min)/_step)*_step;
			updateLevel( lvl );
			updateButtonState(lvl);
		}
		
	}
}
