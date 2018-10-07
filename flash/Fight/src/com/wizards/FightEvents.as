package com.wizards
{
	import com.wizards.models.PersonModel;
	
	import flash.events.Event;
	
	public class FightEvents extends Event
	{
		public static const FIGHT_ANIMATION_START:String 	= "FIGHT_START" 
		public static const FIGHT_ANIMATION_WINNER:String 	= "FIGHT_WINNER"
		
		public var person:PersonModel;
		
		public function FightEvents(event:String, p:PersonModel = null)
		{
			super(event);
			
			this.person = p;
		}

	}
}