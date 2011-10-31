package com.muxxu.kub3dit.components.buttons {
	import com.muxxu.kub3dit.graphics.ButtonSkin;
	import com.nurun.components.button.BaseButton;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.button.visitors.CssVisitor;
	import com.nurun.components.button.visitors.applyDefaultFrameVisitorNoTween;
	import com.nurun.components.invalidator.Validable;
	import com.nurun.components.vo.Margin;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;

	
	/**
	 * Creates a pre-skinned button.
	 * 
	 * @author Francois
	 */
	public class ButtonKube extends BaseButton {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>KBButton</code>.
		 */
		public function ButtonKube(label:String, big:Boolean = false, icon:DisplayObject = null) {
			super(label, big? "buttonBig" : "button", new ButtonSkin(), icon);
			if(icon is Validable) Validable(icon).validate();
			contentMargin = big? new Margin(5, 5, 5, 5) : new Margin(2, 1, 2, 1);
			textBoundsMode = false;
			iconAlign = IconAlign.LEFT;
			textAlign = icon == null? TextAlign.CENTER : TextAlign.LEFT;
			iconSpacing = label.length == 0? 0 : big? 5 : 5;
			applyDefaultFrameVisitorNoTween(this, background);
			if(icon != null && icon is MovieClip) applyDefaultFrameVisitorNoTween(this, icon);
			accept(new CssVisitor());
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
		
	}
}