package com.muxxu.kub3dit.components.editor.toolpanels.terragen {
	import com.muxxu.kub3dit.controler.FrontControler;
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;
	import com.muxxu.kub3dit.engin3d.vo.Point3D;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;

	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	/**
	 * 
	 * @author Francois
	 * @date 1 juil. 2012;
	 */
	public class GenerateTerrainStep extends Sprite {
		private var _label:CssTextField;
		private var _perlinNoise:PerlinNoiseMapStep;
		private var _groundRatio:GroundRatioStep;
		private var _landMark:Shape;
		private var _origine:Point3D;
		private var _kubeID:int;
		
		private var _gridOffset:Point;
		private var _chunksManager:ChunksManager;
		private var _pixels:ByteArray;
		private var _coeff:Number;
		private var _threshold:int;
		private var _maxHeight:int;
		private var _mapWidth:int;
		private var _mapHeight:int;
		private var _contrast:ColorMatrixFilter;
		
		

		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>GenerateTerrainStep</code>.
		 */
		public function GenerateTerrainStep(perlinNoise:PerlinNoiseMapStep, ratio:GroundRatioStep, landMark:Shape, contrast:ColorMatrixFilter) {
			_contrast = contrast;
			_landMark = landMark;
			_groundRatio = ratio;
			_perlinNoise = perlinNoise;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Generates the terrain
		 */
		public function generate(ox:int, oy:int, oz:int, kubeID:int, gridOffset:Point, chunksManager:ChunksManager):void {
			_chunksManager = chunksManager;
			_gridOffset = gridOffset;
			_kubeID = kubeID;
			_origine = new Point3D(ox, oy, oz);
			_maxHeight = _chunksManager.map.mapSizeZ;
			_coeff = _groundRatio.ratio * _maxHeight;
			if(!hasEventListener(Event.ENTER_FRAME)) {
				addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
			enterFrameHandler();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_label = addChild(new CssTextField("tool-label")) as CssTextField;
			
			_label.text = Label.getLabel("toolConfig-terragen-generate");
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		}

		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			var v:int = _perlinNoise.threshold;
			_threshold = v | (v<<8) | (v<<16);
			_mapWidth = _perlinNoise.mapWidth;
			_mapHeight = _perlinNoise.mapHeight;
			
			var bmd:BitmapData = new BitmapData(_mapWidth, _mapHeight, true, 0);
			var offset:Point = _perlinNoise.scrollOffset;
			bmd.perlinNoise(100, 100, 7, _perlinNoise.seed, false, true, 1, true, [offset,offset,offset,offset,offset,offset,offset]);
			bmd.applyFilter(bmd, bmd.rect, new Point(), _contrast);
			bmd.threshold(bmd, bmd.rect, new Point(), "<", _threshold, 0, 0xffffff);
			
			_pixels = bmd.getPixels(bmd.rect);
			_pixels.position = 0;
			
			_landMark.graphics.beginBitmapFill(bmd);
			_landMark.graphics.drawRect(0, 0, bmd.width, bmd.height);
			
			computePositions();
		}
		
		/**
		 * Called when the stage isn't available anymore
		 */
		private function removedFromStageHandler(event:Event):void {
			_landMark.graphics.clear();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			
		}
		
		/**
		 * Called on ENTER FRAME event to generate by batch
		 */
		private function enterFrameHandler(event:Event = null):void {
			var s:int = getTimer();
			var i:int, pixel:uint, pz:int;
			while(getTimer()-s < 20 && _pixels.bytesAvailable) {
				i = _pixels.position/4;
				pixel = _pixels.readUnsignedInt();
				if(pixel == 0) continue;
				
				pz = _coeff * ((pixel & 0xffffff)-_threshold)/(0xffffff-_threshold);
				var j:int, lenJ:int, px:int, py:int;
				lenJ = pz+1;
				px = Math.round(i % _mapWidth + _origine.x - _mapWidth * .5);
				py = Math.round(Math.floor(i / _mapWidth) % (_mapWidth*_mapHeight) + _origine.y - _mapHeight * .5);
				for(j = 0; j < lenJ; ++j) {
					_chunksManager.addInvalidableCube(px, py, j, _kubeID);
				}
			}
			
			if(!_pixels.bytesAvailable) {
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				_chunksManager.invalidate();
			}
			FrontControler.getInstance().showProgress(_pixels.position/_pixels.length);
		}
		
	}
}