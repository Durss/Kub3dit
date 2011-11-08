package com.muxxu.kub3dit.engin3d.chunks {
	import com.muxxu.kub3dit.engin3d.map.Map;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import flash.display.BitmapData;

	
	public class ChunkData {
		
		public var _x:int;
		public var _y:int;
		public var _sizeX:int;
		public var _sizeY:int;
		public var _sizeZ:int;
		public var _data:Array;
		public var _bufferArray:Vector.<Number>;
		public var _indexesArray:Vector.<uint>;
		private var _map:Map;
		
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
		}

		
		private function createBufferArray():Vector.<Number> {
			var padding:int					= Textures.PADDING;
			var bmd:BitmapData				= Textures.getInstance().bitmapData;
			var cols:int					= bmd.width/(16+padding);
			var textureStepRatioX:Number	= 1 / (bmd.width/(16+padding));
			var textureStepRatioY:Number	= 1 / (bmd.height/(16+padding));
			var textureStretchX:Number		= 1 / (bmd.width) * .3;
			var textureStretchY:Number		= 1 / (bmd.height) * .3;
			var paddingSizeX:Number			= 1 / (bmd.width) * (padding);
			var paddingSizeY:Number			= 1 / (bmd.height) * (padding);
			var count:int = 0;
			var buffer:Vector.<Number> = new Vector.<Number>();
			var xloc:int;
			var yloc:int;
			var zloc:int;
			var index:int = 0;
			var i_index:int = 0;
//			var wasCubeOver:Boolean;
//			var dropShadow:Boolean;
			var transparent:Array = Textures.getInstance().transparencies;
			var translucide:Array = Textures.getInstance().translucide;
			var cubesFrames:Array = Textures.getInstance().cubesFrames;
			//FIXME shadow casting broken due to modified loop order.
			for(zloc = 0; zloc < _sizeZ; zloc++) {
				for(yloc = 0; yloc < _sizeY; ++yloc) {
					for (xloc = 0; xloc < _sizeX; ++xloc) {
//					dropShadow = false;
//					wasCubeOver = false;
//					for(zloc = _sizeZ-1; zloc > -1; --zloc) {
					
						var tile:int = _data[zloc][yloc][xloc];
						if (tile != 0) {
						
							var tileTop:int = cubesFrames[tile][0];
							var tileSide:int = cubesFrames[tile][1];
							var tileBottom:int = cubesFrames[tile][2];
							
							var tileTopX:Number = (tileTop%cols) * textureStepRatioX;
							var tileTopY:Number = Math.floor(tileTop/cols) * textureStepRatioY;
							
							var tileSideX:Number = (tileSide%cols) * textureStepRatioX;
							var tileSideY:Number = Math.floor(tileSide/cols) * textureStepRatioY;
							
							var tileBottomX:Number = (tileBottom%cols) * textureStepRatioX;
							var tileBottomY:Number = Math.floor(tileBottom/cols) * textureStepRatioY;

							var underCube:int	= _map.getTile(xloc + _x, yloc + _y, zloc - 1);
							var leftCube:int	= _map.getTile(xloc + _x + 1, yloc + _y, zloc);
							var frontCube:int	= _map.getTile(xloc + _x, yloc + _y - 1, zloc);
							var backCube:int	= _map.getTile(xloc + _x, yloc + _y + 1, zloc);
							var rightCube:int	= _map.getTile(xloc + _x - 1, yloc + _y, zloc);
							var overCube:int	= _map.getTile(xloc + _x, yloc + _y, zloc + 1);
							
							var alpha:Number = translucide[tile]===true? .5 : 1;
//							if(!dropShadow && wasCubeOver && overCube == 0) dropShadow = true;
//							var brightness:Number = dropShadow? .85: 1;
							var brightness:Number = 1;
//							brightness += (_x+_y)%16 == 0? 1 : 0;
						
							
							//BACK
//							if((zloc > 0 || (zloc == 0 && yloc == _sizeY - 1))
//							&& (backCube == 0 || transparent[tile] === true || transparent[backCube] === true)
//							&& tileSide > -1) {
							if((backCube == 0 || transparent[tile] === true || transparent[backCube] === true)
							&& tileSide > -1) {
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 1 + (count);
								_indexesArray[i_index++] = 2 + (count);
								
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 2 + (count);
								_indexesArray[i_index++] = 3 + (count);
								count += 4;
								
								buffer[index++] = -.5 + xloc + _x; //X
								buffer[index++] = .5 + yloc + _y; //Y
								buffer[index++] = .5 - zloc; //Z
								buffer[index++] = tileSideX + textureStepRatioX - textureStretchX - paddingSizeX; //U
								buffer[index++] = tileSideY + textureStepRatioY - textureStretchY - paddingSizeY; //V
								buffer[index++] = alpha;//Alpha
								buffer[index++] = brightness;//Brightness
								
								buffer[index++] = -.5 + xloc + _x;
								buffer[index++] = .5 + yloc + _y;
								buffer[index++] = -.5 - zloc;
								buffer[index++] = tileSideX + textureStepRatioX - textureStretchX - paddingSizeX;
								buffer[index++] = tileSideY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								buffer[index++] = .5 + xloc + _x;
								buffer[index++] = .5 + yloc + _y;
								buffer[index++] = -.5 - zloc;
								buffer[index++] = tileSideX + textureStretchX;
								buffer[index++] = tileSideY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
							
								buffer[index++] = .5 + xloc + _x;
								buffer[index++] = .5 + yloc + _y;
								buffer[index++] = .5 - zloc;
								buffer[index++] = tileSideX + textureStretchX;
								buffer[index++] = tileSideY + textureStepRatioY - textureStretchY - paddingSizeY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
							}
							
							
							//FRONT
//							if ((zloc > 0 || (zloc ==0 && yloc == 0))
//							&& (frontCube == 0 || transparent[tile] === true || transparent[frontCube] === true)
//							&& tileSide > -1) {
							if ((frontCube == 0 || transparent[tile] === true || transparent[frontCube] === true)
							&& tileSide > -1) {
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 1 + (count);
								_indexesArray[i_index++] = 2 + (count);
								
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 2 + (count);
								_indexesArray[i_index++] = 3 + (count);
								count += 4;

								buffer[index++] = -.5 + xloc + _x;
								buffer[index++] = -.5 + yloc + _y;
								buffer[index++] = -.5 - zloc;
								buffer[index++] = tileSideX  + textureStepRatioX - textureStretchX - paddingSizeX;
								buffer[index++] = tileSideY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								buffer[index++] = -.5 + xloc + _x;
								buffer[index++] = -.5 + yloc + _y;
								buffer[index++] = .5 - zloc;
								buffer[index++] = tileSideX + textureStepRatioX - textureStretchX - paddingSizeX;
								buffer[index++] = tileSideY + textureStepRatioY - textureStretchY - paddingSizeY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;

								buffer[index++] = .5 + xloc + _x;
								buffer[index++] = -.5 + yloc + _y;
								buffer[index++] = .5 - zloc;
								buffer[index++] = tileSideX + textureStretchX;
								buffer[index++] = tileSideY + textureStepRatioY - textureStretchY - paddingSizeY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								buffer[index++] = .5 + xloc + _x;
								buffer[index++] = -.5 + yloc + _y;
								buffer[index++] = -.5 - zloc;
								buffer[index++] = tileSideX + textureStretchX;
								buffer[index++] = tileSideY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
							}
							
							
							//LEFT
//							if ((zloc > 0 || (zloc ==0 && xloc == _sizeX-1))
//							&& (leftCube == 0 || transparent[tile] === true || transparent[leftCube] === true)
//							&& tileSide > -1) {
							if ((leftCube == 0 || transparent[tile] === true || transparent[leftCube] === true)
							&& tileSide > -1) {
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 1 + (count);
								_indexesArray[i_index++] = 2 + (count);
								
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 2 + (count);
								_indexesArray[i_index++] = 3 + (count);
								count += 4;
								
								buffer[index++] = .5 + xloc + _x;
								buffer[index++] = .5 + yloc + _y;
								buffer[index++] = .5 - zloc;
								buffer[index++] = tileSideX + textureStepRatioX - textureStretchX - paddingSizeX;
								buffer[index++] = tileSideY + textureStepRatioY - textureStretchY - paddingSizeY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								buffer[index++] = .5 + xloc + _x;
								buffer[index++] = .5 + yloc + _y;
								buffer[index++] = -.5 - zloc;
								buffer[index++] = tileSideX + textureStepRatioX - textureStretchX - paddingSizeX;
								buffer[index++] = tileSideY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								buffer[index++] = .5 + xloc + _x;
								buffer[index++] = -.5 + yloc + _y;
								buffer[index++] = -.5 - zloc;
								buffer[index++] = tileSideX + textureStretchX;
								buffer[index++] = tileSideY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
				
								buffer[index++] = .5 + xloc + _x;
								buffer[index++] = -.5 + yloc + _y;
								buffer[index++] = .5 - zloc;
								buffer[index++] = tileSideX + textureStretchX;
								buffer[index++] = tileSideY + textureStepRatioY - textureStretchY - paddingSizeY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
							}
							
							
							//RIGHT
//							if ((zloc > 0 || (zloc ==0 && xloc == 0))
//							&& (rightCube == 0 || transparent[tile] === true || transparent[rightCube] === true)
//							&& tileSide > -1) {
							if ((rightCube == 0 || transparent[tile] === true || transparent[rightCube] === true)
							&& tileSide > -1) {
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 1 + (count);
								_indexesArray[i_index++] = 2 + (count);
								
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 2 + (count);
								_indexesArray[i_index++] = 3 + (count);
								count += 4;
							              
								buffer[index++] = -.5 + xloc + _x;
								buffer[index++] = .5 + yloc + _y;
								buffer[index++] = -.5 - zloc;
								buffer[index++] = tileSideX + textureStepRatioX - textureStretchX - paddingSizeX;
								buffer[index++] =  tileSideY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								buffer[index++] = -.5 + xloc + _x;
								buffer[index++] = .5 + yloc + _y;
								buffer[index++] = .5 - zloc;
								buffer[index++] = tileSideX + textureStepRatioX - textureStretchX - paddingSizeX;
								buffer[index++] = tileSideY + textureStepRatioY - textureStretchY - paddingSizeY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								buffer[index++] = -.5 + xloc + _x;
								buffer[index++] = -.5 + yloc + _y;
								buffer[index++] = .5 - zloc;
								buffer[index++] = tileSideX + textureStretchX;
								buffer[index++] = tileSideY + textureStepRatioY - textureStretchY - paddingSizeY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								buffer[index++] = -.5 + xloc + _x;
								buffer[index++] = -.5 + yloc + _y;
								buffer[index++] = -.5 - zloc;
								buffer[index++] = tileSideX + textureStretchX;
								buffer[index++] = tileSideY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
							}
							
							
							
							// TOP
							if(tileTop > -1
							&& (overCube == 0 || transparent[tile] === true || transparent[overCube] === true)) {
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 1 + (count);
								_indexesArray[i_index++] = 2 + (count);
								
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 2 + (count);
								_indexesArray[i_index++] = 3 + (count);
								count += 4;
								
								buffer[index++] = -.5 + xloc + _x;
								buffer[index++] = .5 + yloc + _y;
								buffer[index++] = -.5 - zloc;
								buffer[index++] = tileTopX + textureStepRatioX - textureStretchX - paddingSizeX;
								buffer[index++] =  tileTopY + textureStepRatioY - textureStretchY - paddingSizeY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								buffer[index++] = -.5 + xloc + _x;
								buffer[index++] = -.5 + yloc + _y;
								buffer[index++] = -.5 - zloc;
								buffer[index++] = tileTopX + textureStretchX;
								buffer[index++] = tileTopY + textureStepRatioY - textureStretchY - paddingSizeY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								buffer[index++] = .5 + xloc + _x;
								buffer[index++] = -.5 + yloc + _y;
								buffer[index++] = -.5 - zloc;
								buffer[index++] = tileTopX + textureStretchX;
								buffer[index++] = tileTopY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								buffer[index++] = .5 + xloc + _x;
								buffer[index++] = .5 + yloc + _y;
								buffer[index++] = -.5 - zloc;
								buffer[index++] = tileTopX + textureStepRatioX - textureStretchX - paddingSizeX;
								buffer[index++] = tileTopY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
							}
							
							
							
							// BOTTOM
							if (zloc > 0 && tileBottom > -1
							&& (underCube == 0 || transparent[tile] === true || transparent[underCube] === true) ) {
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 1 + (count);
								_indexesArray[i_index++] = 2 + (count);
								
								_indexesArray[i_index++] = 0 + (count);
								_indexesArray[i_index++] = 2 + (count);
								_indexesArray[i_index++] = 3 + (count);
								count += 4;
								
								//back right
								buffer[index++] = -.5 + xloc + _x; //X
								buffer[index++] = .5 + yloc + _y; //Y
								buffer[index++] = .5 - zloc; //Z
								buffer[index++] = tileBottomX + textureStepRatioX - textureStretchX - paddingSizeX;
								buffer[index++] = tileBottomY + textureStepRatioY - textureStretchY - paddingSizeY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								//back left
								buffer[index++] = .5 + xloc + _x;
								buffer[index++] = .5 + yloc + _y;
								buffer[index++] = .5 - zloc;
								buffer[index++] = tileBottomX + textureStepRatioX - textureStretchX - paddingSizeX;
								buffer[index++] = tileBottomY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								//Front left
								buffer[index++] = .5 + xloc + _x;
								buffer[index++] = -.5 + yloc + _y;
								buffer[index++] = .5 - zloc;
								buffer[index++] = tileBottomX + textureStretchX;
								buffer[index++] = tileBottomY + textureStretchY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
								
								//Front right
								buffer[index++] = -.5 + xloc + _x;
								buffer[index++] = -.5 + yloc + _y;
								buffer[index++] = .5 - zloc;
								buffer[index++] = tileBottomX + textureStretchX;
								buffer[index++] = tileBottomY + textureStepRatioY - textureStretchY - paddingSizeY;
								buffer[index++] = alpha;
								buffer[index++] = brightness;
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