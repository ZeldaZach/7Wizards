package com.wizards.models
{
	import com.wizards.Global;
	import com.wizards.utils.URLHelper;
	
	import flash.display.MovieClip;
	
	public class DefaultModelsFactory implements IModelsFactory
	{
		protected var _skin:String;
		
		protected var _customModels:Object = {};
		
		public static const MOVE_MODEL:String    = "ModelMove";
		public static const FIGHT_MODEL:String   = "ModelFight";
		public static const FIGHT1_MODEL:String  = "ModelFight1";
		public static const FIGHT2_MODEL:String  = "ModelFight2";
		public static const STATIC_MODEL:String  = "ModelStatic";
		public static const DRESSUP_MODEL:String = "ModelDressUp";
//		public static const WINNER_MODEL:String = "ModelWon";
		
		public function DefaultModelsFactory(skin:String)
		{
			_skin = skin;
			 
			addCustomModel(MOVE_MODEL);
			addCustomModel(FIGHT_MODEL);
			addCustomModel(FIGHT1_MODEL);
			addCustomModel(FIGHT2_MODEL);
			addCustomModel(STATIC_MODEL);
			addCustomModel(DRESSUP_MODEL);
//			addCustomModel(WINNER_MODEL);
		}
		
		protected function addCustomModel(className:String):void
		{
			_customModels[className] = Global.classLoader.getClass(URLHelper.personModels(_skin), className);
		}
		
		public function getModel(modelType:String):MovieClip
		{
			var model:MovieClip;
			var modelClass:Class;
			
			if (modelType in _customModels)
			{
				modelClass = _customModels[modelType];
				model = MovieClip(new modelClass());
			}
			
			return model;
		}

	}
}