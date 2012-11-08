package com.muxxu.kub3dit.engin3d.chunks {
	import com.muxxu.kub3dit.engin3d.map.Map;
	import com.muxxu.kub3dit.engin3d.map.Textures;

	import flash.display.BitmapData;
	import flash.geom.Point;


	
	public class ChunkData {
		public static const CUBE_SIZE_RATIO:Number = 100;
		
		public var _x:int;
		public var _y:int;
		public var _sizeX:int;
		public var _sizeY:int;
		public var _sizeZ:int;
		public var _data:Array;
		public var _buffersOpaque:Vector.<Vector.<Number>>;
		public var _indexesOpaque:Vector.<Vector.<uint>>;
		public var _buffersTransparent:Vector.<Vector.<Number>>;
		public var _indexesTransparent:Vector.<Vector.<uint>>;
		public var _buffersTranslucide:Vector.<Vector.<Number>>;
		public var _indexesTranslucide:Vector.<Vector.<uint>>;
		private var _map:Map;
//		private var _faces:Vector.<Face>;
		
		public function ChunkData(sizeX:int, sizeY:int, sizeZ:int, map:Map) {
			_map = map;
			_sizeX = sizeX;
			_sizeY = sizeY;
			_sizeZ = sizeZ;
		}
		
		/**
		 * Creates the bugger arrays
		 */
		public function createArrays():void {
//			_faces = new Vector.<Face>();
			_buffersOpaque = new Vector.<Vector.<Number>>();
			_indexesOpaque = new Vector.<Vector.<uint>>();
			_buffersTransparent = new Vector.<Vector.<Number>>();
			_indexesTransparent = new Vector.<Vector.<uint>>();
			_buffersTranslucide = new Vector.<Vector.<Number>>();
			_indexesTranslucide = new Vector.<Vector.<uint>>();
			createBufferArrays();
		}

		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			_data = null;
			_map = null;
			_indexesOpaque = null;
			_buffersOpaque = null;
			_indexesTransparent = null;
			_buffersTransparent = null;
//			_faces = new Vector.<Face>();
		}

		
		private function createBufferArrays():void {
			var bmd:BitmapData				= Textures.getInstance().spriteSheet;
			var textureStepRatioX:Number	= 1 / bmd.width;
			var textureStepRatioY:Number	= 1 / bmd.height;
			var textureStretchX:Number		= 1 / bmd.width * .3;
			var textureStretchY:Number		= 1 / bmd.height * .3;
			var textureSizeRatio:Number		= 16 / bmd.width;
			var xloc:int;
			var yloc:int;
			var zloc:int;
			
			var countTmp:int;
			var countOpaque:int;
			var countTransp:int;
			var countTransl:int;
			
			var bufferTmp:Vector.<Number>;
			var indexesTmp:Vector.<uint>;
			
			var bufferOpaque:Vector.<Number>	= new Vector.<Number>();
			var indexesOpaque:Vector.<uint>		= new Vector.<uint>();
			
			var bufferTransp:Vector.<Number>	= new Vector.<Number>();
			var indexesTransp:Vector.<uint>		= new Vector.<uint>();
			
			var bufferTransl:Vector.<Number>	= new Vector.<Number>();
			var indexesTransl:Vector.<uint>		= new Vector.<uint>();
			
			var b_indexTmp:int;
			var i_indexTmp:int;
			
			var b_indexOpaque:int;
			var i_indexOpaque:int;
			
			var b_indexTransp:int;
			var i_indexTransp:int;
			
			var b_indexTransl:int;
			var i_indexTransl:int;
			
			var cubeSizeRatio:Number = CUBE_SIZE_RATIO;
			var vertexOffset:Number = .5 * cubeSizeRatio;
			var px:int = _x * cubeSizeRatio;
			var py:int = _y * cubeSizeRatio;
			var wasCubeOver:Boolean;
			var dropShadow:Boolean;
			var transparent:Array = Textures.getInstance().transparencies;
			var translucide:Array = Textures.getInstance().translucide;
			var backfaceTest:Array = [];
			for (var i:String in translucide) {
				if(translucide[i] != undefined) backfaceTest[i] = translucide[i];
			}
			for (i in transparent) {
				if(transparent[i] != undefined) backfaceTest[i] = transparent[i];
			}
			
			var cubesFrameCoos:Array = Textures.getInstance().cubesFrames;
//			for(zloc = 0; zloc < _sizeZ; zloc++) {
			for(yloc = 0; yloc < _sizeY; ++yloc) {
				for (xloc = 0; xloc < _sizeX; ++xloc) {
					dropShadow = false;
					wasCubeOver = false;
					for(zloc = _sizeZ-1; zloc > -1; --zloc) {
					
						var tile:int = _data[zloc][yloc][xloc];
						if (tile != 0) {
							
							var xLoc2:int = xloc * cubeSizeRatio;
							var yLoc2:int = yloc * cubeSizeRatio;
							var zLoc2:int = zloc * cubeSizeRatio;
							
							var tileTop:Point = cubesFrameCoos[tile][0];
							var tileSide:Point = cubesFrameCoos[tile][1];
							var tileBottom:Point = cubesFrameCoos[tile][2];
							
							var tileTopX:Number = tileTop.x * textureStepRatioX;
							var tileTopY:Number = tileTop.y * textureStepRatioY;
							var tileSideX:Number = tileSide.x * textureStepRatioX;
							var tileSideY:Number = tileSide.y * textureStepRatioY;
							
							var tileBottomX:Number = tileBottom.x * textureStepRatioX;
							var tileBottomY:Number = tileBottom.y * textureStepRatioY;

							var underCube:int	= _map.getTile(xloc + _x, yloc + _y, zloc - 1);
							var leftCube:int	= _map.getTile(xloc + _x + 1, yloc + _y, zloc);
							var frontCube:int	= _map.getTile(xloc + _x, yloc + _y - 1, zloc);
							var backCube:int	= _map.getTile(xloc + _x, yloc + _y + 1, zloc);
							var rightCube:int	= _map.getTile(xloc + _x - 1, yloc + _y, zloc);
							var overCube:int	= _map.getTile(xloc + _x, yloc + _y, zloc + 1);
							
//							var alpha:Number = translucide[tile]===true? .4 : 1;
							if(!dropShadow && wasCubeOver && overCube == 0) dropShadow = true;
							var brightness:Number = dropShadow? .8: 1;
//							var brightness:Number = 1;
//							brightness += (_x+_y)%16 == 0? 1 : 0;
							var isTransparent:Boolean = transparent[tile]===true;
							var isTranslucide:Boolean = translucide[tile]===true;
							countTmp	= isTranslucide? countTransl :		isTransparent? countTransp :	countOpaque;
							i_indexTmp	= isTranslucide? i_indexTransl :	isTransparent? i_indexTransp :	i_indexOpaque;
							b_indexTmp	= isTranslucide? b_indexTransl :	isTransparent? b_indexTransp :	b_indexOpaque;
							bufferTmp	= isTranslucide? bufferTransl :		isTransparent? bufferTransp :	bufferOpaque;
							indexesTmp	= isTranslucide? indexesTransl :	isTransparent? indexesTransp :	indexesOpaque;
							
							//BACK
							if((backCube == 0 || backfaceTest[tile] === true || backfaceTest[backCube] === true)
							&& tileSide.x > -1) {
								indexesTmp[i_indexTmp++] = 0 + countTmp;
								indexesTmp[i_indexTmp++] = 1 + countTmp;
								indexesTmp[i_indexTmp++] = 2 + countTmp;
								
								indexesTmp[i_indexTmp++] = 0 + countTmp;
								indexesTmp[i_indexTmp++] = 2 + countTmp;
								indexesTmp[i_indexTmp++] = 3 + countTmp;
								countTmp += 4;
								
								bufferTmp[b_indexTmp++] = -vertexOffset + xLoc2 + px; //X
								bufferTmp[b_indexTmp++] = vertexOffset + yLoc2 + py; //Y
								bufferTmp[b_indexTmp++] = vertexOffset - zLoc2; //Z
								bufferTmp[b_indexTmp++] = tileSideX + textureSizeRatio - textureStretchX; //U
								bufferTmp[b_indexTmp++] = tileSideY + textureSizeRatio - textureStretchY; //V
//								bufferTmp[b_indexTmp++] = alpha;//Alpha
								bufferTmp[b_indexTmp++] = .9;//Brightness
								
								bufferTmp[b_indexTmp++] = -vertexOffset + xLoc2 + px;
								bufferTmp[b_indexTmp++] = vertexOffset + yLoc2 + py;
								bufferTmp[b_indexTmp++] = -vertexOffset - zLoc2;
								bufferTmp[b_indexTmp++] = tileSideX + textureSizeRatio - textureStretchX;
								bufferTmp[b_indexTmp++] = tileSideY + textureStretchY;
//								bufferTmp[b_indexTmp++] = alpha;
								bufferTmp[b_indexTmp++] = .9;
								
								bufferTmp[b_indexTmp++] = vertexOffset + xLoc2 + px;
								bufferTmp[b_indexTmp++] = vertexOffset + yLoc2 + py;
								bufferTmp[b_indexTmp++] = -vertexOffset - zLoc2;
								bufferTmp[b_indexTmp++] = tileSideX + textureStretchX;
								bufferTmp[b_indexTmp++] = tileSideY + textureStretchY;
//								bufferTmp[b_indexTmp++] = alpha;
								bufferTmp[b_indexTmp++] = .9;
							
								bufferTmp[b_indexTmp++] = vertexOffset + xLoc2 + px;
								bufferTmp[b_indexTmp++] = vertexOffset + yLoc2 + py;
								bufferTmp[b_indexTmp++] = vertexOffset - zLoc2;
								bufferTmp[b_indexTmp++] = tileSideX + textureStretchX;
								bufferTmp[b_indexTmp++] = tileSideY + textureSizeRatio - textureStretchY;
//								bufferTmp[b_indexTmp++] = alpha;
								bufferTmp[b_indexTmp++] = .9;
								
//								_faces.push(new Face(buffer, index, 7, false));
//								_faces.push(new Face(buffer, index, 7, true));
							}
							
							
							//FRONT
							if ((frontCube == 0 || backfaceTest[tile] === true || backfaceTest[frontCube] === true)
							&& tileSide.x > -1) {
								indexesTmp[i_indexTmp++] = 0 + countTmp;
								indexesTmp[i_indexTmp++] = 1 + countTmp;
								indexesTmp[i_indexTmp++] = 2 + countTmp;
								
								indexesTmp[i_indexTmp++] = 0 + countTmp;
								indexesTmp[i_indexTmp++] = 2 + countTmp;
								indexesTmp[i_indexTmp++] = 3 + countTmp;
								countTmp += 4;

								bufferTmp[b_indexTmp++] = -vertexOffset + xLoc2 + px;
								bufferTmp[b_indexTmp++] = -vertexOffset + yLoc2 + py;
								bufferTmp[b_indexTmp++] = -vertexOffset - zLoc2;
								bufferTmp[b_indexTmp++] = tileSideX  + textureSizeRatio - textureStretchX;
								bufferTmp[b_indexTmp++] = tileSideY + textureStretchY;
//								bufferTmp[b_indexTmp++] = alpha;
								bufferTmp[b_indexTmp++] = .9;
								
								bufferTmp[b_indexTmp++] = -vertexOffset + xLoc2 + px;
								bufferTmp[b_indexTmp++] = -vertexOffset + yLoc2 + py;
								bufferTmp[b_indexTmp++] = vertexOffset - zLoc2;
								bufferTmp[b_indexTmp++] = tileSideX + textureSizeRatio - textureStretchX;
								bufferTmp[b_indexTmp++] = tileSideY + textureSizeRatio - textureStretchY;
//								bufferTmp[b_indexTmp++] = alpha;
								bufferTmp[b_indexTmp++] = .9;

								bufferTmp[b_indexTmp++] = vertexOffset + xLoc2 + px;
								bufferTmp[b_indexTmp++] = -vertexOffset + yLoc2 + py;
								bufferTmp[b_indexTmp++] = vertexOffset - zLoc2;
								bufferTmp[b_indexTmp++] = tileSideX + textureStretchX;
								bufferTmp[b_indexTmp++] = tileSideY + textureSizeRatio - textureStretchY;
//								bufferTmp[b_indexTmp++] = alpha;
								bufferTmp[b_indexTmp++] = .9;
								
								bufferTmp[b_indexTmp++] = vertexOffset + xLoc2 + px;
								bufferTmp[b_indexTmp++] = -vertexOffset + yLoc2 + py;
								bufferTmp[b_indexTmp++] = -vertexOffset - zLoc2;
								bufferTmp[b_indexTmp++] = tileSideX + textureStretchX;
								bufferTmp[b_indexTmp++] = tileSideY + textureStretchY;
//								bufferTmp[b_indexTmp++] = alpha;
								bufferTmp[b_indexTmp++] = .9;
								
//								_faces.push(new Face(buffer, index, 7, false));
//								_faces.push(new Face(buffer, index, 7, true));
							}
							
							
							//LEFT
							if ((leftCube == 0 || backfaceTest[tile] === true || backfaceTest[leftCube] === true)
							&& tileSide.x > -1) {
								indexesTmp[i_indexTmp++] = 0 + countTmp;
								indexesTmp[i_indexTmp++] = 1 + countTmp;
								indexesTmp[i_indexTmp++] = 2 + countTmp;
								
								indexesTmp[i_indexTmp++] = 0 + countTmp;
								indexesTmp[i_indexTmp++] = 2 + countTmp;
								indexesTmp[i_indexTmp++] = 3 + countTmp;
								countTmp += 4;
								
								bufferTmp[b_indexTmp++] = vertexOffset + xLoc2 + px;
								bufferTmp[b_indexTmp++] = vertexOffset + yLoc2 + py;
								bufferTmp[b_indexTmp++] = vertexOffset - zLoc2;
								bufferTmp[b_indexTmp++] = tileSideX + textureSizeRatio - textureStretchX;
								bufferTmp[b_indexTmp++] = tileSideY + textureSizeRatio - textureStretchY;
//								bufferTmp[b_indexTmp++] = alpha;
								bufferTmp[b_indexTmp++] = brightness;
								
								bufferTmp[b_indexTmp++] = vertexOffset + xLoc2 + px;
								bufferTmp[b_indexTmp++] = vertexOffset + yLoc2 + py;
								bufferTmp[b_indexTmp++] = -vertexOffset - zLoc2;
								bufferTmp[b_indexTmp++] = tileSideX + textureSizeRatio - textureStretchX;
								bufferTmp[b_indexTmp++] = tileSideY + textureStretchY;
//								bufferTmp[b_indexTmp++] = alpha;
								bufferTmp[b_indexTmp++] = brightness;
								
								bufferTmp[b_indexTmp++] = vertexOffset + xLoc2 + px;
								bufferTmp[b_indexTmp++] = -vertexOffset + yLoc2 + py;
								bufferTmp[b_indexTmp++] = -vertexOffset - zLoc2;
								bufferTmp[b_indexTmp++] = tileSideX + textureStretchX;
								bufferTmp[b_indexTmp++] = tileSideY + textureStretchY;
//								bufferTmp[b_indexTmp++] = alpha;
								bufferTmp[b_indexTmp++] = brightness;
				
								bufferTmp[b_indexTmp++] = vertexOffset + xLoc2 + px;
								bufferTmp[b_indexTmp++] = -vertexOffset + yLoc2 + py;
								bufferTmp[b_indexTmp++] = vertexOffset - zLoc2;
								bufferTmp[b_indexTmp++] = tileSideX + textureStretchX;
								bufferTmp[b_indexTmp++] = tileSideY + textureSizeRatio - textureStretchY;
//								bufferTmp[b_indexTmp++] = alpha;
								bufferTmp[b_indexTmp++] = brightness;
								
//								_faces.push(new Face(buffer, index, 7, false));
//								_faces.push(new Face(buffer, index, 7, true));
							}
							
							
							//RIGHT
							if ((rightCube == 0 || backfaceTest[tile] === true || backfaceTest[rightCube] === true)
							&& tileSide.x > -1) {
								indexesTmp[i_indexTmp++] = 0 + countTmp;
								indexesTmp[i_indexTmp++] = 1 + countTmp;
								indexesTmp[i_indexTmp++] = 2 + countTmp;
								
								indexesTmp[i_indexTmp++] = 0 + countTmp;
								indexesTmp[i_indexTmp++] = 2 + countTmp;
								indexesTmp[i_indexTmp++] = 3 + countTmp;
								countTmp += 4;
							              
								bufferTmp[b_indexTmp++] = -vertexOffset + xLoc2 + px;
								bufferTmp[b_indexTmp++] = vertexOffset + yLoc2 + py;
								bufferTmp[b_indexTmp++] = -vertexOffset - zLoc2;
								bufferTmp[b_indexTmp++] = tileSideX + textureSizeRatio - textureStretchX;
								bufferTmp[b_indexTmp++] =  tileSideY + textureStretchY;
//								bufferTmp[b_indexTmp++] = alpha;
								bufferTmp[b_indexTmp++] = brightness;
								
								bufferTmp[b_indexTmp++] = -vertexOffset + xLoc2 + px;
								bufferTmp[b_indexTmp++] = vertexOffset + yLoc2 + py;
								bufferTmp[b_indexTmp++] = vertexOffset - zLoc2;
								bufferTmp[b_indexTmp++] = tileSideX + textureSizeRatio - textureStretchX;
								bufferTmp[b_indexTmp++] = tileSideY + textureSizeRatio - textureStretchY;
//								bufferTmp[b_indexTmp++] = alpha;
								bufferTmp[b_indexTmp++] = brightness;
								
								bufferTmp[b_indexTmp++] = -vertexOffset + xLoc2 + px;
								bufferTmp[b_indexTmp++] = -vertexOffset + yLoc2 + py;
								bufferTmp[b_indexTmp++] = vertexOffset - zLoc2;
								bufferTmp[b_indexTmp++] = tileSideX + textureStretchX;
								bufferTmp[b_indexTmp++] = tileSideY + textureSizeRatio - textureStretchY;
//								bufferTmp[b_indexTmp++] = alpha;
								bufferTmp[b_indexTmp++] = brightness;
								
								bufferTmp[b_indexTmp++] = -vertexOffset + xLoc2 + px;
								bufferTmp[b_indexTmp++] = -vertexOffset + yLoc2 + py;
								bufferTmp[b_indexTmp++] = -vertexOffset - zLoc2;
								bufferTmp[b_indexTmp++] = tileSideX + textureStretchX;
								bufferTmp[b_indexTmp++] = tileSideY + textureStretchY;
//								bufferTmp[b_indexTmp++] = alpha;
								bufferTmp[b_indexTmp++] = brightness;
								
//								_faces.push(new Face(buffer, index, 7, false));
//								_faces.push(new Face(buffer, index, 7, true));
							}
							
							
							
							// TOP
							if(tileTop.x > -1
							&& (overCube == 0 || backfaceTest[tile] === true || backfaceTest[overCube] === true)) {
								indexesTmp[i_indexTmp++] = 0 + countTmp;
								indexesTmp[i_indexTmp++] = 1 + countTmp;
								indexesTmp[i_indexTmp++] = 2 + countTmp;
								
								indexesTmp[i_indexTmp++] = 0 + countTmp;
								indexesTmp[i_indexTmp++] = 2 + countTmp;
								indexesTmp[i_indexTmp++] = 3 + countTmp;
								countTmp += 4;
								
								bufferTmp[b_indexTmp++] = -vertexOffset + xLoc2 + px;
								bufferTmp[b_indexTmp++] = vertexOffset + yLoc2 + py;
								bufferTmp[b_indexTmp++] = -vertexOffset - zLoc2;
								bufferTmp[b_indexTmp++] = tileTopX + textureSizeRatio - textureStretchX;
								bufferTmp[b_indexTmp++] =  tileTopY + textureSizeRatio - textureStretchY;
//								bufferTmp[b_indexTmp++] = alpha;
								bufferTmp[b_indexTmp++] = brightness;
								
								bufferTmp[b_indexTmp++] = -vertexOffset + xLoc2 + px;
								bufferTmp[b_indexTmp++] = -vertexOffset + yLoc2 + py;
								bufferTmp[b_indexTmp++] = -vertexOffset - zLoc2;
								bufferTmp[b_indexTmp++] = tileTopX + textureStretchX;
								bufferTmp[b_indexTmp++] = tileTopY + textureSizeRatio - textureStretchY;
//								bufferTmp[b_indexTmp++] = alpha;
								bufferTmp[b_indexTmp++] = brightness;
								
								bufferTmp[b_indexTmp++] = vertexOffset + xLoc2 + px;
								bufferTmp[b_indexTmp++] = -vertexOffset + yLoc2 + py;
								bufferTmp[b_indexTmp++] = -vertexOffset - zLoc2;
								bufferTmp[b_indexTmp++] = tileTopX + textureStretchX;
								bufferTmp[b_indexTmp++] = tileTopY + textureStretchY;
//								bufferTmp[b_indexTmp++] = alpha;
								bufferTmp[b_indexTmp++] = brightness;
								
								bufferTmp[b_indexTmp++] = vertexOffset + xLoc2 + px;
								bufferTmp[b_indexTmp++] = vertexOffset + yLoc2 + py;
								bufferTmp[b_indexTmp++] = -vertexOffset - zLoc2;
								bufferTmp[b_indexTmp++] = tileTopX + textureSizeRatio - textureStretchX;
								bufferTmp[b_indexTmp++] = tileTopY + textureStretchY;
//								bufferTmp[b_indexTmp++] = alpha;
								bufferTmp[b_indexTmp++] = brightness;
								
//								_faces.push(new Face(buffer, index, 7, false));
//								_faces.push(new Face(buffer, index, 7, true));
							}
							
							
							
							// BOTTOM
							if (zLoc2 > 0 && tileBottom.x > -1
							&& (underCube == 0 || backfaceTest[tile] === true || backfaceTest[underCube] === true) ) {
								indexesTmp[i_indexTmp++] = 0 + countTmp;
								indexesTmp[i_indexTmp++] = 1 + countTmp;
								indexesTmp[i_indexTmp++] = 2 + countTmp;
								
								indexesTmp[i_indexTmp++] = 0 + countTmp;
								indexesTmp[i_indexTmp++] = 2 + countTmp;
								indexesTmp[i_indexTmp++] = 3 + countTmp;
								countTmp += 4;
								
								//back right
								bufferTmp[b_indexTmp++] = -vertexOffset + xLoc2 + px; //X
								bufferTmp[b_indexTmp++] = vertexOffset + yLoc2 + py; //Y
								bufferTmp[b_indexTmp++] = vertexOffset - zLoc2; //Z
								bufferTmp[b_indexTmp++] = tileBottomX + textureSizeRatio - textureStretchX;
								bufferTmp[b_indexTmp++] = tileBottomY + textureSizeRatio - textureStretchY;
//								bufferTmp[b_indexTmp++] = alpha;
								bufferTmp[b_indexTmp++] = brightness - .35;
								
								//back left
								bufferTmp[b_indexTmp++] = vertexOffset + xLoc2 + px;
								bufferTmp[b_indexTmp++] = vertexOffset + yLoc2 + py;
								bufferTmp[b_indexTmp++] = vertexOffset - zLoc2;
								bufferTmp[b_indexTmp++] = tileBottomX + textureSizeRatio - textureStretchX;
								bufferTmp[b_indexTmp++] = tileBottomY + textureStretchY;
//								bufferTmp[b_indexTmp++] = alpha;
								bufferTmp[b_indexTmp++] = brightness - .35;
								
								//Front left
								bufferTmp[b_indexTmp++] = vertexOffset + xLoc2 + px;
								bufferTmp[b_indexTmp++] = -vertexOffset + yLoc2 + py;
								bufferTmp[b_indexTmp++] = vertexOffset - zLoc2;
								bufferTmp[b_indexTmp++] = tileBottomX + textureStretchX;
								bufferTmp[b_indexTmp++] = tileBottomY + textureStretchY;
//								bufferTmp[b_indexTmp++] = alpha;
								bufferTmp[b_indexTmp++] = brightness - .35;
								
								//Front right
								bufferTmp[b_indexTmp++] = -vertexOffset + xLoc2 + px;
								bufferTmp[b_indexTmp++] = -vertexOffset + yLoc2 + py;
								bufferTmp[b_indexTmp++] = vertexOffset - zLoc2;
								bufferTmp[b_indexTmp++] = tileBottomX + textureStretchX;
								bufferTmp[b_indexTmp++] = tileBottomY + textureSizeRatio - textureStretchY;
//								bufferTmp[b_indexTmp++] = alpha;
								bufferTmp[b_indexTmp++] = brightness - .35;
								
//								_faces.push(new Face(buffer, index, 7, false));
//								_faces.push(new Face(buffer, index, 7, true));
							}
						
							if(zloc < _sizeZ-1) wasCubeOver = true;
						
							if(bufferTmp.length + 6*4*6 >= 65535) {
								if(isTransparent) {
									_buffersTransparent.push(bufferTmp);
									_indexesTransparent.push(indexesTmp);
									bufferTransp = new Vector.<Number>();
									indexesTransp = new Vector.<uint>();
									i_indexTransp = 0;
									b_indexTransp= 0;
									countTransp= 0;
									
								}else if(isTranslucide) {
									_buffersTranslucide.push(bufferTmp);
									_indexesTranslucide.push(indexesTmp);
									bufferTransl = new Vector.<Number>();
									indexesTransl= new Vector.<uint>();
									i_indexTransl= 0;
									b_indexTransl= 0;
									countTransl= 0;
									
								}else{
									_buffersOpaque.push(bufferTmp);
									_indexesOpaque.push(indexesTmp);
									bufferOpaque = new Vector.<Number>();
									indexesOpaque = new Vector.<uint>();
									i_indexOpaque = 0;
									b_indexOpaque = 0;
									countOpaque = 0;
								}
							}else{
								if(isTransparent) {
									i_indexTransp = i_indexTmp;
									b_indexTransp = b_indexTmp;
									countTransp = countTmp;
								}else if(isTranslucide) {
									i_indexTransl = i_indexTmp;
									b_indexTransl = b_indexTmp;
									countTransl = countTmp;
								}else{
									i_indexOpaque = i_indexTmp;
									b_indexOpaque = b_indexTmp;
									countOpaque = countTmp;
								}
							}
						}
					}
				}
			}
			
			if(bufferOpaque.length > 0) {
				_buffersOpaque.push(bufferOpaque);
				_indexesOpaque.push(indexesOpaque);
			}
			
			if(bufferTransp.length > 0) {
				_buffersTransparent.push(bufferTransp);
				_indexesTransparent.push(indexesTransp);
			}
			
			if(bufferTransl.length > 0) {
				_buffersTranslucide.push(bufferTransl);
				_indexesTranslucide.push(indexesTransl);
			}
		}
	}

}