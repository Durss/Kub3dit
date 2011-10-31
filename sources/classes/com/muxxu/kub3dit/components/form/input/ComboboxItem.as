package com.muxxu.kub3dit.components.form.input {
	import com.muxxu.kub3dit.graphics.BulletPointBmp;
	import com.muxxu.kub3dit.graphics.ComboboxEntryBackgroundGraphic;
	import com.muxxu.kub3dit.graphics.ComboboxEntrySelectedBackgroundGraphic;
	import com.muxxu.kub3dit.graphics.SubmitSmallBmp;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.button.events.NurunButtonEvent;
	import com.nurun.components.button.visitors.CssVisitor;
	import com.nurun.components.button.visitors.applyDefaultFrameVisitorNoTween;
	import com.nurun.components.form.ToggleButton;
	import com.nurun.components.vo.Margin;
	import com.nurun.utils.text.CssManager;

	import flash.display.Bitmap;
	import flash.events.Event;

	
	/**
	 * 
	 * @author Francois DURSUS for Nurun
	 * @date 7 juin 2011;
	 */
	public class ComboboxItem extends ToggleButton {

		private var _over:Boolean;
		private var _scrollDirection:int;
		private var _lastScrollH:int;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ComboboxItem</code>.
		 */
		public function ComboboxItem(label:String) {
			super(label, "comboboxButtonItem", "comboboxButtonItemSelected", new ComboboxEntryBackgroundGraphic(), new ComboboxEntrySelectedBackgroundGraphic(), new Bitmap(new BulletPointBmp(NaN, NaN)), new Bitmap(new SubmitSmallBmp(NaN, NaN)));
			iconAlign = IconAlign.LEFT;
			textAlign = TextAlign.LEFT;
			iconSpacing = 10;
			contentMargin = new Margin(10, 2, 10, 2);
			_labelTxt.autoWrap = false;
			_labelTxt.wordWrap = false;
			_labelTxt.multiline = false;
			allowMultiline = false;
			height = parseInt(CssManager.getInstance().styleSheet.getStyle("."+_style)["fontSize"]) + 5;
			
			accept(new CssVisitor());
			applyDefaultFrameVisitorNoTween(this, _backgroundMc, _iconMc);
			
			addEventListener(NurunButtonEvent.OVER, overHandler);
			addEventListener(NurunButtonEvent.OUT, outHandler);
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
		/**
		 * Called when the component is rolled over
		 */
		private function overHandler(event:NurunButtonEvent):void {
			if(_labelTxt.maxScrollH > 0) {
				_over = true;
				_scrollDirection = 1;
				if(!hasEventListener(Event.ENTER_FRAME)) {
					addEventListener(Event.ENTER_FRAME, enterFrameHandler);
				}
			}
		}
		
		/**
		 * Called when the component is rolled out
		 */
		private function outHandler(event:NurunButtonEvent):void {
			_over = false;
			_scrollDirection = -2;
			_labelTxt.scrollH = _lastScrollH;
		}
		
		/**
		 * Called on ENTER_FRAME event to make the text scrolling
		 */
		private function enterFrameHandler(event:Event):void {
			if(_over || _labelTxt.scrollH > 0) {
				if(_labelTxt.scrollH + _scrollDirection * 3 < 0) {
					_labelTxt.scrollH = 0;
				}else{
					_labelTxt.scrollH += _scrollDirection * 3;
				}
				if(_labelTxt.scrollH == 0 || _labelTxt.scrollH == _labelTxt.maxScrollH) {
					_scrollDirection = -_scrollDirection;
				}
			}else{
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
			_lastScrollH = _labelTxt.scrollH;
		}
		
	}
}