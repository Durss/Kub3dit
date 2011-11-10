package com.muxxu.kub3dit.events {
	import flash.events.Event;
	
	/**
	 * Event fired by anybody that has to display something on the tooltip
	 * 
	 * @author Francois
	 * @date 31 oct. 2011;
	 */
	public class ToolTipEvent extends Event {
		
		public static const OPEN:String = "OPEN";
		private var _data:*;
		private var _align:String;
		private var _margin:int;
		private var _style:String;
		
		
		

		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ToolTipEvent</code>.
		 */
		public function ToolTipEvent(type:String, data:*, align:String = "br", margin:int = 5, style:String = "tooltipContent", bubbles:Boolean = true, cancelable:Boolean = false) {
			_style = style;
			_margin = margin;
			_align = align;
			_data = data;
			super(type, bubbles, cancelable);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the data to display
		 */
		public function get data():* { return _data; }
		
		/**
		 * Gets the tooltip alignment
		 */
		public function get align():String { return _align; }
		
		/**
		 * Gets the margin between the cursor and the tooltip
		 */
		public function get margin():int { return _margin; }
		
		/**
		 * Gets the CSS style of the text 
		 */
		public function get style():String { return _style; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes a clone of the event object.
		 */
		override public function clone():Event {
			return new ToolTipEvent(type, data, align, margin, _style, bubbles, cancelable);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}