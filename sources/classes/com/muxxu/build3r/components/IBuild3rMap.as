package com.muxxu.build3r.components {
	import com.muxxu.build3r.vo.LightMapData;
	import com.muxxu.kub3dit.engin3d.vo.Point3D;
	/**
	 * @author Francois
	 */
	public interface IBuild3rMap {
		
		/**
		 * Updates the map.
		 */
		function update(mapReferencePoint:Point3D, positionReference:Point3D, position:Point3D, map:LightMapData):void;
		
		/**
		 * Sets the rendering size
		 */
		function set sizes(value:int):void;
		
		/**
		 * Gets the rendering size
		 */
		function get sizes():int;
		
	}
}
