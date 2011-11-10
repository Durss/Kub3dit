package com.muxxu.kub3dit.engin3d.events {
	import flash.events.Event;
	
	/**
	 * Event fired by Map
	 * 
	 * @author Francois
	 * @date 25 sept. 2011;
	 */
	public class MapEvent extends Event {
		
		public static const LOAD:String = "mapLoad";
		public static const PROGRESS:String = "mapProgress";
		public static const COMPLETE:String = "mapComplete";
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MapEvent</code>.
		 */
		public function MapEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes a clone of the event object.
		 */
		override public function clone():Event {
			return new MapEvent(type, bubbles, cancelable);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}