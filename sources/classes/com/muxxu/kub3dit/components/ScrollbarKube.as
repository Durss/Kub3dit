package com.muxxu.kub3dit.components {
	import com.muxxu.kub3dit.graphics.ScrollbarDownBtSkin;
	import com.muxxu.kub3dit.graphics.ScrollbarScrollerBtBigSkin;
	import com.muxxu.kub3dit.graphics.ScrollbarScrollerBtSkin;
	import com.muxxu.kub3dit.graphics.ScrollbarTrackBtSkin;
	import com.muxxu.kube3dit.graphics.ScrollbarUpBtSkin;
	import com.nurun.components.scroll.scroller.scrollbar.Scrollbar;
	import com.nurun.components.scroll.scroller.scrollbar.ScrollbarClassicSkin;

	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	
	/**
	 * Creates a pre-skined scrollbar
	 * 
	 * @author Francois
	 */
	public class ScrollbarKube extends Scrollbar {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>KBScrollbar</code>.
		 */
		public function ScrollbarKube(slider:Boolean = false, lockWheel:Boolean = false) {
			var upBt:ScrollbarUpBtSkin, downBt:ScrollbarDownBtSkin, scrollerBt:MovieClip;
			if(!slider) {
				upBt = new ScrollbarUpBtSkin();
				downBt = new ScrollbarDownBtSkin();
				scrollerBt = new ScrollbarScrollerBtSkin();
			}else{
				scrollerBt = new ScrollbarScrollerBtBigSkin();
			}
			super(new ScrollbarClassicSkin(upBt, downBt, scrollerBt, null, new ScrollbarTrackBtSkin()));
			if(lockWheel) addEventListener(MouseEvent.MOUSE_WHEEL, lockEvent, true, 1);
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

		private function lockEvent(event:MouseEvent):void {
			event.stopPropagation();
		}
		
	}
}