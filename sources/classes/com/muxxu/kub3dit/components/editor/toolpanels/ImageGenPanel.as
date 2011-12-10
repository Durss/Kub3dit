package com.muxxu.kub3dit.components.editor.toolpanels {
	import com.muxxu.kub3dit.views.KubeSelectorView;
	import com.nurun.structure.mvc.views.ViewLocator;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import com.nurun.components.text.CssTextField;
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
		private var _levelsCb:CheckBoxKube;
		private var _colorsArray:Array;
		private var _processPercent:CssTextField;
		private var _selectorView:KubeSelectorView;
		private var _eraseMode:Boolean;
		private var _enabledCubes:Array;
		
		
		
		
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
		public function set eraseMode(value:Boolean):void {
			_eraseMode = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get eraseMode():Boolean {
			return _eraseMode;
		}
		
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
		 * Gets the height of the component.
		 */
		override public function get height():Number {
			if(contains(_processPercent)) {
				return super.height + 10;
			}else {
				return super.height;
			}
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		public function draw(ox:int, oy:int, oz:int, kubeID:int, gridSize:int, gridOffset:Point):void {
			if(_pixels == null || _pixels.length == 0) return;
			
			_oz = oz;
			_oy = oy;
			_ox = ox;
			_running = true;
			_index = 0;
			_pixels.position = 0;
			_enabledCubes = _selectorView.enabledCubes;
			addChild(_processPercent);
			_chunksManager.clearInvalidateStack();
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			enterFrameHandler();
			dispatchEvent(new Event(Event.RESIZE));
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
			_selectorView = ViewLocator.getInstance().locateViewByType(KubeSelectorView) as KubeSelectorView;
			_landMark = new Shape();
//			_colorsBmd = Textures.getInstance().colorsBmd;
//			_colorsPixels = _colorsBmd.getPixels(_colorsBmd.rect);
			_colorsArray = Textures.getInstance().genColors;
			
			_loadBt = addChild(new ButtonKube(Label.getLabel("toolConfig-imageGen-load"))) as ButtonKube;
			_clearBt = addChild(new ButtonKube(Label.getLabel("toolConfig-imageGen-clear"))) as ButtonKube;
			_levelsCb = addChild(new CheckBoxKube(Label.getLabel("toolConfig-imageGen-levels"))) as CheckBoxKube;
			_processPercent = new CssTextField("tool-imageGenProcessing");
			
			_clearBt.x = Math.round(_loadBt.x + _loadBt.width + 5);
			_clearBt.enabled = false;
			_levelsCb.y = Math.round(_clearBt.y + _clearBt.height);
			
			_processPercent.text = "100%";
			_processPercent.x = Math.round((_clearBt.x + _clearBt.width - _processPercent.width) * .5);
			_processPercent.y = _levelsCb.y + _levelsCb.height + 10;
			
			_cmd = new BrowseForFileCmd("Sandkube image", "*.png;*.jpg;*.bmp;*.gif", true);
			_cmd.addEventListener(CommandEvent.COMPLETE, loadImageCompleteHandler);
			_clearBt.addEventListener(MouseEvent.CLICK, clickButtonHandler);
			_loadBt.addEventListener(MouseEvent.CLICK, clickButtonHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		}
		
		/**
		 * Called when the component is removed from the stage
		 */
		private function removedFromStageHandler(event:Event):void {
			_selectorView.selectMode = false;
			stopProcessing();
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			_selectorView.selectMode = true;
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}
		
		/**
		 * Stops the generation's processing
		 */
		private function stopProcessing():void {
			_landMark.graphics.clear();
			_clearBt.enabled = false;
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			_chunksManager.clearInvalidateStack();
			if(contains(_processPercent)) removeChild(_processPercent);
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		/**
		 * Draw the landmark
		 */
		private function drawLandMark():void {
			_landMark.graphics.clear();
			_landMark.graphics.beginBitmapFill(_bmd);
			_landMark.graphics.drawRect(0, 0, _bmd.width, _bmd.height);
		}
		
		
		
		
		
		//__________________________________________________________ INPUT HANDLERS
		
		/**
		 * Called when a key is released on the stage
		 */
		private function keyUpHandler(event:KeyboardEvent):void {
			if(event.keyCode == Keyboard.ESCAPE) {
				stopProcessing();
			}
		}
		
		/**
		 * Called when a button is clicked
		 */
		private function clickButtonHandler(event:MouseEvent):void {
			if(event.currentTarget == _loadBt ){
				_cmd.execute();
				
			}else if(event.currentTarget == _clearBt){
				_pixels = null;
				_landMark.graphics.clear();
				_clearBt.enabled = false;
			}
		}
		
		
		
		
		//__________________________________________________________ PROCESSING
		
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
		 * Called on ENTER_FRAME event to render
		 */
		private function enterFrameHandler(event:Event = null):void {
			var px:int, py:int, pz:int, tile:int;
			var startTime:int, w:int, h:int, c1:uint, c2:uint, cS:uint;
			var distMin:int, dist:int, id:int, cIndex:int;
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
					id = 1;
					do {
						if(_enabledCubes[id] == undefined) {
							id ++;
						}else{
							c2 = _colorsArray[id][cIndex]["c"];
							dist = ColorFunctions.getDistanceBetweenColors(c1, c2);
							if(dist < distMin) {
								tile = id;
								distMin = dist;
								cS = c2;
								pz = _colorsArray[id][cIndex]["z"];
	//						}else if(cIndex == 0){
	//							//Skips the whole kube's level
	//							id ++;
	//							cIndex = 0;
							}
							
							cIndex ++;
							if(cIndex > (_colorsArray[id] as Array).length-1) {
								id ++;
								cIndex = 0;
							}
						}
						
						if(_colorsArray[id] == undefined) id = -1;
					}while(id != -1);
					
					px += _ox - Math.floor(w * .5);
					py += _oy - Math.floor(h * .5);
					
					_chunksManager.addInvalidableCube(px, py, _levelsCb.selected? _oz + pz : _oz, tile);
				}
				
				_index++;
			}while(getTimer()-startTime < 35 && _pixels.bytesAvailable);
			
			_processPercent.text = Math.round(_pixels.position/_pixels.length * 100)+"%";
			
			if(!_pixels.bytesAvailable) {
				_chunksManager.invalidate();
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				removeChild(_processPercent);
				dispatchEvent(new Event(Event.RESIZE));
			}
		}
		
	}
}