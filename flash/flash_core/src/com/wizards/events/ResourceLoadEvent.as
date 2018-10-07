package com.wizards.events
{
	import flash.events.Event;
	
	public class ResourceLoadEvent extends Event
	{
		public static var CLASS_LOADED:String = "classLoaded";
	    public static var LOAD_ERROR:String   = "loadError";
	
		public var url:String;
		
		public function ResourceLoadEvent(event:String, url:String = null)
		{
			super(event);
			this.url = url;
		}

	}
}