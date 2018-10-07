package com.wizards.services
{
	import com.wizards.dto.FightDTO;
	import com.wizards.events.CallbackEvent;
	
	public class FightService extends WebService
	{
		public function FightService(resultHandler:Function, faultHandler:Function = null)
		{
			super();
			
			addEventListener(CallbackEvent.WEB_SERVICE_RESULT, resultHandler);
			addEventListener(CallbackEvent.WEB_SERVICE_FAULT, faultHandler || onDefaultFault);
		}
		
		public function fight(args:Object = null):void
		{
			super.doCall("fight/fight", FightDTO, args, false);
		}
		
		public function fight_dragon(args:Object = null):void
		{
			super.doCall("dragon/fight", FightDTO, args, false);
		}
		

	}
}