package com.muxxu.kub3dit.commands {
	/**
	 * @author Francois
	 */
	public interface ISaveView {
		/**
		 * Specifies if the last loaded map is editable or not.
		 * 
		 * modified if someday i add an option to create a new map without
		 * reloading the whole application.
		 */
		function set editableMap(value:Boolean):void
		
		/**
		 * Sets the map's ID
		 */
		function set mapId(value:String):void
	}
}
