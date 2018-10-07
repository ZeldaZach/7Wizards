package com.wizards.utils
{
	public class ObjectUtils
	{
		public static function getPropertiesStartWith(o:Object, name:String):Array
		{
			var result:Array = [];
			for(var property:String in o)
			{
				if(property.indexOf(name, 0) != -1)
				{
					result.push(property);
				}
			}
			return result;
		}
		
		public static function getAllProperties(o:Object):Array
		{
			var result:Array = [];
			for(var property:String in o)
			{
				result.push(property);
			}
			return result;
		}
		
    }
}