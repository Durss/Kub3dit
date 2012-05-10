package com.muxxu.kub3dit.components.buttons {
	import com.nurun.utils.draw.createRect;
	import com.muxxu.kub3dit.graphics.ButtonSkin;
	import com.nurun.components.button.GraphicButton;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.visitors.applyDefaultFrameVisitorNoTween;
	import com.nurun.components.invalidator.Validable;
	import com.nurun.components.vo.Margin;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	/**
	 * 
	 * @author Francois
	 * @date 31 oct. 2011;
	 */
	public class GraphicButtonKube extends GraphicButton {
		
		private var _hasBackground:Boolean;
		
		
		

		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>GraphicButtonKube</code>.
		 */
		public function GraphicButtonKube(icon:DisplayObject, hasBackground:Boolean = true) {
			_hasBackground = hasBackground;
			super(_hasBackground? new ButtonSkin() : createRect(0), icon);
			if(icon is Validable) Validable(icon).validate();
			contentMargin = new Margin(2, 1, 2, 1);
			iconAlign = IconAlign.LEFT;
			if(_hasBackground) {
				applyDefaultFrameVisitorNoTween(this, background);
			}
			if(icon != null && icon is MovieClip) applyDefaultFrameVisitorNoTween(this, icon);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		override public function set background(value:DisplayObject):void {
			super.background = value;
			applyDefaultFrameVisitorNoTween(this, value);
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}