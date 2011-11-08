package com.muxxu.kub3dit.views {
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.components.text.CssTextField;
	import com.muxxu.kub3dit.components.KubeSelectorButton;
	import com.muxxu.kub3dit.controler.FrontControler;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.model.Model;
	import com.muxxu.kub3dit.utils.drawIsoKube;
	import com.nurun.components.form.FormComponentGroup;
	import com.nurun.components.form.events.FormComponentGroupEvent;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;


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
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			trace("KubeSelectorView.update(event)");
			var model:Model = event.model as Model;
			if(!_ready)  {
				_ready = true;
				createList(model.currentKubeId);
			}
		}
		/**
		 * Sets the width of the component without simply scaling it.
		 */
		override public function set width(value:Number):void {
			_width = value;
			computePositions();
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
			_kubes = new Vector.<KubeSelectorButton>();
			_group = new FormComponentGroup();
			
			_holder = addChild(new Sprite()) as Sprite;
			_title = addChild(new CssTextField("kubesListTitle")) as CssTextField;
			
			_width = 200;
			_title.text = Label.getLabel("kubesList");
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
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
		}
		
		/**
		 * Creates the kube's list.
		 */
		private function createList(selectedId:String):void {
			var frames:Array = Textures.getInstance().cubesFrames;
			var bitmaps:Array = Textures.getInstance().bitmapDatas;
			var top:BitmapData, side:BitmapData, empty:BitmapData, bt:KubeSelectorButton;
			empty = new BitmapData(16, 16, true, 0);
			for (var i:String in frames) {
				top = bitmaps[i][0] == null? empty : bitmaps[i][0];
				side = bitmaps[i][1] == null? empty : bitmaps[i][1];
				bt = new KubeSelectorButton( drawIsoKube(top, side, true, .75), i );
				_kubes.push(bt);
				_holder.addChild(bt);
				_group.add(bt);
				if(i == selectedId) {
					bt.selected = true;
				}
			}
			computePositions();
			_group.addEventListener(FormComponentGroupEvent.CHANGE, changeSelectionHandler);
		}
		
		/**
		 * Called when a new kube is selected
		 */
		private function changeSelectionHandler(event:FormComponentGroupEvent):void {
			FrontControler.getInstance().changeKubeId( KubeSelectorButton(event.selectedItem).id );
		}
		
	}
}