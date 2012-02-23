package com.muxxu.build3r.views {
	import com.muxxu.build3r.controler.FrontControlerBuild3r;
	import com.muxxu.build3r.vo.Metrics;
	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.model.Model;
	import com.nurun.components.vo.Margin;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;

	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * 
	 * @author Francois
	 * @date 23 févr. 2012;
	 */
	public class CloseView extends AbstractView {
		private var _closeBt:ButtonKube;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>CloseView</code>.
		 */
		public function CloseView() {
			addEventListener(Event.ADDED_TO_STAGE, initialize);
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
		private function initialize(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			_closeBt = addChild(new ButtonKube("X",false,null,true)) as ButtonKube;
			_closeBt.style = "b-closeBt";
			_closeBt.contentMargin = new Margin(1, -2, 0, 0);
			_closeBt.width = 15;
			_closeBt.height = 17;
			_closeBt.x = Math.round(Metrics.STAGE_WIDTH - _closeBt.width);
			
			addEventListener(MouseEvent.CLICK, clickHandler);
		}

		private function clickHandler(event:MouseEvent):void {
			if(event.target == _closeBt) {
				FrontControlerBuild3r.getInstance().closeWindow();
			}
		}
		
	}
}