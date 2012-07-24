package com.muxxu.kub3dit.views {
	import com.muxxu.kub3dit.commands.IPassView;
	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.components.form.input.InputKube;
	import com.muxxu.kub3dit.graphics.CancelIcon;
	import com.muxxu.kub3dit.graphics.SubmitIcon;
	import com.muxxu.kub3dit.model.Model;
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.components.text.CssTextField;
	import com.nurun.components.vo.Margin;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.utils.pos.PosUtils;

	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * 
	 * @author Francois
	 * @date 2 janv. 2012;
	 */
	public class MapPasswordView extends AbstractWindowView implements IPassView {
		
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
			super(Label.getLabel("prompt-mapLoadPassTitle"));
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
		override public function open(...args):void {
			_loadMethod = args[0];
			_error.visible = false;
			_submitBt.enabled = true;
			super.open();
			stage.focus = _input;
		}
		
		/**
		 * Called if the password is wrong
		 */
		public function error():void {
			_error.visible = true;
			_submitBt.enabled = true;
			stage.focus = _input;
			_input.textfield.setSelection(0, _input.textfield.length);
			computePositions();
		}
		
		


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		override protected function initialize():void {
			super.initialize();
			
			_label = _container.addChild(new CssTextField("promptWindowContent")) as CssTextField;
			_input = _container.addChild(new InputKube()) as InputKube;
			_error = _container.addChild(new CssTextField("promptWindowContentError")) as CssTextField;
			_submitBt = _container.addChild(new ButtonKube(Label.getLabel("prompt-mapLoadPassSubmit"), false, new SubmitIcon())) as ButtonKube;
			_cancelBt = _container.addChild(new ButtonKube(Label.getLabel("prompt-mapLoadPassCancel"), false, new CancelIcon())) as ButtonKube;
			
			_submitBt.contentMargin = new Margin(5, 3, 5, 3);
			_cancelBt.contentMargin = new Margin(5, 3, 5, 3);
			
			_error.visible = false;
			_label.text = Label.getLabel("prompt-mapLoadPassDescription");
			_error.text = Label.getLabel("prompt-mapLoadPassError");
			_label.width = _input.width = 250;
			_submitBt.width = _cancelBt.width = 250 * .5 - 5;
			_input.textfield.displayAsPassword = true;
			
			_input.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
		}
		
		/**
		 * Resize and replace the elements.
		 */
		override protected function computePositions(event:Event = null):void {
			PosUtils.vPlaceNext(5, _label, _input, _submitBt);
			if(_error.visible) {
				PosUtils.vPlaceNext(5, _input, _error, _submitBt);
			}
			_cancelBt.y = _submitBt.y;
			_cancelBt.x = Math.round(_submitBt.width + 5);
			
			super.computePositions();
		}
		
		/**
		 * Called when form is sbmitted
		 */
		private function submitHandler(event:Event):void {
			_error.visible = false;
			_submitBt.enabled = false;
			_loadMethod(_input.text);
			computePositions();
		}
		
		/**
		 * Called when disable layer is clicked.
		 * Closes the view.
		 */
		override protected function clickHandler(event:MouseEvent):void {
			if(_loadMethod == null) return;
			
			if (event.target == _disableLayer || event.target == _cancelBt) {
				close();
				_loadMethod(null);
			}else if(event.target == _submitBt) {
				submitHandler(event);
			}
		}
		
	}
}