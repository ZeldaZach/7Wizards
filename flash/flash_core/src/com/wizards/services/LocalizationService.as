package com.wizards.services
{
	import com.wizards.Global;
	import com.wizards.events.CallbackEvent;
	import com.wizards.utils.Strings;
	
	import flash.events.Event;
	
	public class LocalizationService extends WebService
	{
		public function LocalizationService(resultHandler:Function, faultHandler:Function = null)
		{
			super();
			
			addEventListener(CallbackEvent.WEB_SERVICE_RESULT, resultHandler);
			addEventListener(CallbackEvent.WEB_SERVICE_FAULT, faultHandler || defaultFaultHandler);
		}
		
		public function getLocalization():void
		{
			super.doCall(Strings.substitute("/locale_{0}.xml?{1}", Global.locale, Global.buildVersion));
		}
		
		private function defaultFaultHandler(event:Event):void
		{
			trace("error")
			//DEFAULT ERROR HANDLER
		}

	}
}