package com.muxxu.kub3dit.components.stats {
	import com.muxxu.kub3dit.vo.ToolTipAlign;
	import com.nurun.structure.environnement.label.Label;
	import com.muxxu.kub3dit.events.ToolTipEvent;
	import flash.events.MouseEvent;
	import flash.display.BitmapData;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.utils.drawIsoKube;
	import com.nurun.components.text.CssTextField;
	import flash.display.Sprite;
	
	/**
	 * 
	 * @author Francois
	 * @date 8 avr. 2012;
	 */
	public class KubeCounter extends Sprite {
		
		private static var _CACHE:Array = [];
		private var _label:CssTextField;
		private var _kubeId:int;
		private var _total:int;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>KubeCounter</code>.
		 */
		public function KubeCounter() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get kubeId():int { return _kubeId; }

		public function get total():int { return _total; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Populates the component
		 */
		public function populate(kubeId:int, total:int):void {
			_total = total;
			_kubeId = kubeId;
			var bmd:BitmapData;
			if(_CACHE[kubeId] == undefined) {
				_CACHE[kubeId] = bmd = drawIsoKube(Textures.getInstance().bitmapDatas[kubeId][0], Textures.getInstance().bitmapDatas[kubeId][1], false, 1, true);
			}else{
				bmd = _CACHE[kubeId];
			}
			_label.text = total.toString();
			
			graphics.clear();
			graphics.beginBitmapFill(bmd);
			graphics.drawRect(0, 0, bmd.width, bmd.height);
			graphics.endFill();
			
			_label.x = Math.round((bmd.width - _label.width) * .5);
			_label.y = Math.round(bmd.height * .6 - _label.height * .5);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_label = addChild(new CssTextField("statsNumber")) as CssTextField;
			
			mouseChildren = false;
			
			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
		}
		
		/**
		 * Called when the component is rolled over.
		 */
		private function rollOverHandler(event:MouseEvent):void {
			dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, Label.getLabel("kube" + _kubeId), ToolTipAlign.TOP));
		}
		
	}
}