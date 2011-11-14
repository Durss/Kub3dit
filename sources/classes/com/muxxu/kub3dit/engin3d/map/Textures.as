package com.muxxu.kub3dit.engin3d.map {
	import mx.utils.ColorUtil;
	import com.nurun.utils.color.ColorFunctions;
	import com.muxxu.kub3dit.exceptions.Kub3ditExceptionSeverity;
	import com.nurun.structure.environnement.label.Label;
	import com.muxxu.kub3dit.exceptions.Kub3ditException;
	import com.muxxu.kub3dit.vo.CubeData;
	import flash.utils.ByteArray;
	import com.nurun.utils.string.StringUtils;

	import flash.display.BitmapData;
	import flash.errors.IllegalOperationError;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	/**
	 * Singleton Textures
	 * 
	 * @author Francois
	 * @date 4 sept. 2011;
	 */
	public class Textures {
		
		private static var _instance:Textures;
		public static const PADDING:int = 1;
		
		private var _spriteSheet:BitmapData;
		private var _cubesFramesCoos:Array;
		private var _transparent:Array;
		private var _translucide:Array;
		private var _bitmapDatas:Array;
		private var _levelColors:Array;
		private var _customKubes:Array;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Textures</code>.
		 */
		public function Textures(enforcer:SingletonEnforcer) {
			if(enforcer == null) {
				throw new IllegalOperationError("A singleton can't be instanciated. Use static accessor 'getInstance()'!");
			}
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Singleton instance getter.
		 */
		public static function getInstance():Textures {
			if(_instance == null) _instance = new  Textures(new SingletonEnforcer());
			return _instance;	
		}
		
		/**
		 * Gets the textures bitmapdata
		 */
		public function get spriteSheet():BitmapData {
			return _spriteSheet;
		}
		
		/**
		 * Gets the cubes frames
		 * 
		 * 2D array structured like that :
		 * [
		 * 	kubeID:	[
		 * 				0(top face): Point()
		 * 				1(side face): Point()
		 * 				2(bottom face): Point()
		 * 			]
		 * }
		 */
		public function get cubesFrames():Array { return _cubesFramesCoos; }
		
		/**
		 * Gets the transparencies IDs
		 * 
		 * The returned data is an associative array whose keys are IDs of the
		 * kubes containing transparency.
		 */
		public function get transparencies():Array { return _transparent; }
		
		/**
		 * Gets the translucide IDs
		 * 
		 * The returned data is an associative array whose keys are IDs of the
		 * kubes that should be translucide.
		 */
		public function get translucide():Array { return _translucide; }
		
		/**
		 * Gets the bitmapDatas
		 * 
		 * 2D array structured like that :
		 * [
		 * 	kubeID:	[
		 * 				0(top face): BitmapData()
		 * 				1(side face): BitmapData()
		 * 				2(bottom face): BitmapData()
		 * 			]
		 * }
		 */
		public function get bitmapDatas():Array { return _bitmapDatas; }
		
		/**
		 * Gets the level colors
		 * 
		 * 2D array structured like that :
		 * [
		 * 	kubeID:	[
		 * 				1(level): uint
		 * 				2(level): uint
		 * 				...(level): uint
		 * 				31(level): uint
		 * 			]
		 * }
		 */
		public function get levelColors():Array { return _levelColors; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Initialize the class.
		 * 
		 * @param spritesMap	file that defines the textures coordinates and relations
		 * @param bitmapData	bitmapData containing the textures
		 * @param additionals	contains the additional informations (transparencies, translucides, etc..)
		 */
		public function initialize(spritesMap:String, additionals:String, bitmapData:BitmapData, colors:BitmapData):void {
			_cubesFramesCoos= [];
			_translucide	= [];
			_transparent	= [];
			_bitmapDatas	= [];
			_levelColors	= [];
			_customKubes	= [];
			
			//Read sprite sheet map to define kube textures by their ID.
			_spriteSheet = new BitmapData(1024, 1024, true, 0x55ff0000);
			_spriteSheet.copyPixels(bitmapData, bitmapData.rect, new Point());
			
			var i:int, len:int, lines:Array, chunks:Array, id:int, type:String, w:int, h:int;
			w = _spriteSheet.width;
			h = _spriteSheet.height;
			spritesMap = spritesMap.replace(/(\r|\n)+/gi, "\n");
			lines = spritesMap.split(/\n/gi);
			len = lines.length;
			for(i = 0; i < len; ++i) {
				if(StringUtils.trim(String(lines[i])).length == 0) continue;
				//seperate id from coordinates
				chunks = String(lines[i]).split(/\s=\s/gi);
				//Get the ID
				id = parseInt(String(chunks[0]).replace(/[^\d]/gi, ""));
				//Get the type
				type = String(chunks[0]).replace(/[\d]/gi, "");
				if(_cubesFramesCoos[id] == undefined) {
					_cubesFramesCoos[id] = [];
				}
				//extract the coordinates
				chunks = String(chunks[1]).split(/\s/gi);
				//Compute the index from the coordinates
				while(type.length > 0) {
					switch(type.charAt(0)){
						case "h": _cubesFramesCoos[id][0] = new Point(parseInt(chunks[0]), parseInt(chunks[1])); break;
						case "c": _cubesFramesCoos[id][1] = new Point(parseInt(chunks[0]), parseInt(chunks[1])); break;
						case "b": _cubesFramesCoos[id][2] = new Point(parseInt(chunks[0]), parseInt(chunks[1])); break;
						default: throw new Error("Unknow face type \""+type.charAt(0)+"\"!");
					}
					type = type.substr(1, type.length - 1);
				}
			}
			
			//Parse additional informations to define the translucide and transparent
			//kubes and to remove the unnecessary faces (top/bottom grass kubes for expl).
			var j:int, lenJ:int;
			lines = additionals.split(/\n/gi);
			len = lines.length;
			for(i = 0; i < len; ++i) {
				chunks = String(lines[i]).split(/\s=\s/gi);
				if(chunks[0] == "translucides") {
					chunks = StringUtils.trim(String(chunks[1])).split(/\s/g);
					lenJ = chunks.length;
					for(j = 0; j < lenJ; ++j) {
						_translucide[parseInt(chunks[j])] = true;
						_transparent[parseInt(chunks[j])] = true;
					}
					
				}else if(chunks[0] == "transparents") {
					chunks = StringUtils.trim(String(chunks[1])).split(/\s/g);
					lenJ = chunks.length;
					for(j = 0; j < lenJ; ++j) {
						_transparent[parseInt(chunks[j])] = true;
					}
					
				}else if(chunks[0] == "noBottomTop") {
					chunks = StringUtils.trim(String(chunks[1])).split(/\s/g);
					lenJ = chunks.length;
					for(j = 0; j < lenJ; ++j) {
						_cubesFramesCoos[parseInt(chunks[j])][2] = _cubesFramesCoos[parseInt(chunks[j])][0] = new Point(-1,-1);
					}
				}
			}
			
			//Extract the bitmapData
			var top:BitmapData, side:BitmapData, bottom:BitmapData, rect:Rectangle, pt:Point;
			
			rect = new Rectangle(0,0,16,16);
			pt = new Point();
			
			for (var k:String in _cubesFramesCoos) {
				var tileTop:Point = _cubesFramesCoos[k][0];
				var tileSide:Point = _cubesFramesCoos[k][1];
				var tileBottom:Point = _cubesFramesCoos[k][2];
				
				_bitmapDatas[k] = [];
				
				if(tileTop.x > -1) {
					top = new BitmapData(16, 16, true, 0);
					rect.x = tileTop.x;
					rect.y = tileTop.y;
					top.copyPixels(_spriteSheet, rect, pt);
					_bitmapDatas[k][0] = top;
				}
				
				if(tileSide.x > -1) {
					side = new BitmapData(16, 16, true, 0);
					rect.x = tileSide.x;
					rect.y = tileSide.y;
					side.copyPixels(_spriteSheet, rect, pt);
					_bitmapDatas[k][1] = side;
				}
				
				if(tileBottom.x > -1) {
					bottom = new BitmapData(16, 16, true, 0);
					rect.x = tileBottom.x;
					rect.y = tileBottom.y;
					bottom.copyPixels(_spriteSheet, rect, pt);
					_bitmapDatas[k][2] = bottom;
				}
			}
			
			
			//initializes the level colors
			w = colors.width;
			len = w * colors.height;
			var pixels:ByteArray = colors.getPixels(colors.rect);
			for(i = 0; i < len; ++i) {
				id = int(i/w) + 1;
				if(i%w == 0) {
					_levelColors[id] = [];
				}
				pixels.position = i*4;
				_levelColors[id][i%w] = pixels.readUnsignedInt();
			}
		}
		
		/**
		 * Adds a custom kube
		 */
		public function addKube(data:CubeData):void {
			var max:int = 30;
			var total:int = _customKubes.length;
			if(total == max) {
				throw new Kub3ditException(Label.getLabel("maxCustomKubesError").replace(/\$\{VALUE\}/gi, max), Kub3ditExceptionSeverity.INFO);
				return;
			}
			_customKubes.push(data);
			var id:int = 256 - _customKubes.length;
			
			_levelColors[id] = [];
			_bitmapDatas[id] = [];
			_cubesFramesCoos[id] = [];
			
			//Registers the bitmap faces
			_bitmapDatas[id][0] = data.kub.faceTop;//TOP
			_bitmapDatas[id][1] = data.kub.faceSides;//SIDE
			_bitmapDatas[id][2] = data.kub.faceBottom;//BOTTOM
			
			//Distribute the items from the bottom right to the left - top
			var margin:int = _spriteSheet.width - Math.floor(_spriteSheet.width/(16+PADDING))*(16+PADDING);
			var pos:Point = new Point();
			pos.y = _spriteSheet.height - PADDING - margin - 16;
			
			//Update texture and store the coordinates
			var i:int, j:int, color:uint, bmd:BitmapData, pixels:ByteArray;
			var frame:int = total*3;
			for(i = 0; i < 3; ++i) {
				if(i == 0) bmd = data.kub.faceTop;
				if(i == 1) bmd = data.kub.faceSides;
				if(i == 2) bmd = data.kub.faceBottom;
				
				do {
					pos.x = _spriteSheet.width - margin - (16+PADDING) * (frame+1);
					if(pos.x < 0) {
						frame -= Math.floor((_spriteSheet.width - PADDING) / (16+PADDING));
						pos.y -= 16+PADDING;
					}
				}while(pos.x < 0);
				_cubesFramesCoos[id][i] = pos.clone();
				_spriteSheet.copyPixels(bmd, bmd.rect, pos);
				
				//Check for transparency on the texture
				if(_transparent[id] !== true) {
					pixels = bmd.getPixels(bmd.rect);
					pixels.position = 0;
					while(pixels.bytesAvailable) {
						if(((pixels.readUnsignedInt() >> 24) & 0xff) < 0xff) {
							_transparent[id] = true;
							break;
						}
					}
				}
				
				//Compute levels colors
				if(i == 0) {
					color = ColorFunctions.bitmapDataAverage(bmd, 100, bmd.rect);
					var sat:Number = ColorFunctions.getSaturation(color); 
					for(j = 1; j < 32; j+=2) {
						_levelColors[id][j] = _levelColors[id][j+1] =
						ColorFunctions.setRGBSaturation(ColorUtil.adjustBrightness2(color, j/2*3), sat + (240-sat) * .35/16 * j ) + 0xff000000;
					}
					_levelColors[id][0] = _levelColors[id][1] = _levelColors[id][2];
				}
				frame ++;
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}

internal class SingletonEnforcer{}