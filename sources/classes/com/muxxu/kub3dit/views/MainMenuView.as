package com.muxxu.kub3dit.views {
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.controler.FrontControler;
	import com.muxxu.kub3dit.graphics.Build3rIcon;
	import com.muxxu.kub3dit.graphics.SaveIcon;
	import com.muxxu.kub3dit.graphics.StatsIcon;
	import com.muxxu.kub3dit.model.Model;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.pos.PosUtils;

	import flash.events.MouseEvent;

	/**
	 * 
	 * @author Francois
	 * @date 10 nov. 2011;
	 */
	public class MainMenuView extends AbstractView {
		private var _saveBt:ButtonKube;
		private var _ready:Boolean;
		private var _statsBt:ButtonKube;
		private var _build3rBt:ButtonKube;
		
		
		
		
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
			_saveBt = addChild(new ButtonKube(Label.getLabel("mainMenu-save"), false, new SaveIcon())) as ButtonKube;
			_statsBt = addChild(new ButtonKube(Label.getLabel("mainMenu-stats"), false, new StatsIcon())) as ButtonKube;
			_build3rBt = addChild(new ButtonKube(Label.getLabel("mainMenu-build3r"), false, new Build3rIcon())) as ButtonKube;

			addEventListener(MouseEvent.CLICK, clickHandler);
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			PosUtils.hPlaceNext(5, _saveBt, _statsBt, _build3rBt);
		}

		private function clickHandler(event:MouseEvent):void {
			if(event.target == _saveBt) {
				FrontControler.getInstance().saveMap();
			}else if(event.target == _statsBt) {
				(ViewLocator.getInstance().locateViewByType(StatsView) as StatsView).open();
			}else if(event.target == _build3rBt) {
				(ViewLocator.getInstance().locateViewByType(Build3rView) as Build3rView).open();
			}
		}
		
	}
}