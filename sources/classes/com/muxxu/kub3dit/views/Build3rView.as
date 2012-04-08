package com.muxxu.kub3dit.views {
	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;

	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * 
	 * @author Francois
	 * @date 8 avr. 2012;
	 */
	public class Build3rView extends AbstractWindowView {
		private var _description:CssTextField;
		private var _nextBt:ButtonKube;
		private var _prevBt:ButtonKube;
		private var _pageIndex:int;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Build3rView</code>.
		 */
		public function Build3rView() {
			super(Label.getLabel("build3r-title"));
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
		 * Initialize the class.
		 */
		override protected function initialize():void {
			super.initialize();
			
			_description = _container.addChild(new CssTextField("promptWindowContent")) as CssTextField;
			_nextBt = _container.addChild(new ButtonKube(Label.getLabel("build3r-detailsNext"))) as ButtonKube;
			_prevBt = _container.addChild(new ButtonKube(Label.getLabel("build3r-detailsPrev"))) as ButtonKube;
			
			_description.selectable = true;
			
			updatePage();
		}
		
		override protected function clickHandler(event:MouseEvent):void {
			if(event.target == _prevBt) {
				_pageIndex --;
				updatePage();
			}else if(event.target == _nextBt) {
				_pageIndex ++;
				updatePage();
			}else {
				super.clickHandler(event);
			}
		}

		private function updatePage():void {
			_description.text = Label.getLabel("build3r-details-page"+_pageIndex);
			_description.width = 550;
			
			_nextBt.enabled = !/Missing/gi.test(Label.getLabel("build3r-details-page"+(_pageIndex+1)));
			_prevBt.enabled = !/Missing/gi.test(Label.getLabel("build3r-details-page"+(_pageIndex-1)));
			
			if(stage != null) computePositions();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		override protected function computePositions(event:Event = null):void {
			_prevBt.y = _nextBt.y = Math.round(_description.height + 10);
			_nextBt.x = Math.round(_description.width - _nextBt.width);
			super.computePositions();
		}
		
	}
}