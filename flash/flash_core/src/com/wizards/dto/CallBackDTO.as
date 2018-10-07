package com.wizards.dto
{
	public class CallBackDTO implements IDTO
	{
		private var _message:String;
		private var _dataObject:Object;
		private var _success:Boolean;
		
		public function populate(data:Object):void
		{
			_dataObject = data
			_success    = data.success;
			_message    = data.message;
		}
		
		public function getData():Object
		{
			return _dataObject;
		}
		
		public function setData(o:Object):void
		{
			_dataObject = o;
		}
		
		public function success():Boolean
		{
			return _success;
		}
		
		public function message():String
		{
			return _message;
		}
		
	}
}