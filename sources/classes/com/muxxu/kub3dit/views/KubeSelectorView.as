package com.muxxu.kub3dit.views {
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
			var model:Model = event.model as Model;
			if(!_ready)  {
				_ready = true;
				createList(model.currentKubeId);
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
		private function initialize():void {
			_kubes = new Vector.<KubeSelectorButton>();
			_group = new FormComponentGroup();
			
			_holder = addChild(new Sprite()) as Sprite;
			
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
			PosUtils.hDistribute(_kubes, stage.stageWidth, 2, 2);
			PosUtils.alignToBottomOf(_holder, stage, 5);
			
			graphics.clear();
			graphics.beginFill(0, .5);
			graphics.drawRect(0, _holder.y - 5, stage.stageWidth, _holder.height + 10);
			graphics.endFill();
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
				bt = new KubeSelectorButton( drawIsoKube(top, side), i );
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