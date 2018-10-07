package com.wizards.utils
{
	import com.wizards.events.ResourceLoadEvent;
	import com.wizards.loaders.ILoaderView;
	
	import flash.display.Loader;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	
	public class ClassLoader 
	{
	    private var _swfLib:String;
	    private var _request:URLRequest;
	    private var _loadedClass:Class;
	    
	    private var _modules:Object = {};

		/**
		 * Class loader for base swf library loading
		 * */
		public function ClassLoader() 
		{
		}
		
		public function getClass(url:String, className:String):Class
		{
			var domain:ApplicationDomain = Module(_modules[url]).domain;
			return domain.hasDefinition(className) ? Class(domain.getDefinition(className)) : null;
		}
		
		public function getInstance(url:String, className:String):Object
		{
			var domain:ApplicationDomain = Module(_modules[url]).domain;
			if (domain.hasDefinition(className))
			{
				var objectClass:Class = Class(domain.getDefinition(className));
				return new objectClass();  
			}
			else
			{
				throw new IllegalOperationError('class ' + className + ' not found in ' + url);
				return null;
			}
		}
		
		
		public function getDomain(url:String):ApplicationDomain
		{
			var module:Module = _modules[url];
			return (module) ? module.domain : null;
		}
		
	    public function callbackOnReady(listener:Function, urlList:Array):void
	    {
	    	
	    	var task:TaskCounter = new TaskCounter();
	    	for each (var url:String in urlList)
			{
				var module:Module;
				
				if (url in _modules)
				{
					module = _modules[url];	
				}
				else
				{
					module = new Module(url);
					_modules[url] = module;
				}
				
				if (!module.isComplete)
				{
					task.addCount();
					module.addEventListener(ResourceLoadEvent.CLASS_LOADED, task.completeTask);
					module.addEventListener(ResourceLoadEvent.LOAD_ERROR, resourceLoadError);
				}
			}
			
			if (task.isEmpty)
			{
				listener();
			}
			else {
				task.completeEvent.addEventListener(TaskCounter.COMPLEATE_TASK, 
					function():void {
							listener();
						});
			}
	    }
	    
	    public function resourceLoadError(e:ResourceLoadEvent):void
	    {
		    throw(new Error("Can't load resource: " + e.url));
	    }
	    

	}
}
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;
	import com.wizards.loaders.BaseLoader;
	import com.wizards.services.WebService;
	import flash.utils.setTimeout;
	import mx.logging.ILogger;
	import com.wizards.loaders.ILoaderView;
	import com.wizards.events.ResourceLoadEvent;
	import com.wizards.Global;
	

internal class Module extends EventDispatcher
{
	public var loader:BaseLoader;
	public var domain:ApplicationDomain;
	public var isComplete:Boolean = false;
	
	private var url:String;
	
	public function Module(url:String, loaderView:ILoaderView = null)
	{
		this.url = url;
		
		loader = new BaseLoader(loaderView);
		
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
    	loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        
		loader.load(new URLRequest(url))
	}
	
	private function completeHandler(e:Event):void 
	{
      isComplete = true;
	  domain = loader.contentLoaderInfo.applicationDomain;

	  removeEventListener(Event.COMPLETE, completeHandler)
	  dispatchEvent(new ResourceLoadEvent(ResourceLoadEvent.CLASS_LOADED, url));
	}
	
	private function ioErrorHandler(e:IOErrorEvent):void 
	{
	  isComplete = true;
	  dispatchEvent(new ResourceLoadEvent(ResourceLoadEvent.LOAD_ERROR, url));
	}
	
    private function securityErrorHandler(e:Event):void {
       isComplete = true;
       dispatchEvent(new ResourceLoadEvent(ResourceLoadEvent.LOAD_ERROR, url));
    }
}