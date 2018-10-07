package com.wizards.models
{
	import com.wizards.Global;
	import com.wizards.utils.URLHelper;
	
	public class PetModelFactory extends DefaultModelsFactory
	{
		public function PetModelFactory(skin:String)
		{
			super(skin);
		}
		
		override protected function addCustomModel(className:String):void
		{
			var clazz:Class = Global.classLoader.getClass(URLHelper.petsModels(_skin), className);
			if(clazz) {
				_customModels[className] = clazz; 
			}
		}

	}
}