package com.muxxu.kub3dit.views {
	import com.nurun.components.vo.Margin;
	import com.muxxu.kub3dit.graphics.CancelIcon;
	import com.muxxu.kub3dit.graphics.SubmitIcon;
	import gs.TweenLite;

	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.components.form.input.InputKube;
	import com.muxxu.kub3dit.components.window.PromptWindow;
	import com.muxxu.kub3dit.model.Model;
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * 
	 * @author Francois
	 * @date 2 janv. 2012;
	 */
	public class MapPasswordView extends AbstractView {
		private var _disableLayer:Sprite;
		private var _content:Sprite;
		private var _window:PromptWindow;
		private var _label:CssTextField;
		private var _input:InputKube;
		private var _submitBt:ButtonKube;
		private var _loadMethod:Function;
		private var _error:CssTextField;
		private var _cancelBt:ButtonKube;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MapPasswordView</code>.
		 */
		public function MapPasswordView() {
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
			model;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Opens the view
		 */
		public function open(loadMethod:Function):void {
			TweenLite.to(this, .25, {autoAlpha:1});
			_loadMethod = loadMethod;
			_error.visible = false;
			computePositions();
			stage.focus = _input;
		}
		
		/**
		 * Called if the password is wrong
		 */
		public function error():void {
			_error.visible = true;
			stage.focus = _input;
			_input.textfield.setSelection(0, _input.textfield.length);
			computePositions();
		}
		
		/**
		 * Closes the view
		 */
		public function close():void {
			TweenLite.to(this, .25, {autoAlpha:0});
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
			_content = new Sprite();
			_label = _content.addChild(new CssTextField("promptWindowContent")) as CssTextField;
			_input = _content.addChild(new InputKube()) as InputKube;
			_error = _content.addChild(new CssTextField("promptWindowContentError")) as CssTextField;
			_submitBt = _content.addChild(new ButtonKube(Label.getLabel("prompt-mapLoadPassSubmit"), false, new SubmitIcon())) as ButtonKube;
			_cancelBt = _content.addChild(new ButtonKube(Label.getLabel("prompt-mapLoadPassCancel"), false, new CancelIcon())) as ButtonKube;
			
			_submitBt.contentMargin = new Margin(5, 3, 5, 3);
			_cancelBt.contentMargin = new Margin(5, 3, 5, 3);
			
			_error.visible = false;
			_label.text = Label.getLabel("prompt-mapLoadPassDescription");
			_error.text = Label.getLabel("prompt-mapLoadPassError");
			_label.width = _input.width = 250;
			_submitBt.width = _cancelBt.width = 250 * .5 - 5;
			
			_window = addChild(new PromptWindow(Label.getLabel("prompt-mapLoadPassTitle"), _content)) as PromptWindow;
			
			_input.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
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
			PosUtils.vPlaceNext(5, _label, _input, _submitBt);
			if(_error.visible) {
				PosUtils.vPlaceNext(5, _input, _error, _submitBt);
			}
			_cancelBt.y = _submitBt.y;
			_cancelBt.x = Math.round(_submitBt.width + 5);
			_window.updateSizes();
			PosUtils.centerInStage(_window);
			_disableLayer.graphics.clear();
			_disableLayer.graphics.beginFill(0xffffff, .5);
			_disableLayer.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			_disableLayer.graphics.endFill();
		}
		
		/**
		 * Called when form is sbmitted
		 */
		private function submitHandler(event:Event):void {
			_loadMethod(_input.text);
		}
		
		/**
		 * Called when disable layer is clicked.
		 * Closes the view.
		 */
		private function clickHandler(event:MouseEvent):void {
			if (event.target == _disableLayer || event.target == _cancelBt) {
				close();
				_loadMethod(null);
			}else if(event.target == _submitBt) {
				submitHandler(event);
			}
		}
		
	}
}