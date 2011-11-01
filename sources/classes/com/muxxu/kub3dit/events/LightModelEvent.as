package com.muxxu.kub3dit.events {
	import flash.events.Event;
	
	/**
	 * Event fired by Model
	 * 
	 * @author Francois
	 * @date 30 oct. 2011;
	 */
	public class LightModelEvent extends Event {
		
		public static const KUBE_SELECTION_CHANGE:String = "KUBE_SELECTION_CHANGE";
		private var _data:*;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>LightModelEvent</code>.
		 */
		public function LightModelEvent(type:String, data:*, bubbles:Boolean = false, cancelable:Boolean = false) {
			_data = data;
			super(type, bubbles, cancelable);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the event's data
		 */
		public function get data():* { return _data; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes a clone of the event object.
		 */
		override public function clone():Event {
			return new LightModelEvent(type, data, bubbles, cancelable);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}