package com.muxxu.kub3dit.components.form {
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.components.text.CssTextField;
	import flash.utils.Dictionary;
	import flash.events.Event;
	import com.nurun.components.form.events.FormComponentGroupEvent;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.components.form.FormComponentGroup;
	import flash.display.Sprite;
	
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * 
	 * @author Francois
	 * @date 5 nov. 2011;
	 */
	public class AxisSelector extends Sprite {
		
		private var _z:RadioButtonKube;
		private var _x:RadioButtonKube;
		private var _y:RadioButtonKube;
		private var _group:FormComponentGroup;
		private var _itemToValue:Dictionary;
		private var _value:String;
		private var _label:CssTextField;
		private var _lineBreakLabel:Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>AxisSelector</code>.
		 */
		public function AxisSelector(lineBreakLabel:Boolean = true) {
			_lineBreakLabel = lineBreakLabel;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the selected axis value
		 */
		public function get value():String { return _value; }



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
			_group = new FormComponentGroup();
			_label = addChild(new CssTextField("inputToolsConfLabel")) as CssTextField;
			_x = addChild(new RadioButtonKube("x", _group)) as RadioButtonKube;
			_y = addChild(new RadioButtonKube("y", _group)) as RadioButtonKube;
			_z = addChild(new RadioButtonKube("z", _group)) as RadioButtonKube;
			
			_itemToValue = new Dictionary();
			_itemToValue[_x] = "x";
			_itemToValue[_y] = "y";
			_itemToValue[_z] = "z";
			
			_y.selected = true;
			_value = "y";
			
			_x.validate();
			_y.validate();
			_z.validate();
			
			_label.text = Label.getLabel("axisSelector");
			
			computePositions();
			
			_group.addEventListener(FormComponentGroupEvent.CHANGE, changeHandler);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			if(_lineBreakLabel) {
				_x.y = _y.y = _z.y = Math.round(_label.height);
				PosUtils.hPlaceNext(2, _x, _y, _z);
			}else{
				PosUtils.hPlaceNext(2, _label, _x, _y, _z);
			}
		}
		
		/**
		 * Called when selection changes
		 */
		private function changeHandler(event:FormComponentGroupEvent):void {
			_value = _itemToValue[event.selectedItem];
			dispatchEvent(new Event(Event.CHANGE));
		}
		
	}
}