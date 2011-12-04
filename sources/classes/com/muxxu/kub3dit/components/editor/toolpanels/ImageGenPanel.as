package com.muxxu.kub3dit.components.editor.toolpanels {
	import com.muxxu.kub3dit.commands.BrowseForFileCmd;
	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.components.form.CheckBoxKube;
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.lang.Disposable;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.color.ColorFunctions;

	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	/**
	 * 
	 * @author Francois
	 * @date 3 déc. 2011;
	 */
	public class ImageGenPanel extends Sprite implements IToolPanel {
		private var _chunksManager:ChunksManager;
		private var _landMark:Shape;
		private var _colorsBmd:BitmapData;
		private var _loadBt:ButtonKube;
		private var _clearBt:ButtonKube;
		private var _cmd:BrowseForFileCmd;
		private var _bmd:BitmapData;
		private var _pixels:ByteArray;
		private var _running:Boolean;
		private var _index:int;
		private var _ox:int;
		private var _oy:int;
		private var _oz:int;
		private var _colorsPixels:ByteArray;
		private var _levelsCb:CheckBoxKube;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ImageGenPanel</code>.
		 */
		public function ImageGenPanel() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		public function set chunksManager(value:ChunksManager):void {
			_chunksManager = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get landmark():Shape {
			return _landMark;
		}

		/**
		 * @inheritDoc
		 */
		public function set eraseMode(value:Boolean):void {
			
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		public function draw(ox:int, oy:int, oz:int, kubeID:int, gridSize:int, gridOffset:Point):void {
			_oz = oz;
			_oy = oy;
			_ox = ox;
			_running = true;
			_index = 0;
			_pixels.position = 0;
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			enterFrameHandler();
		}
		
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_landMark = new Shape();
			_colorsBmd = Textures.getInstance().colorsBmd;
			_colorsPixels = _colorsBmd.getPixels(_colorsBmd.rect);
			
			_loadBt = addChild(new ButtonKube(Label.getLabel("toolConfig-imageGen-load"))) as ButtonKube;
			_clearBt = addChild(new ButtonKube(Label.getLabel("toolConfig-imageGen-clear"))) as ButtonKube;
			_levelsCb = addChild(new CheckBoxKube(Label.getLabel("toolConfig-imageGen-levels"))) as CheckBoxKube;
			
			_clearBt.x = Math.round(_loadBt.x + _loadBt.width + 5);
			_clearBt.enabled = false;
			_levelsCb.y = Math.round(_clearBt.y + _clearBt.height);
			
			_cmd = new BrowseForFileCmd("Sandkube image", "*.png;*.jpg;*.bmp;*.gif", true);
			_cmd.addEventListener(CommandEvent.COMPLETE, loadImageCompleteHandler);
			_clearBt.addEventListener(MouseEvent.CLICK, clickButtonHandler);
			_loadBt.addEventListener(MouseEvent.CLICK, clickButtonHandler);
		}
		
		/**
		 * Called when a button is clicked
		 */
		private function clickButtonHandler(event:MouseEvent):void {
			if(event.currentTarget == _loadBt ){
				_cmd.execute();
				
			}else if(event.currentTarget == _clearBt){
				_landMark.graphics.clear();
				_clearBt.enabled = false;
			}
		}
		
		/**
		 * Called when SandKube image loading completes.
		 */
		private function loadImageCompleteHandler(event:CommandEvent):void {
			_bmd = event.data as BitmapData;
			_pixels = _bmd.getPixels(_bmd.rect);
			
			drawLandMark();
			
			_clearBt.enabled = true;
		}
		
		/**
		 * Draw the landmark
		 */
		private function drawLandMark():void {
			_landMark.graphics.clear();
			_landMark.graphics.beginBitmapFill(_bmd);
			_landMark.graphics.drawRect(0, 0, _bmd.width, _bmd.height);
		}
		
		/**
		 * Called on ENTER_FRAME event to render
		 */
		private function enterFrameHandler(event:Event = null):void {
			var px:int, py:int, pz:int, tile:int;
			var startTime:int, w:int, h:int, c1:uint, c2:uint, cS:uint;
			var distMin:int, dist:int;
			startTime = getTimer();
			w = _bmd.width;
			h = _bmd.height;
			do {
				px = _index%w;
				py = Math.floor(_index/w);
				
				c1 = _pixels.readUnsignedInt();
				//Skip pixels under a specific alpha value 
				if((c1 >> 24)&0xff > 0xcc) {
					distMin = int.MAX_VALUE;
					_colorsPixels.position = 0;
					while(_colorsPixels.bytesAvailable){
						c2 = _colorsPixels.readUnsignedInt();
						dist = ColorFunctions.getDistanceBetweenColors(c1, c2);
						if(dist < distMin) {
							tile = Math.floor((_colorsPixels.position/4) / _colorsBmd.width) + 1;
							distMin = dist;
							cS = c2;
							pz = (_colorsPixels.position/4) % _colorsBmd.width;
							if(distMin < 2) break;
						}
						_colorsPixels.position += 4;//Skips one color because levels color change only every two levels
					}
					
					px += _ox - w * .5;
					py += _oy - h * .5;
					
					_chunksManager.update(px, py, _levelsCb.selected? pz : _oz, tile);
				}
				
				_index++;
			}while(getTimer()-startTime < 100 && _pixels.bytesAvailable);
			
			if(!_pixels.bytesAvailable) {
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
		}
		
	}
}