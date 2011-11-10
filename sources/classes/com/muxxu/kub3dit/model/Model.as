package com.muxxu.kub3dit.model {
	import com.muxxu.kub3dit.commands.BrowseForFileCmd;
	import com.muxxu.kub3dit.commands.InitTexturesCmd;
	import com.muxxu.kub3dit.engin3d.map.Map;
	import com.muxxu.kub3dit.events.LightModelEvent;
	import com.muxxu.kub3dit.exceptions.Kub3ditException;
	import com.muxxu.kub3dit.exceptions.Kub3ditExceptionSeverity;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.structure.mvc.model.IModel;
	import com.nurun.structure.mvc.model.events.ModelEvent;
	import com.nurun.structure.mvc.views.ViewLocator;

	import flash.events.EventDispatcher;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * @author Francois
	 * @date 30 oct. 2011;
	 */
	public class Model extends EventDispatcher implements IModel {
		
		private var _initTexturesCmd:InitTexturesCmd;
		private var _currentKubeId:String;
		private var _map:Map;
		
		
		
		
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
		
		/**
		 * Gets the map's reference.
		 */
		public function get map():Map { return _map; }



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
		
		/**
		 * Saves the currentMap
		 */
		public function saveMap():void {
			var ba:ByteArray = new ByteArray();
			_map.data.readBytes(ba);
			ba.compress();
			ba.position = 0;
			
			var fr:FileReference = new FileReference();
			fr.save(ba, "kub3dit.map");
		}
		
		/**
		 * Loads a map
		 */
		public function loadMap():void {
			var cmd:BrowseForFileCmd = new BrowseForFileCmd();
			cmd.addEventListener(CommandEvent.COMPLETE, loadMapCompleteHandler);
			cmd.addEventListener(CommandEvent.ERROR, loadMapErrorHandler);
			cmd.execute();
		}
		
		/**
		 * Creates a map
		 */
		public function createMap(sizeX:int, sizeY:int, sizeZ:int):void {
			_map = new Map(sizeX * 32, sizeY * 32, sizeZ);
			update();
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
		
		
		
		
		//__________________________________________________________ MAP LOADING
		
		/**
		 * Called when a map's loading completes
		 */
		private function loadMapCompleteHandler(event:CommandEvent):void {
			var data:ByteArray = event.data as ByteArray;
			data.uncompress();
			data.position = 0;
			_map.load(data);
			
//			_map = new Map(mapSizeX, mapSizeY, mapSizeZ);
		}
		
		/**
		 * Called if map loading fails
		 */
		private function loadMapErrorHandler(event:CommandEvent):void {
			throw new Kub3ditException(event.data as String, Kub3ditExceptionSeverity.MINOR);
		}
		
	}
}