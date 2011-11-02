package com.muxxu.kub3dit.views {
	import flash.events.MouseEvent;
	import com.nurun.utils.pos.roundPos;
	import com.muxxu.kub3dit.vo.ToolTipAlign;
	import flash.display.InteractiveObject;
	import com.muxxu.kub3dit.vo.ToolTipMessage;
	import com.muxxu.kub3dit.components.tooltip.content.TTTextContent;
	import com.muxxu.kub3dit.components.tooltip.ToolTip;
	import com.muxxu.kub3dit.events.ToolTipEvent;
	import com.muxxu.kub3dit.model.Model;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.structure.mvc.views.ViewLocator;

	import flash.events.Event;

	/**
	 * 
	 * @author Francois
	 * @date 31 oct. 2011;
	 */
	public class ToolTipView extends AbstractView {
		private var _toolTip:ToolTip;
		private var _opened:Boolean;
		private var _alignType:String;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ToolTipView</code>.
		 */
		public function ToolTipView() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:Model = event.model as Model;
			model;
			ViewLocator.getInstance().removeView(this);
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_toolTip = addChild(new ToolTip()) as ToolTip;
			_toolTip.addEventListener(Event.CLOSE, closeHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(ToolTipEvent.OPEN, openHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
		
		/**
		 * Called when the mouse moves.
		 */
		private function mouseMoveHandler(event:MouseEvent):void {
			if(!_opened) return;
			
			switch(_alignType){
				case ToolTipAlign.TOP_LEFT:
					_toolTip.x = mouseX - _toolTip.width - 10;
					_toolTip.y = mouseY + 12;
					break;
					
				case ToolTipAlign.TOP:
					_toolTip.x = mouseX - _toolTip.width * .5;
					_toolTip.y = mouseY - _toolTip.height - 5;
					break;
					
				case ToolTipAlign.TOP_RIGHT:
					_toolTip.x = mouseX - _toolTip.width * .5;
					_toolTip.y = mouseY + 12;
					break;
					
				
				case ToolTipAlign.LEFT:
					_toolTip.x = mouseX - _toolTip.width - 10;
					_toolTip.y = mouseY - _toolTip.height * .5;
					break;
					
				case ToolTipAlign.MIDDLE:
					_toolTip.x = mouseX - _toolTip.width * .5;
					_toolTip.y = mouseY - _toolTip.height * .5;
					break;
					
				case ToolTipAlign.RIGHT:
					_toolTip.x = mouseX + 12;
					_toolTip.y = mouseY - _toolTip.height * .5;
					break;
				
				case ToolTipAlign.BOTTOM_LEFT:
					_toolTip.x = mouseX - _toolTip.width - 10;
					_toolTip.y = mouseY + 12;
					break;
					
				case ToolTipAlign.BOTTOM:
					_toolTip.x = mouseX - _toolTip.width * .5;
					_toolTip.y = mouseY + 12;
					break;
					
				default:
				case ToolTipAlign.BOTTOM_RIGHT:
					_toolTip.x = mouseX + 12;
					_toolTip.y = mouseY + 12;
					break;
			}
			roundPos(_toolTip);
		}
		
		/**
		 * Called when the tooltip is closed
		 */
		private function closeHandler(event:Event):void {
			_opened = false;
		}
		
		/**
		 * Called when the tooltip needs to be opened
		 */
		private function openHandler(event:ToolTipEvent):void {
			_opened = true;
			_toolTip.open(new ToolTipMessage(new TTTextContent(true, event.data as String), event.target as InteractiveObject));
			_alignType = event.align;
			mouseMoveHandler(null);
		}
		
	}
}