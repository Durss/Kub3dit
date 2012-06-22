package com.muxxu.kub3dit.views {
	import flash.utils.Dictionary;
	import gs.TweenLite;
	import gs.easing.Sine;

	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.components.buttons.KubeSelectorButton;
	import com.muxxu.kub3dit.components.form.AddKubeForm;
	import com.muxxu.kub3dit.controler.FrontControler;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.events.LightModelEvent;
	import com.muxxu.kub3dit.events.TextureEvent;
	import com.muxxu.kub3dit.graphics.AddIcon;
	import com.muxxu.kub3dit.model.Model;
	import com.muxxu.kub3dit.utils.drawIsoKube;
	import com.nurun.components.form.FormComponentGroup;
	import com.nurun.components.form.events.FormComponentGroupEvent;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;


	[Event(name="resize", type="flash.events.Event")]


	/**
	 * 
	 * @author Francois
	 * @date 30 oct. 2011;
	 */
	public class KubeSelectorView extends AbstractView {
		
		private var _ready:Boolean;
		private var _kubes:Vector.<KubeSelectorButton>;
		private var _holder:Sprite;
		private var _group:FormComponentGroup;
		private var _width:Number;
		private var _title:CssTextField;
		private var _addKube:ButtonKube;
		private var _addKubeForm:AddKubeForm;
		private var _selectedKubeId:String;
		private var _selectMode:Boolean;
		private var _kubeIdToButton:Dictionary;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>KubeSelectorView</code>.
		 */
		public function KubeSelectorView() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Sets the width of the component without simply scaling it.
		 */
		override public function set width(value:Number):void {
			_width = value;
			computePositions();
		}
		
		/**
		 * Sets if the view should be in selection mode or not.
		 * Selection mode provides a way choose multiple enabled cubes
		 */
		public function set selectMode(value:Boolean):void {
			_selectMode = value;
			
			var i:int, len:int, alpha:Number;
			len = _kubes.length;
			alpha = _selectMode? 1 : .5;
			for(i = 0; i < len; ++i) {
				_kubes[i].selectionMode = value;
				TweenLite.killTweensOf(_kubes[i]);
				TweenLite.to(_kubes[i], .2, {alpha:_kubes[i].selected? 1 : alpha, delay:i*.0025, ease:Sine.easeInOut});
			}
			
			if(value) {
				_group.allowMultipleSelection = true;
			}else{
				_group.allowMultipleSelection = false;
			}
		}
		
		/**
		 * Gets all the enabled kubes. Used for image generation.
		 * Returns an associative array whose keys are the enabled kubes IDs.
		 */
		public function get enabledCubes():Array {
			var i:int, len:int, ret:Array;
			len = _kubes.length;
			ret = [];
			for(i = 0; i < len; ++i) {
				if(_kubes[i].selected) {
					ret[parseInt(_kubes[i].id)] = true;
				}
			}
			return ret;
		}
		
		/**
		 * Gets the currently selected kube ID
		 */
		public function get currentKubeId():int { return parseInt(_selectedKubeId); }
		
		/**
		 * Sets the currently selected kube ID
		 */
		public function set currentKubeId(value:int):void {
			KubeSelectorButton(_kubeIdToButton[value]).selected = true;
			_selectedKubeId = value.toString();
			FrontControler.getInstance().changeKubeId(_selectedKubeId);
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:Model = event.model as Model;
			if(!_ready)  {
				_ready = true;
				_selectedKubeId = model.currentKubeId;
				updateList();
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_group = new FormComponentGroup();
			
			_holder = addChild(new Sprite()) as Sprite;
			_title = addChild(new CssTextField("kubesListTitle")) as CssTextField;
			_addKube = addChild(new ButtonKube("Ajouter", false, new AddIcon())) as ButtonKube;
			_addKubeForm = addChild(new AddKubeForm(_addKube)) as AddKubeForm;
			
			_width = 200;
			_title.text = Label.getLabel("kubesList");
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(MouseEvent.ROLL_OVER, rollHandler);
			addEventListener(MouseEvent.ROLL_OUT, rollHandler);
			Textures.getInstance().addEventListener(TextureEvent.CHANGE_SPRITESHEET, updateList);
			ViewLocator.getInstance().addEventListener(LightModelEvent.KUBE_ADD_COMPLETE, updateList);
		}
		
		/**
		 * Claled when the view is rolled over.
		 */
		private function rollHandler(event:MouseEvent):void {
			if(event.target != this || (event.type == MouseEvent.ROLL_OUT && _selectMode)) return;
			
			var i:int, len:int, alpha:Number;
			len = _kubes.length;
			alpha = event.type == MouseEvent.ROLL_OVER? 1 : .5;
			for(i = 0; i < len; ++i) {
				TweenLite.killTweensOf(_kubes[i]);
				TweenLite.to(_kubes[i], .2, {alpha:_kubes[i].selected? 1 : alpha, delay:i*.0025, ease:Sine.easeInOut});
			}
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
//			stage.addEventListener(Event.RESIZE, computePositions);
//			computePositions();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			PosUtils.hDistribute(_kubes, _width, 2, 2);
			_title.width = _width;
			_holder.y = Math.round(_title.height + 2);
			
			_addKube.height = _title.height = 20;
			_addKube.x = _width - _addKube.width;
			_addKubeForm.width = _width;
			_addKubeForm.y = _title.height;
			
			graphics.clear();
			graphics.beginFill(0xff0000, 0);
			graphics.drawRect(0, 0, _width, _holder.y+_holder.height);
			graphics.endFill();
		}
		
		/**
		 * Creates the kube's list.
		 */
		private function updateList(event:Event = null):void {
			var i:int, len:int;
			len = _kubes==null? 0 : _kubes.length;
			for(i = 0; i < len; ++i) {
				_holder.removeChild(_kubes[i]);
			}
			_group.removeAll();
			_kubes = new Vector.<KubeSelectorButton>();
			_kubeIdToButton = new Dictionary();
			_group.removeEventListener(FormComponentGroupEvent.CHANGE, changeSelectionHandler);
			
			var frames:Array = Textures.getInstance().cubesFrames;
			var bitmaps:Array = Textures.getInstance().bitmapDatas;
			var top:BitmapData, side:BitmapData, empty:BitmapData, bt:KubeSelectorButton;
			empty = new BitmapData(16, 16, true, 0);
			for (var k:String in frames) {
				top = bitmaps[k][0] == null? empty : bitmaps[k][0];
				side = bitmaps[k][1] == null? empty : bitmaps[k][1];
				bt = new KubeSelectorButton( drawIsoKube(top, side, true, .75), k );
				_kubes.push(bt);
				_holder.addChild(bt);
				_group.add(bt);
				_kubeIdToButton[k] = bt;
				if(k == _selectedKubeId) {
					bt.selected = true;
				}
			}
			computePositions();
			_group.addEventListener(FormComponentGroupEvent.CHANGE, changeSelectionHandler);
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		/**
		 * Called when a new kube is selected
		 */
		private function changeSelectionHandler(event:FormComponentGroupEvent):void {
			if(_selectMode) return;
			_selectedKubeId = KubeSelectorButton(event.selectedItem).id;
			FrontControler.getInstance().changeKubeId(_selectedKubeId);
		}
		
	}
}