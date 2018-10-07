package com.wizards.locale
{
	import flash.events.Event;
	
	public class Localization
	{
		/**
		 * bundles (like HasMap) - contais cached resource
		 * */
		private static var bundles:Object = new Object();
		private static var bundle : ResourceBundle = new ResourceBundle();
		
		public static function getBundle(id : String, callback:Function = null) : ResourceBundle
		{
			
			if(!bundles[id])
			{
				var internalListen:Function = function(e:Event):void
					{
						bundle.removeEventListener(ResourceBundle.RESOURCE_LOADED, internalListen)
						bundles[id] = bundle;		
						
						if(callback != null) 	
						{
							callback();
						}			
					}
					
				bundle.addEventListener(ResourceBundle.RESOURCE_LOADED, internalListen);
				
				bundle.id = id;
			}
			
			return bundles[id];
		}
		

	}
}