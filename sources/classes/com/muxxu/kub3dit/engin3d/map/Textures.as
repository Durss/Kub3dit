package com.muxxu.kub3dit.engin3d.map {
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
		
		private var _bmd:BitmapData;
		private var _cubesFrames:Array;
		private var _transparent:Array;
		private var _translucide:Array;
		private var _bitmapDatas:Array;
		private var _levelColors:Array;
		
		
		
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
		public function get bitmapData():BitmapData {
			return _bmd;
		}
		
		/**
		 * Gets the cubes frames
		 */
		public function get cubesFrames():Array { return _cubesFrames; }
		
		/**
		 * Gets the transparencies IDs
		 */
		public function get transparencies():Array { return _transparent; }
		
		/**
		 * Gets the translucide IDs
		 */
		public function get translucide():Array { return _translucide; }
		
		/**
		 * Gets the bitmapDatas
		 */
		public function get bitmapDatas():Array { return _bitmapDatas; }
		
		/**
		 * Gets the level colors
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
			_cubesFrames	= [];
			_translucide	= [];
			_transparent	= [];
			_bitmapDatas	= [];
			_levelColors	= [];
			
			//Read sprite sheet map to define kube textures by their ID.
			_bmd = bitmapData;
			var i:int, len:int, lines:Array, chunks:Array, id:int, type:String, w:int, h:int, index:int;
			w = bitmapData.width;
			h = bitmapData.height;
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
				if(_cubesFrames[id] == undefined) {
					_cubesFrames[id] = [];
				}
				//extract the coordinates
				chunks= String(chunks[1]).split(/\s/gi);
				//Compute the index from the coordinates
				index = ((parseInt(chunks[1])/(16+PADDING)) * (w/(16+PADDING)) + parseInt(chunks[0])/(16+PADDING));
				while(type.length > 0) {
					switch(type.charAt(0)){
						case "h": _cubesFrames[id][0] = index; break;
						case "c": _cubesFrames[id][1] = index; break;
						case "b": _cubesFrames[id][2] = index; break;
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
						_cubesFrames[parseInt(chunks[j])][2] = _cubesFrames[parseInt(chunks[j])][0] = -1;
					}
				}
			}
			
			//Extract the bitmapData
			var padding:int					= Textures.PADDING;
			var cols:int					= _bmd.width/(16+padding);
			var textureStepRatio:Number		= 16+padding;
			var top:BitmapData, side:BitmapData, bottom:BitmapData, rect:Rectangle, pt:Point;
			
			rect = new Rectangle(0,0,16,16);
			pt = new Point();
			
			for (var k:String in _cubesFrames) {
				var tileTop:int = _cubesFrames[k][0];
				var tileSide:int = _cubesFrames[k][1];
				var tileBottom:int = _cubesFrames[k][2];
				
				_bitmapDatas[k] = [];
				
				if(tileTop > -1) {
					top = new BitmapData(16, 16, true, 0);
					var tileTopX:Number = (tileTop%cols) * textureStepRatio;
					var tileTopY:Number = Math.floor(tileTop/cols) * textureStepRatio;
					rect.x = tileTopX;
					rect.y = tileTopY;
					top.copyPixels(_bmd, rect, pt);
					_bitmapDatas[k][0] = top;
				}
				
				if(tileSide > -1) {
					side = new BitmapData(16, 16, true, 0);
					var tileSideX:Number = (tileSide%cols) * textureStepRatio;
					var tileSideY:Number = Math.floor(tileSide/cols) * textureStepRatio;
					rect.x = tileSideX;
					rect.y = tileSideY;
					side.copyPixels(_bmd, rect, pt);
					_bitmapDatas[k][1] = side;
				}
				
				if(tileBottom > -1) {
					bottom = new BitmapData(16, 16, true, 0);
					var tileBottomX:Number = (tileSide%cols) * textureStepRatio;
					var tileBottomY:Number = Math.floor(tileSide/cols) * textureStepRatio;
					rect.x = tileBottomX;
					rect.y = tileBottomY;
					bottom.copyPixels(_bmd, rect, pt);
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


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}

internal class SingletonEnforcer{}