package com.muxxu.kub3dit.components.form.input {
	import com.muxxu.kub3dit.graphics.Build3rInputSkin;
	import com.muxxu.kub3dit.graphics.InputSkinBig;
	import com.nurun.utils.text.CssManager;
	import flash.events.MouseEvent;
	import com.nurun.utils.math.MathUtils;
	import flash.events.Event;
	import com.muxxu.kub3dit.graphics.InputSkin;
	import com.nurun.components.form.Input;
	import com.nurun.components.vo.Margin;
	
	/**
	 * 
	 * @author Francois
	 */
	public class InputKube extends Input {
		
		private var _isNumeric:Boolean;
		private var _minNumValue:int;
		private var _maxNumValue:int;
		
		
		

		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>KBInput</code>.
		 */
		public function InputKube(defaultLabel:String = "", big:Boolean = false, isNumeric:Boolean = false, minNumValue:int = 0, maxNumValue:int = 100, build3r:Boolean=false) {
			_maxNumValue = maxNumValue;
			_minNumValue = minNumValue;
			_isNumeric = isNumeric;
			var locMargins:Margin = new Margin(4, 2, 4, 0);
			super(big? "inputBig" : build3r? "b-input" : "input", big? new InputSkinBig() : build3r? new Build3rInputSkin() : new InputSkin(), defaultLabel, big? "inputBigDefault" : "inputDefault", locMargins);
			
			if(isNumeric) {
				textfield.restrict = "[0-9]";
				textfield.maxChars = maxNumValue.toString().length;
				width = textfield.maxChars * (parseInt(CssManager.getInstance().styleSheet.getStyle("."+style)["fontSize"])+1) + locMargins.width;
				addEventListener(Event.CHANGE, changeValueHandler);
				addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			}else{
				width = 10 * (parseInt(CssManager.getInstance().styleSheet.getStyle("."+style)["fontSize"])+1) + locMargins.width;
			}
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Sets the enable state of the component.
		 */
		public function set enabled(value:Boolean):void {
			mouseEnabled = value;
			mouseChildren = value;
			textfield.tabEnabled = value;
			alpha = value? 1 : .5;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Called when the input's value changes
		 */
		private function changeValueHandler(event:Event):void {
			var v:int = parseInt(text);
			v = MathUtils.restrict(v, _minNumValue, _maxNumValue);
			if(v.toString() != text) {
				event.stopPropagation();
				text = v.toString();
			}
		}
		
		/**
		 * Called when the user uses the mouse's wheel over the input
		 */
		private function mouseWheelHandler(event:MouseEvent):void {
			var v:int = parseInt(text) + event.delta/Math.abs(event.delta);
			v = MathUtils.restrict(v, _minNumValue, _maxNumValue);
			text = v.toString();
			dispatchEvent(new Event(Event.CHANGE));
		}
		
	}
}