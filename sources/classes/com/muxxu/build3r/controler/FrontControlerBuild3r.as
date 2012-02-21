package com.muxxu.build3r.controler {
	import com.muxxu.build3r.model.ModelBuild3r;

	import flash.errors.IllegalOperationError;
	import flash.geom.Point;
	
	
	/**
	 * Singleton FrontControlerBuild3r
	 * 
	 * @author Francois
	 * @date 19 févr. 2012;
	 */
	public class FrontControlerBuild3r {
		private static var _instance:FrontControlerBuild3r;
		private var _model:ModelBuild3r;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>FrontControlerBuild3r</code>.
		 */
		public function FrontControlerBuild3r(enforcer:SingletonEnforcer) {
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
		public static function getInstance():FrontControlerBuild3r {
			if(_instance == null)_instance = new  FrontControlerBuild3r(new SingletonEnforcer());
			return _instance;	
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Initialize the class.
		 */
		public function initialize(model:ModelBuild3r):void {
			_model = model;
		}
		
		/**
		 * Browses for an external map's file
		 */
		public function browseForMap():void {
			_model.browseForMap();
		}
		
		/**
		 * Loads a map by its ID
		 */
		public function loadMapById(id:String, password:String):void {
			_model.loadMapById(id, password);
		}
		
		/**
		 * Sets the map's reference point.
		 * The reference point in-game is already stored in the model. (last kube touched)
		 */
		public function setReferencePoint(reference:Point):void {
			_model.setReferencePoint(reference);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}

internal class SingletonEnforcer{}