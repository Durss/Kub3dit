package com.muxxu.kub3dit.views {
	import flash.events.MouseEvent;
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
			stage.removeEventListener(MouseEvent.CLICK, clickHandler);
			stage.removeEventListener(Event.RESIZE, computePositions);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			stage.addEventListener(MouseEvent.CLICK, clickHandler);
			computePositions();
		}
		
		/**
		 * Called when th view is clicked to skip it.
		 */
		private function clickHandler(event:MouseEvent):void {
			onAnimComplete(0);
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
		private function onAnimComplete(delay:Number = .5):void {
			_logo.stop();
			TweenLite.to(_logo, delay==0? .2 : .5, {autoAlpha:0, onComplete:onComplete, delay:delay});
		}
		
		/**
		 * Called when logo is hidden
		 */
		private function onComplete():void {
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
	}
}