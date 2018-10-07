package com.wizards.services
{
	import com.wizards.Global;
	import com.wizards.dto.CallBackDTO;
	import com.wizards.dto.IDTO;
	import com.wizards.events.CallbackEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	public class WebService extends EventDispatcher
	{
		private var request:URLRequest;
		private var loader:URLLoader;
		private var variables:URLVariables;

		public var dto:IDTO;
		
		public function WebService()
		{
			super();
		}
		
		/**
		 * Makes the web service call
		 * @param $method either POST or GET. POST is set as default
		 * @param $arguments any parameters or variables that you need to make with your web service call
		 *
		 */
		public function doCall(path:String, clazz:Class = null, arguments:Object = null, showLoader:Boolean = true, method:String = URLRequestMethod.GET):void
		{
			if(showLoader) Global.loaderView.show();
			
			if (clazz != null )
			{
				dto = new clazz();
			}
			
			var url:String = path;
			
			if(path.charAt(0) != "/")
			{
				url = Global.baseUrl + url;
			}
			
			request = new URLRequest(url);
			var variables :URLVariables = new URLVariables();
			
			if(arguments)
			{
				var jsonString:String = JSON.stringify(arguments);
        	        variables.json = jsonString;
			}
    	    variables.flash = true;
    	    variables.drid  = Global.drid;
			request.data    = variables;
			
			request.method = method.toUpperCase();
			
			Global.synchUrlLoader.addEventListener(Event.COMPLETE, handleRequestLoaded);
			Global.synchUrlLoader.addEventListener(IOErrorEvent.IO_ERROR, handleRequestError);
			
			Global.synchUrlLoader.load(request);
		}
		
		private function handleRequestLoaded(event:Event):void
		{
			Global.synchUrlLoader.removeEventListener(Event.COMPLETE, handleRequestLoaded);
			
			if(Global.synchUrlLoader.isCompleated) {
				Global.loaderView.hide();
			}
			
			this.dispatchEvent(new CallbackEvent(CallbackEvent.WEB_SERVICE_RESULT, parseResult(event.target.data)));
		}

		private function handleRequestError(event:IOErrorEvent):void
		{
			Global.synchUrlLoader.removeEventListener(IOErrorEvent.IO_ERROR, handleRequestError);
			
			if(Global.synchUrlLoader.isCompleated) {
				Global.loaderView.hide();
			}
			
			this.dispatchEvent(new CallbackEvent(CallbackEvent.WEB_SERVICE_FAULT));
		}
		
		private function parseResult(result:Object):IDTO
		{
			
			if(dto != null)
			{
				var jsonData:Object;
				var xml:XML = new XML(result);
				
				if(xml.hasComplexContent())
				{
					ExternalInterface.call("navigateToLogin");
					
					if(Global.isDebug)
					{
						throw(new Error("XML data from server. May be you are not logget in! "));
					}
					
					return null;
				}
				
				jsonData = JSON.parse(result as String);
				
				if(jsonData.error)
				{
					throw(new Error("SERVER SIDE ERROR: " + jsonData.message.toString()));
				}
				
				if(jsonData.drid != null) {
					Global.drid = Number(jsonData.drid);
				}
				
				dto.populate(jsonData);
				return dto;
			}
			
			var resultDTO:CallBackDTO = new CallBackDTO();
			resultDTO.setData(result);
			
			
			return resultDTO;
		}
		
		protected function onDefaultFault(e:Event):void
		{
			throw(new Error(e))
		} 
		

		

	}
}