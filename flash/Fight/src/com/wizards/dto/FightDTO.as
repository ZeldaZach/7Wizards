package com.wizards.dto
{
	public class FightDTO implements IDTO
	{
		private var _message:String;
		private var _dataObject:Object;
		private var _success:Boolean;
		
		public var description:String;
		public var won:Boolean;
		public var refresh:Boolean;
		public var log_id:String;
		public var user_pet_killed:Boolean = false;
		public var opponent_pet_killed:Boolean = false;
		
		public function populate(data:Object):void
		{
			won			= data.won;
			refresh		= data.refresh;
			log_id		= data.log_id;
			description = data.description;
			_success    = data.success;
			_message    = data.message;
			_dataObject = data;
			
			user_pet_killed = !Boolean(data.user_pet_active);
			opponent_pet_killed = !Boolean(data.opponent_pet_active); 
		}
		
		public function getData():Object
		{
			return _dataObject;
		}
		
		public function message():String
		{
			return _message;
		}
		
		public function setData(o:Object):void
		{
			_dataObject = o;
		}
		
		public function success():Boolean
		{
			return _success || false;
		}

	}
}