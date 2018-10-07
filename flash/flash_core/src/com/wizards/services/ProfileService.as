package com.wizards.services
{
	import com.wizards.dto.CallBackDTO;
	import com.wizards.dto.PersonDTO;
	import com.wizards.events.CallbackEvent;
	
	public class ProfileService extends WebService
	{
		public function ProfileService(resultHandler:Function, faultHandler:Function = null)
		{
			super();
			
			addEventListener(CallbackEvent.WEB_SERVICE_RESULT, resultHandler);
			addEventListener(CallbackEvent.WEB_SERVICE_FAULT, faultHandler || onDefaultFault);
		}
		
		public function getClothes(args:Object = null):void
		{
			super.doCall("profile/user_data", PersonDTO, args);
		}
		
		public function save(args:Object):void
		{
			super.doCall("profile/clothe_save", CallBackDTO, args);
		}
		
		public function buy(args:Object):void
		{
			super.doCall("profile/buy", CallBackDTO, args);
		}
		
	}
}