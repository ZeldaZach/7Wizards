package com.wizards.controls
{
	import flash.display.SimpleButton;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	/**Wrapper for Simple button with actionname**/
	public class ExtendedButton extends EventDispatcher
	{
		public var actionName:String;
		public var isMetalPicker:Boolean;
		public var button:SimpleButton;

		public function ExtendedButton(simpleButton:SimpleButton, name:String, metalPicker:Boolean = false)
		{
			isMetalPicker = metalPicker;
			button = simpleButton;
			actionName = name;
			button.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		public function onClick(e:MouseEvent):void
		{
			dispatchEvent(e);
		}
		
		

	}
}