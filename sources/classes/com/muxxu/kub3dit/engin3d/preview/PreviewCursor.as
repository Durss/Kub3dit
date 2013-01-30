package com.muxxu.kub3dit.engin3d.preview {
	import flash.geom.Vector3D;
	import com.muxxu.kub3dit.engin3d.chunks.ChunkData;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.engin3d.molehill.CubeFragmentShader;
	import com.muxxu.kub3dit.engin3d.molehill.CubeVertexShader;
	import com.muxxu.kub3dit.events.TextureEvent;
	import com.muxxu.kub3dit.views.EditorView;
	import com.muxxu.kub3dit.views.KubeSelectorView;
	import com.nurun.structure.mvc.views.ViewLocator;

	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Point;
	
	/**
	 * 
	 * @author Francois
	 * @date 29 déc. 2011;
	 */
	public class PreviewCursor {
		private var _accelerated:Boolean;
		private var _context3D:Context3D;
		private var _shaderProgram:Program3D;
		private var _texture:Texture;
		private var _editorView:EditorView;
		private var _selectorView:KubeSelectorView;
		private var _forcedPosition:Vector3D;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>PreviewCursor</code>.
		 */
		public function PreviewCursor(context3D:Context3D, accelerated:Boolean) {
			_accelerated = accelerated;
			_context3D = context3D;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Forces the position to a specific point.
		 * Used when the mouse is over a kube in the 3D scene.
		 */
		public function set forcedPosition(forcedPosition:Vector3D):void {
			_forcedPosition = forcedPosition;
		}
		
		/**
		 * Gets if the forced position.
		 */
		public function get forcedPosition():Vector3D {
			return _forcedPosition;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */

		public function render():void {
			var cubeSizeRatio:Number = ChunkData.CUBE_SIZE;
			var tile:int = _selectorView.currentKubeId;
			
			var px:int = _forcedPosition==null? _editorView.mousePos.x * cubeSizeRatio : _forcedPosition.x * cubeSizeRatio;
			var py:int = _forcedPosition==null? _editorView.mousePos.y * cubeSizeRatio : _forcedPosition.y * cubeSizeRatio;
			var pz:int = _forcedPosition==null? _editorView.mousePos.z * cubeSizeRatio : _forcedPosition.z * cubeSizeRatio;
			
			if(_forcedPosition==null && pz == -1 * cubeSizeRatio) return;//mouse out of grid in this case
			
			var bmd:BitmapData			= Textures.getInstance().spriteSheet;
			var cubesFrameCoos:Array	= Textures.getInstance().cubesFrames;
			
			var textureStepRatioX:Number	= 1 / bmd.width;
			var textureStepRatioY:Number	= 1 / bmd.height;
			var textureStretchX:Number		= 1 / bmd.width * .3;
			var textureStretchY:Number		= 1 / bmd.height * .3;
			var textureSizeRatio:Number		= 16 / bmd.width;
			var vertexOffset:Number			= .5 * cubeSizeRatio;
			
			var tileTop:Point = cubesFrameCoos[tile][0];
			var tileSide:Point = cubesFrameCoos[tile][1];
			var tileBottom:Point = cubesFrameCoos[tile][2];
			
			var tileTopX:Number = tileTop.x * textureStepRatioX;
			var tileTopY:Number = tileTop.y * textureStepRatioY;
			var tileSideX:Number = tileSide.x * textureStepRatioX;
			var tileSideY:Number = tileSide.y * textureStepRatioY;
			
			var tileBottomX:Number = tileBottom.x * textureStepRatioX;
			var tileBottomY:Number = tileBottom.y * textureStepRatioY;
	
			var brightness:Number = 1.1;
			var verticesBuffer:Vector.<Number> = new Vector.<Number>();
			var indexesBuffer:Vector.<uint> = new Vector.<uint>();
			
			var count:int, i_index:int, index:int;
			
			//BACK
			indexesBuffer[i_index++] = 0 + count;
			indexesBuffer[i_index++] = 1 + count;
			indexesBuffer[i_index++] = 2 + count;
			
			indexesBuffer[i_index++] = 0 + count;
			indexesBuffer[i_index++] = 2 + count;
			indexesBuffer[i_index++] = 3 + count;
			count += 4;
			
			verticesBuffer[index++] = -vertexOffset + px; //X
			verticesBuffer[index++] = vertexOffset + py; //Y
			verticesBuffer[index++] = vertexOffset - pz; //Z
			verticesBuffer[index++] = tileSideX + textureSizeRatio - textureStretchX; //U
			verticesBuffer[index++] = tileSideY + textureSizeRatio - textureStretchY; //V
			verticesBuffer[index++] = brightness;//Brightness
			
			verticesBuffer[index++] = -vertexOffset + px;
			verticesBuffer[index++] = vertexOffset + py;
			verticesBuffer[index++] = -vertexOffset - pz;
			verticesBuffer[index++] = tileSideX + textureSizeRatio - textureStretchX;
			verticesBuffer[index++] = tileSideY + textureStretchY;
			verticesBuffer[index++] = brightness;
			
			verticesBuffer[index++] = vertexOffset + px;
			verticesBuffer[index++] = vertexOffset + py;
			verticesBuffer[index++] = -vertexOffset - pz;
			verticesBuffer[index++] = tileSideX + textureStretchX;
			verticesBuffer[index++] = tileSideY + textureStretchY;
			verticesBuffer[index++] = brightness;
		
			verticesBuffer[index++] = vertexOffset + px;
			verticesBuffer[index++] = vertexOffset + py;
			verticesBuffer[index++] = vertexOffset - pz;
			verticesBuffer[index++] = tileSideX + textureStretchX;
			verticesBuffer[index++] = tileSideY + textureSizeRatio - textureStretchY;
			verticesBuffer[index++] = brightness;
			
			
			//FRONT
			indexesBuffer[i_index++] = 0 + count;
			indexesBuffer[i_index++] = 1 + count;
			indexesBuffer[i_index++] = 2 + count;
			
			indexesBuffer[i_index++] = 0 + count;
			indexesBuffer[i_index++] = 2 + count;
			indexesBuffer[i_index++] = 3 + count;
			count += 4;

			verticesBuffer[index++] = -vertexOffset + px;
			verticesBuffer[index++] = -vertexOffset + py;
			verticesBuffer[index++] = -vertexOffset - pz;
			verticesBuffer[index++] = tileSideX  + textureSizeRatio - textureStretchX;
			verticesBuffer[index++] = tileSideY + textureStretchY;
			verticesBuffer[index++] = brightness;
			
			verticesBuffer[index++] = -vertexOffset + px;
			verticesBuffer[index++] = -vertexOffset + py;
			verticesBuffer[index++] = vertexOffset - pz;
			verticesBuffer[index++] = tileSideX + textureSizeRatio - textureStretchX;
			verticesBuffer[index++] = tileSideY + textureSizeRatio - textureStretchY;
			verticesBuffer[index++] = brightness;

			verticesBuffer[index++] = vertexOffset + px;
			verticesBuffer[index++] = -vertexOffset + py;
			verticesBuffer[index++] = vertexOffset - pz;
			verticesBuffer[index++] = tileSideX + textureStretchX;
			verticesBuffer[index++] = tileSideY + textureSizeRatio - textureStretchY;
			verticesBuffer[index++] = brightness;
			
			verticesBuffer[index++] = vertexOffset + px;
			verticesBuffer[index++] = -vertexOffset + py;
			verticesBuffer[index++] = -vertexOffset - pz;
			verticesBuffer[index++] = tileSideX + textureStretchX;
			verticesBuffer[index++] = tileSideY + textureStretchY;
			verticesBuffer[index++] = brightness;
			
			
			
			//LEFT
			indexesBuffer[i_index++] = 0 + count;
			indexesBuffer[i_index++] = 1 + count;
			indexesBuffer[i_index++] = 2 + count;
			
			indexesBuffer[i_index++] = 0 + count;
			indexesBuffer[i_index++] = 2 + count;
			indexesBuffer[i_index++] = 3 + count;
			count += 4;
			
			verticesBuffer[index++] = vertexOffset + px;
			verticesBuffer[index++] = vertexOffset + py;
			verticesBuffer[index++] = vertexOffset - pz;
			verticesBuffer[index++] = tileSideX + textureSizeRatio - textureStretchX;
			verticesBuffer[index++] = tileSideY + textureSizeRatio - textureStretchY;
			verticesBuffer[index++] = brightness;
			
			verticesBuffer[index++] = vertexOffset + px;
			verticesBuffer[index++] = vertexOffset + py;
			verticesBuffer[index++] = -vertexOffset - pz;
			verticesBuffer[index++] = tileSideX + textureSizeRatio - textureStretchX;
			verticesBuffer[index++] = tileSideY + textureStretchY;
			verticesBuffer[index++] = brightness;
			
			verticesBuffer[index++] = vertexOffset + px;
			verticesBuffer[index++] = -vertexOffset + py;
			verticesBuffer[index++] = -vertexOffset - pz;
			verticesBuffer[index++] = tileSideX + textureStretchX;
			verticesBuffer[index++] = tileSideY + textureStretchY;
			verticesBuffer[index++] = brightness;

			verticesBuffer[index++] = vertexOffset + px;
			verticesBuffer[index++] = -vertexOffset + py;
			verticesBuffer[index++] = vertexOffset - pz;
			verticesBuffer[index++] = tileSideX + textureStretchX;
			verticesBuffer[index++] = tileSideY + textureSizeRatio - textureStretchY;
			verticesBuffer[index++] = brightness;
			
			
			
			//RIGHT
			indexesBuffer[i_index++] = 0 + count;
			indexesBuffer[i_index++] = 1 + count;
			indexesBuffer[i_index++] = 2 + count;
			
			indexesBuffer[i_index++] = 0 + count;
			indexesBuffer[i_index++] = 2 + count;
			indexesBuffer[i_index++] = 3 + count;
			count += 4;
		              
			verticesBuffer[index++] = -vertexOffset + px;
			verticesBuffer[index++] = vertexOffset + py;
			verticesBuffer[index++] = -vertexOffset - pz;
			verticesBuffer[index++] = tileSideX + textureSizeRatio - textureStretchX;
			verticesBuffer[index++] =  tileSideY + textureStretchY;
			verticesBuffer[index++] = brightness;
			
			verticesBuffer[index++] = -vertexOffset + px;
			verticesBuffer[index++] = vertexOffset + py;
			verticesBuffer[index++] = vertexOffset - pz;
			verticesBuffer[index++] = tileSideX + textureSizeRatio - textureStretchX;
			verticesBuffer[index++] = tileSideY + textureSizeRatio - textureStretchY;
			verticesBuffer[index++] = brightness;
			
			verticesBuffer[index++] = -vertexOffset + px;
			verticesBuffer[index++] = -vertexOffset + py;
			verticesBuffer[index++] = vertexOffset - pz;
			verticesBuffer[index++] = tileSideX + textureStretchX;
			verticesBuffer[index++] = tileSideY + textureSizeRatio - textureStretchY;
			verticesBuffer[index++] = brightness;
			
			verticesBuffer[index++] = -vertexOffset + px;
			verticesBuffer[index++] = -vertexOffset + py;
			verticesBuffer[index++] = -vertexOffset - pz;
			verticesBuffer[index++] = tileSideX + textureStretchX;
			verticesBuffer[index++] = tileSideY + textureStretchY;
			verticesBuffer[index++] = brightness;
			
			
			
			// TOP
			if(tileTop.x > -1) {
				indexesBuffer[i_index++] = 0 + count;
				indexesBuffer[i_index++] = 1 + count;
				indexesBuffer[i_index++] = 2 + count;
				
				indexesBuffer[i_index++] = 0 + count;
				indexesBuffer[i_index++] = 2 + count;
				indexesBuffer[i_index++] = 3 + count;
				count += 4;
				
				verticesBuffer[index++] = -vertexOffset + px;
				verticesBuffer[index++] = vertexOffset + py;
				verticesBuffer[index++] = -vertexOffset - pz;
				verticesBuffer[index++] = tileTopX + textureSizeRatio - textureStretchX;
				verticesBuffer[index++] =  tileTopY + textureSizeRatio - textureStretchY;
				verticesBuffer[index++] = brightness;
				
				verticesBuffer[index++] = -vertexOffset + px;
				verticesBuffer[index++] = -vertexOffset + py;
				verticesBuffer[index++] = -vertexOffset - pz;
				verticesBuffer[index++] = tileTopX + textureStretchX;
				verticesBuffer[index++] = tileTopY + textureSizeRatio - textureStretchY;
				verticesBuffer[index++] = brightness;
				
				verticesBuffer[index++] = vertexOffset + px;
				verticesBuffer[index++] = -vertexOffset + py;
				verticesBuffer[index++] = -vertexOffset - pz;
				verticesBuffer[index++] = tileTopX + textureStretchX;
				verticesBuffer[index++] = tileTopY + textureStretchY;
				verticesBuffer[index++] = brightness;
				
				verticesBuffer[index++] = vertexOffset + px;
				verticesBuffer[index++] = vertexOffset + py;
				verticesBuffer[index++] = -vertexOffset - pz;
				verticesBuffer[index++] = tileTopX + textureSizeRatio - textureStretchX;
				verticesBuffer[index++] = tileTopY + textureStretchY;
				verticesBuffer[index++] = brightness;
			}
			
			
			
			// BOTTOM
			if(tileBottom.x > -1) {
				indexesBuffer[i_index++] = 0 + count;
				indexesBuffer[i_index++] = 1 + count;
				indexesBuffer[i_index++] = 2 + count;
				
				indexesBuffer[i_index++] = 0 + count;
				indexesBuffer[i_index++] = 2 + count;
				indexesBuffer[i_index++] = 3 + count;
				count += 4;
				
				//back right
				verticesBuffer[index++] = -vertexOffset + px; //X
				verticesBuffer[index++] = vertexOffset + py; //Y
				verticesBuffer[index++] = vertexOffset - pz; //Z
				verticesBuffer[index++] = tileBottomX + textureSizeRatio - textureStretchX;
				verticesBuffer[index++] = tileBottomY + textureSizeRatio - textureStretchY;
				verticesBuffer[index++] = brightness;
				
				//back left
				verticesBuffer[index++] = vertexOffset + px;
				verticesBuffer[index++] = vertexOffset + py;
				verticesBuffer[index++] = vertexOffset - pz;
				verticesBuffer[index++] = tileBottomX + textureSizeRatio - textureStretchX;
				verticesBuffer[index++] = tileBottomY + textureStretchY;
				verticesBuffer[index++] = brightness;
				
				//Front left
				verticesBuffer[index++] = vertexOffset + px;
				verticesBuffer[index++] = -vertexOffset + py;
				verticesBuffer[index++] = vertexOffset - pz;
				verticesBuffer[index++] = tileBottomX + textureStretchX;
				verticesBuffer[index++] = tileBottomY + textureStretchY;
				verticesBuffer[index++] = brightness;
				
				//Front right
				verticesBuffer[index++] = -vertexOffset + px;
				verticesBuffer[index++] = -vertexOffset + py;
				verticesBuffer[index++] = vertexOffset - pz;
				verticesBuffer[index++] = tileBottomX + textureStretchX;
				verticesBuffer[index++] = tileBottomY + textureSizeRatio - textureStretchY;
				verticesBuffer[index++] = brightness;
			}
			
			_context3D.setTextureAt(0, _texture);
			_context3D.setProgram(_shaderProgram);
			
			var vertexBuffer:VertexBuffer3D = _context3D.createVertexBuffer(verticesBuffer.length / 6, 6);
			var indexBuffer:IndexBuffer3D = _context3D.createIndexBuffer(indexesBuffer.length);
			vertexBuffer.uploadFromVector(verticesBuffer, 0, verticesBuffer.length / 6);
			indexBuffer.uploadFromVector(indexesBuffer, 0, indexesBuffer.length);
			
			_context3D.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3); //xyz
			_context3D.setVertexBufferAt(1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_2); //uv
			_context3D.setVertexBufferAt(2, vertexBuffer, 5, Context3DVertexBufferFormat.FLOAT_1); //brightness
			
			_context3D.drawTriangles(indexBuffer);
			_context3D.setVertexBufferAt(0, null); //clean the buffers
			_context3D.setVertexBufferAt(1, null); //clean the buffers
			_context3D.setVertexBufferAt(2, null); //clean the buffers
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_editorView = ViewLocator.getInstance().locateViewByType(EditorView) as EditorView;
			_selectorView = ViewLocator.getInstance().locateViewByType(KubeSelectorView) as KubeSelectorView;
			
			//Init shader
			var vs:CubeVertexShader = new CubeVertexShader();
			var fs:CubeFragmentShader = new CubeFragmentShader(_context3D, false, false);
			_shaderProgram = _context3D.createProgram();
			_shaderProgram.upload(vs.agalcode, fs.agalcode);

			Textures.getInstance().addEventListener(TextureEvent.CHANGE_SPRITESHEET, updateTexture);
			updateTexture();
		}
		
		/**
		 * Updates the texture.
		 */
		private function updateTexture(event:TextureEvent = null):void {
			var bitmapData:BitmapData = Textures.getInstance().spriteSheet;
			_texture = _context3D.createTexture(bitmapData.width, bitmapData.height, Context3DTextureFormat.BGRA, false);
			_texture.uploadFromBitmapData(bitmapData);
		}
		
	}
}