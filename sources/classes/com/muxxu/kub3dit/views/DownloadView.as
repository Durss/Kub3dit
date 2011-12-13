package com.muxxu.kub3dit.views {
	import com.muxxu.kub3dit.graphics.LevelsIcon;
	import gs.TweenLite;

	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.components.window.PromptWindow;
	import com.muxxu.kub3dit.controler.FrontControler;
	import com.muxxu.kub3dit.events.LightModelEvent;
	import com.muxxu.kub3dit.events.ToolTipEvent;
	import com.muxxu.kub3dit.graphics.DownloadIcon;
	import com.muxxu.kub3dit.graphics.SubmitIcon;
	import com.muxxu.kub3dit.graphics.UploadIcon;
	import com.muxxu.kub3dit.model.Model;
	import com.muxxu.kub3dit.vo.ToolTipAlign;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.pos.PosUtils;

	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.ByteArray;

	/**
	 * 
	 * @author Francois
	 * @date 11 déc. 2011;
	 */
	public class DownloadView extends AbstractView {
		
		private const _MAX_SIZE:int = 100 * 1024;
		
		private var _window:PromptWindow;
		private var _content:Sprite;
		private var _disableLayer:Sprite;
		private var _downloadBt:DisplayObject;
		private var _uploadBt:ButtonKube;
		private var _mapSize:uint;
		private var _uploadIcon:UploadIcon;
		private var _submitIcon:SubmitIcon;
		private var _mapUrl:String;
		private var _levelsBt:ButtonKube;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>DownloadView</code>.
		 */
		public function DownloadView() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:Model = event.model as Model;
			model.addEventListener(LightModelEvent.MAP_UPLOAD_COMPLETE, uploadMapCompleteHandler);
			model.addEventListener(LightModelEvent.SAVE_MAP_GENERATION_COMPLETE, saveMapCompleteHandler);
			ViewLocator.getInstance().removeView(this);
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
			alpha = 0;
			visible = false;
			_uploadIcon = new UploadIcon();
			_submitIcon = new SubmitIcon();
			_disableLayer = addChild(new Sprite()) as Sprite;
			_content = new Sprite();
			_levelsBt = _content.addChild(new ButtonKube(Label.getLabel("prompt-mapDownloadLevels"), true, new LevelsIcon())) as ButtonKube;
			_downloadBt = _content.addChild(new ButtonKube(Label.getLabel("prompt-mapDownload"), true, new DownloadIcon())) as ButtonKube;
			_uploadBt = _content.addChild(new ButtonKube(Label.getLabel("prompt-mapUpload"), true, _uploadIcon)) as ButtonKube;
			
			_levelsBt.width = _downloadBt.width = _uploadBt.width = 250;
			PosUtils.vPlaceNext(5, _levelsBt, _downloadBt, _uploadBt);
			
			_window = addChild(new PromptWindow(Label.getLabel("prompt-mapSave"), _content)) as PromptWindow;
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
			_uploadBt.addEventListener(MouseEvent.ROLL_OVER, overUploadHandler);
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
			}else if(event.target == _uploadBt) {
				if(_uploadBt.icon == _uploadIcon) {
					FrontControler.getInstance().uploadMap();
				}else{
					Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, Config.getVariable("shareUrl").replace(/\{ID\}/gi, _mapUrl));
				}
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
			_uploadBt.icon = _uploadIcon;
			_uploadBt.label = Label.getLabel("prompt-mapUpload");
			TweenLite.to(this, .25, {autoAlpha:1});
			_mapSize = ByteArray(event.data).length;
			_uploadBt.enabled = _mapSize < _MAX_SIZE;
			_uploadBt.mouseEnabled = true;//To be able to open the tooltip when mouse is over
		}
		
		/**
		 * Called when upload button is rolled over.
		 * Displays a tooltip if it's disabled
		 */
		private function overUploadHandler(event:MouseEvent):void {
			if (!_uploadBt.enabled) {
				var label:String = Label.getLabel("prompt-mapUploadInfo");
				label = label.replace(/\{SIZE_MAX\}/gi, Math.round(_MAX_SIZE/1024));
				label = label.replace(/\{SIZE\}/gi, Math.round(_mapSize/1024));
				_uploadBt.dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, label, ToolTipAlign.TOP));
			}
		}
		
		/**
		 * Called when map's upload completes
		 */
		private function uploadMapCompleteHandler(event:LightModelEvent):void {
			_mapUrl = event.data as String;
			_uploadBt.icon = _submitIcon;
			_uploadBt.label = Label.getLabel("prompt-mapUploadCopyLink");
		}
		
	}
}