package com.muxxu.kub3dit.controler {
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;
	import com.muxxu.kub3dit.model.Model;

	import flash.errors.IllegalOperationError;
	import flash.utils.ByteArray;
	
	
	/**
	 * Singleton FrontControler
	 * 
	 * @author Francois
	 * @date 30 oct. 2011;
	 */
	public class FrontControler {
		
		private static var _instance:FrontControler;
		private var _model:Model;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>FrontControler</code>.
		 */
		public function FrontControler(enforcer:SingletonEnforcer) {
			if(enforcer == null) {
				throw new IllegalOperationError("A singleton can't be instanciated. Use static accessor 'getInstance()'!");
			}
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Singleton instance getter.
		 */
		public static function getInstance():FrontControler {
			if(_instance == null)_instance = new  FrontControler(new SingletonEnforcer());
			return _instance;	
		}
		
		/**
		 * Sets the chuncks manager's reference
		 */
		public function set chunksManager(value:ChunksManager):void {
			_model.chunksManager = value;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Initialize the class.
		 */
		public function initialize(model:Model):void {
			_model = model;
		}
		
		/**
		 * Cahnges the currently selected kube's ID
		 */
		public function changeKubeId(id:String):void {
			_model.changeKubeId(id);
		}
		
		/**
		 * Saves the currentMap
		 */
		public function saveMap():void {
			_model.saveMap();
		}
		
		/**
		 * Loads a map
		 */
		public function loadMap():void {
			_model.loadMap();
		}
		
		/**
		 * Creates a map
		 */
		public function createMap(sizeX:int, sizeY:int, sizeZ:int):void {
			_model.createMap(sizeX, sizeY, sizeZ);
		}
		
		/**
		 * Tells the model that the 3D view is ready
		 */
		public function view3DReady():void {
			_model.setView3DReady();
		}
		
		/**
		 * Adds a kube to the textures
		 */
		public function addKube(kubeId:String):void {
			_model.addKube(kubeId);
		}
		
		/**
		 * Downloads the map's levels
		 */
//		public function downloadMapLevels():void {
//			_model.downloadMapLevels();
//		}
		
		/**
		 * Downloads the map
		 */
		public function downloadMap():void {
			_model.downloadMap();
		}
		
		/**
		 * Uploads the map
		 */
		public function uploadMap(modify:Boolean, pass:String):void {
			_model.uploadMap(modify, pass);
		}
		
		/**
		 * Updates the uploaded map
		 */
		public function updateUploadedMap(id:String):void {
			_model.updateUploadedMap(id);
		}
		
		/**
		 * Exports a selection
		 */
		public function exportSelection(data:ByteArray, width:int, height:int, depth:int):void {
			_model.exportSelection(data, width, height, depth);
		}
		
		/**
		 * Replaces a kube by an other one in the whole map.
		 */
		public function replaceKubes(replacer:int, replaced:int):void {
			_model.replaceKubes(replacer, replaced);
		}
		
		/**
		 * Undo the last action
		 */
		public function undo():void {
			_model.undo();
		}
		
		/**
		 * Redo the last action
		 */
		public function redo():void {
			_model.redo();
		}
		
		/**
		 * Saves the current modification history
		 */
		public function saveHistory():void {
			_model.saveHistory();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}

internal class SingletonEnforcer{}