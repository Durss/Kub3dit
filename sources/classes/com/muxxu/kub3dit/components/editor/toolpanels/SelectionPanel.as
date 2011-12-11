package com.muxxu.kub3dit.components.editor.toolpanels {
	import flash.geom.Point;

	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;

	import flash.display.Shape;
	import flash.display.Sprite;
	
	/**
	 * 
	 * @author Francois
	 * @date 11 déc. 2011;
	 */
	public class SelectionPanel extends Sprite implements IToolPanel {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>SelectionPanel</code>.
		 */
		public function SelectionPanel() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		public function set chunksManager(value:ChunksManager):void {
		}

		/**
		 * @inheritDoc
		 */
		public function get landmark():Shape {
			return null;
		}

		/**
		 * @inheritDoc
		 */
		public function set eraseMode(value:Boolean):void {
		}

		/**
		 * @inheritDoc
		 */
		public function get eraseMode():Boolean {
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get fixedLandmark():Boolean {
			return true;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		public function dispose():void {
			
		}
		
		/**
		 * @inheritDoc
		 */
		public function draw(ox:int, oy:int, oz:int, kubeID:int, gridSize:int, gridOffset:Point):void {
			
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			
		}
		
	}
}