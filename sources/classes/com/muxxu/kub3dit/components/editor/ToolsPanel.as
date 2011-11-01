package com.muxxu.kub3dit.components.editor {
	import com.muxxu.kub3dit.components.editor.toolpanels.SpherePanel;
	import com.muxxu.kub3dit.components.editor.toolpanels.CubePanel;
	import com.nurun.utils.vector.VectorUtils;
	import com.muxxu.kub3dit.components.buttons.ButtonEditorTool;
	import com.muxxu.kub3dit.components.buttons.ButtonHelp;
	import com.muxxu.kub3dit.components.editor.toolpanels.CirclePanel;
	import com.muxxu.kub3dit.components.editor.toolpanels.DiskPanel;
	import com.muxxu.kub3dit.components.editor.toolpanels.FilledRectanglePanel;
	import com.muxxu.kub3dit.components.editor.toolpanels.PencilPanel;
	import com.muxxu.kub3dit.components.editor.toolpanels.RectanglePanel;
	import com.muxxu.kub3dit.events.ButtonEditorToolEvent;
	import com.muxxu.kub3dit.events.ToolsPanelEvent;
	import com.muxxu.kub3dit.graphics.RubberIcon;
	import com.muxxu.kub3dit.graphics.Tool1Icon;
	import com.muxxu.kub3dit.graphics.Tool2Icon;
	import com.muxxu.kub3dit.graphics.Tool3Icon;
	import com.muxxu.kub3dit.graphics.Tool4Icon;
	import com.muxxu.kub3dit.graphics.Tool5Icon;
	import com.muxxu.kub3dit.graphics.Tool6Icon;
	import com.muxxu.kub3dit.graphics.Tool7Icon;
	import com.muxxu.kub3dit.graphics.Tool8Icon;
	import com.nurun.components.form.FormComponentGroup;
	import com.nurun.components.form.events.FormComponentGroupEvent;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	[Event(name="openPanel", type="com.muxxu.kub3dit.events.ToolsPanelEvent")]
	[Event(name="selectTool", type="com.muxxu.kub3dit.events.ToolsPanelEvent")]
	[Event(name="eraseModeChange", type="com.muxxu.kub3dit.events.ToolsPanelEvent")]
	
	/**
	 * Displays the tools buttons.
	 * 
	 * @author Francois
	 * @date 31 oct. 2011;
	 */
	public class ToolsPanel extends Sprite {
		
		private var _rubber:ButtonEditorTool;
		private var _pencil:ButtonEditorTool;
		private var _bucket:ButtonEditorTool;
		private var _circle:ButtonEditorTool;
		private var _disk:ButtonEditorTool;
		private var _rect:ButtonEditorTool;
		private var _rectf:ButtonEditorTool;
		private var _helpBt:ButtonHelp;
		private var _group:FormComponentGroup;
		private var _tools:Vector.<ButtonEditorTool>;
		private var _buttonToClassType:Dictionary;
		private var _cube:ButtonEditorTool;
		private var _sphere:ButtonEditorTool;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ToolsPanel</code>.
		 */
		public function ToolsPanel() {
			
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets if the rubber is selected.
		 */
		public function get eraseMode():Boolean {
			return _rubber.selected;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Initialize the class.
		 */
		public function init():void {
			initialize();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_rubber	= addChild(new ButtonEditorTool( new RubberIcon(), false )) as ButtonEditorTool;
			_pencil	= addChild(new ButtonEditorTool( new Tool1Icon(), true )) as ButtonEditorTool;
			_bucket	= addChild(new ButtonEditorTool( new Tool2Icon(), false )) as ButtonEditorTool;
			_circle	= addChild(new ButtonEditorTool( new Tool3Icon(), true )) as ButtonEditorTool;
			_disk	= addChild(new ButtonEditorTool( new Tool4Icon(), true )) as ButtonEditorTool;
			_rect	= addChild(new ButtonEditorTool( new Tool5Icon(), true )) as ButtonEditorTool;
			_rectf	= addChild(new ButtonEditorTool( new Tool6Icon(), true )) as ButtonEditorTool;
			_cube	= addChild(new ButtonEditorTool( new Tool7Icon(), true )) as ButtonEditorTool;
			_sphere	= addChild(new ButtonEditorTool( new Tool8Icon(), true )) as ButtonEditorTool;
			_helpBt	= addChild(new ButtonHelp( Label.getLabel("helpTools") )) as ButtonHelp;
			
			_group = new FormComponentGroup();
			_tools = new Vector.<ButtonEditorTool>();
			_tools.push(_pencil);
			_tools.push(_bucket);
			_tools.push(_circle);
			_tools.push(_disk);
			_tools.push(_rect);
			_tools.push(_rectf);
			_tools.push(_cube);
			_tools.push(_sphere);
			
			_buttonToClassType = new Dictionary();
			_buttonToClassType[_pencil] = PencilPanel;
			_buttonToClassType[_circle] = CirclePanel;
			_buttonToClassType[_disk] = DiskPanel;
			_buttonToClassType[_rect] = RectanglePanel;
			_buttonToClassType[_rectf] = FilledRectanglePanel;
			_buttonToClassType[_cube] = CubePanel;
			_buttonToClassType[_sphere] = SpherePanel;
			
			var i:int, len:int;
			len = _tools.length;
			for(i = 0; i < len; ++i) {
				_group.add( _tools[i] );
				_tools[i].addEventListener(ButtonEditorToolEvent.CLICK, toolClickedHandler);
			}
			
			_helpBt.width = _helpBt.height = 20;
			_group.addEventListener(FormComponentGroupEvent.CHANGE, changeToolHandler);
			_rubber.addEventListener(Event.CHANGE, changeEraseModeHandler);
			
			var clazz:Class = _buttonToClassType[_group.selectedItem];
			dispatchEvent(new ToolsPanelEvent(ToolsPanelEvent.SELECT_TOOL, clazz));
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			var margin:int = 10;
			_pencil.y = _rubber.height + margin;
			PosUtils.vPlaceNext(0, VectorUtils.toArray(_tools));
			var last:ButtonEditorTool = _tools[ _tools.length - 1 ];
			_helpBt.y = Math.round(last.y + last.height + 10);
		}
		
		/**
		 * Called when a new tool is selected
		 */
		private function changeToolHandler(event:FormComponentGroupEvent):void {
			var clazz:Class = _buttonToClassType[event.selectedItem];
			if(clazz != null) {
				dispatchEvent(new ToolsPanelEvent(ToolsPanelEvent.SELECT_TOOL, clazz));
			}
		}
		
		/**
		 * Called when a tool button is clicked.
		 * Detect if the configuration panel has to be opened or not.
		 */
		private function toolClickedHandler(event:ButtonEditorToolEvent):void {
			if(event.openConfig) {
				dispatchEvent(new ToolsPanelEvent(ToolsPanelEvent.OPEN_PANEL));
			}
		}
		
		/**
		 * Called when the rubber is clicked.
		 */
		private function changeEraseModeHandler(event:Event):void {
			dispatchEvent(new ToolsPanelEvent(ToolsPanelEvent.ERASE_MODE_CHANGE));
		}
		
	}
}