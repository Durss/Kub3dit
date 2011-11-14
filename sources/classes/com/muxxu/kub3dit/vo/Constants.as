package com.muxxu.kub3dit.vo {
	/**
	 * @author Francois
	 */
	public class Constants {
		
		/**
		 * Basic file type with the following data :
		 * byte  : file type
		 * short : map size X
		 * short : map size Y
		 * short : map size Z
		 * bytes : map data
		 */
		public static const MAP_FILE_TYPE_1:int = 1;
		
		/**
		 * Same thing as type 1 but with custom cubes:
		 * byte  : file type
		 * 
		 * byte  : number of custom cubes
		 * short : length of the cube's XML string
		 * bytes : cube's XML string
		 * [x number of cubes]
		 * 
		 * short : camera pos X
		 * short : camera pos Y
		 * short : camera pos Z
		 * uint  : camera rotation X
		 * int   : camera rotation Y
		 * 
		 * short : map size Y
		 * short : map size Z
		 * 
		 * bytes : map data
		 * 
		 */
		public static const MAP_FILE_TYPE_2:int = 2;
		
	}
}
