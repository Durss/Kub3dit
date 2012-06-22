package com.muxxu.kub3dit.components.editor.toolpanels {
	import com.muxxu.kub3dit.events.ToolTipEvent;
	import com.muxxu.kub3dit.components.form.CheckBoxKube;
	import com.muxxu.kub3dit.events.TextureEvent;
	import com.muxxu.kub3dit.commands.BrowseForFileCmd;
	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.components.buttons.GraphicButtonKube;
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;
	import com.muxxu.kub3dit.engin3d.map.Map;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.graphics.FLipHorizontalIcon;
	import com.muxxu.kub3dit.graphics.FLipVerticalIcon;
	import com.muxxu.kub3dit.graphics.RotationCCWIcon;
	import com.muxxu.kub3dit.graphics.RotationCWIcon;
	import com.muxxu.kub3dit.vo.MapDataParser;
	import com.nurun.components.invalidator.Validable;
	import com.nurun.components.text.CssTextField;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.lang.Disposable;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.math.MathUtils;

	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * @author Francois
	 * @date 11 nov. 2011;
	 */
	public class ImportPanel extends Sprite implements IToolPanel {
		private var _chunksManager:ChunksManager;
		private var _landMark:Shape;
		private var _cmd:BrowseForFileCmd;
		private var _bmd:BitmapData;
		private var _colors:Array;
		private var _loadBt:ButtonKube;
		private var _rotationLabel:CssTextField;
		private var _data:ByteArray;
		private var _clearBt:ButtonKube;
		private var _rCwBt:GraphicButtonKube;
		private var _rCcwBt:GraphicButtonKube;
		private var _rotation:int;
		private var _eraseMode:Boolean;
		private var _flipLabel:CssTextField;
		private var _hFlipBt:GraphicButtonKube;
		private var _vFlipBt:GraphicButtonKube;
		private var _hflipState:Boolean;
		private var _vflipState:Boolean;
		private var _lastDrawGUID:String;
		private var _width:int;
		private var _height:int;
		private var _depth:int;
		private var _mergeMode:CheckBoxKube;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ImportPanel</code>.
		 */
		public function ImportPanel() {
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
		 * @inheritDoc
		 */
		public function get fixedLandmark():Boolean {
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set level(value:int):void { }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function draw(ox:int, oy:int, oz:int, kubeID:int, gridSize:int, gridOffset:Point):void {
			var drawGUID:String = ox + "" + oy + "" + oz + "" + kubeID + "" + eraseMode + "" + _rotation + "" + _hflipState + "" + _vflipState;
			if(drawGUID == _lastDrawGUID) return;
			_lastDrawGUID = drawGUID;
			
			if(_data == null) return;
			
			_data.position = 0;
			var i:int, px:int, py:int, pz:int, tile:int, reg:int;
			var max:int = _colors.length;
			var merge:Boolean = _mergeMode.selected;
			while(_data.bytesAvailable) {
				tile = _data.readUnsignedByte();
				if((tile > 0 || !merge) && tile < max) {
					px = i%_width;
					py = Math.floor(i/_width)%_height;
					pz = oz + Math.floor(i/(_width*_height));
					if(_rotation == 90) {
						reg = px;
						px = _width - py - 1;
						py = reg;
					}else
					if(_rotation == 180) {
						reg = px;
						px = _width - 1 - px;
						py = _height - 1 - py;
					}else
					if(_rotation == 270) {
						reg = px;
						px = py;
						py = _height - reg - 1;
					}
					
					if(_hflipState) {
						px = _width - 1 - px;
					}
					if(_vflipState) {
						py = _height - 1 - py;
					}
					
					px += ox - Math.floor(_width * .5);
					py += oy - Math.floor(_height * .5);
					
					_chunksManager.addInvalidableCube(px, py, pz, _eraseMode? 0 : tile);
				}
				
				i++;
			}
			_chunksManager.invalidate();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_landMark = new Shape();
			_colors = Textures.getInstance().levelColors;
			
			_loadBt = addChild(new ButtonKube(Label.getLabel("toolConfig-import-load"))) as ButtonKube;
			_clearBt = addChild(new ButtonKube(Label.getLabel("toolConfig-import-clear"))) as ButtonKube;
			_rCwBt = addChild(new GraphicButtonKube(new RotationCWIcon())) as GraphicButtonKube;
			_rCcwBt = addChild(new GraphicButtonKube(new RotationCCWIcon())) as GraphicButtonKube;
			_rotationLabel = addChild(new CssTextField("inputToolsConfLabel")) as CssTextField;
			_mergeMode = addChild(new CheckBoxKube(Label.getLabel("toolConfig-import-merge"))) as CheckBoxKube;
			
			_flipLabel = addChild(new CssTextField("inputToolsConfLabel")) as CssTextField;
			_hFlipBt = addChild(new GraphicButtonKube(new FLipHorizontalIcon())) as GraphicButtonKube;
			_vFlipBt = addChild(new GraphicButtonKube(new FLipVerticalIcon())) as GraphicButtonKube;
			
			_rotationLabel.text = Label.getLabel("toolConfig-import-rotate");
			_flipLabel.text = Label.getLabel("toolConfig-import-flip");
			
			_clearBt.x = Math.round(_loadBt.x + _loadBt.width + 5);
			_mergeMode.y = Math.round(_clearBt.y + _clearBt.height + 5);;
			_rotationLabel.y = Math.round(_mergeMode.y + _mergeMode.height + 5);
			_rCcwBt.x = _rotationLabel.x + Math.max(_flipLabel.width, _rotationLabel.width) + 10;
			_rCwBt.x = _rCcwBt.x + _rCcwBt.width + 10;
			_rCwBt.y = _rCcwBt.y = _rotationLabel.y;
			
			_flipLabel.y = Math.round(_rCwBt.y + _rCwBt.height + 5);
			_hFlipBt.x = _rCcwBt.x;
			_vFlipBt.x = _hFlipBt.x + _hFlipBt.width + 10;
			_vFlipBt.y = _hFlipBt.y = _flipLabel.y;
			
			_mergeMode.selected = true;
			
			var i:int, len:int = numChildren;
			for(i = 0; i < len; ++i) {
				if(getChildAt(i) is Validable) Validable(getChildAt(i)).validate();
			}
			
			_clearBt.enabled = _rCwBt.enabled = _rCcwBt.enabled = _hFlipBt.enabled = _vFlipBt.enabled = false;
			_rotationLabel.alpha = _flipLabel.alpha = .4;
			
			_cmd = new BrowseForFileCmd("Sandkube / Kub3dit map", "*.png;*.jpg;*.jpeg");
			_cmd.addEventListener(CommandEvent.COMPLETE, loadImageCompleteHandler);
			addEventListener(MouseEvent.CLICK, clickButtonHandler);
			_mergeMode.addEventListener(MouseEvent.ROLL_OVER, overMergeHandler);
			Textures.getInstance().addEventListener(TextureEvent.CHANGE_SPRITESHEET, spriteSeetChangeHandler);
		}
		
		/**
		 * Called when merge button is rolled over to display its help.
		 */
		private function overMergeHandler(event:MouseEvent):void {
			_mergeMode.dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, Label.getLabel("toolConfig-import-mergeHelp")));
		}
		
		/**
		 * Called when spritesheet changes
		 */
		private function spriteSeetChangeHandler(event:TextureEvent):void {
			_colors = Textures.getInstance().levelColors;
		}
		
		/**
		 * Called when a button is clicked
		 */
		private function clickButtonHandler(event:MouseEvent):void {
			if(event.target == _loadBt ){
				_cmd.execute();
				
			}else if(event.target == _clearBt){
				_data = null;
				_landMark.graphics.clear();
				_clearBt.enabled = _rCwBt.enabled = _rCcwBt.enabled = _hFlipBt.enabled = _vFlipBt.enabled = false;
				_rotationLabel.alpha = _flipLabel.alpha = .4;
				
			}else if(event.target == _rCcwBt){
				_rotation -= 90;
				
			}else if(event.target == _rCwBt){
				_rotation += 90;
				
			}else if(event.target == _hFlipBt){
				_hflipState = !_hflipState;
				
			}else if(event.target == _vFlipBt){
				_vflipState = !_vflipState;
			}
			
			if(_rotation < 0) _rotation = 360 + _rotation;
			if(_rotation > 360) _rotation -= 360;
			drawLandMark();
		}
		
		/**
		 * Called when image image loading completes.
		 */
		private function loadImageCompleteHandler(event:CommandEvent):void {
			var i:int, len:int, px:int, py:int, pz:int, tile:int, sandkubeType:Boolean;
			var ba:ByteArray = event.data as ByteArray;
			_data = new ByteArray();
			try {
				var map:Map = MapDataParser.parse(ba, false, false);
			}catch(error:Error) {
				//not a Kub3dit map. Parse it as a Sandkube image
				sandkubeType = true;
			}
			
			//Gets map's sizes
			if(sandkubeType) {
				_width = _height = 32;
				_depth = 32;//sandkube has one level too.
				ba.position = ba.length - _width*_height*_depth;
				ba.readBytes(_data);
			}else{
				_width = map.mapSizeX;
				_height = map.mapSizeY;
				_depth = map.mapSizeZ;
				_data = map.data;
			}
			
			if(_bmd != null) _bmd.dispose();
			_bmd = new BitmapData(_width, _height, true, 0);
			
			//Draw radar
			len = _width * _height;
			var max:int = _colors.length;
			for(i = 0; i < len; ++i) {
				px = i%_width;
				py = Math.floor(i/_width)%_height;
				pz = _depth-1;
				while(pz>=0) {
					_data.position = px + py*_width + pz*_width*_height;
					tile = _data.readUnsignedByte();
					if(tile > 0) {
						if(tile < max) {
							_bmd.setPixel32(px, py, _colors[tile][pz]);
						}
						break;
					}
					pz--;
				}
			}
			
			_rotation = 0;
			_hflipState = false;
			_vflipState = false;
			
			drawLandMark();
			
			_clearBt.enabled = _rCwBt.enabled = _rCcwBt.enabled = _hFlipBt.enabled = _vFlipBt.enabled = true;
			_rotationLabel.alpha = _flipLabel.alpha = 1;
		}
		
		/**
		 * Draw the landmark
		 */
		private function drawLandMark():void {
			if(_data == null) return;
			
			var m:Matrix = new Matrix();
			m.rotate(_rotation * MathUtils.DEG2RAD);
			if(_rotation == 90) m.translate(_width, 0);
			if(_rotation == 180) m.translate(_width, _height);
			if(_rotation == 270) m.translate(0, _height);
			
			if(_hflipState) m.scale(-1, 1);
			if(_vflipState) m.scale(1, -1);
			
			_landMark.graphics.clear();
			_landMark.graphics.beginBitmapFill(_bmd, m);
			_landMark.graphics.drawRect(0, 0, _width, _height);
		}
		
	}
}