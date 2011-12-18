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
		public function Point3D(x:int = 0, y:int = 0, z:int = 0) {
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
			return "("+x+", "+y+", "+z+")";
		}
		
		/**
		 * Makes a clone of the object
		 */
		public function clone():Point3D {
			return new Point3D(x, y, z);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}