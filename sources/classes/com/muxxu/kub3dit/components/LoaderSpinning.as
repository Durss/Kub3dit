package com.muxxu.kub3dit.components {
	import com.muxxu.kube3dit.graphics.SpinGraphic;

	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	/**
	 * 
	 * @author Francois
	 */
	public class LoaderSpinning extends SpinGraphic {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>LoaderSpinning</code>.
		 */
		public function LoaderSpinning() {
			filters = [new DropShadowFilter(0,0,0,.4,5,5,2,2)];
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */

		public function dispose():void {
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}

		public function open():void {
			visible = true;
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}

		public function close():void {
			visible = false;
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}



		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */

		private function enterFrameHandler(event:Event):void {
			rotation -= 15;
		}
		
	}
}