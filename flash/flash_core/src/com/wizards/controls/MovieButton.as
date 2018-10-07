package com.wizards.controls
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class MovieButton
	{
		public static function createButton(movie:MovieClip, name:String, func:Function = null, font:Font = null):MovieClip
		{
			movie.mcText.text = name;
			movie.visible = true;
			movie.useHandCursor = true;
			movie.buttonMode = true;
			movie.mouseChildren = false;

			if(func != null)
			{
				movie.addEventListener(MouseEvent.CLICK, func);
			}
			
			if(font)
			{
				decorateField(movie.mcText, font);
			}
			
			return movie 
		}
		
		public static function decorateField(field:TextField, font:Font):void {
			var format:TextFormat = new TextFormat();
				format.font = font.fontName;
				field.defaultTextFormat = format;
				field.embedFonts = true;
				field.autoSize = "center";	
		}
		
		public static function createLabel(button:SimpleButton, text:String):void 
		{
			var states:Array = [button.downState, button.upState, button.overState];
			
			for each(var state:DisplayObjectContainer in states) {
				for (var i:int = 0; i < state.numChildren; i++)
				{
					try
					{
						var child:Object = state.getChildAt(i);
						if(child is TextField) {
							(child as TextField).text = text;
							break;
						}
					}
					catch(e : SecurityError)
					{
						//Ok. can be thrown if child is loaded from another domain
					}
				}
			}
		}

	}
}