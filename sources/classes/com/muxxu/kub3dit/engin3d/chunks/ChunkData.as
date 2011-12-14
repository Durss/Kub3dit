package com.muxxu.kub3dit.engin3d.chunks {
	import com.muxxu.kub3dit.engin3d.map.Map;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.engin3d.vo.Face;
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
		public var _bufferArray:Vector.<Number>;
		public var _indexesArray:Vector.<uint>;
		private var _map:Map;
		private var _faces:Vector.<Face>;
		
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
			_faces = new Vector.<Face>();
			_indexesArray = new Vector.<uint>();
			_bufferArray = createBufferArray();
		}

		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			_data = null;
			_map = null;
			_bufferArray = null;
			_indexesArray = null;
			_faces = new Vector.<Face>();
		}

		
		private function createBufferArray():Vector.<Number> {
			var bmd:BitmapData				= Textures.getInstance().spriteSheet;
			var textureStepRatioX:Number	= 1 / bmd.width;
			var textureStepRatioY:Number	= 1 / bmd.height;
			var textureStretchX:Number		= 1 / bmd.width * .3;
			var textureStretchY:Number		= 1 / bmd.height * .3;
			var textureSizeRatio:Number		= 16 / bmd.width;
			var count:int = 0;
			var buffer:Vector.<Number> = new Vector.<Number>();
			var xloc:int;
			var yloc:int;
			var zloc:int;
			var index:int = 0;
			var i_index:int = 0;
			var cubeSizeRatio:Number = CUBE_SIZE_RATIO;
			var vertexOffset:Number = .5 * cubeSizeRatio;
			var px:int = _x * cubeSizeRatio;
			var py:int = _y * cubeSizeRatio;
//			var wasCubeOver:Boolean;
//			var dropShadow:Boolean;
			var transparent:Array = Textures.getInstance().transparencies;
			var translucide:Array = Textures.getInstance().translucide;
			var cubesFrameCoos:Array = Textures.getInstance().cubesFrames;
			//FIXME shadow casting broken due to modified loop order.
			for(zloc = 0; zloc < _sizeZ; zloc++) {
				for(yloc = 0; yloc < _sizeY; ++yloc) {
					for (xloc = 0; xloc < _sizeX; ++xloc) {
//					dropShadow = false;
//					wasCubeOver = false;
//					for(zloc = _sizeZ-1; zloc > -1; --zloc) {
					
						var tile:int = _data[zloc][yloc][xloc];
						var xLoc2:int = xloc * cubeSizeRatio;
						var yLoc2:int = yloc * cubeSizeRatio;
						var zLoc2:int = zloc * cubeSizeRatio;
						if (tile != 0) {
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
							
							var alpha:Number = translucide[tile]===true? .4 : 1;
//							if(!dropShadow && wasCubeOver && overCube == 0) dropShadow = true;
//							var brightness:Number = dropShadow? .85: 1;
							var brightness:Number = 1;
//							brightness += (_x+_y)%16 == 0? 1 : 0;
						
							
							//BACK
							if((backCube == 0 || transparent[tile] === true || transparent[backCube] === true)
							&& tileSide.x > -1) {
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 1 + (count);
								_indexesArray[i_index++] = 2 + (count);
								
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 2 + (count);
								_indexesArray[i_index++] = 3 + (count);
								count += 4;
								
								buffer[index++] = -vertexOffset + xLoc2 + px; //X
								buffer[index++] = vertexOffset + yLoc2 + py; //Y
								buffer[index++] = vertexOffset - zLoc2; //Z
								buffer[index++] = tileSideX + textureSizeRatio - textureStretchX; //U
								buffer[index++] = tileSideY + textureSizeRatio - textureStretchY; //V
								buffer[index++] = alpha;//Alpha
								buffer[index++] = brightness;//Brightness
								
								buffer[index++] = -vertexOffset + xLoc2 + px;
								buffer[index++] = vertexOffset + yLoc2 + py;
								buffer[index++] = -vertexOffset - zLoc2;
								buffer[index++] = tileSideX + textureSizeRatio - textureStretchX;
								buffer[index++] = tileSideY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								buffer[index++] = vertexOffset + xLoc2 + px;
								buffer[index++] = vertexOffset + yLoc2 + py;
								buffer[index++] = -vertexOffset - zLoc2;
								buffer[index++] = tileSideX + textureStretchX;
								buffer[index++] = tileSideY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
							
								buffer[index++] = vertexOffset + xLoc2 + px;
								buffer[index++] = vertexOffset + yLoc2 + py;
								buffer[index++] = vertexOffset - zLoc2;
								buffer[index++] = tileSideX + textureStretchX;
								buffer[index++] = tileSideY + textureSizeRatio - textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								_faces.push(new Face(buffer, index, 7, false));
								_faces.push(new Face(buffer, index, 7, true));
							}
							
							
							//FRONT
							if ((frontCube == 0 || transparent[tile] === true || transparent[frontCube] === true)
							&& tileSide.x > -1) {
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 1 + (count);
								_indexesArray[i_index++] = 2 + (count);
								
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 2 + (count);
								_indexesArray[i_index++] = 3 + (count);
								count += 4;

								buffer[index++] = -vertexOffset + xLoc2 + px;
								buffer[index++] = -vertexOffset + yLoc2 + py;
								buffer[index++] = -vertexOffset - zLoc2;
								buffer[index++] = tileSideX  + textureSizeRatio - textureStretchX;
								buffer[index++] = tileSideY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								buffer[index++] = -vertexOffset + xLoc2 + px;
								buffer[index++] = -vertexOffset + yLoc2 + py;
								buffer[index++] = vertexOffset - zLoc2;
								buffer[index++] = tileSideX + textureSizeRatio - textureStretchX;
								buffer[index++] = tileSideY + textureSizeRatio - textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;

								buffer[index++] = vertexOffset + xLoc2 + px;
								buffer[index++] = -vertexOffset + yLoc2 + py;
								buffer[index++] = vertexOffset - zLoc2;
								buffer[index++] = tileSideX + textureStretchX;
								buffer[index++] = tileSideY + textureSizeRatio - textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								buffer[index++] = vertexOffset + xLoc2 + px;
								buffer[index++] = -vertexOffset + yLoc2 + py;
								buffer[index++] = -vertexOffset - zLoc2;
								buffer[index++] = tileSideX + textureStretchX;
								buffer[index++] = tileSideY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								_faces.push(new Face(buffer, index, 7, false));
								_faces.push(new Face(buffer, index, 7, true));
							}
							
							
							//LEFT
							if ((leftCube == 0 || transparent[tile] === true || transparent[leftCube] === true)
							&& tileSide.x > -1) {
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 1 + (count);
								_indexesArray[i_index++] = 2 + (count);
								
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 2 + (count);
								_indexesArray[i_index++] = 3 + (count);
								count += 4;
								
								buffer[index++] = vertexOffset + xLoc2 + px;
								buffer[index++] = vertexOffset + yLoc2 + py;
								buffer[index++] = vertexOffset - zLoc2;
								buffer[index++] = tileSideX + textureSizeRatio - textureStretchX;
								buffer[index++] = tileSideY + textureSizeRatio - textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								buffer[index++] = vertexOffset + xLoc2 + px;
								buffer[index++] = vertexOffset + yLoc2 + py;
								buffer[index++] = -vertexOffset - zLoc2;
								buffer[index++] = tileSideX + textureSizeRatio - textureStretchX;
								buffer[index++] = tileSideY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								buffer[index++] = vertexOffset + xLoc2 + px;
								buffer[index++] = -vertexOffset + yLoc2 + py;
								buffer[index++] = -vertexOffset - zLoc2;
								buffer[index++] = tileSideX + textureStretchX;
								buffer[index++] = tileSideY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
				
								buffer[index++] = vertexOffset + xLoc2 + px;
								buffer[index++] = -vertexOffset + yLoc2 + py;
								buffer[index++] = vertexOffset - zLoc2;
								buffer[index++] = tileSideX + textureStretchX;
								buffer[index++] = tileSideY + textureSizeRatio - textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								_faces.push(new Face(buffer, index, 7, false));
								_faces.push(new Face(buffer, index, 7, true));
							}
							
							
							//RIGHT
							if ((rightCube == 0 || transparent[tile] === true || transparent[rightCube] === true)
							&& tileSide.x > -1) {
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 1 + (count);
								_indexesArray[i_index++] = 2 + (count);
								
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 2 + (count);
								_indexesArray[i_index++] = 3 + (count);
								count += 4;
							              
								buffer[index++] = -vertexOffset + xLoc2 + px;
								buffer[index++] = vertexOffset + yLoc2 + py;
								buffer[index++] = -vertexOffset - zLoc2;
								buffer[index++] = tileSideX + textureSizeRatio - textureStretchX;
								buffer[index++] =  tileSideY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								buffer[index++] = -vertexOffset + xLoc2 + px;
								buffer[index++] = vertexOffset + yLoc2 + py;
								buffer[index++] = vertexOffset - zLoc2;
								buffer[index++] = tileSideX + textureSizeRatio - textureStretchX;
								buffer[index++] = tileSideY + textureSizeRatio - textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								buffer[index++] = -vertexOffset + xLoc2 + px;
								buffer[index++] = -vertexOffset + yLoc2 + py;
								buffer[index++] = vertexOffset - zLoc2;
								buffer[index++] = tileSideX + textureStretchX;
								buffer[index++] = tileSideY + textureSizeRatio - textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								buffer[index++] = -vertexOffset + xLoc2 + px;
								buffer[index++] = -vertexOffset + yLoc2 + py;
								buffer[index++] = -vertexOffset - zLoc2;
								buffer[index++] = tileSideX + textureStretchX;
								buffer[index++] = tileSideY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								_faces.push(new Face(buffer, index, 7, false));
								_faces.push(new Face(buffer, index, 7, true));
							}
							
							
							
							// TOP
							if(tileTop.x > -1
							&& (overCube == 0 || transparent[tile] === true || transparent[overCube] === true)) {
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 1 + (count);
								_indexesArray[i_index++] = 2 + (count);
								
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 2 + (count);
								_indexesArray[i_index++] = 3 + (count);
								count += 4;
								
								buffer[index++] = -vertexOffset + xLoc2 + px;
								buffer[index++] = vertexOffset + yLoc2 + py;
								buffer[index++] = -vertexOffset - zLoc2;
								buffer[index++] = tileTopX + textureSizeRatio - textureStretchX;
								buffer[index++] =  tileTopY + textureSizeRatio - textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								buffer[index++] = -vertexOffset + xLoc2 + px;
								buffer[index++] = -vertexOffset + yLoc2 + py;
								buffer[index++] = -vertexOffset - zLoc2;
								buffer[index++] = tileTopX + textureStretchX;
								buffer[index++] = tileTopY + textureSizeRatio - textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								buffer[index++] = vertexOffset + xLoc2 + px;
								buffer[index++] = -vertexOffset + yLoc2 + py;
								buffer[index++] = -vertexOffset - zLoc2;
								buffer[index++] = tileTopX + textureStretchX;
								buffer[index++] = tileTopY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								buffer[index++] = vertexOffset + xLoc2 + px;
								buffer[index++] = vertexOffset + yLoc2 + py;
								buffer[index++] = -vertexOffset - zLoc2;
								buffer[index++] = tileTopX + textureSizeRatio - textureStretchX;
								buffer[index++] = tileTopY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								_faces.push(new Face(buffer, index, 7, false));
								_faces.push(new Face(buffer, index, 7, true));
							}
							
							
							
							// BOTTOM
							if (zLoc2 > 0 && tileBottom.x > -1
							&& (underCube == 0 || transparent[tile] === true || transparent[underCube] === true) ) {
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 1 + (count);
								_indexesArray[i_index++] = 2 + (count);
								
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 2 + (count);
								_indexesArray[i_index++] = 3 + (count);
								count += 4;
								
								//back right
								buffer[index++] = -vertexOffset + xLoc2 + px; //X
								buffer[index++] = vertexOffset + yLoc2 + py; //Y
								buffer[index++] = vertexOffset - zLoc2; //Z
								buffer[index++] = tileBottomX + textureSizeRatio - textureStretchX;
								buffer[index++] = tileBottomY + textureSizeRatio - textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								//back left
								buffer[index++] = vertexOffset + xLoc2 + px;
								buffer[index++] = vertexOffset + yLoc2 + py;
								buffer[index++] = vertexOffset - zLoc2;
								buffer[index++] = tileBottomX + textureSizeRatio - textureStretchX;
								buffer[index++] = tileBottomY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								//Front left
								buffer[index++] = vertexOffset + xLoc2 + px;
								buffer[index++] = -vertexOffset + yLoc2 + py;
								buffer[index++] = vertexOffset - zLoc2;
								buffer[index++] = tileBottomX + textureStretchX;
								buffer[index++] = tileBottomY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								//Front right
								buffer[index++] = -vertexOffset + xLoc2 + px;
								buffer[index++] = -vertexOffset + yLoc2 + py;
								buffer[index++] = vertexOffset - zLoc2;
								buffer[index++] = tileBottomX + textureStretchX;
								buffer[index++] = tileBottomY + textureSizeRatio - textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								_faces.push(new Face(buffer, index, 7, false));
								_faces.push(new Face(buffer, index, 7, true));
							}
						
//							wasCubeOver = true;
						}
					}
				}
			}
			
			return buffer;
		}
	}

}