package com.muxxu.kub3dit.components.buttons {
	import gs.TweenLite;

	import com.muxxu.kub3dit.events.ButtonEditorToolEvent;
	import com.muxxu.kub3dit.graphics.ButtonWarnSkin;
	import com.muxxu.kub3dit.graphics.OptionsIcon;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.events.NurunButtonEvent;
	import com.nurun.components.form.GroupableFormComponent;
	import com.nurun.components.vo.Margin;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	[Event(name="clickBET", type="com.muxxu.kub3dit.events.ButtonEditorToolEvent")]
	
	
	/**
	 * Creates a button for the editor.
	 * This button can be flaged as "customizable". If it is, then rolling
	 * over the will display an option button to open a configuration panel.
	 * 
	 * @author Francois
	 * @date 31 oct. 2011;
	 */
	public class ButtonEditorTool extends Sprite implements GroupableFormComponent {
		
		private var _icon:DisplayObject;
		private var _customizable:Boolean;
		private var _button:GraphicButtonKube;
		private var _optionsBt:GraphicButtonKube;
		private var _selected:Boolean;
		private var _defaultSkin:DisplayObject;
		private var _selectedSkin:ButtonWarnSkin;
		
		
		

		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ButtonEditorTool</code>.
		 * 
		 * @param icon			button's icon
		 * @param customizable	defines if the tool can be customized
		 */
		public function ButtonEditorTool(icon:DisplayObject, customizable:Boolean) {
			_customizable = customizable;
			_icon = icon;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		public function get selected():Boolean {
			return _selected;
		}

		/**
		 * @inheritDoc
		 */
		public function set selected(value:Boolean):void {
			_selected = value;
			updateSkin();
			dispatchEvent(new Event(Event.CHANGE));
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		public function select():void {
			_selected = true;
			updateSkin();
		}

		/**
		 * @inheritDoc
		 */
		public function unSelect():void {
			_selected = false;
			updateSkin();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			if(_customizable) {
				_optionsBt = addChild(new GraphicButtonKube(new OptionsIcon(), false)) as GraphicButtonKube;
				_optionsBt.contentMargin = new Margin(0, 0, 0, 0);
			}
			_button = addChild(new GraphicButtonKube(_icon)) as GraphicButtonKube;
			_defaultSkin = _button.background;
			_selectedSkin = new ButtonWarnSkin();
			
			_button.iconAlign = IconAlign.CENTER;
			_button.width = _button.height = 20;
			
			if(_customizable) {
				_button.addEventListener(NurunButtonEvent.OVER, overHandler);
				addEventListener(MouseEvent.ROLL_OUT, outHandler);
			}
			
			addEventListener(MouseEvent.CLICK, clickHandler);
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			if(_optionsBt != null) {
				_optionsBt.x = _button.width - _optionsBt.width;
			}
		}
		
		/**
		 * Updates the button's skin
		 */
		private function updateSkin():void {
			_button.background = _selected? _selectedSkin : _defaultSkin;
		}
		
		
		
		
		//__________________________________________________________ MOUSE EVENTS
		
		/**
		 * Called whent the main button is rolled over
		 */
		private function overHandler(event:NurunButtonEvent):void {
			TweenLite.to(_optionsBt, .2, {x:_button.width});
		}
		
		/**
		 * Called when the component is rolled out
		 */
		private function outHandler(event:MouseEvent):void {
			if(isNaN(event.localX)) return;//weird thing fired sometimes :/...
			
			TweenLite.to(_optionsBt, .2, {x:_button.width - _optionsBt.width});
		}
		
		/**
		 * Called when a button is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			var isOption:Boolean = event.target == _optionsBt;
			if((isOption && !_selected) || !isOption){
				selected = !_selected;
			}
			dispatchEvent(new ButtonEditorToolEvent(ButtonEditorToolEvent.CLICK, isOption));
		}
		
	}
}