package com.muxxu.build3r.views {
	import flash.geom.Matrix;
	import com.nurun.utils.pos.PosUtils;
	import flash.display.Shape;
	import flash.events.Event;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.utils.drawIsoKube;
	import com.muxxu.kub3dit.engin3d.vo.Point3D;
	import com.muxxu.build3r.vo.LightMapData;
	import flash.display.BitmapData;
	import com.muxxu.build3r.model.ModelBuild3r;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;

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
				var margin:int, tile:int, ratio:Number, m:Matrix;
				ratio = 1;
				margin = 5;
				textures = Textures.getInstance().bitmapDatas;
				map = model.map;
				pos = new Point3D();
				ref = model.position;
				ref.x -= model.positionReference.x - model.mapReferencePoint.x;
				ref.y -= model.positionReference.y - model.mapReferencePoint.y;
				
				len = _WIDTH * _HEIGHT * _DEPTH;
				w = 39 * ratio;
				h = 41 * ratio;
				_holder.graphics.clear();
				//TODO fix placements and offsets
				for(i = 0; i < len; ++i) {
					pos.x = i % _WIDTH - Math.floor(_WIDTH*.5); 
					pos.y = Math.floor(i / _HEIGHT)%_HEIGHT - Math.floor(_HEIGHT*.5);
					pos.z =  Math.floor(i / (_HEIGHT*_WIDTH)) - Math.floor(_DEPTH*.5);
					
					tile = map.getTile(pos.x + ref.x, pos.y + ref.y, pos.z + ref.z);
					if(tile > 0) {
						bmd = drawIsoKube(textures[tile][0], textures[tile][1], false, ratio, true);
					}else{
						bmd = drawIsoKube(_emptyFace, _emptyFace, false, ratio, true);
					}
					
					pos.x  = (pos.x + Math.floor(_WIDTH*.5)) * (w + margin) + (pos.z+Math.floor(_DEPTH*.5)) * (w + margin) *.5;
					pos.y = (pos.y + Math.floor(_HEIGHT*.5)) * (h + margin) + (pos.z+Math.floor(_DEPTH*.5)) * (h + margin)*.5;
					
					m = new Matrix();
					m.translate(pos.x, pos.y);
					
					_holder.graphics.beginBitmapFill(bmd, m, false);
					_holder.graphics.drawRect(pos.x, pos.y, w, h);
					_holder.graphics.endFill();
				}
				
				PosUtils.centerInStage(_holder);
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
			_emptyFace = new BitmapData(16, 16, true, 0x33ffffff);
			_holder = addChild(new Shape()) as Shape;
			_label = addChild(new CssTextField("b-label")) as CssTextField;
			_label.text = "Touchez un kube forum pour savoir quel kube doit se trouver à son emplacement.";
			
			_label.width = stage.stageWidth;
		}
		
	}
}