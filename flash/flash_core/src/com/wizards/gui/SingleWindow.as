package com.wizards.gui
{
	import com.wizards.Global;
	
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.system.Security;
	
	public class SingleWindow extends MovieClip
	{
		protected var _viewClass:Class;
		
		protected var _view:AbstractView;
		
		public function SingleWindow(size:Rectangle)
		{
			
			Global.appSize = size;
			
			if(root.loaderInfo.parameters)
			{
				if(root.loaderInfo.parameters.version)
				{
					Global.buildVersion = root.loaderInfo.parameters.version;
				}
				
				if(root.loaderInfo.parameters.base_url)
				{
					Global.baseUrl = root.loaderInfo.parameters.base_url;
				}
				
				if(root.loaderInfo.parameters.debug)
				{
					Global.isDebug = Boolean(Number(root.loaderInfo.parameters.debug));
				}
				
				if(root.loaderInfo.parameters.locale)
				{
					Global.locale = String(Number(root.loaderInfo.parameters.locale));
				}
				
				if(root.loaderInfo.parameters.drid)
				{
					Global.drid = Number(root.loaderInfo.parameters.drid);
				}
			}
			
			Global.initialize(root);
			
			Security.allowDomain("www.7wizards.com");
		}
		
		protected function initialize():void
		{
			createNewView();
		}
		
		private function createNewView():void
		{
			
			_view = new _viewClass();
			_view.parameters = root.loaderInfo.parameters;
		
			addChild(_view.content);
			addChild(Global.loaderView.content);
			
			if(_view.loader && _view.loaderLayot())
			{
				_view.loaderLayot().addChild(_view.loader.content);
			}

			_view.created();
		}
		
		public function get view():AbstractView
		{
			return _view;	
		}
		
	}
}