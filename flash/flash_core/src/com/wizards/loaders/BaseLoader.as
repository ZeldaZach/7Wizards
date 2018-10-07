package com.wizards.loaders
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	public class BaseLoader extends Loader
	{
		private var _url:String;
		private var _view:ILoaderView;
		private var _compleated:Boolean;
		
		/***
		 * Compleately not implemented
		 * */
		public function BaseLoader(view : ILoaderView = null)
		{
			super();
			_view = view;
			
			contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadFault);
			
			if (_view)
				contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
		}
		
		public function isCompleated():Boolean
		{
			return _compleated;
		}
		
		override public function load(request:URLRequest, context:LoaderContext = null):void
		{
			_compleated = false;
			_url = request.url;
			super.load(request, context);
		}
		
		protected function onLoadComplete(e:Event):void
		{
			_compleated = true;
		}
		
		protected function onLoadFault(e:IOErrorEvent):void
		{
			_compleated = true;
		}
		
		protected function onProgress(e:ProgressEvent):void
		{
//			_view.content.inner_text.text = 'www';
//			trace(2);
		}
		
		

	}
}