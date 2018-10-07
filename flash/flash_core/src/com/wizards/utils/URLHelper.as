package com.wizards.utils
{
	import com.wizards.Global;
	
	public class URLHelper
	{
		public static var RESOURCES_CORE : String = "/flash/resources/{0}/"
		public static var RESOURCES_PATH_FORMAT : String = RESOURCES_CORE + "{1}.swf?"
		public static var PERSONS : String = "persons";
		public static var PETS : String = "pets";
		
		static public function resourceURL(folder:String, id:String):String
		{
			return Strings.substitute(RESOURCES_PATH_FORMAT, folder, id) + Global.buildVersion;
		}
		
		static public function personModels(modelName:String) : String
		{
			return resourceURL(PERSONS, modelName);
		}
		
		static public function clothesURL(type:String, id:String):String
		{
			return resourceURL(type, id );
		}
		
		static public function petsModels(kind:String):String
		{
			return resourceURL(PETS, kind );
		}

	}
}