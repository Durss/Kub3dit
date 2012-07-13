package com.muxxu.kub3dit.views {
	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.exceptions.Kub3ditException;
	import com.muxxu.kub3dit.exceptions.Kub3ditExceptionSeverity;
	import com.muxxu.kub3dit.graphics.SubmitIcon;
	import com.nurun.components.text.CssTextField;
	import com.nurun.components.vo.Margin;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;

	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.text.TextFieldAutoSize;

	/**
	 * 
	 * @author Francois
	 * @date 8 avr. 2012;
	 */
	public class ExceptionView extends AbstractWindowView {
		
		private var _label:CssTextField;
		private var _submitBt:ButtonKube;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ExceptionView</code>.
		 */
		public function ExceptionView() {
			super(Label.getLabel("prompt-exception"));
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
			alpha = 0;
			visible = false;
			_label = _container.addChild(new CssTextField("promptWindowContent")) as CssTextField;
			_submitBt = _container.addChild(new ButtonKube(Label.getLabel("prompt-exception-ok"), false, new SubmitIcon())) as ButtonKube;
			
			_label.selectable = true;
			_submitBt.contentMargin = new Margin(5, 3, 5, 3);
		}
		
		/**
		 * Called when the stage is available.
		 */
		override protected function addedToStageHandler(event:Event):void {
			super.addedToStageHandler(event);
			root.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);
		}
		
		/**
		 * Called if an uncaught error is received
		 */
		private function uncaughtErrorHandler(event:UncaughtErrorEvent):void {
			event.preventDefault();
			event.stopImmediatePropagation();
			
			if(event.error is Kub3ditException) {
				_label.text = Kub3ditException(event.error).message;
				_submitBt.visible = Kub3ditException(event.error).severity != Kub3ditExceptionSeverity.FATAL;
			}else if(event.error != null){
				_label.text = Error(event.error).getStackTrace();
				_submitBt.visible = false;
			}
			open();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		override protected function computePositions(event:Event = null):void {
			_label.autoSize = TextFieldAutoSize.LEFT;
			if(_label.width > 300) _label.width = 270;
			PosUtils.hCenterIn(_submitBt, _label);
			PosUtils.vPlaceNext(10, _label, _submitBt);
			
			super.computePositions();
		}
		
		/**
		 * Called when disable layer is clicked.
		 * Closes the view.
		 */
		override protected function clickHandler(event:MouseEvent):void {
			if(!_submitBt.visible) return;
			
			if (event.target == _disableLayer || event.target == _submitBt) {
				close();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function keyUpHandler(event:KeyboardEvent):void {
			if(!_submitBt.visible) return;
			super.keyUpHandler(event);
		}
		
	}
}