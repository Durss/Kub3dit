package com.muxxu.kub3dit.components.buttons {
	import com.muxxu.kub3dit.vo.ToolTipAlign;
	import com.nurun.structure.environnement.label.Label;
	import com.muxxu.kub3dit.events.ToolTipEvent;
	import gs.TweenLite;

	import com.muxxu.kub3dit.vo.KubeSelecorItemData;
	import com.nurun.components.tile.ITileEngineItem2D;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * 
	 * @author Francois
	 * @date 10 mai 2012;
	 */
	public class KubeSelectorItem extends Sprite implements ITileEngineItem2D {
		private var _data:KubeSelecorItemData;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>KubeSelectorItem</code>.
		 */
		public function KubeSelectorItem() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get data():KubeSelecorItemData {
			return _data;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		public function populate(data:*):void {
			_data = data as KubeSelecorItemData;
			var bmd:BitmapData = _data.bmd;
			graphics.clear();
			graphics.beginBitmapFill(bmd);
			graphics.drawRect(0, 0, bmd.width, bmd.height);
			graphics.endFill();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			buttonMode = true;
			addEventListener(MouseEvent.ROLL_OVER, rollHandler);
			addEventListener(MouseEvent.ROLL_OUT, rollHandler);
		}

		private function rollHandler(event:MouseEvent):void {
			var over:Boolean = event.type == MouseEvent.ROLL_OVER;
			TweenLite.to(this, .2, {colorMatrixFilter:{brightness:over? 1.4: 1, remove:!over}});
			if(over) {
				dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, Label.getLabel("kube"+_data.id), ToolTipAlign.BOTTOM));
			}
		}
		
	}
}