package com.wizards.models.clothes
{
	import com.wizards.controls.HashMap;
	import com.wizards.utils.ObjectUtils;
	import com.wizards.utils.Strings;
	
	public class PersonClothes
	{
		
		public static const CATEGORY_CLOTHES_TO_REPLACE:Array = ["hair", "face"];
		public static const CATEGORY_CLOTHES_ALL_AVAILABLE:Array = ["face", "hair", "top", "middle", "boots", "armleft", "armright", "wings", "fon"];
		public static const FORMAT_ID:String = "{0}_{1}{2}";
		public static const FORMAT_NAME:String = "{0}_{1}";
		
		private var _categories_clothes:HashMap = new HashMap();
		private var _all_clothes:HashMap = new HashMap();
		private var _used_clothes:HashMap = new HashMap();
		private var _used_categories:Array = [];
		private var _skin_name:String;
		
		public function PersonClothes(skin_name:String, used_clothes:Object, all_clothes:Object)
		{
			_skin_name = skin_name;
			
			populate_used(used_clothes);
			populate_all(all_clothes);
		}
		
		public function get all_clothes():HashMap {
			return _all_clothes;
		}
		
		public function get used_clothes():HashMap {
			return _used_clothes;
		}
		
		public function get used_categories():Array {
			return _used_categories;
		}
		
		/**
		 * Clothes count by category
		 **/
		public function get_count(category:String):Number {
			var item:Object = _all_clothes.getItem(category);
			var count:Number = 0; 
			if(item.count > 0) {
				count = item.count;
			} else if(item.list.length > 0) {
				count = item.list.length;
			}
			return count;
		}
		
		public function next_clothe(category:String):String {
			var used_item:Object = _used_clothes.getItem(category);
			var aval_item:Object = _all_clothes.getItem(category);
			
			if(aval_item.count > 0) {
				
				used_item.id = used_item.id + 1;
				if(used_item.id > aval_item.count) {
					//Hair and face can't be empty
					used_item.id = CATEGORY_CLOTHES_TO_REPLACE.indexOf(category) >= 0 ? 1 : 0
				}
				return get_format(used_item, category);
				
			} else {
				var index:Number = aval_item.list.indexOf(used_item.name) + 1;
				if(index >= aval_item.list.length) {
					used_item = CATEGORY_CLOTHES_TO_REPLACE.indexOf(category) >= 0 ? 0 : -1
				}
				return get_format(aval_item.list.getIndex(index), category);
			}
			
		}
		
		public function prev_clothe(category:String):String {
			var item:Object = _used_clothes.getItem(category);
			return null;
		}
		
		public function active_name(category:String):String {
			return get_format(_used_clothes.getItem(category), category);
		}
		
		private function get_format(item:Object, category:String):String {
			if(item == null) return "";
			
			if(!Strings.isBlank(item.name)) {
				return Strings.substitute(FORMAT_NAME, category, item.name);
			} else {
				return Strings.substitute(FORMAT_ID, _skin_name, category, item.id);
			}
		}
		
		private function populate_all(items:Object):HashMap {
			for each(var clothe_name:String in ObjectUtils.getAllProperties(items))
			{
				var _count:Number = items[clothe_name].count || 0;
				var _list:Array = items[clothe_name].list   || [];
				var _color:int = items[clothe_name].color;
				
				_categories_clothes.put(clothe_name, {color:_color, count:_count, list:_list});
				
				if(_count > 0) {
					for(var i:int = 1; i <= _count; i++) {
						_all_clothes.put(clothe_name, {color:_color, name:Strings.substitute(FORMAT_ID, _skin_name, clothe_name, i)});	
					}
				} else if(_list.length > 0) {
					for(var j:int = 0; j < Number(_list.length); j++) {
						var _full_name:String = Strings.substitute(FORMAT_NAME, clothe_name, _list[j]);
						_all_clothes.put(_full_name, {color:_color, name:_full_name});
					}
				}
				
			}
			
			return _all_clothes; 
		}
		
		private function populate_used(items:Object):HashMap {
			for each(var clothe_name:String in ObjectUtils.getAllProperties(items))
			{
				var _id:Number = items[clothe_name].id    || 0;
				var _name:String = items[clothe_name].name || "";
				var _color:int = items[clothe_name].color;
				
				if(Strings.isBlank(_name)) {
					_used_clothes.put(clothe_name, {color:_color, name:Strings.substitute(FORMAT_ID, _skin_name, clothe_name, _id)});	
				} else {
					_used_clothes.put(clothe_name, {color:_color,name:Strings.substitute(FORMAT_NAME, clothe_name, _name)});
				}
				
				_used_categories.push(clothe_name); 
			}
			return _used_clothes; 
		}
		
		public function setColor(_key:String, _color:int):void {
			_used_clothes.getItem(_key).color = _color;
		}
		
		public static function has_part(part:String):Boolean
		{
			return CATEGORY_CLOTHES_TO_REPLACE.indexOf(part.split("_")[0]) != -1;
		}
		
		/**
		 * Check is dress with name exists
		 * */
		public function has_category(name:String):Boolean
		{
			return _used_categories.indexOf(name) >= 0;
		}

	}
}