package com.muxxu.build3r.components {
	import com.muxxu.kub3dit.utils.drawIsoKube;
	import flash.display.BitmapData;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.nurun.components.tile.ITileEngineItem2D;
	import flash.display.Shape;
	
	/**
	 * 
	 * @author Francois
	 * @date 21 févr. 2012;
	 */
	public class KubeTEItem extends Shape implements ITileEngineItem2D {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>KubeTEItem</code>.
		 */
		public function KubeTEItem() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Populates the component
		 */
		public function populate(data:*):void {
			graphics.clear();
			
			if (data > 0) {
				var bmds:Array = Textures.getInstance().bitmapDatas[data];
				var bmd:BitmapData = drawIsoKube(bmds[0], bmds[1], false, .5, true);
				graphics.beginBitmapFill(bmd);
				graphics.drawRect(0, 0, bmd.width, bmd.height);
				graphics.endFill();
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			
		}
		
	}
}