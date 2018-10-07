package com.wizards
{
	import com.wizards.loaders.ILoaderView;
	import com.wizards.loaders.LoaderView;
	import com.wizards.utils.ClassLoader;
	import com.wizards.utils.SynchUrlLoader;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.geom.Rectangle;
	
	public class Global
	{
		/***
		 * Should override from flash vars
		 * */
		public static var buildVersion:String = "0";
		public static var baseUrl:String = "/";
		public static var isDebug:Boolean = true;
		public static var locale:String = "en";
		public static var _appSize:Rectangle;
		
		private static var _drid:Number = 0;
		private static var _tasks:Number = 0;
		private static var _classLoader:ClassLoader = new ClassLoader();
		private static var _synchUrlLoader: SynchUrlLoader= new SynchUrlLoader();
		private static var _loader:ILoaderView = new LoaderView();
		
		public static function initialize(root:DisplayObject):void
		{
			_root = root;
			
		}
		
		public static function get classLoader():ClassLoader
		{
			return _classLoader;
		}
		
		public static function get synchUrlLoader():SynchUrlLoader
		{
			return _synchUrlLoader;
		}
		
		private static var _root:DisplayObject;
		public static function get stage():Stage
		{
			return _root.stage;
		} 
		
		public static function set appSize(r:Rectangle):void
		{
			_appSize = r;
			_loader.x = _appSize.right/2;
			_loader.y = _appSize.top/2;
		}
		
		public static function get loaderView():ILoaderView
		{
			return _loader;
		}
		
		public static function set drid(value:Number):void {
			if(value > 0) {
				_drid = value
			}
		}
		
		public static function get drid():Number {
			return _drid;
		}
		
		

	}
}