package com.muxxu.kub3dit.events {
	import flash.events.Event;
	
	/**
	 * Event fired by anybody that has to display something on the tooltip
	 * 
	 * @author Francois
	 * @date 31 oct. 2011;
	 */
	public class ToolTipEvent extends Event {
		
		public static const OPEN:String = "OPEN";
		
		private var _data:*;
		
		
		

		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ToolTipEvent</code>.
		 */
		public function ToolTipEvent(type:String, data:*, bubbles:Boolean = false, cancelable:Boolean = false) {
			_data = data;
			super(type, bubbles, cancelable);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the data to display
		 */
		public function get data():* { return _data; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes a clone of the event object.
		 */
		override public function clone():Event {
			return new ToolTipEvent(type, bubbles, cancelable);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}