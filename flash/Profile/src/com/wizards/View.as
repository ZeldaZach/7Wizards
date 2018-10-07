package com.wizards
{
	import com.wizards.events.CallbackEvent;
	import com.wizards.gui.AbstractView;
	import com.wizards.loaders.FullLoaderView;
	import com.wizards.models.DefaultModelsFactory;
	import com.wizards.models.PersonModel;
	import com.wizards.services.ProfileService;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class View extends AbstractView
	{
		private var _person:PersonModel;
		private var _profile:McProfile = new McProfile();
		
		public function View()
		{
			super(_profile)
			loader = new FullLoaderView(loaderLayot());
		}
		
		/**
		 * Layer for preloader
		 * */
		public override function loaderLayot():MovieClip
		{
			return content.loader;
		} 
		
		public override function created():void
		{
			populatePerson();
		}
		
		private function populatePerson():void
		{
			
			new ProfileService(onUserDataResult).getClothes({id:parameters.user_id});
		}
		
		private function onUserDataResult(e:CallbackEvent):void
		{
			if(e.dto)
			{
				_person = new PersonModel();
				_person.addEventListener(PersonModel.PERSON_CREATED, hideLoader); 
				_person.modelType = DefaultModelsFactory.DRESSUP_MODEL;
				_person.setPersonData(e.dto);
//				_person.position.left = 50;
//				_person.position.top = 5;
				
				content.content_dressup.addChild(_person);
			
			}
			
		}
		
		private function hideLoader(e:Event):void
		{
			loader.hide();
		}

	}
}