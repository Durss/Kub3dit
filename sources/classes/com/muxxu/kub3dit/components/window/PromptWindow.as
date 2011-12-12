package com.muxxu.kub3dit.components.window {
	import flash.filters.DropShadowFilter;
	import com.nurun.components.text.CssTextField;
	import flash.display.DisplayObject;
	import com.muxxu.kub3dit.graphics.PromptWindowGraphic;
	import flash.display.Sprite;
	
	/**
	 * 
	 * @author Francois
	 * @date 11 déc. 2011;
	 */
	public class PromptWindow extends Sprite {
		private var _background:PromptWindowGraphic;
		private var _title:String;
		private var _content:DisplayObject;
		private var _titleTf:CssTextField;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>AbstractPromptWindow</code>.
		 */
		public function PromptWindow(title:String, content:DisplayObject) {
			_content = content;
			_title = title;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Updates the sizes of the window.
		 * Call this method if the content's sizes change.
		 */
		public function udapteSizes():void {
			computePositions();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_background = addChild(new PromptWindowGraphic()) as PromptWindowGraphic;
			_titleTf = addChild(new CssTextField("promptWindowTitle")) as CssTextField;
			
			_titleTf.text = _title;
			_titleTf.filters = [new DropShadowFilter(3, 135, 0x2D89B0, 1, 1, 1, 10, 2)];
			
			addChild(_content);
			
			filters = [new DropShadowFilter(0,0,0,1,10,10,.4,2)];
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_titleTf.width = _content.width;
			while(_titleTf.numLines > 1) _titleTf.width += 2;
			
			_titleTf.x = 10;
			_titleTf.y = 3;
			_background.width = _titleTf.width + 25;
			_background.height = 60 + _content.height;
			_content.y = 40;
			_content.x = Math.round((_background.width - _content.width) * .5);
		}
		
	}
}