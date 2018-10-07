package com.wizards.loaders
{
	import flash.display.MovieClip;
	
	public class FullLoaderView implements ILoaderView
	{
		private var _content:McBgLoader = new McBgLoader();
		private var _layout:MovieClip;
		
		public function FullLoaderView(layout:MovieClip)
		{
			_layout	= layout;
		}
		
		public function get content():MovieClip
		{
			return _content;
		}
		
		public function show():void
		{
			_content.visible = true;
		}
		
		public function hide():void
		{
			_content.visible = false;
		}
		
		public function set y(_y:Number):void
		{
//			_content.y = _y
		}
		
		public function set x(_x:Number):void
		{
//			_content.x = _x
		}

	}
}