package com.wizards.models
{
	import com.wizards.Global;
	import com.wizards.dto.IDTO;
	import com.wizards.dto.PersonDTO;
	import com.wizards.loaders.ILoaderView;
	import com.wizards.utils.ObjectUtils;
	import com.wizards.utils.SpriteDecorator;
	import com.wizards.utils.Strings;
	import com.wizards.utils.URLHelper;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	
	public class PersonModel extends Sprite
	{
	
		public static const PERSON_CREATED:String = "person_created"
		private var _content:MovieClip;
		private var _personDto:PersonDTO;
		
		private var _assets:Array = [];
		private var _assetsLoaded:Boolean;
		private var _factory:IModelsFactory;
		private var _cache_dersses:int;
		private var _scale:Number = 1;
		private var _modelType:String = DefaultModelsFactory.MOVE_MODEL
		
		private var _loader:ILoaderView;
		
		public function PersonModel(cache:int = PersonDTO.CACHE_ACTIVE_DRESSES)
		{
			super();
			_cache_dersses = cache;
		}
		
		public function setPersonData(dto:IDTO):void
		{
			if(dto)
			{
				_personDto = new PersonDTO(dto.getData())
				
				refresh();
			}
		}
		
		public function get dto():PersonDTO
		{
			return _personDto;
		}
		
		public function set modelType(type:String):void
		{
			_modelType = type;
		}
		
		public function get modelType():String
		{
			return this._modelType;
		}
		
		public function set scale(value:Number):void
		{
			_scale = value;
		}
		
		public function set position(pos:Rectangle):void
		{
			dto.position = pos;
		}
		
		public function get position():Rectangle
		{
			return dto.position;
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
			
			decorateModel();
			
			_content.scaleX = _content.scaleY = _scale;
			
			dispatchEvent(new Event(PERSON_CREATED));
			Global.loaderView.hide();

		}
		
		public function get factory():IModelsFactory
		{
			if(!_factory)
			{
				_factory = new DefaultModelsFactory(_personDto.skin);
			}
			return _factory 
		}
		
		public function get content():MovieClip
		{
			return _content;
		}
		
		/**
		 * Load all user items clothes from swf libraries
		 * Caching resources
		 * */
		private function loadAssets(cleanFlag:Boolean = false):void
		{
			var urlList:Array = [];
			urlList.push(URLHelper.personModels(_personDto.skin));
			
			var dressResources:Array = _personDto.getActiveDresses();
			
			if(_cache_dersses == PersonDTO.CACHE_ALL_DRESSES)
			{
				dressResources = _personDto.getAllDresses();
			}
			 
			for each(var dress:Object in dressResources)
			{
				//dress.by_name - cetegory name
				if(dress.by_name) {
					urlList.push(URLHelper.clothesURL("clothes", dress.by_name + "_" + dress.name));
				} else {
					urlList.push(URLHelper.clothesURL("clothes", _personDto.skin + "_" + dress.name));
				}
			}
			
			Global.classLoader.callbackOnReady(onAssetsComplete, urlList);
		}
		
		private function onAssetsComplete(e:Event = null):void
		{
			createModel();
			
			_assetsLoaded = true;
		}
		
		private function decorateModel():void
		{
			
			_assets = [];
			
				var dressResources:Array = _personDto.getActiveDresses();
			for each(var dress:Object in dressResources)
			{
				var url:String;
				if(dress.by_name) {
					url = URLHelper.clothesURL("clothes", dress.by_name + "_" + dress.name);
				} else {
					url = URLHelper.clothesURL("clothes", _personDto.skin + "_" + dress.name);
				}
				var domain:ApplicationDomain = Global.classLoader.getDomain(url);
			
				if (domain)
					_assets.push({domain: domain, color:dress.color});
				
			}
			
			SpriteDecorator.decorateColor(_content.body, _personDto.body_color);
			SpriteDecorator.decoratePerson(_content.body, _assets, _personDto);
			
			addChild(_content);
		}
		
		public function nextClothe(clotheName:String):void
		{
			if(_personDto.clothes[clotheName].by_names != null) {
				
				var default_name:String = _personDto.clothes[clotheName].by_names[0];
				
				if(_personDto.usedClothes[clotheName] == null) {
					_personDto.usedClothes[clotheName] = _personDto.getDefaultClotheItem(clotheName)
				}
					var index:Number = _personDto.clothes[clotheName].by_names.indexOf(_personDto.usedClothes[clotheName].name);
					var next_name:String = _personDto.clothes[clotheName].by_names[index + 1];
					
					if(next_name == null) 
						next_name = "" ;   
					 
					_personDto.usedClothes[clotheName].name = next_name ;
					_personDto.usedClothes[clotheName].by_name = clotheName;
				
			} else if(_personDto.clothes[clotheName].count != null){
				var nextId:Number = _personDto.nextDressId(clotheName);
				_personDto.usedClothes[clotheName].id = nextId;
			}
			
			refresh();
		}
		
		public function prevClothe(clotheName:String):void
		{
			//next clothes by names
			if(_personDto.clothes[clotheName].by_names != null) {
				var default_name:String = _personDto.clothes[clotheName].by_names[_personDto.clothes[clotheName].by_names.length - 1];
				
				if(Strings.isBlank(_personDto.usedClothes[clotheName].name)) {
					_personDto.usedClothes[clotheName].name = default_name;
				} else {
					var index:Number = _personDto.clothes[clotheName].by_names.indexOf(_personDto.usedClothes[clotheName].name);
					var next_name:String = _personDto.clothes[clotheName].by_names[index - 1];
					
					if(next_name == null)
					 	next_name = "";
					 
					_personDto.usedClothes[clotheName].name = next_name ;
				}
				
				_personDto.usedClothes[clotheName].by_name = clotheName;
			} else if(_personDto.clothes[clotheName].count != null){
				
				//next clothes by ids
				var prevId:Number = _personDto.prevDressId(clotheName);
				_personDto.usedClothes[clotheName].id = prevId;
			}
			
			refresh();
		}
		
		public function setColor(clotheName:String, color:int):void
		{
			
			_personDto.usedClothes[clotheName].color = color
			
			refresh();
		}
		
		public function setBodyColor(color:int):void
		{
			
			_personDto.body_color = color;
			
			refresh();
		}
		
		public function clearDresses():void
		{
			for each(var name:String in ObjectUtils.getAllProperties(_personDto.usedClothes))
			{
				if(_personDto.usedClothes[name].name != null) {
					_personDto.usedClothes[name].name = "";
				} else {
					
					if(PersonDTO.PERSON_PARTS_TO_REPLACE.indexOf(name) >= 0)
					{
						_personDto.usedClothes[name].id = 1;
					} else {
						
						_personDto.usedClothes[name].id = 0;
					}
				}
			}
			
			refresh();
		}
		
		public function get clothes():Object
		{
			return _personDto.usedClothes;
		}
		
		public function get available_clothes():Object
		{
			return _personDto.clothes;
		}
		
		public function getItemCategories():Array
		{
			var categories:Array = []
			for (var category:String in _personDto.clothes)
			{
				categories.push(category); 
			}
			return categories;
		}
		
		public function get hasPet():Boolean
		{
			return dto.hasPet();
		}
		
		public function get currentFrame():Number
		{
			if(_content.body)
			{
				return _content.body.currentFrame;
			}
			return 0;	
		}
		
		public function get totalFrames():Number
		{
			if(_content.body)
			{
				return _content.body.totalFrames;
			}
			return 0;	
		}
		
		
		public static function playAll(content:DisplayObjectContainer):void
		{
			if (content  is MovieClip)
        		(content as MovieClip).gotoAndPlay(1);
   
		    if (content.numChildren)
		    {
		        var child:DisplayObjectContainer;
		        for (var i:int, n:int = content.numChildren; i < n; ++i)
		        {
		            if (content.getChildAt(i) is DisplayObjectContainer)
		            {
		                child = content.getChildAt(i) as DisplayObjectContainer;
		               
		                if (child.numChildren)
		                    playAll(child);
		                else if (child is MovieClip)
		                    (child as MovieClip).gotoAndPlay(1);
		            }
		        }
    		}
		}
		
		public static function stopAll(content:DisplayObjectContainer):void
		{
			if(content == null) return
			
			if (content  is MovieClip)
        		(content as MovieClip).gotoAndStop(1);
   
		    if (content.numChildren)
		    {
		        var child:DisplayObjectContainer;
		        for (var i:int, n:int = content.numChildren; i < n; ++i)
		        {
		            if (content.getChildAt(i) is DisplayObjectContainer)
		            {
		                child = content.getChildAt(i) as DisplayObjectContainer;
		               
		                if (child.numChildren)
		                    stopAll(child);
		                else if (child is MovieClip)
		                    (child as MovieClip).gotoAndStop(1);
		            }
		        }
    		}
		}
	}
}