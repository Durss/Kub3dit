package com.muxxu.kub3dit.components.tooltip.content {
	import flash.events.IEventDispatcher;

	/**
	 * Should be implemented by all the tooltip's contents.
	 * 
	 * @author Francois
	 */
	public interface ToolTipContent extends IEventDispatcher {
		
		/**
		 * Makes the component garbage collectable.
		 */
		function dispose():void;
		
	}
}
