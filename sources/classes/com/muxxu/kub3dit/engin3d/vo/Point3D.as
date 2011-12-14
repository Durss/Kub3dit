package com.muxxu.kub3dit.engin3d.vo {
	
	/**
	 * 
	 * @author Francois
	 * @date 15 déc. 2011;
	 */
	public class Point3D  {
		
		public var x:int;
		public var y:int;
		public var z:int;
		
		
		

		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Point3D</code>.
		 */
		public function Point3D(x:int, y:int, z:int) {
			this.z = z;
			this.y = y;
			this.x = x;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Gets a string representation of the value object.
		 */
		public function toString():String {
			return "[Point3D :: x="+x+", x="+y+", x="+z+"]";
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}