package com.muxxu.kub3dit.components {
	import flash.filters.DropShadowFilter;
	import com.muxxu.kub3dit.graphics.DisabledCubeIcon;
	import com.muxxu.kub3dit.graphics.EnabledCubeIcon;
	import com.muxxu.kub3dit.vo.ToolTipAlign;
	import com.nurun.structure.environnement.label.Label;
	import com.muxxu.kub3dit.events.ToolTipEvent;
	import flash.filters.GlowFilter;
	import flash.filters.ColorMatrixFilter;
	import gs.TweenLite;

	import com.nurun.components.button.GraphicButton;
	import com.nurun.components.button.events.NurunButtonEvent;
	import com.nurun.components.form.GroupableFormComponent;

	import flash.display.DisplayObject;
	import flash.events.Event;
	
	/**
	 * 
	 * @author Francois
	 * @date 30 oct. 2011;
	 */
	public class KubeSelectorButton extends GraphicButton implements GroupableFormComponent {
		
		private var _id:int;
		private var _selected:Boolean;
		private var _disable:ColorMatrixFilter;
		private var _glow:GlowFilter;
		private var _selectionMode:Boolean;
		private var _enabledIcon:EnabledCubeIcon;
		private var _disabledIcon:DisabledCubeIcon;
		private var _filter:DropShadowFilter;
		private var _defaultModeState:Boolean;
		private var _selectionModeState:Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>KubeButton</code>.
		 */
		public function KubeSelectorButton(background:DisplayObject, id:String) {
			_id = parseInt(id);
			_disable = new ColorMatrixFilter([.8, .2, .2, 0, 0, .2, .8, .2, 0, 0, .2, .2, .8, 0, 0, 0, 0, 0, 1, 0]);
			_glow = new GlowFilter( 0xffffff, 1, 10, 10, 1, 2 );
			
			super(background);
			
			_filter = new DropShadowFilter(0,0,0,1,2,2,10,2);
			_enabledIcon = new EnabledCubeIcon();
			_disabledIcon = new DisabledCubeIcon();
			
			_enabledIcon.filters = _disabledIcon.filters = [_filter];
			
			addEventListener(NurunButtonEvent.OVER, overHandler);
			addEventListener(NurunButtonEvent.OUT, outHandler);
			addEventListener(NurunButtonEvent.RELEASE_OUTSIDE, outHandler);
			addEventListener(NurunButtonEvent.CLICK, clickCustomHandler, false, 9999);
			
			selected = false;
			_defaultModeState = false;
			_selectionModeState = _id != 1 && _id != 56 && (_id < 56 || _id > 68) && _id != 71 && _id != 73 && _id != 75 && _id != 77;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		
		/**
		 * @inheritDoc
		 */
		public function get selected():Boolean { return _selected; }
		
		/**
		 * @inheritDoc
		 */
		public function set selected(value:Boolean):void {
			_selected = value;
			updateState();
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * Gets the related kube's ID
		 */
		public function get id():String { return _id.toString(); }
		
		/**
		 * Sets the selection mode of the component
		 */
		public function set selectionMode(value:Boolean):void {
			_selected = value? _selectionModeState : _defaultModeState;
			_selectionMode = value;
			if(value) {
				addChild(_enabledIcon);
				addChild(_disabledIcon);
				_enabledIcon.x = 30 - _enabledIcon.width;
				_enabledIcon.y = 30 - _enabledIcon.height;
				_disabledIcon.x = 30 - _disabledIcon.width;
				_disabledIcon.y = 30 - _disabledIcon.height;
				updateState();
			}else if(contains(_enabledIcon)) {
				removeChild(_enabledIcon);
				removeChild(_disabledIcon);
//				updateState();
			}
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */

		/**
		 * @inheritDoc
		 */
		public function select():void {
			_selected = true;
			updateState();
		}

		/**
		 * @inheritDoc
		 */
		public function unSelect():void {
			_selected = false;
			updateState();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */

		/**
		 * Called when the component is clicked.<br>
		 */
		protected function clickCustomHandler(event:NurunButtonEvent):void {
			selected = !_selected;
		}
		
		/**
		 * Called when the component is rolled out
		 */
		private function outHandler(event:NurunButtonEvent):void {
			TweenLite.to(this, .2, {colorMatrixFilter:{brightness:1, remove:true}});
		}

		/**
		 * Called when the component is rolled over
		 */
		private function overHandler(event:NurunButtonEvent):void {
			TweenLite.to(this, .2, {colorMatrixFilter:{brightness:1.5}});
			dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, Label.getLabel("kube"+_id), ToolTipAlign.LEFT));
		}
		
		/**
		 * Updates the component's state
		 */
		protected function updateState():void {
			_enabledIcon.visible = _selected;
			_disabledIcon.visible = !_selected;
			if(_selectionMode) {
				_selectionModeState = _selected;
				background.filters = [];
			}else{
				_defaultModeState = _selected;
				if(_selected) {
					background.filters = [_glow];
				}else{
					background.filters = [_disable];
				}
				alpha = _selected? 1 : .5;
			}
		}
		
	}
}