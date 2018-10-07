package com.wizards.dto
{
	public interface IDTO
	{
		function populate(data:Object):void;
		function getData():Object;	
		function success():Boolean;
		function message():String;		
	}
}