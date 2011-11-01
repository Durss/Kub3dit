package com.muxxu.kub3dit.events {
	import flash.events.Event;
	
	/**
	 * Event fired by ToolsPanel
	 * 
	 * @author Francois
	 * @date 31 oct. 2011;
	 */
	public class ToolsPanelEvent extends Event {
		
		
		public static const OPEN_PANEL:String = "openPanel";
		public static const SELECT_TOOL:String = "selectTool";
		public static const ERASE_MODE_CHANGE:String = "eraseModeChange";
		
		private var _panelType:Class;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ToolsPanelEvent</code>.
		 */
		public function ToolsPanelEvent(type:String, panelType:Class = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			_panelType = panelType;
			super(type, bubbles, cancelable);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the panel's type to open.
		 */
		public function get panelType():Class { return _panelType; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes a clone of the event object.
		 */
		override public function clone():Event {
			return new ToolsPanelEvent(type, panelType, bubbles, cancelable);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}