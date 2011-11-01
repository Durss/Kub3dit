package com.muxxu.kub3dit.model {
	import com.muxxu.kub3dit.events.LightModelEvent;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.structure.mvc.model.events.ModelEvent;
	import com.nurun.core.commands.events.CommandEvent;
	import com.muxxu.kub3dit.commands.InitTexturesCmd;
	import com.nurun.structure.mvc.model.IModel;
	import flash.events.EventDispatcher;
	
	/**
	 * 
	 * @author Francois
	 * @date 30 oct. 2011;
	 */
	public class Model extends EventDispatcher implements IModel {
		
		private var _initTexturesCmd:InitTexturesCmd;
		private var _currentKubeId:String;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Model</code>.
		 */
		public function Model() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the currently selected kube.
		 */
		public function get currentKubeId():String { return _currentKubeId; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Starts the application
		 */
		public function start():void {
			_initTexturesCmd = new InitTexturesCmd();
			_initTexturesCmd.addEventListener(CommandEvent.COMPLETE, initCompleteHandler);
			_initTexturesCmd.execute();
		}
		
		/**
		 * Cahnges the currently selected kube's ID
		 */
		public function changeKubeId(id:String):void {
			_currentKubeId = id;
			ViewLocator.getInstance().dispatchToViews(new LightModelEvent(LightModelEvent.KUBE_SELECTION_CHANGE, _currentKubeId));
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_currentKubeId = "3";
		}
		
		/**
		 * Called when textures are ready
		 */
		private function initCompleteHandler(event:CommandEvent):void {
			update();
		}
		
		/**
		 * Fire an update to the views
		 */
		private function update():void {
			dispatchEvent(new ModelEvent(ModelEvent.UPDATE, this));
		}
		
	}
}