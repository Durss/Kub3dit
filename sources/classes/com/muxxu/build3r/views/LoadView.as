package com.muxxu.build3r.views {
	import com.muxxu.build3r.vo.Metrics;
	import com.muxxu.build3r.i18n.LabelBuild3r;
	import gs.TweenLite;

	import com.muxxu.build3r.controler.FrontControlerBuild3r;
	import com.muxxu.build3r.model.ModelBuild3r;
	import com.muxxu.kub3dit.commands.IPassView;
	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.components.form.input.InputKube;
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.pos.PosUtils;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;

	/**
	 * 
	 * @author Francois
	 * @date 19 févr. 2012;
	 */
	public class LoadView extends AbstractView implements IPassView {
		
		private var _browseBt:ButtonKube;
		private var _idInput:InputKube;
		private var _idBt:ButtonKube;
		private var _labelBrowse:CssTextField;
		private var _passInput:InputKube;
		private var _emptyCt:ColorTransform;
		
		[Embed(source="../../../../../assets/bitmaps/icon_browse.gif")]
		private var _browseIcon:Class;
		[Embed(source="../../../../../assets/bitmaps/cube.gif")]
		private var _idIcon:Class;
		private var _error:CssTextField;
		private var _labelID:CssTextField;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>LoadView</code>.
		 */
		public function LoadView() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:ModelBuild3r = event.model as ModelBuild3r;
			visible = model.map == null;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		public function open(passwordCallback:Function):void {
			mouseEnabled = mouseChildren = true;
			visible = true;
			stage.focus = _passInput;
			_passInput.textfield.setSelection(0, _passInput.text.length);
			_passInput.transform.colorTransform = _emptyCt;
			TweenLite.from(_passInput, .5, {tint:0xff0000});
			
			_error.text = LabelBuild3r.getl("load-mapProtected");
		}

		/**
		 * @inheritDoc
		 */
		public function error():void {
			mouseEnabled = mouseChildren = true;
			stage.focus = _passInput;
			_passInput.textfield.setSelection(0, _passInput.text.length);
			_passInput.transform.colorTransform = _emptyCt;
			TweenLite.from(_passInput, .5, {tint:0xff0000});
			if(String(_passInput.value).length == 0) {
				_error.text = LabelBuild3r.getl("load-mapProtected");
			}else{
				_error.text = LabelBuild3r.getl("load-wrongPass");
			}
		}
		
		/**
		 * Called if loaded map's type isn't good.
		 */
		public function typeError():void {
			mouseEnabled = mouseChildren = true;
			_error.text = LabelBuild3r.getl("load-invalidFile");
		}
		
		/**
		 * Called if th emap isn't found
		 */
		public function mapNotFound():void {
			mouseEnabled = mouseChildren = true;
			_error.text = LabelBuild3r.getl("load-notFound");
			_idInput.textfield.setSelection(0, _idInput.text.length);
		}

		/**
		 * @inheritDoc
		 */
		public function close():void {
			visible = false;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_labelBrowse = addChild(new CssTextField("b-label")) as CssTextField;
			_labelID= addChild(new CssTextField("b-label")) as CssTextField;
			_error = addChild(new CssTextField("b-error")) as CssTextField;
			_browseBt = addChild(new ButtonKube(LabelBuild3r.getl("load-browse"), false, null, true)) as ButtonKube;
			
			_browseBt.icon = new _browseIcon();
			_browseBt.contentMargin.left = 15;
			
			_idInput = addChild(new InputKube(LabelBuild3r.getl("load-id"), false, false, 0, 0, true)) as InputKube;
			_passInput = addChild(new InputKube(LabelBuild3r.getl("load-pass"), false, false, 0, 0, true)) as InputKube;
			_idBt = addChild(new ButtonKube(LabelBuild3r.getl("load-submit"), false, null, true)) as ButtonKube;
			
			_idBt.icon = new _idIcon();
			_idBt.contentMargin.left = 15;
			
			_emptyCt = new ColorTransform();
			
			_labelBrowse.text = LabelBuild3r.getl("load-titleBrowse");
			_labelID.text = LabelBuild3r.getl("load-titleId");
			_idInput.textfield.restrict = '[0-9][a-z][A-Z]';
			_idInput.textfield.maxChars = 15;
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			_browseBt.addEventListener(MouseEvent.CLICK, submitHandler);
			_idBt.addEventListener(MouseEvent.CLICK, submitHandler);
			_idInput.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
			_passInput.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
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
			_labelBrowse.width = _idInput.width = _browseBt.width = _passInput.width =
			_idBt.width = _error.width = _labelID.width = Metrics.STAGE_WIDTH;
			
			PosUtils.vPlaceNext(5, _labelBrowse, _browseBt);
			PosUtils.vPlaceNext(30, _browseBt, _labelID);
			PosUtils.vPlaceNext(5, _labelID, _idInput, _passInput, _idBt, _error);
			_error.y += 10;
		}
		
		/**
		 * Called when the form is submitted
		 */
		private function submitHandler(event:Event):void {
			if(!mouseEnabled) return;
			
			_error.text = "";
			
			if(event.target == _browseBt) {
				FrontControlerBuild3r.getInstance().browseForMap();
			}else{
				if(String(_idInput.value).length == 0) {
					stage.focus = _idInput;
					_idInput.transform.colorTransform = _emptyCt;
					TweenLite.from(_idInput, .5, {tint:0xff0000});
				}else{
					mouseEnabled = mouseChildren = false;
					FrontControlerBuild3r.getInstance().loadMapById(_idInput.value as String, _passInput.value as String);
				}
			}
		}
		
	}
}