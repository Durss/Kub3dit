package com.muxxu.kub3dit.components.editor.toolpanels {
	import com.nurun.structure.environnement.label.Label;
	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.components.buttons.GraphicButtonKube;
	import com.muxxu.kub3dit.components.editor.CamPathEntry;
	import com.muxxu.kub3dit.components.form.ScrollbarKube;
	import com.muxxu.kub3dit.components.form.input.InputKube;
	import com.muxxu.kub3dit.engin3d.camera.Camera3D;
	import com.muxxu.kub3dit.engin3d.chunks.ChunkData;
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;
	import com.muxxu.kub3dit.engin3d.map.Map;
	import com.muxxu.kub3dit.engin3d.vo.Point3D;
	import com.muxxu.kub3dit.events.ToolTipEvent;
	import com.muxxu.kub3dit.graphics.AddPointIcon;
	import com.muxxu.kub3dit.graphics.ClearPathIcon;
	import com.muxxu.kub3dit.graphics.SaveIcon;
	import com.muxxu.kub3dit.graphics.TimerIcon;
	import com.muxxu.kub3dit.vo.ToolTipAlign;
	import com.nurun.components.scroll.ScrollPane;
	import com.nurun.components.scroll.scrollable.ScrollableDisplayObject;
	import com.nurun.core.lang.Disposable;
	import com.nurun.core.lang.isEmpty;
	import com.nurun.utils.pos.roundPos;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	/**
	 * 
	 * @author Francois
	 * @date 27 juin 2012;
	 */
	public class CamPathPanel extends Sprite implements IToolPanel {
		private var _captureButton:ButtonKube;
		private var _timerIcon:TimerIcon;
		private var _registering:Boolean;
		private var _prevPos:Point3D;
		private var _path:Array;
		private var _addPointButton:ButtonKube;
		private var _clearButton:GraphicButtonKube;
		private var _buttonToTooltip:Dictionary;
		private var _registerButton:ButtonKube;
		private var _nameInput:InputKube;
		private var _listHolder:ScrollableDisplayObject;
		private var _scrollpane:ScrollPane;
		private var _map:Map;
		private var _width:int;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>CamPathPanel</code>.
		 */
		public function CamPathPanel() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		public function set chunksManager(value:ChunksManager):void {
			_map = value.map;
			updateList();
		}
		
		/**
		 * @inheritDoc
		 */
		public function get landmark():Shape {
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set eraseMode(value:Boolean):void {
		}
		
		/**
		 * @inheritDoc
		 */
		public function get eraseMode():Boolean {
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set level(value:int):void {
		}
		
		/**
		 * @inheritDoc
		 */
		public function get fixedLandmark():Boolean {
			return false;
		}
		
		/**
		 * Gets the height of the component.
		 */
		override public function get height():Number { return Math.round(_scrollpane.y + _scrollpane.height); }
		
		/**
		 * Gets the width of the component.
		 */
		override public function get width():Number { return _width; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		public function dispose():void {
		}
		
		/**
		 * @inheritDoc
		 */
		public function draw(ox:int, oy:int, oz:int, kubeID:int, gridSize:int, gridOffset:Point):void {
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_path = [];
			_timerIcon = new TimerIcon();
			_timerIcon.innerMc.stop();
			_captureButton = addChild(new ButtonKube(Label.getLabel("toolConfig-campath-capture"), false, _timerIcon)) as ButtonKube;
			_addPointButton = addChild(new ButtonKube(Label.getLabel("toolConfig-campath-addPoint"), false, new AddPointIcon())) as ButtonKube;
			_clearButton = addChild(new GraphicButtonKube(new ClearPathIcon())) as GraphicButtonKube;
			_nameInput = addChild(new InputKube(Label.getLabel("toolConfig-campath-inputDefault"))) as InputKube;
			_registerButton = addChild(new ButtonKube(Label.getLabel("toolConfig-campath-save"), false, new SaveIcon())) as ButtonKube;
			_listHolder = addChild(new ScrollableDisplayObject()) as ScrollableDisplayObject;
			_scrollpane = addChild(new ScrollPane(_listHolder, new ScrollbarKube())) as ScrollPane;
			
			_width = 300;
			_scrollpane.autoHideScrollers = true;
			_scrollpane.width = _width;
			
			_buttonToTooltip = new Dictionary();
			_buttonToTooltip[_clearButton] = Label.getLabel("toolConfig-campath-helpClear");
			_buttonToTooltip[_captureButton] = Label.getLabel("toolConfig-campath-helpCapture");
			_buttonToTooltip[_addPointButton] = Label.getLabel("toolConfig-campath-helpAddPoint");
			
			//Green color
			var m:Array = [0.6467894315719604, 1.1897121667861938, -0.8365015983581543, 0, 0,
							0.013973236083984375, 0.6644432544708252, 0.32158347964286804, 0, 0,
							0.9033367037773132, -0.177803635597229, 0.27446693181991577, 0, 0,
							0, 0, 0, 1, 0];
			_registerButton.filters = [new ColorMatrixFilter(m)];
			_registerButton.enabled = false;
			_clearButton.enabled = false;
			
			addEventListener(MouseEvent.CLICK, clickNewHandler);
			addEventListener(MouseEvent.MOUSE_OVER, rollHandler);
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			computePositions();
			Camera3D.path = _path;
		}
		
		/**
		 * Called when a key is released
		 */
		private function keyUpHandler(event:KeyboardEvent):void {
			if(event.keyCode == Keyboard.F3) {
				_clearButton.enabled = true;
				_registerButton.enabled = true;
				_path.push(Camera3D.getCurrentStateAsObject());
			}
		}
		
		/**
		 * Resizes and replaces the elements
		 */
		private function computePositions():void {
			_addPointButton.y = _captureButton.height + 5;
			_clearButton.height = _clearButton.width = Math.round(_addPointButton.y + _addPointButton.height);
			_captureButton.width = _addPointButton.width = Math.round(_width - _clearButton.width - 5);
			_clearButton.x = _captureButton.width + 5;
			
			_registerButton.width = _nameInput.width = _clearButton.x + _clearButton.width;
			_nameInput.y = _clearButton.y + _clearButton.height + 5;
			_registerButton.y = _nameInput.y + _nameInput.height + 5;
			
			_scrollpane.y = _registerButton.y + _registerButton.height + 15;
			
//			_visits.y = _addPointButton.y + _addPointButton.height + 5;
			
			roundPos(_captureButton, _addPointButton, _clearButton);
		}
		
		/**
		 * Called when a component is rolled over
		 */
		private function rollHandler(event:MouseEvent):void {
			if(_buttonToTooltip[event.target] != null) {
				Sprite(event.target).dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, _buttonToTooltip[event.target], ToolTipAlign.TOP_LEFT, 0));
			}
		}
		
		/**
		 * Called when a component is clicked
		 */
		private function clickNewHandler(event:MouseEvent):void {
			if(event.target == _captureButton) {
				_registering = !_registering;
				
				if(_registering) {
					_captureButton.text = "Terminer la capture";
					_timerIcon.innerMc.play();
					Camera3D.setPath( _path );
					addEventListener(Event.ENTER_FRAME, enterFrameHandler);
					enterFrameHandler();
				}else{
					_captureButton.text = "Capturer mes déplacements";
					_timerIcon.innerMc.gotoAndStop(1);
					removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				}
				computePositions();
				
			}else
			if(event.target == _clearButton) {
				_path = [];
				_prevPos = null;
				Camera3D.path = _path;
				_clearButton.enabled = false;
				_registerButton.enabled = false;
				
			}else
			if(event.target == _addPointButton) {
				_path.push(Camera3D.getCurrentStateAsObject());
				_clearButton.enabled = true;
				_registerButton.enabled = true;
				
			}else
			if(event.target == _registerButton) {
				_map.addCameraPath(_path, isEmpty(_nameInput.value)? Label.getLabel("toolConfig-campath-defaultName") : _nameInput.text);
				updateList();
				computePositions();
				dispatchEvent(new Event(Event.RESIZE));
			}
			
		}
		
		/**
		 * Called on ENTER_FRAME event to capture the camera's displacement
		 */
		private function enterFrameHandler(event:Event = null):void {
			var newPos:Point3D = new Point3D(Camera3D.px, Camera3D.py, Camera3D.pz);
			if(_prevPos != null) {
				if(_prevPos.distance(newPos) > ChunkData.CUBE_SIZE_RATIO * 3) {
					_path.push( Camera3D.getCurrentStateAsObject() );
					_prevPos = newPos;
					_clearButton.enabled = true;
					_registerButton.enabled = true;
				}
			}else{
				_prevPos = newPos;
			}
		}
		
		/**
		 * Updates the paths list.
		 */
		private function updateList():void {
			while(_listHolder.content.numChildren > 0) {
				if(_listHolder.content.getChildAt(0) is Disposable) Disposable(_listHolder.content.getChildAt(0)).dispose();
				_listHolder.content.getChildAt(0).removeEventListener(Event.CLEAR, deleteItemHandler);
				_listHolder.content.removeChildAt(0);
			}
			
			var paths:Array = _map.cameraPaths;
			var i:int, len:int, item:CamPathEntry, py:int;
			
			if(paths != null) {
				len = paths.length;
				for(i = 0; i < len; ++i) {
					item = new CamPathEntry(paths[i], i);
					item.width = _width;
					item.addEventListener(Event.CLEAR, deleteItemHandler);
					_listHolder.addChild(item);
					item.y = py;
					py += item.height + 1;
				}
				_scrollpane.height = Math.min(len == 0? 0 : item.height * 13, py);
			}else{
				_scrollpane.height = 0;
			}
		}
		
		/**
		 * Called when an item is deleted
		 */
		private function deleteItemHandler(event:Event):void {
			var data:Object = CamPathEntry(event.currentTarget).data;
			var i:int, len:int;
			len = _map.cameraPaths.length;
			for(i = 0; i < len; ++i) {
				if(_map.cameraPaths[i] == data) {
					_map.cameraPaths.splice(i, 1);
					break;
				}
			}
			updateList();
		}
		
	}
}