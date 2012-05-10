package com.muxxu.kub3dit.components.editor.toolpanels {
	import com.muxxu.kub3dit.controler.FrontControler;
	import flash.events.MouseEvent;
	import com.muxxu.kub3dit.components.buttons.GraphicButtonKube;
	import com.muxxu.kub3dit.components.form.KubeSelectorInput;
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;
	import com.muxxu.kub3dit.graphics.ReplaceCCWIcon;
	import com.muxxu.kub3dit.graphics.ReplaceCWIcon;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	/**
	 * 
	 * @author Francois
	 * @date 10 mai 2012;
	 */
	public class ReplacePanel extends Sprite implements IToolPanel {
		private var _selector1:KubeSelectorInput;
		private var _selector2:KubeSelectorInput;
		private var _replaceBtCW:GraphicButtonKube;
		private var _replaceBtCCW:GraphicButtonKube;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ReplacePanel</code>.
		 */
		public function ReplacePanel() {
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
		public function set level(value:int):void {
		}

		/**
		 * @inheritDoc
		 */
		public function get fixedLandmark():Boolean {
			return false;
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
			_replaceBtCW = addChild(new GraphicButtonKube(new ReplaceCWIcon(), false)) as GraphicButtonKube;
			_replaceBtCCW = addChild(new GraphicButtonKube(new ReplaceCCWIcon(), false)) as GraphicButtonKube;
			_selector1 = addChild(new KubeSelectorInput()) as KubeSelectorInput;
			_selector2 = addChild(new KubeSelectorInput()) as KubeSelectorInput;
			
			_selector1.x = _selector2.x = _replaceBtCW.width;
			_selector2.y = 45;
			_replaceBtCW.y = 20;
			_replaceBtCCW.x = 70;
			_replaceBtCCW.y = 25;
			
			_replaceBtCW.addEventListener(MouseEvent.CLICK, clickReplaceHandler);
			_replaceBtCCW.addEventListener(MouseEvent.CLICK, clickReplaceHandler);
		}
		
		/**
		 * Called when a replace button is clicked
		 */
		private function clickReplaceHandler(event:MouseEvent):void {
			var replacer:int = event.currentTarget == _replaceBtCW? _selector1.kubeID : _selector2.kubeID;
			var replaced:int = event.currentTarget == _replaceBtCW? _selector2.kubeID : _selector1.kubeID;
			FrontControler.getInstance().replaceKubes(replacer, replaced);
		}
		
	}
}