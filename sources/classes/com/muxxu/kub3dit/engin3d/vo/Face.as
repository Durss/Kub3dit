package com.muxxu.kub3dit.engin3d.vo {
	
	/**
	 * 
	 * @author Francois
	 * @date 14 déc. 2011;
	 */
	public class Face {
		
		public var a:Point3D;
		public var b:Point3D;
		public var c:Point3D;
		public var centroid:Point3D;
		
		
		
		

		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Face</code>.
		 */
		public function Face(buffer:Vector.<Number>, index:int, registers:int, secondFace:Boolean) {
			a = new Point3D(buffer[index - registers * 4], buffer[index - registers * 4+1], buffer[index - registers * 4+2]);
			if(!secondFace) {
				b = new Point3D(buffer[index - registers * 3], buffer[index - registers * 3+1], buffer[index - registers * 3+2]);
				c = new Point3D(buffer[index - registers * 2], buffer[index - registers * 2+1], buffer[index - registers * 2+2]);
			}else{
				b = new Point3D(buffer[index - registers * 2], buffer[index - registers * 2+1], buffer[index - registers * 2+2]);
				c = new Point3D(buffer[index - registers], buffer[index - registers + 1], buffer[index - registers + 2]);
			}
			centroid = new Point3D((a.x+b.x+c.x)/3, (a.y+b.y+c.y)/3, (a.z+b.z+c.z)/3);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}