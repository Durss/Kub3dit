package com.muxxu.kub3dit.components.editor {
	import com.nurun.structure.environnement.label.Label;
	import com.muxxu.kub3dit.controler.FrontControler;
	import flash.events.Event;
	import com.muxxu.kub3dit.graphics.DelPathtIcon;
	import com.muxxu.kub3dit.events.ToolTipEvent;
	import com.muxxu.kub3dit.components.buttons.GraphicButtonKube;
	import com.muxxu.kub3dit.engin3d.camera.Camera3D;
	import com.muxxu.kub3dit.graphics.CameraIcon;
	import com.nurun.components.text.CssTextField;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	//Whe the clear button is clicked
	[Event(name="clear", type="flash.events.Event")]
	
	/**
	 * 
	 * @author Francois
	 * @date 30 juin 2012;
	 */
	public class CamPathEntry extends Sprite {
		private var _labelTf:CssTextField;
		private var _camButton:GraphicButtonKube;
		private var _label:String;
		private var _data:Object;
		private var _index:int;
		private var _width:Number;
		private var _prevPath:Array;
		private var _delButton:GraphicButtonKube;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>CamPathEntry</code>.
		 */
		public function CamPathEntry(data:Object, index:int) {
			_index = index;
			_data = data;
			_label = data["name"];
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Sets the width of the component without simply scaling it.
		 */
		override public function set width(value:Number):void {
			_width = value;
			computePositions();
		}
		
		/**
		 * Gets the width of the component.
		 */
		override public function get width():Number { return _width; }
		
		/**
		 * Gets the item's data
		 */
		public function get data():Object { return _data; }



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
			_labelTf = addChild(new CssTextField("tool-campath-entry")) as CssTextField;
			_camButton = addChild(new GraphicButtonKube(new CameraIcon())) as GraphicButtonKube;
			_delButton = addChild(new GraphicButtonKube(new DelPathtIcon())) as GraphicButtonKube;
			
			_labelTf.text = _label;
			
			addEventListener(MouseEvent.MOUSE_OVER, overButtonHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.ROLL_OVER, rollhandler);
			addEventListener(MouseEvent.ROLL_OUT, rollhandler);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			if(isNaN(_width)) return;
			
			_labelTf.width = _width - _camButton.width;
			_delButton.height = _delButton.width = 
			_camButton.height = _camButton.width = 
			_camButton.x = Math.round(_labelTf.height);
			_labelTf.x = Math.round(_camButton.x + _camButton.width);
			
			graphics.beginFill(_index % 2 == 0? 0xffffff : 0, .2);
			graphics.drawRect(0, 0, _width, height);
			graphics.endFill();
		}
		
		/**
		 * Called when the item is rolled over
		 */
		private function rollhandler(event:MouseEvent):void {
			if(event.type == MouseEvent.ROLL_OVER) {
				_prevPath = Camera3D.path;
				Camera3D.path = _data["path"];
			}else{
				Camera3D.path = _prevPath;
			}
		}
		
		/**
		 * Called when a button is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target == _camButton) {
				_prevPath = null;
				FrontControler.getInstance().playPathByID(_data["id"]);
			}else
			if(event.target == _delButton) {
				dispatchEvent(new Event(Event.CLEAR));
			}
		}
		
		/**
		 * Called when a button is rolled over
		 */
		private function overButtonHandler(event:MouseEvent):void {
			if(event.target == _camButton) {
				dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, Label.getLabel("toolConfig-campath-helpFollow")));
			}else
			if(event.target == _delButton) {
				dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, Label.getLabel("toolConfig-campath-helpDelete")));
			}
		}
		
	}
}