package com.muxxu.kub3dit.views {
	import com.muxxu.kub3dit.components.LoaderSpinning;
	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.components.stats.KubeCounter;
	import com.muxxu.kub3dit.engin3d.map.Map;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.graphics.CheckGraphic;
	import com.muxxu.kub3dit.model.Model;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.vector.VectorUtils;

	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	/**
	 * 
	 * @author Francois
	 * @date 8 avr. 2012;
	 */
	public class StatsView extends AbstractWindowView {
		private var _map:Map;
		private var _ba:ByteArray;
		private var _spool:Vector.<KubeCounter>;
		private var _values:Array;
		private var _parsingComplete:Boolean;
		private var _spin:LoaderSpinning;
		private var _label:CssTextField;
		private var _kubesHolder:Sprite;
		private var _copy:ButtonKube;
		private var _checkIcon:CheckGraphic;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>StatsView</code>.
		 */
		public function StatsView() {
			super(Label.getLabel("stats-title"));
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:Model = event.model as Model;
			_map = model.map;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function open(...args):void {
			super.open();
			startParsing();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		override protected function initialize():void {
			super.initialize();
			
			_checkIcon = new CheckGraphic();
			_spin = addChild(new LoaderSpinning()) as LoaderSpinning;
			_spool = new Vector.<KubeCounter>();
			_kubesHolder = _container.addChild(new Sprite()) as Sprite;
			_label = _container.addChild(new CssTextField("statsDetails")) as CssTextField;
			_copy = _container.addChild(new ButtonKube(Label.getLabel("stats-copy"))) as ButtonKube;
			
			_parsingComplete = true;
			_checkIcon.filters = [new DropShadowFilter(2,45,0,.4,2,2,.6,2)];
			
			addEventListener(Event.ENTER_FRAME, parseHandler);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function clickHandler(event:MouseEvent):void {
			if(event.target == _copy) {
				copyTextFormat();
			}else{
				super.clickHandler(event);
			}
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		override protected function computePositions(event:Event = null):void {
			super.computePositions();
			
			_spin.x = _window.x + 20;
			_spin.y = _window.y + 20;
		}
		
		/**
		 * Starts the stats parsing
		 */
		private function startParsing():void {
			//Clone map
			_ba = new ByteArray();
			_ba.writeBytes( _map.data );
			_ba.position = 0;
			
			_values = [];
			var i:int, len:int;
			len = Textures.getInstance().cubesFrames.length + Textures.getInstance().customKubes.length;
			for(i = 0; i < len; ++i) {
				_values[i] = 0;
			}
			
			while(_kubesHolder.numChildren > 0) { _kubesHolder.removeChildAt(0); }
			
			_copy.enabled = false;
			_parsingComplete = false;
			_spin.open();
			parseHandler();
		}
		
		/**
		 * Parses the map progressively not to lock the UI
		 */
		private function parseHandler(event:Event = null):void {
			if(_parsingComplete) return;
			
			var s:int = getTimer();
			var tile:int;
			while(getTimer()-s < 20 && _ba.bytesAvailable) {
				tile = _ba.readUnsignedByte();
				if(tile > 0) _values[tile] ++; 
			}
			
			var i:int, len:int, index:int, item:KubeCounter, total:int;
			len = _values.length;
			for(i = 0; i < len; ++i) {
				if(_values[i] > 0) {
					if(index >= _spool.length) {
						item = new KubeCounter();
						_spool.push(item);
					}else{
						item = _spool[index];
					}
					
					_kubesHolder.addChild(item);
					item.populate(i, _values[i]);
					
					index ++;
					total += _values[i];
				}
			}
			
			PosUtils.hDistribute(VectorUtils.toArray(_spool), (39+5)*12, 5, 5, true);
			if(!_ba.bytesAvailable) {
				_parsingComplete = true;
				_copy.enabled = true;
				_spin.close();
			}

			var days:int = Math.ceil(total/Config.getNumVariable("energyPerDay"));
			var price:Number = days * Config.getNumVariable("energyCost");
			_label.text = Label.getLabel("stats-details").replace(/\{TOTAL\}/gi, total).replace(/\{DAYS\}/gi, days).replace(/\{PRICE\}/gi, price.toFixed(2));
			_label.y = _kubesHolder.height + 10;
			_label.width = Math.max(150, _kubesHolder.width);
			_copy.y = Math.round(_label.y + _label.height) + 10;
			_copy.x = Math.round((_label.width - _copy.width) * .5);
			
			computePositions();
		}
		
		/**
		 * Copies a textual representation of the statistics
		 */
		private function copyTextFormat():void {
			var i:int, len:int, item:KubeCounter, text:String;
			len = _kubesHolder.numChildren;
			text = "";
			for(i = 0; i < len; ++i) {
				item = _kubesHolder.getChildAt(i) as KubeCounter;
				text += item.total+" - "+Label.getLabel("kube"+item.kubeId)+"\r";
			}
			
			text += _label.rawText;
			
			
			if(Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, text)) {
				_checkIcon.gotoAndPlay(1);
				_copy.icon = _checkIcon;
				_copy.x = Math.round((_label.width - _copy.width) * .5);
				setTimeout(removeIcon, 1500);
			}
		}
		
		/**
		 * Removes the copy button icon.
		 */
		private function removeIcon():void {
			_copy.icon = null;
			_copy.x = Math.round((_label.width - _copy.width) * .5);
		}
		
	}
}