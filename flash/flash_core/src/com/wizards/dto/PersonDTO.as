package com.wizards.dto
{
	import com.wizards.utils.ObjectUtils;
	
	import flash.geom.Rectangle;
	
	import mx.utils.ObjectUtil;
	
	public class PersonDTO implements IDTO
	{
		/***
		 * Flags that marks do we need load active clothes or 
		 * all available clothes
		 * */
		public static const CACHE_ACTIVE_DRESSES:int = 0;
		public static const CACHE_ALL_DRESSES:int = 1;
		
		public static const PERSON_PARTS_TO_REPLACE:Array = ["hair", "face", "pants"];
		
		public var user_id:Number;
		public var attr_md5:String;
		public var name:String;
		public var a_level:String;
		public var skin:String;
		public var pet_kind:String;
		public var antipet:Boolean;
		public var body_color:int = 0xFEE4C5;//DEFAULT BODY COLOR
		public var clothes:Object;
		public var usedClothes:Object;
		
		private var _success:Boolean;
		private var _dataObject:Object;
		private var _message:String;
		
		public var price:Number;
		public var hasAvatar:Boolean;
		public var is_friend:Boolean;
		public var is_clan:Boolean;
		public var is_war:Boolean;
		public var position:Rectangle = new Rectangle();
		
		public function PersonDTO(data:Object = null)
		{
			if(data) populate(ObjectUtil.copy(data));
		}
		
		public function populate(data:Object):void
		{
			this._dataObject = data;
			this._success    = data.success;
			this._message    = data.message;
			
			this.user_id   	 = data.user_id;
			this.attr_md5    = data.attr_md5;
			this.name   	 = data.name;
			this.a_level     = data.a_level;
			this.skin   	 = data.skin;
			this.pet_kind 	 = data.pet_kind;
			this.clothes 	 = data.clothes; 
			this.usedClothes = data.used_clothes;
			this.price		 = data.price;
			this.hasAvatar   = data.has_avatar;
			this.antipet     = data.antipet;
			this.is_friend   = data.friends;
			this.is_clan     = data.same_clan;
			this.is_war      = data.on_war;
	
			if(data.body_color)
			{
				this.body_color	 = data.body_color;
			}
		}
		
		public function message():String
		{
			return _message;
		}
		
		/**
		 * return data (JSON format)
		 * */
		public function getData():Object
		{
			return _dataObject;
		}
		
		public function hasPet():Boolean
		{
			return Number(this.pet_kind) != 0;
		}
		
		public static function hasPart(part:String):Boolean
		{
			return PERSON_PARTS_TO_REPLACE.indexOf(part.split("_")[0]) != -1;
		}
		
		public function getMaxClothes(clotheName:String):Number
		{
			if(this.clothes[clotheName].hasOwnProperty("count")) {
				return this.clothes[clotheName].count;
			} else {
				return this.clothes[clotheName].by_names.lenght;
			}
		}
		
		public function nextDressId(clotheName:String):Number
		{
			if(!usedClothes.hasOwnProperty(clotheName) && usedClothes[clotheName] == null)
			{
				usedClothes[clotheName] = getDefaultClotheItem(clotheName)
			}
					
			if(usedClothes[clotheName].id != null) {
				
				var activeId:Number = usedClothes[clotheName].id + 1;
				var maxId:Number 	= getMaxClothes(clotheName);
				
				if(activeId > maxId) 
				{
					//default id is 0 or 1 for [hair, face]
					if(PERSON_PARTS_TO_REPLACE.indexOf(clotheName) >= 0)
					{
						activeId = 1;
					} else {
						activeId = 0;
					}
					
				}
				return activeId; 
			} 
			return -1;
		}
		
		public function prevDressId(clotheName:String):Number
		{
			if(!usedClothes.hasOwnProperty(clotheName) && usedClothes[clotheName] == null)
			{
				usedClothes[clotheName] = getDefaultClotheItem(clotheName)
			}
			
			if(usedClothes[clotheName].id != null) {
				
				var activeId:Number = usedClothes[clotheName].id - 1;
				var maxId:Number 	= getMaxClothes(clotheName);
				
				if(activeId < 0 || (PERSON_PARTS_TO_REPLACE.indexOf(clotheName) >= 0 && activeId == 0)) 
				{
					activeId = maxId;
				}
				return activeId;
			}
			
			return -1
		}
		
		public function getDressId(part:String):String
		{
			var pieceName:String = part.split("_")[0];
			return usedClothes[pieceName].id;
		}
		
		/**
		 * Check is dress with name exists
		 * */
		public function hasCategory(name:String):Boolean
		{
			for each(var category:Object in getAllDresses())
			{
				var pieceName:String = category.name.split("_")[0];
				if(pieceName.indexOf(name) == 0) return true;
			}
			return false
		}
		
		/**
		 * return - all available items for current person 
		 * with format Example: ["armleft1", "armleft2", "boots1", "boots2"]
		 * */
		public function getAllDresses():Array
		{
			var dresses:Array = [];
			for each(var dressName:String in ObjectUtils.getAllProperties(clothes))
			{
				if(!usedClothes.hasOwnProperty(dressName))
				{
					usedClothes[dressName] = getDefaultClotheItem(dressName)
				}
						
				if(clothes[dressName].hasOwnProperty("count")) {
					
					//load by index
					for(var i:int = 1; i <= Number(clothes[dressName].count); i++)
					{
						dresses.push({name:dressName + i, color:usedClothes[dressName].color});
					}
				} else {
					//load by name
					for(var j:int = 0; j < Number(clothes[dressName].by_names.length); j++) {
						dresses.push({name:clothes[dressName].by_names[j], color:usedClothes[dressName].color, by_name:dressName});
					}
					
				}
			}
			return dresses;
		}
		
		public function getDefaultClotheItem(dressName:String):Object
		{
			if(clothes[dressName].hasOwnProperty("count")) {
				return {id:0, color:clothes[dressName].color};
			} else {
				return {name:"", color:clothes[dressName].color};
			}
		}
		
		/**
		 * return - all used items for current person 
		 * with format Example: ["armleft2", "boots1", "face2"]
		 * */
		public function getActiveDresses():Array
		{
			var dresses:Array = [];
			for each(var dress:String in ObjectUtils.getAllProperties(usedClothes))
			{
					
				if(usedClothes[dress].name != null) {//(if null) seems user do not use any item from this category
					if(usedClothes[dress].name != "")
						dresses.push({name:usedClothes[dress].name, color:usedClothes[dress].color, by_name:dress});
				} else {
					if(usedClothes[dress].id != 0) //(if 0) seems user do not use any item from this category
						dresses.push({name:dress + usedClothes[dress].id, color:usedClothes[dress].color});	
				}
					
			}
			return dresses;
		}
		
		public function success():Boolean
		{
			return _success;
		}
		
	}
}