package com.wizards.controls
{
	import mx.collections.ArrayCollection;
	
	public dynamic class HashMap extends Object {

        public function clear():void {
            for (var key:String in this)
                this[key] = null;
        }

        /** 'get' is an ActionScript reserved word */
        public function getIndex(index:int):* {
            var i:int = 0;
            for (var key:String in this) {
                if (i==index)
                    return this[key];
            }
            return null;
        }

        /** ActionScript cannot overload functions so a unique function name was chosen */
        public function getItem(key:String):Object { return this[key]; }

        public function put(key:String, value:Object):void {
            this[key] = value;
        }

        public function remove(key:String):Object {
            this[key] = null;
            return this;
        }

        public function size():int {
            var len:int = 0;
            for (var key:String in this)
                len++;
            return len;
        }

        public function toString():String {
            var delim:String = "";
            var str:String;
            for (var key:String in this) {
                str += delim + key + ": " + this[key];
                delim = "\n";
            }
            return str;
        }

        public function values():ArrayCollection {
            var values:ArrayCollection = new ArrayCollection();
            for (var key:String in this)
                values.addItem(this[key]);
            return values;
        }
    }
}