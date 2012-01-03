package com.muxxu.kub3dit.vo {
	
	/**
	 * 
	 * @author Francois
	 * @date 29 déc. 2011;
	 */
	public class CubeSize {
		
		public var width:int;
		public var height:int;
		public var depth:int;
		
		
		

		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>CubeData</code>.
		 */
		public function CubeSize(width:int, height:int, depth:int) {
			this.depth = depth;
			this.height = height;
			this.width = width;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		public function toString():String {
			return "(w="+width+", h="+height+", d="+depth+")";
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}