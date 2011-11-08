package com.muxxu.kub3dit.views {
	import flash.filters.DropShadowFilter;
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
		private var _eraseMode:Boolean;
		private var _kubeSelector:KubeSelectorView;
		
		
		
		
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
				_kubeSelector.update(event);
				_grid.currentKube = model.currentKubeId;
				computePositions();
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
			_kubeSelector = addChild(new KubeSelectorView()) as KubeSelectorView;
			
			stage.addEventListener(Event.RESIZE, computePositions);
			_tools.addEventListener(ToolsPanelEvent.OPEN_PANEL, openConfigPanelHandler);
			_tools.addEventListener(ToolsPanelEvent.SELECT_TOOL, selectToolHandler);
			_tools.addEventListener(ToolsPanelEvent.ERASE_MODE_CHANGE, eraseModeChangeHandler);
			
			_tools.init();//kind of dirty... this is used to be sure to listen for the event before they are fired.
			
			_background.filters = [new DropShadowFilter(2, 135, 0, .2, 2, 2, 1, 2)];
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			_grid.x = Math.round(_tools.width + 10);
			_grid.y = 5;
			_tools.x = 5;
			_tools.y = 5;
			
			_kubeSelector.width = Math.round(_grid.x + _grid.width - 5);
			_kubeSelector.x = 5;
			_kubeSelector.y = Math.max(_tools.height, _grid.height) + 15;
			
			_background.width = Math.round(_grid.x + _grid.width + 5);
			_background.height = Math.round(_kubeSelector.y + _kubeSelector.height) + 10;
			
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
			_currentPanel.eraseMode = _eraseMode;
			_grid.currentPanel = _currentPanel;
		}
		
		/**
		 * Called when the erase mode changes
		 */
		private function eraseModeChangeHandler(event:ToolsPanelEvent):void {
			_eraseMode = _tools.eraseMode;
			_currentPanel.eraseMode = _tools.eraseMode;
		}
		
	}
}