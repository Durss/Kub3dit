package com.muxxu.kub3dit.components.buttons {
	import com.nurun.components.button.IconAlign;
	import com.muxxu.kub3dit.events.ToolTipEvent;
	import com.muxxu.kub3dit.graphics.HelpButtonGraphic;
	import com.nurun.components.button.events.NurunButtonEvent;
	
	/**
	 * 
	 * @author Francois
	 * @date 31 oct. 2011;
	 */
	public class ButtonHelp extends ButtonKube {
		
		private var _ttLabel:String;
		
		
		

		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ButtonHelp</code>.
		 */
		public function ButtonHelp(label:String) {
			_ttLabel = label;
			super("", false, new HelpButtonGraphic());
			addEventListener(NurunButtonEvent.OVER, overCustomHandler);
			width = height = 15;
			iconAlign = IconAlign.CENTER;
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

		private function overCustomHandler(event:NurunButtonEvent):void {
			dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, _ttLabel, true));
		}
		
	}
}