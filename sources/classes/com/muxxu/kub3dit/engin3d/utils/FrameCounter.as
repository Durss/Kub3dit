package com.muxxu.kub3dit.engin3d.utils {
	import flash.system.System;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getTimer;
	
	public class FrameCounter extends Sprite{
		private var last:uint = getTimer();
		private var ticks:uint = 0;
		private var tf:TextField;
		
		public function FrameCounter(xPos:int=0, yPos:int=0, color:uint=0x000000, fillBackground:Boolean=false, backgroundColor:uint=0x000000) {
			x = xPos;
			y = yPos;
			tf = new TextField();
			tf.textColor = color;
			tf.text = "-- fps";
			tf.selectable = false;
			tf.background = fillBackground;
			tf.backgroundColor = backgroundColor;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.filters = [new GlowFilter(0,1,1.5,1.5,10,2)];
			addChild(tf);
			width = tf.textWidth;
			height = tf.textHeight;
			addEventListener(Event.ENTER_FRAME, tick);
		}
	
		
		public function tick(evt:Event):void {
			ticks++;
			var now:uint = getTimer();
			var delta:uint = now - last;

			if (delta >= 1000) {
				var fps:Number = ticks / delta * 1000;
				tf.text = fps.toFixed(1) + " fps\n"+(Math.round((System.totalMemory/1024)/1024 * 100)/100)+"Mo";
				ticks = 0;
				last = now;
			}
		}
	}
}