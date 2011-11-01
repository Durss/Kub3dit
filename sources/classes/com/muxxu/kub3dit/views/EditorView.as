package com.muxxu.kub3dit.views {
	import com.muxxu.kub3dit.components.editor.toolpanels.IToolPanel;
	import com.muxxu.kub3dit.events.ToolsPanelEvent;
	import com.muxxu.kub3dit.components.editor.ConfigToolPanel;
	import com.muxxu.kub3dit.components.editor.Grid;
	import com.muxxu.kub3dit.components.editor.ToolsPanel;
	import com.muxxu.kub3dit.graphics.EditorBackgroundGraphic;
	import com.muxxu.kub3dit.model.Model;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.pos.PosUtils;

	import flash.events.Event;

	/**
	 * 
	 * @author Francois
	 * @date 30 oct. 2011;
	 */
	public class EditorView extends AbstractView {
		
		private var _grid:Grid;
		private var _ready:Boolean;
		private var _background:EditorBackgroundGraphic;
		private var _tools:ToolsPanel;
		private var _config:ConfigToolPanel;
		private var _currentPanel:IToolPanel;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>EditorView</code>.
		 */
		public function EditorView() {
			
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:Model = event.model as Model;
			if(!_ready) {
				_ready = true;
				initialize();
				_grid.currentKube = model.currentKubeId;
			}
		}
		
		override public function get width():Number {
			return _background.width;
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
			_background = addChild(new EditorBackgroundGraphic()) as EditorBackgroundGraphic;
			_grid = addChild(new Grid()) as Grid;
			_config = addChild(new ConfigToolPanel()) as ConfigToolPanel;
			_tools = addChild(new ToolsPanel()) as ToolsPanel;
			
			stage.addEventListener(Event.RESIZE, computePositions);
			_tools.addEventListener(ToolsPanelEvent.OPEN_PANEL, openConfigPanelHandler);
			_tools.addEventListener(ToolsPanelEvent.SELECT_TOOL, selectToolHandler);
			_tools.addEventListener(ToolsPanelEvent.ERASE_MODE_CHANGE, eraseModeChangeHandler);
			
			_tools.init();//kind of dirty... this is used to be sure to listen for the event before they are fired.
			
			computePositions();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			_background.width = Math.round(_tools.width + 15 + _grid.width);
			_background.height = Math.max(_tools.height, _grid.height, 10) + 10;
			_grid.x = Math.round(_tools.width + 10);
			_grid.y = 5;
			_tools.x = 5;
			_tools.y = 5;
			
			_config.width = _grid.width;
			_config.x = _grid.x;
			_config.y = _grid.y;
			
			PosUtils.alignToRightOf(this, stage);
		}
		
		/**
		 * Called when the tools panel asks for a config panel opening
		 */
		private function openConfigPanelHandler(event:ToolsPanelEvent):void {
			_config.open();
		}
		
		/**
		 * Called when a new tool is selected
		 */
		private function selectToolHandler(event:ToolsPanelEvent):void {
			_config.close();
			_currentPanel = _config.setPanelType(event.panelType);
			_grid.currentPanel = _currentPanel;
		}
		
		/**
		 * Called when the erase mode changes
		 */
		private function eraseModeChangeHandler(event:ToolsPanelEvent):void {
			_currentPanel.eraseMode = _tools.eraseMode;
		}
		
	}
}