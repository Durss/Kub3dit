package com.muxxu.kub3dit.components.form.input {
	import com.muxxu.kub3dit.graphics.InputSkin;
	import com.nurun.components.form.Input;
	import com.nurun.components.vo.Margin;
	
	/**
	 * 
	 * @author Francois
	 */
	public class InputKube extends Input {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>KBInput</code>.
		 */
		public function InputKube(defaultLabel:String = "", big:Boolean = false) {
			super(big? "inputBig" : "input", new InputSkin(), defaultLabel, big? "inputBigDefault" : "inputDefault", new Margin(4, 2, 4, 2));
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
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
		
	}
}