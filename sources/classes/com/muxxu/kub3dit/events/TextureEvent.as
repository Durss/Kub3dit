package com.muxxu.kub3dit.events {
	import flash.events.Event;
	
	/**
	 * Event fired by Texture singleton
	 * 
	 * @author Francois
	 * @date 31 déc. 2011;
	 */
	public class TextureEvent extends Event {
		
		public static const CHANGE_SPRITESHEET:String = "CHANGE_SPRITESHEET";
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>TextureEvent</code>.
		 */
		public function TextureEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
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
			return new TextureEvent(type, bubbles, cancelable);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}