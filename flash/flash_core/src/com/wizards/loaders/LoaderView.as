package com.wizards.loaders
{
	import flash.display.MovieClip;
	
	public class LoaderView implements ILoaderView
	{
		private var _piceLoader:McLoadingLoader = new McLoadingLoader();
		
		public function LoaderView()
		{
//			_piceLoader.visible = false;	
		}
		
		public function get content():MovieClip
		{
			return _piceLoader;
		}
		
		public function show():void
		{
			_piceLoader.visible = true;
		}
		
		public function hide():void
		{
			_piceLoader.visible = false;
		}
		
		public function set y(_y:Number):void
		{
			_piceLoader.y = _y
		}
		
		public function set x(_x:Number):void
		{
			_piceLoader.x = _x
		}
	}
}