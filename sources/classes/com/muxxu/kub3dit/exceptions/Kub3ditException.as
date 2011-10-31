package com.muxxu.kub3dit.exceptions {
	
	/**
	 * 
	 * @author Francois
	 * @date 30 oct. 2011;
	 */
	public class Kub3ditException extends Error {
		
		private var _severity:int;
		
		
		

		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Kub3ditException</code>.
		 */
		public function Kub3ditException(message:String, severity:int) {
			_severity = severity;
			super(message);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the excception's severity
		 */
		public function get severity():int {
			return _severity;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}