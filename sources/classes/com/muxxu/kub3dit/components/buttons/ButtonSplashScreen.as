package com.muxxu.kub3dit.components.buttons {
	import gs.easing.Sine;

	import com.muxxu.kub3dit.graphics.SplashScreenButtonGraphic;
	import com.nurun.components.button.BaseButton;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.button.visitors.CssVisitor;
	import com.nurun.components.button.visitors.FrameVisitor;
	import com.nurun.components.button.visitors.FrameVisitorOptions;
	import com.nurun.components.button.visitors.PropertiesVisitor;
	import com.nurun.components.button.visitors.PropertiesVisitorOptions;
	import com.nurun.components.button.visitors.applyDefaultFrameVisitorNoTween;
	import com.nurun.components.vo.Margin;
	import com.nurun.utils.text.TextBounds;

	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * 
	 * @author Francois
	 * @date 10 nov. 2011;
	 */
	public class ButtonSplashScreen extends BaseButton {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ButtonSplashScreen</code>.
		 */
		public function ButtonSplashScreen(label:String) {
			super(label, "splashScreenButton", new SplashScreenButtonGraphic());
			contentMargin = new Margin(5, 5, 5, 5);
			textBoundsMode = false;
			iconAlign = IconAlign.LEFT;
			textAlign = icon == null? TextAlign.CENTER : TextAlign.LEFT;
			iconSpacing = 5;
			if(icon != null && icon is MovieClip) applyDefaultFrameVisitorNoTween(this, icon);
			accept(new CssVisitor());

			var fv:FrameVisitor = new FrameVisitor();
			var fvOpts:FrameVisitorOptions = new FrameVisitorOptions("out", "over", "down", "down", true, .25, Sine.easeOut);
			fvOpts.outFrameFrom = "over";
			fv.addTarget(background as MovieClip, fvOpts);
			accept(fv);
			
			var pv:PropertiesVisitor = new PropertiesVisitor();
			var pvOpts:PropertiesVisitorOptions = new PropertiesVisitorOptions({x:30, y:5, ease:Sine.easeOut}, {x:40, y:-7, ease:Sine.easeOut}, {x:37, y:-4, ease:Sine.easeOut}, {}, .25);
			pv.addTarget(_labelTxt, pvOpts);
			pvOpts = new PropertiesVisitorOptions({dropShadowFilter:{blurX:10, blurY:10, angle:135, distance:5, color:0, alpha:.25, quality:2}}, {dropShadowFilter:{distance:10}}, {dropShadowFilter:{distance:8}}, {}, .25);
			pv.addTarget(this, pvOpts);
			accept(pv);
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
		 * Resize and replace the elements.
		 * 
		 * Copy/past from the framework's source to prevent from label's move.
		 */
		override protected function computePositions():void {
			var bounds:Rectangle, iconH:int, iconW:int, marginClone:Margin, align:String;
			
			_labelTxt.setText(_label, _style);
			_labelTxt.wordWrap = _allowMultiline? (_width > 0) : false;
//			_labelTxt.multiline = _allowMultiline;
			_labelTxt.autoSize = (_width > 0 && _height > 0) ? TextFieldAutoSize.NONE : TextFieldAutoSize.LEFT;
			if(_labelTxt.autoSize == TextFieldAutoSize.NONE) {
				_labelTxt.height = _height + 4 - _contentMargin.height;
			}
			marginClone = _contentMargin.clone();
			
			iconW	= (_iconMc != null)? _iconMc.width + _iconSpacing : 0;
			if(_width > 0) {
				//This line is source of problems if the button's width is set
				//to it's current width. The textfield's width will be fixed to the
				//"width" value including its left and right gutters. So the
				//available width for the text content will be lower than before
				//when the button was autoSized.
				_labelTxt.width = _width - iconW - marginClone.width - 50;//-50 is the properties visitor label offset plus a left margin
			}
			if(_labelTxt.length == 0){
				bounds	= new Rectangle(0,0,0,0);
			}
			else if(_textBoundsMode){
				bounds	= TextBounds.getBounds(_labelTxt);
			}else{
				bounds	= new Rectangle(0,0,_labelTxt.width, _labelTxt.height);
			}
			
			iconH	= (_iconMc != null)? _iconMc.height : 0;
			_backW	= (_width > 0)?		_width	: Math.round(iconW + bounds.width + marginClone.width) + 50;
			_backH	= (_height > 0)?	_height	: Math.round(Math.max(iconH, bounds.height) + marginClone.height);
			
			if(_backgroundMc != null) {
				_backgroundMc.width		= _backW;
				_backgroundMc.height	= _backH;
			}
			
			if(_iconMc != null) {
				if(_iconAlign == IconAlign.LEFT) {
					_iconMc.x = marginClone.left;
					marginClone.left += iconW;
				}
				if(_iconAlign == IconAlign.CENTER) {
					_iconMc.x = Math.round((_backW - _iconMc.width) * .5);
				}
				if(_iconAlign == IconAlign.RIGHT) {
					_iconMc.x = _backW - marginClone.right - _iconMc.width;
					marginClone.right += iconW;
				}
				if(_height > 0) {
					_iconMc.y	= Math.round((_height - iconH) * .5);
				}else if(iconH < bounds.height) {
					_iconMc.y	= Math.round((_backH - iconH) * .5);
				}else{
					_iconMc.y	= marginClone.top;
				}
			}
			
			if(contains(_labelTxt)) {
				if(_textAlign == TextAlign.LEFT) {
//					_labelTxt.x = marginClone.left;
//					_labelTxt.x -= bounds.left;
					align = "left";
				}
				if(_textAlign == TextAlign.CENTER) {
//					_labelTxt.x = Math.round((_backW - _labelTxt.width) * .5);
					align = "center";
				}
				if(_textAlign == TextAlign.RIGHT) {
//					_labelTxt.x = _backW - _labelTxt.width - marginClone.right;
					align = "right";
				}
//				
//				if(_height > 0) {
//					_labelTxt.y	= Math.round((_height - bounds.height) * .5);
//				}else if(iconH > bounds.height) {
//					_labelTxt.y	= Math.round((iconH - bounds.height) * .5 + marginClone.top);
//				}else{
//					_labelTxt.y	= marginClone.top;
//				}
//				_labelTxt.y += -bounds.top + _yLabelOffset;
				
				//If the component's width is fixed, the textfield's width is
				//set to the available width and wordwrap at true. That way, the
				//text can be multilined if it's too long. But in that case the
				//text can't be centered or right aligned. So we just specify with
				//HTML that the content should be aligned as we want it to be.
				if(_labelTxt.wordWrap) {
					_labelTxt.setText('<p align="'+align+ '">' + _label + '</p>');
				}
			}
			
			if(_labelTxt.autoSize == TextFieldAutoSize.NONE) {
				_labelTxt.height = _backH - _labelTxt.y;
			}
			
			graphics.clear();
			graphics.beginFill(0xFF0000, 0);
			graphics.drawRect(0, 0, _backW, _backH);
		}
		
	}
}