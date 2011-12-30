package com.muxxu.kub3dit.components.editor.toolpanels {
	import com.muxxu.kub3dit.vo.CubeSize;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;

	import flash.display.Shape;
	/**
	 * @author Francois
	 */
	public interface IToolPanel extends IEventDispatcher {
		
		/**
		 * Makes the component garbage collectable.
		 */
		function dispose():void;
		
		/**
		 * Called to draw something on the grid
		 * 
		 * @param ox				X position under the mouse
		 * @param oy				Y position under the mouse
		 * @param oz				Z position of the grid
		 * @param gridSize			size of the grid
		 */
		function draw(ox:int, oy:int, oz:int, kubeID:int, gridSize:int, gridOffset:Point):void;
		
		/**
		 * Sets the chunks manager reference.
		 */
		function set chunksManager(value:ChunksManager):void;
		
		/**
		 * Gets the landmark graphics
		 */
		function get landmark():Shape;
		
		/**
		 * Defines the erase mode.
		 */
		function set eraseMode(value:Boolean):void;
		
		/**
		 * Gets the erase mode state.
		 */
		function get eraseMode():Boolean;
		
		/**
		 * Gets if the landmark should be fixed.
		 * If this getter returns true, then the landmark will be fixed at the
		 * top left of the editor's grid.
		 */
		function get fixedLandmark():Boolean;
		
		/**
		 * Gets the sizes of the 3D landmark
		 */
//		function get landmark3DSize():CubeSize;
	}
}
