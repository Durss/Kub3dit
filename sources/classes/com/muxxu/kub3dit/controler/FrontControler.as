package com.muxxu.kub3dit.controler {
	
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


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}

internal class SingletonEnforcer{}