package com.muxxu.kub3dit.views {
	import gs.TweenLite;

	import com.muxxu.kub3dit.graphics.LogoGraphic;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.Sprite;
	import flash.events.Event;
	
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 * 
	 * @author Francois
	 * @date 2 nov. 2011;
	 */
	public class SplashScreenView extends Sprite {
		private var _logo:LogoGraphic;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>SplashScreenView</code>.
		 */
		public function SplashScreenView() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_logo = addChild(new LogoGraphic()) as LogoGraphic;
			_logo.addFrameScript(_logo.totalFrames - 1, onAnimComplete);
			
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * Called when the display object is removed from display list.
		 */
		private function removedFromStageHandler(event:Event):void {
			stage.removeEventListener(Event.RESIZE, computePositions);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			computePositions();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			PosUtils.centerInStage(_logo);
		}
		
		/**
		 * Called when animation completes
		 */
		private function onAnimComplete():void {
			_logo.stop();
			TweenLite.to(_logo, .5, {autoAlpha:0, onComplete:onComplete, delay:.5});
		}
		
		/**
		 * Called when logo is hidden
		 */
		private function onComplete():void {
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
	}
}