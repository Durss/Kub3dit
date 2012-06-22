package com.muxxu.kub3dit.components.editor.toolpanels {
	import com.muxxu.kub3dit.views.KubeSelectorView;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.draw.createRect;
	import flash.geom.Point;

	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;

	import flash.display.Shape;
	import flash.display.Sprite;
	
	/**
	 * 
	 * @author Francois
	 * @date 22 juin 2012;
	 */
	public class PipetaPanel extends Sprite implements IToolPanel {
		private var _chunksManager:ChunksManager;
		private var _landMark:Shape;
		private var _selectorView:KubeSelectorView;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>PipetaPanel</code>.
		 */
		public function PipetaPanel() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function set chunksManager(value:ChunksManager):void {
			_chunksManager = value;
		}

		public function get landmark():Shape {
			return _landMark;
		}

		public function set eraseMode(value:Boolean):void {
		}

		public function get eraseMode():Boolean {
			return false;
		}

		public function set level(value:int):void {
		}

		public function get fixedLandmark():Boolean {
			return false;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */

		public function dispose():void {
		}

		public function draw(ox:int, oy:int, oz:int, kubeID:int, gridSize:int, gridOffset:Point):void {
			var id:uint = _chunksManager.map.getTile(ox, oy, oz);
			if(id > 0) {
				_selectorView.currentKubeId = id;
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_landMark = createRect(0x99ffffff, 1, 1);
			_selectorView = ViewLocator.getInstance().locateViewByType(KubeSelectorView) as KubeSelectorView;
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			
		}
		
	}
}