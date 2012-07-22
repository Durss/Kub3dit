package com.muxxu.kub3dit.components.form {
	import flash.filters.ColorMatrixFilter;
	import gs.TweenLite;

	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.components.form.input.InputKube;
	import com.muxxu.kub3dit.controler.FrontControler;
	import com.muxxu.kub3dit.events.LightModelEvent;
	import com.muxxu.kub3dit.events.ToolTipEvent;
	import com.muxxu.kub3dit.graphics.SubmitIcon;
	import com.muxxu.kub3dit.graphics.UpdateIcon;
	import com.muxxu.kub3dit.graphics.UploadIcon;
	import com.muxxu.kub3dit.model.Model;
	import com.muxxu.kub3dit.vo.ToolTipAlign;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.environnement.label.Label;

	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.ByteArray;
	
	[Event(name="resize", type="flash.events.Event")]
	
	/**
	 * @author Francois
	 * @date 1 janv. 2012;
	 */
	public class UploadForm extends Sprite {
		
		private const _MAX_SIZE:int = 100 * 1024;
		
		private var _uploadBt:ButtonKube;
		private var _submitIcon:SubmitIcon;
		private var _uploadIcon:UploadIcon;
		private var _mapUrl:String;
		private var _width:Number;
		private var _mapSize:uint;
		private var _protectCB:CheckBoxKube;
		private var _modifyCB:CheckBoxKube;
		private var _passInput:InputKube;
		private var _passLabel:CssTextField;
		private var _updateBt:ButtonKube;
		private var _mapId:String;
		private var _editableMap:Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>UploadForm</code>.
		 */
		public function UploadForm() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Sets the model's reference.
		 */
		public function set model(value:Model):void {
			value.addEventListener(LightModelEvent.MAP_UPLOAD_ERROR, uploadMapErrorHandler);
			value.addEventListener(LightModelEvent.MAP_UPLOAD_COMPLETE, uploadMapCompleteHandler);
			value.addEventListener(LightModelEvent.SAVE_MAP_GENERATION_COMPLETE, saveMapCompleteHandler);
		}
		
		/**
		 * Sets the width of the component without simply scaling it.
		 */
		override public function set width(value:Number):void {
			_width = value;
			computePositions();
		}
		/**
		 * Specifies if the last loaded map is editable or not.
		 */
		public function set editableMap(value:Boolean):void {
			_editableMap = value;
			addChild(_updateBt);
			if(!value) removeChild(_updateBt);
			computePositions();
		}
		
		/**
		 * Sets the map's ID
		 */
		public function set mapId(value:String):void {
			_mapId = value;
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
			_uploadIcon = new UploadIcon();
			_submitIcon = new SubmitIcon();
			_uploadBt = addChild(new ButtonKube(Label.getLabel("prompt-mapUpload"), true, _uploadIcon)) as ButtonKube;
			_modifyCB = addChild(new CheckBoxKube(Label.getLabel("prompt-mapUploadModify"))) as CheckBoxKube;
			_protectCB = addChild(new CheckBoxKube(Label.getLabel("prompt-mapUploadProtect"))) as CheckBoxKube;
			_passLabel = addChild(new CssTextField("checkBox")) as CssTextField;
			_passInput = addChild(new InputKube()) as InputKube;
			_updateBt = new ButtonKube(Label.getLabel("prompt-mapUpdate"), true, new UpdateIcon());
			
			_passLabel.text = Label.getLabel("prompt-mapUploadProtectPass");
			_passInput.textfield.restrict = "0-9A-Za-z*$_-#!";
			_passInput.textfield.maxChars = 30;
			
			_passInput.enabled = false;
			_passLabel.alpha = .4;
			
			_modifyCB.selected = true;
			
			//Green color
			var m:Array = [0.6467894315719604, 1.1897121667861938, -0.8365015983581543, 0, 0,
							0.013973236083984375, 0.6644432544708252, 0.32158347964286804, 0, 0,
							0.9033367037773132, -0.177803635597229, 0.27446693181991577, 0, 0,
							0, 0, 0, 1, 0];
			_updateBt.filters = [new ColorMatrixFilter(m)];
			
			_uploadBt.addEventListener(MouseEvent.ROLL_OVER, overUploadHandler);
			_protectCB.addEventListener(Event.CHANGE, toggleProtectHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_modifyCB.y = 2;
			_modifyCB.x = _protectCB.x = 2;
			_protectCB.y = Math.round(_modifyCB.y + _modifyCB.height + 3);
			_passLabel.y = _passInput.y = _protectCB.y - 2;
			_passLabel.x = Math.round(_protectCB.width + 15);
			_passInput.x = Math.round(_passLabel.x + _passLabel.width);
			_passInput.width = _width - _passInput.x - 2;
			
			var h:int = _passInput.y + _passInput.height + 5;
			
			_uploadBt.width = _updateBt.width = _width;
			_uploadBt.y = h;
			_updateBt.y = Math.round(h + _uploadBt.height + 5);
			
			graphics.beginFill(0x265367, 1);
			graphics.drawRect(0, 0, _width, 1);
			graphics.drawRect(0, 0, 1, h);
			graphics.drawRect(_width-1, 0, 1, h);
			graphics.beginFill(0x69B9DA, 1);
			graphics.drawRect(1, 1, _width - 2, h - 1);
			graphics.endFill();
		}
		
		
		
		//__________________________________________________________ BUTTONS HANDLERS
		
		/**
		 * Called when disable layer is clicked.
		 * Closes the view.
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target == _uploadBt) {
				mouseEnabled = mouseChildren = tabEnabled = tabChildren = false;
				if(_uploadBt.icon == _uploadIcon) {
					FrontControler.getInstance().uploadMap(_modifyCB.selected, _protectCB.selected? _passInput.text : "");
				}else{
					Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, Config.getVariable("shareUrl").replace(/\{ID\}/gi, _mapUrl));
				}
			}else if(event.target == _updateBt) {
				FrontControler.getInstance().updateUploadedMap(_mapId);
				mouseEnabled = mouseChildren = tabEnabled = tabChildren = false;
			}
		}
		
		/**
		 * Toggles the protection mode
		 */
		private function toggleProtectHandler(event:Event):void {
			_passInput.enabled = _protectCB.selected;
			_passLabel.alpha = _protectCB.selected? 1 : .4;
		}
		
		/**
		 * Called when map file genereration completes.
		 */
		private function saveMapCompleteHandler(event:LightModelEvent):void {
			mouseEnabled = mouseChildren = tabEnabled = tabChildren = true;
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
			}else{
				_uploadBt.dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, Label.getLabel("prompt-mapUploadHelp"), ToolTipAlign.TOP));
			}
		}
		
		
		
		//__________________________________________________________ UPLOAD HANDLERS
		
		/**
		 * Called when map's upload completes
		 */
		private function uploadMapCompleteHandler(event:LightModelEvent):void {
			mouseEnabled = mouseChildren = tabEnabled = tabChildren = true;
			_mapUrl = event.data as String;
			_uploadBt.icon = _submitIcon;
			_uploadBt.label = Label.getLabel("prompt-mapUploadCopyLink");
			editableMap = _modifyCB.selected;
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		/**
		 * Called if map upload fails
		 */
		private function uploadMapErrorHandler(event:LightModelEvent):void {
			mouseEnabled = mouseChildren = tabEnabled = tabChildren = true;
		}
		
	}
}