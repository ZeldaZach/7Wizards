package com.wizards.events
{
	import com.wizards.dto.IDTO;
	
	import flash.events.Event;
	
	public class CallbackEvent extends Event
	{
		public static const WEB_SERVICE_FAULT:String 	= "WEB_FAULT" 
		public static const WEB_SERVICE_RESULT:String 	= "WEB_RESULT"
		
		public var event:String;
		public var dto:IDTO;
		
		public function CallbackEvent(event:String, dto:IDTO = null)
		{
			super(event);
			
			this.dto = dto;
		}

	}
}