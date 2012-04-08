package com.muxxu.kub3dit.views {
	import gs.TweenLite;

	import com.muxxu.kub3dit.components.window.PromptWindow;
	import com.muxxu.kub3dit.model.Model;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * 
	 * @author Francois
	 * @date 8 avr. 2012;
	 */
	public class AbstractWindowView extends AbstractView {
		
		protected var _container:Sprite;
		protected var _window:PromptWindow;
		protected var _disableLayer:Sprite;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>AbstractWindowView</code>.
		 */
		public function AbstractWindowView(label:String) {
			initialize();
			_window.label = label;
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
		/**
		 * Opens the view
		 */
		public function open(...args):void {
			TweenLite.to(this, .25, {autoAlpha:1});
			computePositions();
		}
		
		/**
		 * Closes the view
		 */
		public function close():void {
			TweenLite.to(this, .25, {autoAlpha:0});
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		protected function initialize():void {
			alpha = 0;
			visible = false;
			_container = new Sprite();
			_disableLayer = addChild(new Sprite()) as Sprite;
			_window = addChild(new PromptWindow("", _container)) as PromptWindow;
			
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * Called when the stage is available.
		 */
		protected function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			computePositions();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		protected function computePositions(event:Event = null):void {
			_window.updateSizes();
			PosUtils.centerInStage(_window);
			_disableLayer.graphics.clear();
			_disableLayer.graphics.beginFill(0xffffff, .5);
			_disableLayer.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			_disableLayer.graphics.endFill();
		}
		
		/**
		 * Called when disable layer is clicked.
		 * Closes the view.
		 */
		protected function clickHandler(event:MouseEvent):void {
			if (event.target == _disableLayer) {
				close();
			}
		}
		
	}
}