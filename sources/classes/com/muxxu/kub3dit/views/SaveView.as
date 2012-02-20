package com.muxxu.kub3dit.views {
	import com.muxxu.kub3dit.commands.ISaveView;
	import gs.TweenLite;

	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.components.form.UploadForm;
	import com.muxxu.kub3dit.components.window.PromptWindow;
	import com.muxxu.kub3dit.controler.FrontControler;
	import com.muxxu.kub3dit.events.LightModelEvent;
	import com.muxxu.kub3dit.graphics.DownloadIcon;
	import com.muxxu.kub3dit.graphics.LevelsIcon;
	import com.muxxu.kub3dit.model.Model;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * 
	 * @author Francois
	 * @date 11 déc. 2011;
	 */
	public class SaveView extends AbstractView implements ISaveView {
		
		private var _window:PromptWindow;
		private var _content:Sprite;
		private var _disableLayer:Sprite;
		private var _downloadBt:DisplayObject;
		private var _levelsBt:ButtonKube;
		private var _uploadForm:UploadForm;
		private var _editableMap:Boolean;
		private var _mapId:String;
		private var _initialized:Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>DownloadView</code>.
		 */
		public function SaveView() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Specifies if the last loaded map is editable or not.
		 * 
		 * FIXME This way to define if a map is editable or not will have to be
		 * modified if someday i add an option to create a new map without
		 * reloading the whole application.
		 */
		public function set editableMap(value:Boolean):void {
			_editableMap = value;
			_uploadForm.editableMap = value;
			computePositions();
		}
		
		/**
		 * Sets the map's ID
		 */
		public function set mapId(value:String):void {
			_mapId = value;
			_uploadForm.mapId = value;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:Model = event.model as Model;
			if(!_initialized) {
				_initialized = true;
				_uploadForm.model = model;
				model.addEventListener(LightModelEvent.SAVE_MAP_GENERATION_COMPLETE, saveMapCompleteHandler);
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			alpha = 0;
			visible = false;
			_disableLayer = addChild(new Sprite()) as Sprite;
			_content	= new Sprite();
			_levelsBt	= _content.addChild(new ButtonKube(Label.getLabel("prompt-mapDownloadLevels"), true, new LevelsIcon())) as ButtonKube;
			_downloadBt	= _content.addChild(new ButtonKube(Label.getLabel("prompt-mapDownload"), true, new DownloadIcon())) as ButtonKube;
			_uploadForm	= _content.addChild(new UploadForm()) as UploadForm;
			
			_levelsBt.width = _downloadBt.width = _uploadForm.width = 250;
			
			_window = addChild(new PromptWindow(Label.getLabel("prompt-mapSave"), _content)) as PromptWindow;
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		/**
		 * Called when disable layer is clicked.
		 * Closes the view.
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target == _disableLayer) {
				TweenLite.to(this, .25, {autoAlpha:0});
			}else if(event.target == _downloadBt) {
				FrontControler.getInstance().downloadMap();
			}else if(event.target == _levelsBt) {
				FrontControler.getInstance().downloadMapLevels();
			}
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			computePositions();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			PosUtils.vPlaceNext(5, _levelsBt, _downloadBt, _uploadForm);
			_window.updateSizes();
			PosUtils.centerInStage(_window);
			_disableLayer.graphics.clear();
			_disableLayer.graphics.beginFill(0xffffff, .5);
			_disableLayer.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			_disableLayer.graphics.endFill();
		}
		
		/**
		 * Called when map file genereration completes.
		 */
		private function saveMapCompleteHandler(event:LightModelEvent):void {
			TweenLite.to(this, .25, {autoAlpha:1});
		}
		
	}
}