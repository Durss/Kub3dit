package com.muxxu.kub3dit.components.editor {
	import com.muxxu.kub3dit.components.buttons.ButtonEditorTool;
	import com.muxxu.kub3dit.components.buttons.ButtonHelp;
	import com.muxxu.kub3dit.components.editor.toolpanels.BucketPanel;
	import com.muxxu.kub3dit.components.editor.toolpanels.CamPathPanel;
	import com.muxxu.kub3dit.components.editor.toolpanels.CirclePanel;
	import com.muxxu.kub3dit.components.editor.toolpanels.CubePanel;
	import com.muxxu.kub3dit.components.editor.toolpanels.ImageGenPanel;
	import com.muxxu.kub3dit.components.editor.toolpanels.ImportPanel;
	import com.muxxu.kub3dit.components.editor.toolpanels.PencilPanel;
	import com.muxxu.kub3dit.components.editor.toolpanels.PipetaPanel;
	import com.muxxu.kub3dit.components.editor.toolpanels.RectanglePanel;
	import com.muxxu.kub3dit.components.editor.toolpanels.ReplacePanel;
	import com.muxxu.kub3dit.components.editor.toolpanels.SelectionPanel;
	import com.muxxu.kub3dit.components.editor.toolpanels.SpherePanel;
	import com.muxxu.kub3dit.components.editor.toolpanels.TerragenPanel;
	import com.muxxu.kub3dit.events.ButtonEditorToolEvent;
	import com.muxxu.kub3dit.events.ToolsPanelEvent;
	import com.muxxu.kub3dit.graphics.CamPathIcon;
	import com.muxxu.kub3dit.graphics.ImageIcon;
	import com.muxxu.kub3dit.graphics.ImportIcon;
	import com.muxxu.kub3dit.graphics.ReplaceIcon;
	import com.muxxu.kub3dit.graphics.RubberIcon;
	import com.muxxu.kub3dit.graphics.SelectionIcon;
	import com.muxxu.kub3dit.graphics.TerragenIcon;
	import com.muxxu.kub3dit.graphics.Tool1Icon;
	import com.muxxu.kub3dit.graphics.Tool2Icon;
	import com.muxxu.kub3dit.graphics.Tool3Icon;
	import com.muxxu.kub3dit.graphics.Tool5Icon;
	import com.muxxu.kub3dit.graphics.Tool7Icon;
	import com.muxxu.kub3dit.graphics.Tool8Icon;
	import com.muxxu.kub3dit.graphics.Tool9Icon;
	import com.muxxu.kub3dit.vo.KeyboardConfigs;
	import com.nurun.components.form.FormComponentGroup;
	import com.nurun.components.form.events.FormComponentGroupEvent;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.vector.VectorUtils;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
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
		private var _rect:ButtonEditorTool;
		private var _helpBt:ButtonHelp;
		private var _group:FormComponentGroup;
		private var _tools:Vector.<ButtonEditorTool>;
		private var _buttonToClassType:Dictionary;
		private var _cube:ButtonEditorTool;
		private var _sphere:ButtonEditorTool;
		private var _import:ButtonEditorTool;
		private var _select:ButtonEditorTool;
		private var _imgBt:ButtonEditorTool;
		private var _replace:ButtonEditorTool;
		private var _pipeta:ButtonEditorTool;
		private var _terragN:ButtonEditorTool;
		private var _camPath:ButtonEditorTool;
		
		
		
		
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
			_rubber	= addChild(new ButtonEditorTool( new RubberIcon(), false, Label.getLabel("helpToolsRubber"))) as ButtonEditorTool;
			_pencil	= addChild(new ButtonEditorTool( new Tool1Icon(), true, Label.getLabel("helpTools1") )) as ButtonEditorTool;
			_bucket	= addChild(new ButtonEditorTool( new Tool2Icon(), false, Label.getLabel("helpTools2") )) as ButtonEditorTool;
			_circle	= addChild(new ButtonEditorTool( new Tool3Icon(), true, Label.getLabel("helpTools3") )) as ButtonEditorTool;
			_rect	= addChild(new ButtonEditorTool( new Tool5Icon(), true, Label.getLabel("helpTools5") )) as ButtonEditorTool;
			_cube	= addChild(new ButtonEditorTool( new Tool7Icon(), true, Label.getLabel("helpTools7") )) as ButtonEditorTool;
			_sphere	= addChild(new ButtonEditorTool( new Tool8Icon(), true, Label.getLabel("helpTools8") )) as ButtonEditorTool;
			_pipeta	= addChild(new ButtonEditorTool( new Tool9Icon(), false, Label.getLabel("helpTools9") )) as ButtonEditorTool;
			_import	= addChild(new ButtonEditorTool( new ImportIcon(), false, Label.getLabel("helpToolsImport"), true)) as ButtonEditorTool;
			_imgBt	= addChild(new ButtonEditorTool( new ImageIcon(), false, Label.getLabel("helpToolsImg"), true)) as ButtonEditorTool;
			_select	= addChild(new ButtonEditorTool( new SelectionIcon(), false, Label.getLabel("helpToolsSelect"), true)) as ButtonEditorTool;
			_replace= addChild(new ButtonEditorTool( new ReplaceIcon(), false, Label.getLabel("helpToolsReplace"), true)) as ButtonEditorTool;
			_camPath= addChild(new ButtonEditorTool( new CamPathIcon(), false, Label.getLabel("helpToolsCamPath"), true)) as ButtonEditorTool;
			_terragN= addChild(new ButtonEditorTool( new TerragenIcon(), false, Label.getLabel("helpToolsTerragen"), true)) as ButtonEditorTool;
			_helpBt	= addChild(new ButtonHelp( Label.getLabel("helpTools") )) as ButtonHelp;
			
			_group = new FormComponentGroup();
			_tools = new Vector.<ButtonEditorTool>();
			_tools.push(_pencil);
			_tools.push(_bucket);
			_tools.push(_circle);
			_tools.push(_rect);
			_tools.push(_cube);
			_tools.push(_sphere);
			_tools.push(_pipeta);
			_tools.push(_import);
			_tools.push(_imgBt);
			_tools.push(_select);
			_tools.push(_replace);
			_tools.push(_camPath);
			_tools.push(_terragN);
			
//			_select.enabled = false;
			
			_buttonToClassType = new Dictionary();
			_buttonToClassType[_pencil] = PencilPanel;
			_buttonToClassType[_bucket] = BucketPanel;
			_buttonToClassType[_circle] = CirclePanel;
			_buttonToClassType[_rect] = RectanglePanel;
			_buttonToClassType[_cube] = CubePanel;
			_buttonToClassType[_sphere] = SpherePanel;
			_buttonToClassType[_pipeta] = PipetaPanel;
			_buttonToClassType[_import] = ImportPanel;
			_buttonToClassType[_imgBt] = ImageGenPanel;
			_buttonToClassType[_select] = SelectionPanel;
			_buttonToClassType[_replace] = ReplacePanel;
			_buttonToClassType[_camPath] = CamPathPanel;
			_buttonToClassType[_terragN] = TerragenPanel;
			
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
			
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			
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
			
			var i:int, len:int, add:Boolean;
			len = _tools.length;
			for(i = 0; i < len; ++i) {
				if(_tools[i] == _import) add = true;
				if(add) _tools[i].y += 10;
			}
			
			_helpBt.y = Math.round(last.y + last.height + 10);
		}
		
		/**
		 * Called when a key is released.
		 */
		private function keyUpHandler(event:KeyboardEvent):void {
			if(event.target is TextField) return;
			
			if(event.keyCode == KeyboardConfigs.TOGGLE_ERASE) {
				_rubber.selected = !_rubber.selected;
			}
			if(event.keyCode >= Keyboard.NUMBER_1 && event.keyCode <= Keyboard.NUMBER_9) {
				if(_tools.length > event.keyCode-Keyboard.NUMBER_1) {
					_tools[ event.keyCode-Keyboard.NUMBER_1 ].selected = true;
				}
			}
			if(event.keyCode == Keyboard.M) {
				_select.selected = true;
				dispatchEvent(new ToolsPanelEvent(ToolsPanelEvent.OPEN_PANEL));
			}
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