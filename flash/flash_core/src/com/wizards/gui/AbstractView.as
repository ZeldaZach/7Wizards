package com.wizards.gui
{
	import com.wizards.Global;
	import com.wizards.loaders.ILoaderView;
	import com.wizards.locale.Localization;
	import com.wizards.locale.ResourceBundle;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	
	public class AbstractView extends EventDispatcher
	{
		private var _content:MovieClip;
		
		public var _bundle:ResourceBundle;
		
		private var _resourceName:String;
		
		private var _loader:ILoaderView;
		
		public var parameters:Object;
		
		/***
		 *  Preload  localization for current view
		 *  Cache locale
		 * */
		public function AbstractView(content:MovieClip, resource:String = null)
		{
			if (resource != null)
			{
				_resourceName = resource;
				_bundle 	  = Localization.getBundle(resource, initialize);
			} else {
				initialize();
			}
			
			_content = content;
			
			ExternalInterface.addCallback("htmlCallback", htmlCallback);
		}
		
		public function htmlCallback(refresh:Boolean, drid:Number):void {
			if(refresh) {
				this.dispatchEvent(new Event("REFRESH"));
			}
			
			Global.drid = drid;
		}
		
		/**
		 * Cached Resource bundle
		 * */
		public function get bundle():ResourceBundle
		{
			if(!_bundle || !_bundle.isLoaded)
			{
				_bundle = Localization.getBundle(_resourceName, initialize);
			}
			
			return _bundle
		}
		
		/**
		 * Child view should override initialize method
		 * */
		protected function initialize():void
		{
//			throw(new Error("initialize should override"))
		}
		
		public function loaderLayot():MovieClip
		{
			return null;
		}
		
		public function created():void
		{
		}
		
		public function get content():MovieClip { return _content; }
		public function set content(clip:MovieClip):void { _content = clip }
		
		public function get loader():ILoaderView { return _loader; }
		public function set loader(load:ILoaderView):void { _loader = load }
		
		
	}
}