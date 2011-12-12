package com.muxxu.kub3dit.views {
	import flash.filters.DropShadowFilter;
	import com.muxxu.kub3dit.events.LightModelEvent;
	import com.muxxu.kub3dit.graphics.ProgressbarGraphic;
	import com.muxxu.kub3dit.model.Model;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.pos.PosUtils;

	import flash.events.Event;

	/**
	 * 
	 * @author Francois
	 * @date 11 déc. 2011;
	 */
	public class ProgressView extends AbstractView {
		private var _bar:ProgressbarGraphic;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ProgressView</code>.
		 */
		public function ProgressView() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:Model = event.model as Model;
			model.addEventListener(LightModelEvent.PROGRESS, progressHandler);
			ViewLocator.getInstance().removeView(this);
		}



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
			visible = false;
			_bar = addChild(new ProgressbarGraphic()) as ProgressbarGraphic;
			filters = [new DropShadowFilter(0,0,0,1,10,0,.4,2)];
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
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
			PosUtils.centerInStage(_bar);
		}
		
		/**
		 * Called during a progression.
		 */
		private function progressHandler(event:LightModelEvent):void {
			var frame:Number = Math.round(event.data * (_bar.totalFrames-1)) + 1;
			_bar.gotoAndStop(frame);
			visible = event.data < 1;
		}
		
	}
}