package com.wizards.events
{
	import flash.events.Event;
	
	public class DressupEvent extends Event
	{
		public static const PREV_BUTTON_CLICK:String = "dress_prev_button";
		public static const NEXT_BUTTON_CLICK:String = "dress_next_button";
//		public static const PICKER_COLOR_SHOW:String = "dress_color_show_picker";
		public static const PICKER_COLOR_CHANGE:String = "dress_color_hide_picker";
		
		public var dressType:String;
		public var color:int;
		public var event:String;
		
		
		public function DressupEvent(event:String, type:String, color:int = 0xFFFFFF)
		{
			super(event);
			
			this.event = event;
			this.dressType  = type;	
			this.color = color;
		}

	}
}