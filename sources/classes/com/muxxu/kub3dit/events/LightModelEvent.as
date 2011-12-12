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
		public static const KUBE_ADD_COMPLETE:String = "KUBE_ADD_COMPLETE";
		public static const KUBE_ADD_ERROR:String = "KUBE_ADD_ERROR";
		
		public static const LOCK:String = "LOCK";
		public static const UNLOCK:String = "UNLOCK";
		
		public static const PROGRESS:String = "PROGRESS";
		public static const MAP_UPLOAD_COMPLETE:String = "MAP_UPLOAD_COMPLETE";
		public static const SAVE_MAP_GENERATION_COMPLETE:String = "SAVE_MAP_GENERATION_COMPLETE";
		
		private var _data:*;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>LightModelEvent</code>.
		 */
		public function LightModelEvent(type:String, data:* = null, bubbles:Boolean = false, cancelable:Boolean = false) {
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