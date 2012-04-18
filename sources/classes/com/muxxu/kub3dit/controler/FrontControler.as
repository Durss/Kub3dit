package com.muxxu.kub3dit.controler {
	import flash.utils.ByteArray;
	import com.muxxu.kub3dit.model.Model;

	import flash.errors.IllegalOperationError;
	
	
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
		public function downloadMapLevels():void {
			_model.downloadMapLevels();
		}
		
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


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}

internal class SingletonEnforcer{}