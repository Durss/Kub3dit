package com.muxxu.kub3dit.vo {
	import flash.display.BitmapData;
	
	/**
	 * 
	 * @author Francois
	 * @date 10 mai 2012;
	 */
	public class KubeSelecorItemData  {
		
		private var _id:String;
		private var _bmd:BitmapData;
		
		
		

		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>KubeSelecorItemData</code>.
		 */
		public function KubeSelecorItemData(id:String, bmd:BitmapData) {
			_bmd = bmd;
			_id = id;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get id():String {
			return _id;
		}

		public function get bmd():BitmapData {
			return _bmd;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}