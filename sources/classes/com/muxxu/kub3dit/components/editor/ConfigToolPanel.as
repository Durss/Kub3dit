package com.muxxu.kub3dit.components.editor {
	import gs.TweenLite;

	import com.muxxu.kub3dit.components.buttons.GraphicButtonKube;
	import com.muxxu.kub3dit.components.editor.toolpanels.IToolPanel;
	import com.muxxu.kub3dit.graphics.CloseIcon;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.utils.Dictionary;
	
	/**
	 * 
	 * @author Francois
	 * @date 31 oct. 2011;
	 */
	public class ConfigToolPanel extends Sprite {
		
		private var _back:Shape;
		private var _panel:IToolPanel;
		private var _width:Number;
		private var _closeBt:GraphicButtonKube;
		private var _holder:Sprite;
		private var _mask:Shape;
		private var _opened:Boolean;
		private var _panelTypeToPanel:Dictionary;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ConfigToolPanel</code>.
		 */
		public function ConfigToolPanel() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		override public function set width(value:Number):void {
			_width = value;
			computePositions();
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		
		/**
		 * Sets the panel's type to use
		 */
		public function setPanelType(value:Class):IToolPanel {
			if(_panel != null) {
//				_panel.dispose();
				if(_holder.contains(_panel as DisplayObject)) _holder.removeChild(_panel as DisplayObject);
				_panel.removeEventListener(Event.RESIZE, computePositions);
			}
			
			if(_panelTypeToPanel[value] == undefined) {
				_panel = new value() as IToolPanel;
			}else{
				_panel = _panelTypeToPanel[value];
			}
			_panel.addEventListener(Event.RESIZE, computePositions);
			if(_panel == null) {
				throw new IllegalOperationError("Class reference isn't IToolPanel typed!");
				return null;
			}
			
			_panelTypeToPanel[value] = _panel;
			
			return _panel;
		}
		
		/**
		 * Opens a panel
		 */
		public function open():void {
			_opened = true;
			_holder.addChild(_panel as DisplayObject);
			
			computePositions();
			
			_mask.height = 0;
			TweenLite.to(_mask, .25, {height:_back.height});
		}
		
		/**
		 * Closes the config panel
		 */
		public function close():void {
			_opened = false;
			TweenLite.to(_mask, .25, {height:0});
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_panelTypeToPanel = new Dictionary();
			
			_holder = addChild(new Sprite()) as Sprite;
			_back = _holder.addChild(new Shape()) as Shape;
			_closeBt = _holder.addChild(new GraphicButtonKube( new CloseIcon() )) as GraphicButtonKube;
			_mask = addChild(new Shape()) as Shape;
			
			_mask.graphics.beginFill(0xff0000, 1);
			_mask.graphics.drawRect(0, 0, 100, 100);
			_mask.graphics.endFill();
			
			_back.graphics.beginFill(0x2E8FB8, 1);
			_back.graphics.drawRect(0, 0, 100, 100);
			_back.graphics.endFill();
			
			_holder.mask = _mask;
			_mask.height = 0 ;
			
			_closeBt.addEventListener(MouseEvent.CLICK, clickHandler);
			
			filters = [new DropShadowFilter(2,90,0,.2,2,2,1,2)];
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions(event:Event = null):void {
			if(!_opened) return;
			
			var dispObj:DisplayObject = _panel as DisplayObject;
			_back.width = _mask.width = _width;
			_back.height = _mask.height = dispObj.height + 10;
			PosUtils.centerIn(dispObj, _back);
			PosUtils.alignToRightOf(_closeBt, _back);
		}
		
		/**
		 * Called when close button is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			close();
		}
		
	}
}