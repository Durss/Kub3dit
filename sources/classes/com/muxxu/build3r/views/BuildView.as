package com.muxxu.build3r.views {
	import com.muxxu.build3r.controler.FrontControlerBuild3r;
	import com.muxxu.build3r.model.ModelBuild3r;
	import com.muxxu.build3r.vo.LightMapData;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.engin3d.vo.Point3D;
	import com.muxxu.kub3dit.utils.drawIsoKube;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;

	/**
	 * 
	 * @author Francois
	 * @date 20 févr. 2012;
	 */
	public class BuildView extends AbstractView {
		
		private const _WIDTH:int = 3;
		private const _HEIGHT:int = 3;
		private const _DEPTH:int = 3;
		
		private var _label:CssTextField;
		private var _holder:Shape;
		private var _emptyFace:BitmapData;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>BuildView</code>.
		 */
		public function BuildView() {
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:ModelBuild3r = event.model as ModelBuild3r;
			if(model.mapReferencePoint != null) {
				visible = true;
				var i:int, len:int, w:int, h:int, bmd:BitmapData, textures:Array, map:LightMapData, pos:Point3D, ref:Point3D;
				var margin:int, tile:int, ratio:Number, m:Matrix, pos2:Point;
				ratio = 1;
				margin = 0;
				textures = Textures.getInstance().bitmapDatas;
				map = model.map;
				pos = new Point3D();
				pos2 = new Point();
				ref = model.position;
				ref.x -= model.positionReference.x - model.mapReferencePoint.x;
				ref.y -= model.positionReference.y - model.mapReferencePoint.y;
				
				len = _WIDTH * _HEIGHT * _DEPTH;
				w = 39 * ratio+margin;
				h = 41 * ratio+margin;
				_holder.graphics.clear();
				for(i = 0; i < len; ++i) {
					pos.x = _WIDTH - i % _WIDTH - Math.floor(_WIDTH*.5); 
					pos.y = Math.floor(i / _HEIGHT)%_HEIGHT - Math.floor(_HEIGHT*.5);
					pos.z =  Math.floor(i / (_HEIGHT*_WIDTH));
					
					tile = map.getTile(pos.x + ref.x, pos.y + ref.y, pos.z + ref.z - Math.floor(_DEPTH*.5));
					
					if(tile > 0) {
						bmd = drawIsoKube(textures[tile][0], textures[tile][1], false, ratio, true);
					}else{
						bmd = drawIsoKube(_emptyFace, _emptyFace, false, ratio, true);
					}
					
					pos.z -= Math.floor(_DEPTH*.5);
					pos2.x  = (pos.x+Math.floor(_WIDTH*.5)) * w + pos.y * w *.5 - pos.x*w*.5;
					pos2.y = _DEPTH * h * .75 + pos.y * h*.25 - pos.z * h * .5 - pos.x*h*.25 - h;
					
					m = new Matrix();
					m.translate(pos2.x, pos2.y);
					
					_holder.graphics.beginBitmapFill(bmd, m, false);
					_holder.graphics.drawRect(pos2.x, pos2.y, w-margin, h-margin);
					_holder.graphics.endFill();
				}
				
				PosUtils.centerInStage(_holder);
				var bounds:Rectangle = _holder.getBounds(_holder);
				_holder.x -= bounds.x;
				_holder.y -= bounds.y;
			}
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			visible = false;
			_emptyFace = new BitmapData(16, 16, true, 0x09ffffff);
			_holder = addChild(new Shape()) as Shape;
			_label = addChild(new CssTextField("b-label")) as CssTextField;
			_label.text = "Touchez un kube forum pour savoir quel kube doit se trouver à son emplacement.";
			
			_label.width = stage.stageWidth;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyUpHandler);
		}

		private function keyUpHandler(event:KeyboardEvent):void {
			if(!visible) return;
			
			var px:int, py:int, pz:int;
			
			if(event.keyCode == Keyboard.UP) py = -1;
			if(event.keyCode == Keyboard.DOWN) py = 1;
			if(event.keyCode == Keyboard.RIGHT) px = 1;
			if(event.keyCode == Keyboard.LEFT) px = -1;
			if(event.keyCode == Keyboard.PAGE_UP) pz = 1;
			if(event.keyCode == Keyboard.PAGE_DOWN) pz = -1;
			
			FrontControlerBuild3r.getInstance().move(px, py, pz);
		}
		
	}
}