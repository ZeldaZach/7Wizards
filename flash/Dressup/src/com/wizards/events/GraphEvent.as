package com.wizards.events
{
	import flash.events.Event;
	
	public class GraphEvent extends Event
	{
		public static const CUSTOM_EVENT 	:String = 'onCustomEvent';
		private var _evt_type 				:String;
		private var _evt_params 			:Object;
		
		public function GraphEvent(evt_type:String = CUSTOM_EVENT, evt_params:Object = null ) 
		{
			super(evt_type, true, true);
			_evt_type = evt_type;
			_evt_params = evt_params;
		}
		
		public function get params():Object 
		{
			return _evt_params;
		}

	}
}