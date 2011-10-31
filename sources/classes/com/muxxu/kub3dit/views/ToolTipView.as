package com.muxxu.kub3dit.views {
	import flash.display.InteractiveObject;
	import com.muxxu.kub3dit.vo.ToolTipMessage;
	import com.muxxu.kub3dit.components.tooltip.content.TTTextContent;
	import com.muxxu.kub3dit.components.tooltip.ToolTip;
	import com.muxxu.kub3dit.events.ToolTipEvent;
	import com.muxxu.kub3dit.model.Model;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.structure.mvc.views.ViewLocator;

	import flash.events.Event;

	/**
	 * 
	 * @author Francois
	 * @date 31 oct. 2011;
	 */
	public class ToolTipView extends AbstractView {
		private var _toolTip:ToolTip;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ToolTipView</code>.
		 */
		public function ToolTipView() {
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
			model;
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
			_toolTip = addChild(new ToolTip()) as ToolTip;
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			stage.addEventListener(ToolTipEvent.OPEN, openHandler);
			computePositions();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			
		}

		private function openHandler(event:ToolTipEvent):void {
			_toolTip.open(new ToolTipMessage(new TTTextContent(true, event.data as String), event.target as InteractiveObject));
			_toolTip.x = mouseX;
			_toolTip.y = mouseY;
		}
		
	}
}