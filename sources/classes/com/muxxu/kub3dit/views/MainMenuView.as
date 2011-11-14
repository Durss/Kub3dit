package com.muxxu.kub3dit.views {
	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.controler.FrontControler;
	import com.muxxu.kub3dit.model.Model;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.input.keyboard.KeyboardSequenceDetector;
	import com.nurun.utils.input.keyboard.events.KeyboardSequenceEvent;

	import flash.events.MouseEvent;

	/**
	 * 
	 * @author Francois
	 * @date 10 nov. 2011;
	 */
	public class MainMenuView extends AbstractView {
		private var _saveBt:ButtonKube;
		private var _ready:Boolean;
		private var _ks:KeyboardSequenceDetector;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MainMenuView</code>.
		 */
		public function MainMenuView() {
			
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:Model = event.model as Model;
			if(!_ready && model.map != null) {
				_ready = true;
				initialize();
			}
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
//			visible = false;
			
			_saveBt = addChild(new ButtonKube("Save")) as ButtonKube;
			_saveBt.addEventListener(MouseEvent.CLICK, clickHandler);
			
			_ks = new KeyboardSequenceDetector(stage);
			_ks.addSequence("show", "showmenu");
			_ks.addEventListener(KeyboardSequenceEvent.SEQUENCE, keySequenceHandler);
			
			computePositions();
		}

		private function keySequenceHandler(event:KeyboardSequenceEvent):void {
			visible = !visible;
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			
		}

		private function clickHandler(event:MouseEvent):void {
			FrontControler.getInstance().saveMap();
		}
		
	}
}