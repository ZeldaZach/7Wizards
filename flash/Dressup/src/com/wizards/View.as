package com.wizards
{
	import com.wizards.controls.MovieButton;
	import com.wizards.dto.PersonDTO;
	import com.wizards.events.CallbackEvent;
	import com.wizards.events.DressupEvent;
	import com.wizards.gui.AbstractView;
	import com.wizards.loaders.FullLoaderView;
	import com.wizards.locale.Localization;
	import com.wizards.locale.ResourceBundle;
	import com.wizards.models.DefaultModelsFactory;
	import com.wizards.models.PersonModel;
	import com.wizards.services.ProfileService;
	import com.wizards.utils.DynamicBitmap;
	import com.wizards.utils.GraphUtils;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	
	public class View extends AbstractView
	{
		public var person:PersonModel;
		
		private var _profile:McViewBg = new McViewBg();
		private var _navigatePanel:NavigatePanel;
		
		private var _personDto:PersonDTO;
		private var _cloneDto:PersonDTO;
		private var _dbmp:DynamicBitmap;
		
		private const PREVIEW_SCALE:Number = 0.48;
		private const PREVIEW_WIDTH:Number = 255;
		private const PREVIEW_HEIGHT:Number = 268;
		
		private const UPLOAD_URL:String = "/profile/upload";
		private const DRESSUP_URL:String = "/profile/dressup";
		private var _locale:ResourceBundle;
		
		
		/**
		 * All initialization should be implemented in initialize method
		 * 
		 * */
		public function View()
		{
			super(_profile, Config.RESOURCE_BUNDLE_PROFILE);
			content.dressup_modul.buy_texts.visible = false;
			//clean all invisible movieclips from loader layout if exists
			GraphUtils.removeAllChilds(content.dressup_modul.loader);
			
			loader = new FullLoaderView(loaderLayot());
		}
		
		/**
		 * Layer for preloader
		 * */
		public override function loaderLayot():MovieClip
		{
			return content.dressup_modul.loader;
		}
		
		/**
		 * Should be overrided
		 * */
		protected override function initialize():void
		{
			_locale = Localization.getBundle(Config.RESOURCE_BUNDLE_PROFILE);
			
			populatePerson();
			
			ExternalInterface.addCallback("buyAvatar", populatePerson);
		} 
		
		private function initializeButtons():void
		{
			
			if(_personDto.hasAvatar)
			{
				
				if(content.dressup_modul.mcSave.hasEventListener(MouseEvent.CLICK))
				{
					content.dressup_modul.mcSave.removeEventListener(MouseEvent.CLICK, onBuy);
					content.dressup_modul.mcSave.removeEventListener(MouseEvent.CLICK, onSave);
				}
				
				MovieButton.createLabel(content.dressup_modul.mcSave, _locale.getMessage("save"));
				
				if(!content.dressup_modul.mcSave.hasEventListener(MouseEvent.CLICK))
				{
					content.dressup_modul.mcSave.addEventListener(MouseEvent.CLICK, onSave);
				}
				
				MovieButton.createLabel(content.dressup_modul.mcUndress, _locale.getMessage("undress"));
				
				if(!content.dressup_modul.mcUndress.hasEventListener(MouseEvent.CLICK))
				{
					content.dressup_modul.mcUndress.addEventListener(MouseEvent.CLICK, onClear);
				}
			
				MovieButton.createLabel(content.dressup_modul.mcCancel, _locale.getMessage("cancel"));
				
				if(!content.dressup_modul.mcCancel.hasEventListener(MouseEvent.CLICK))
				{
					content.dressup_modul.mcCancel.addEventListener(MouseEvent.CLICK, onCancel);
				}
				content.dressup_modul.buy_texts.visible = false;
			} else {
				MovieButton.createLabel(content.dressup_modul.mcSave, _locale.getMessage("buy"));
				content.dressup_modul.mcSave.removeEventListener(MouseEvent.CLICK, onSave);
				content.dressup_modul.mcSave.addEventListener(MouseEvent.CLICK, onBuy);
				content.dressup_modul.buy_texts.visible = true;
				content.dressup_modul.buy_texts.mcLevel.text = _personDto.getData().level;
				content.dressup_modul.buy_texts.mcPrice.text = _personDto.getData().price;
				
			}
			
			content.dressup_modul.mcCancel.visible = _personDto.hasAvatar;
			content.dressup_modul.mcUndress.visible = _personDto.hasAvatar;
		}
		
		private function populatePerson(model_name:String = null):void
		{
			if(model_name)
			{
				_personDto.skin = model_name
				new ProfileService(onUserDataResult).getClothes({avatar:model_name});
			} else {
				new ProfileService(onUserDataResult).getClothes();
			}
		}
		
		private function onUserDataResult(e:CallbackEvent):void
		{
			if(e.dto)
			{
				//template dto need for rollback to previous state
				_personDto = new PersonDTO(e.dto.getData());
				
				person = new PersonModel(PersonDTO.CACHE_ALL_DRESSES);
				person.addEventListener(PersonModel.PERSON_CREATED, onPersonCreated);
				person.modelType = DefaultModelsFactory.DRESSUP_MODEL;
				person.setPersonData(e.dto);
				person.scale = Config.PERSON_SCALE;
			
				content.dressup_modul.content_dressup.addChild(person);
			
				initializePanel();
				initializeButtons();
			}
			
		}
		
		private function initializePanel():void
		{
			
			GraphUtils.removeAllChilds(content.dressup_modul.mcControls);
			if(_personDto.hasAvatar)
			{
				_navigatePanel = new NavigatePanel(content, person);
				_navigatePanel.addEventListener(DressupEvent.NEXT_BUTTON_CLICK, onNextDress);
				_navigatePanel.addEventListener(DressupEvent.PREV_BUTTON_CLICK, onPrevDress);
				
				content.dressup_modul.mcControls.addChild(_navigatePanel);
			}
		}
		
		private function onPersonCreated(e:Event):void
		{
			loader.hide();
		}
		
		private function onNextDress(e:DressupEvent):void
		{
			person.nextClothe(e.dressType);
		}
		
		private function onPrevDress(e:DressupEvent):void
		{
			person.prevClothe(e.dressType);
		}
		
		private function onSave(event:Event):void
		{
			
			Global.loaderView.show();
			content.dressup_modul.mcSave.mouseEnabled = false;
//			if(e.dto.success()) {
				
				_personDto = person.dto;
				
				var clonePerson:PersonModel = new PersonModel();
					clonePerson.modelType = DefaultModelsFactory.DRESSUP_MODEL;
					clonePerson.scale = PREVIEW_SCALE;
					
					clonePerson.addEventListener(PersonModel.PERSON_CREATED, function():void {

						clonePerson.width  = PREVIEW_WIDTH;
						clonePerson.height = PREVIEW_HEIGHT;
						_dbmp = new DynamicBitmap(clonePerson, "ava.jpg");
						
						try {
							_dbmp.upload(UPLOAD_URL, "avatar_image");
							_dbmp.addEventListener("onLoadSuccess", onUploadCallback);
							
			            } catch (error:Error) {
			               throw(new SecurityError(error)); 
			            }

					})
					
				clonePerson.setPersonData(_personDto);
//			} 
			
		}
		
		private function onUploadCallback(e:Event):void
		{
			new ProfileService(function():void{
				content.dressup_modul.mcSave.mouseEnabled = true;
			}).save({clothes:person.clothes, avatar:_personDto.skin, body_color:_personDto.body_color});
		}
		
		private function onBuy(event:Event):void
		{
			new ProfileService(onBuyCallback).buy({avatar:_personDto.skin});
		}
		
		
		private function onBuyCallback(e:CallbackEvent):void
		{
			if(e.dto.success()) {
				flash.external.ExternalInterface.call("navigate", DRESSUP_URL);
			} else {
				flash.external.ExternalInterface.call("notice_error", e.dto.message());
			}
		}
		
		private function onClear(event:Event):void
		{
			person.clearDresses();
		}
		
		private function onCancel(event:Event):void
		{
			person.setPersonData(_personDto);
		}
	
		
	}
}