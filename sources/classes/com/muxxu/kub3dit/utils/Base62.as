package com.muxxu.kub3dit.utils
{
 
    /**
     * Encode/Decode Base62
     * @author leo@blixtsystems.com
     */
    public class Base62
    {
        public static var chars:String = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
        public static var base:int = 62;
 
        public function Base62()
        {
        }
 
        public static function encode(val:Number):String
        {
            var str:String = '';
            var i:int;
            while(val > 0)
            {
                i = val % base;
                str = chars.substr(i,1) + str;
                val = (val - i) / base;
            }
            return str;
        }
 
        public static function decode(str:String):Number
        {
            var len:int = str.length;
            var val:int = 0;
            for (var i:int = 0; i < len; ++i)
            {
                val += chars.indexOf(str.substr(i,1)) * Math.pow(base, len-i-1);
            }
            return val;
        }
    }
}