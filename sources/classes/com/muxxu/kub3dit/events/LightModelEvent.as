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
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>LightModelEvent</code>.
		 */
		public function LightModelEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
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
			return new LightModelEvent(type, bubbles, cancelable);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}