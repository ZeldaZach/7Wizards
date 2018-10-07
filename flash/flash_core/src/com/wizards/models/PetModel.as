package com.wizards.models
{
	import com.wizards.Global;
	import com.wizards.utils.URLHelper;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class PetModel extends Sprite
	{
		public static const PET_CREATED:String = "pet_created"
		public var _content:MovieClip;
		private var _assetsLoaded:Boolean;
		private var _factory:IModelsFactory;
		private var _kind:String;
		private var _scale:Number = 1;
		private var _modelType:String = DefaultModelsFactory.MOVE_MODEL;
		
		public function PetModel(pet_kind:String)
		{
			_kind = pet_kind;	
		}
		
		public function set modelType(type:String):void
		{
			_modelType = type;
		}
		
		public function get modelType():String
		{
			return _modelType;
		}
		
		public function get kind():String
		{
			return "pet" + _kind;
		}
		
		public function set scale(value:Number):void
		{
			_scale = value;
		}
		
		public function get content():MovieClip
		{
			return _content;
		}
		
		public function get factory():IModelsFactory
		{
			if(!_factory)
			{
				_factory = new PetModelFactory(kind);
			}
			return _factory 
		}
		
		public function refresh():void
		{
			Global.loaderView.show();
			if (_assetsLoaded)
				createModel();
			else
				loadAssets();
		}
		
		private function createModel():void
		{
			if(_content)
			{
				removeChild(_content)
			} 
			
			_content = factory.getModel(_modelType);
			
			_content.scaleX = _content.scaleY = _scale;
			
			addChild(_content);
			
			dispatchEvent(new Event(PET_CREATED));
			
			Global.loaderView.hide();

		}
		
		private function loadAssets():void
		{
			var urlList:Array = [];
			urlList.push(URLHelper.petsModels(kind));
			
			Global.classLoader.callbackOnReady(onAssetsComplete, urlList);
		}
		
		private function onAssetsComplete(e:Event = null):void
		{
			createModel();
			
			_assetsLoaded = true;
		}
		
		public function get currentFrame():Number
		{
			if(_content)
			{
				return _content.currentFrame;
			}
			return 0;	
		}
		
		public function get totalFrames():Number
		{
			if(_content)
			{
				return _content.totalFrames;
			}
			return 0;	
		}
	}
}