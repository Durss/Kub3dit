package com.muxxu.kub3dit.engin3d.events {
	import flash.events.Event;
	
	/**
	 * Event fired by VoxelsManager
	 * 
	 * @author Francois
	 * @date 25 sept. 2011;
	 */
	public class ManagerEvent extends Event {
		
		public static const PROGRESS:String = "renderProgress";
		public static const COMPLETE:String = "renderComplete";
		private var _progressionPercent:Number;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MapEvent</code>.
		 */
		public function ManagerEvent(type:String, progressionPercent:Number = 0, bubbles:Boolean = false, cancelable:Boolean = false) {
			_progressionPercent = progressionPercent;
			super(type, bubbles, cancelable);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get progressionPercent():Number {
			return _progressionPercent;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes a clone of the event object.
		 */
		override public function clone():Event {
			return new ManagerEvent(type, progressionPercent, bubbles, cancelable);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}