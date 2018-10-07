package com.wizards.locale
{
	import com.wizards.events.CallbackEvent;
	import com.wizards.services.LocalizationService;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class ResourceBundle extends EventDispatcher
	{
		public static const RESOURCE_LOADED:String = "resource_loaded";
		
		private var _id : String;
		private var _loaded : Boolean;
		private var _resource:Object = new Object();
		
		public function ResourceBundle()
		{
		}
		
		public function get id():String
		{
			return _id;
		}

		public function set id(value:String):void
		{
			if(_id != value)
			{	
				_id = value;
				_loaded = false;
				new LocalizationService(onResult, onFault).getLocalization();
			}
		}
		
		public function get isLoaded():Boolean
		{
			return _loaded;
		}
		
		public function getMessage(msg:String):String
		{
			if(!_resource || !_resource[msg])
			{
				return "translate error: " + msg
			}
			return _resource[msg];
		}
		
		protected function onResult(e:CallbackEvent):void
		{
			_loaded = true;
			var xml:XML = new XML(e.dto.getData());

			for each(var child : XML in xml.elements(_id).children())
			{
				_resource[child.name()] = child.text();
			}
			
			dispatchEvent(new Event(RESOURCE_LOADED));
		} 
		
		protected function onFault(e:Event):void
		{
			trace("resource error");
		}

	}
}