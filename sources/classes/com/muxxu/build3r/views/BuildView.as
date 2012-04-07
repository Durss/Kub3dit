package com.muxxu.build3r.views {
	import com.muxxu.build3r.components.Build3rSlider;
	import com.muxxu.build3r.components.FlatMap;
	import com.muxxu.build3r.components.IBuild3rMap;
	import com.muxxu.build3r.components.IsoMap;
	import com.muxxu.build3r.controler.FrontControlerBuild3r;
	import com.muxxu.build3r.i18n.LabelBuild3r;
	import com.muxxu.build3r.model.ModelBuild3r;
	import com.muxxu.build3r.vo.Metrics;
	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.events.ToolTipEvent;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.pos.roundPos;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;

	/**
	 * 
	 * @author Francois
	 * @date 20 févr. 2012;
	 */
	public class BuildView extends AbstractView {
		
		private var _slider:Build3rSlider;
		private var _isoView:IsoMap;
		private var _pickupKube:ButtonKube;
		private var _helpBt:ButtonKube;
		private var _targetToLabel:Dictionary;
		private var _changeBt:ButtonKube;
		private var _flatView:FlatMap;
		private var _renderModeBt:ButtonKube;
		private var _renderMode:int;
		private var _views:Vector.<IBuild3rMap>;
		private var _help:CssTextField;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>BuildView</code>.
		 */
		public function BuildView() {
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:ModelBuild3r = event.model as ModelBuild3r;
			if(model.mapReferencePoint != null && model.positionReference != null && model.position != null && model.map != null) {
				visible = true;
				_isoView.update(model.mapReferencePoint, model.positionReference, model.position, model.map);
				_flatView.update(model.mapReferencePoint, model.positionReference, model.position, model.map);
			
				if(model.position != null && !model.autoLoading) {
					_pickupKube.visible = true;
					setTimeout(_pickupKube.hide, 5000);
				}
				updateRenderModeHandler();
			}else if(_views != null){
				visible = false;
				var i:int, len:int;
				len = _views.length;
				for(i = 0; i < len; ++i) {
					if(contains(_views[i] as DisplayObject)) removeChild(_views[i] as DisplayObject);
				}
			}
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
		private function initialize(event:Event):void {
			visible = false;
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			_helpBt = addChild(new ButtonKube(LabelBuild3r.getl("build-helpBt"), false, null, true)) as ButtonKube;
			_changeBt = addChild(new ButtonKube(LabelBuild3r.getl("build-changeHelpBt"), false, null, true)) as ButtonKube;
			_slider = addChild(new Build3rSlider(1, 10)) as Build3rSlider;
			_renderModeBt = addChild(new ButtonKube(LabelBuild3r.getl("build-renderMode-0"), false, null, true)) as ButtonKube;
			_flatView = addChild(new FlatMap()) as FlatMap;
			_isoView = addChild(new IsoMap()) as IsoMap;
			_pickupKube = addChild(new ButtonKube(LabelBuild3r.getl("build-getKube"), false, null, true)) as ButtonKube;
			_help = addChild(new CssTextField("b-help")) as CssTextField;
			
			_renderMode = 0;
			_pickupKube.visible = false;
			_slider.width = Metrics.STAGE_WIDTH;
			_slider.y = Math.round(_helpBt.height) + 5;
			_slider.value = 3;
			_slider.x = Math.round((Metrics.STAGE_WIDTH - _slider.width) * .5);
			_targetToLabel = new Dictionary();
			_targetToLabel[_helpBt] = "build-helpTT";
			_targetToLabel[_changeBt] = "build-changeHelpTT";
			_changeBt.x = _helpBt.width + 5;
			_renderModeBt.x = _changeBt.x + _changeBt.width + 5;
			
			_isoView.y = _slider.y + _slider.height;
			_flatView.y = _isoView.y;
			
			roundPos(_pickupKube, _changeBt, _renderModeBt);
			
			_views = new Vector.<IBuild3rMap>();
			var i:int, len:int = numChildren;
			for(i = 0; i < len; ++i) {
				if(getChildAt(i) is IBuild3rMap) {
					_views.push(getChildAt(i));
					_views[_views.length-1].sizes = _slider.value;
				}
			}
			
			_slider.addEventListener(Event.CHANGE, changeSizeHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			_pickupKube.addEventListener(MouseEvent.CLICK, pickupKubeHandler);
			_helpBt.addEventListener(MouseEvent.ROLL_OVER, overButtonHandler);
			_changeBt.addEventListener(MouseEvent.ROLL_OVER, overButtonHandler);
			_changeBt.addEventListener(MouseEvent.CLICK, clickChangeHandler);
			_renderModeBt.addEventListener(MouseEvent.CLICK, updateRenderModeHandler);
			
			updateRenderModeHandler();
		}
		
		/**
		 *Called when render mode button is clicked.
		 */
		private function updateRenderModeHandler(event:MouseEvent = null):void {
			if(event != null) {
				_renderMode = (_renderMode+1)%2;
				stage.focus = null;
			}
			_renderModeBt.label = LabelBuild3r.getl("build-renderMode-"+_renderMode);
			_slider.maxValue = _renderMode==0? 31 : 10;
			var i:int, len:int;
			len = _views.length;
			for(i = 0; i < len; ++i) {
				if(i == _renderMode) {
					addChild(_views[i] as DisplayObject);
					_slider.value = _views[i].sizes;
				}else if(contains(_views[i] as DisplayObject)) {
					removeChild(_views[i] as DisplayObject);
				}
			}
			if(LabelBuild3r.getl("build-keys-"+_renderMode) == null) {
				_help.text = LabelBuild3r.getl("build-keys");
			}else{
				_help.text = LabelBuild3r.getl("build-keys-"+_renderMode);
			}
			_help.y = Math.floor(Metrics.STAGE_HEIGHT - _help.height);
			PosUtils.hCenterIn(_help, Metrics.STAGE_WIDTH);
			_pickupKube.y = Math.round(Metrics.STAGE_HEIGHT - _pickupKube.height - _help.height + 4);
			PosUtils.hCenterIn(_pickupKube, Metrics.STAGE_WIDTH);
		}
		
		/**
		 * Called when change button is clicked
		 */
		private function clickChangeHandler(event:MouseEvent):void {
			FrontControlerBuild3r.getInstance().clearMap();
		}
		
		/**
		 * Called when a butotn is rolled over.
		 */
		private function overButtonHandler(event:MouseEvent):void {
			var label:String = LabelBuild3r.getl(_targetToLabel[event.currentTarget]);
			EventDispatcher(event.currentTarget).dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, label));
		}
		
		/**
		 * Picks up the kube
		 */
		private function pickupKubeHandler(event:MouseEvent):void {
			FrontControlerBuild3r.getInstance().pickUpKube();
		}
		
		/**
		 * Called when slider's value changes
		 */
		private function changeSizeHandler(event:Event = null):void {
			_views[_renderMode].sizes = _slider.value;
		}
		
		/**
		 * Called when a key is pressed
		 */
		private function keyDownHandler(event:KeyboardEvent):void {
			if(!visible) return;
			
			if(event.keyCode == Keyboard.NUMPAD_ADD || event.keyCode == Keyboard.EQUAL) {
				_slider.value ++;
				changeSizeHandler();
				return;
			}
			
			if (event.keyCode == Keyboard.NUMPAD_SUBTRACT || event.keyCode == Keyboard.NUMBER_6) {
				_slider.value --;
				changeSizeHandler();
				return;
			}
		}
	}
}