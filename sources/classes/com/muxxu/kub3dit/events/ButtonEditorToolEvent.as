package com.muxxu.kub3dit.events {
	import flash.events.Event;
	
	/**
	 * Event fired by ButtonEditorTool
	 * 
	 * @author Francois
	 * @date 31 oct. 2011;
	 */
	public class ButtonEditorToolEvent extends Event {
		
		public static const CLICK:String = "clickBET";
		
		private var _openConfig:Boolean;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ButtonEditorToolEvent</code>.
		 */
		public function ButtonEditorToolEvent(type:String, openConfig:Boolean = false, bubbles:Boolean = false, cancelable:Boolean = false) {
			_openConfig = openConfig;
			super(type, bubbles, cancelable);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets if it's the config button or the main button that has been clicked.
		 */
		public function get openConfig():Boolean { return _openConfig; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes a clone of the event object.
		 */
		override public function clone():Event {
			return new ButtonEditorToolEvent(type, openConfig, bubbles, cancelable);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}