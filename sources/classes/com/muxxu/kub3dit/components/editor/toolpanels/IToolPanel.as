package com.muxxu.kub3dit.components.editor.toolpanels {
	import flash.display.Shape;
	/**
	 * @author Francois
	 */
	public interface IToolPanel {
		
		/**
		 * Makes the component garbage collectable.
		 */
		function dispose():void;
		
		/**
		 * Gets the drawing function
		 * 
		 * Returned method must contain the following parameters:
		 * (X, Y, Z, kubeID, chunksManagerRef)
		 */
		function get drawer():Function;
		
		/**
		 * Gets the landmark graphics
		 */
		function get landmark():Shape;
		
		/**
		 * Defines the erase mode.
		 */
		function set eraseMode(value:Boolean):void;
	}
}
