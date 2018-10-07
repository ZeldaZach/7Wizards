package com.wizards
{
	import com.wizards.controls.MovieButton;
	import com.wizards.controls.VBox;
	import com.wizards.dto.FightDTO;
	import com.wizards.events.CallbackEvent;
	import com.wizards.gui.AbstractView;
	import com.wizards.loaders.FullLoaderView;
	import com.wizards.models.DefaultModelsFactory;
	import com.wizards.models.DragonModel;
	import com.wizards.models.PersonModel;
	import com.wizards.models.PetModel;
	import com.wizards.services.FightService;
	import com.wizards.services.ProfileService;
	import com.wizards.utils.GraphUtils;
	import com.wizards.utils.Strings;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	public class View extends AbstractView
	{
		public var userModel:PersonModel;
		public var opponentModel:PersonModel;
//		public var dragonModel:DragonModel;
		
		public var userPet:PetModel;
		public var opponentPet:PetModel;
		
		private var gong:Gong = new Gong();
		private var attackeMessage:McBubble = new McBubble();
		private var infoPanel:McInfoPanel = new McInfoPanel();
		
		private var winLoseMovie:MovieClip;
		
		private var _profile:McFight = new McFight();
		
		private var _speed:int = 200;
		
		private const SEPARATOR_MOVE_RIGHT:String = "right"
		private const SEPARATOR_MOVE_LEFT:String = "left"
		private const SEPARATOR_MOVE_STOP:String = "stop"
		
		private const MAX_WIDTH:int = 953;
		private const MAX_HEIGHT:int = 334;
		
		private var separatorMove:String = SEPARATOR_MOVE_STOP;
		private var savedSeparator:Rectangle = new Rectangle();
		private var savedOpponentMask:Rectangle = new Rectangle();
		
		private var fightResult:FightDTO;
		private var isAnimated:Boolean = true;
		
		private var animationManager:AnimationManager;
		
		private var _hasBothPets:Boolean = false;
		
		private var _notifiContainer:VBox = new VBox();
		private var _opponentFightBtn:OpponentFightBtn;
		private var _opponentFriendBtn:OpponentFriendBtn;
		private var _opponentClanBtn:OpponentClanBtn;
		private var _opponentWarBtn:OpponentWarBtn;
		
		public function View()
		{
			super(_profile, Config.RESOURCE_BUNDLE_FIGHT);
			
			GraphUtils.removeAllChilds(content.content.loader);
			
			loader = new FullLoaderView(loaderLayot());
		}
		
		/**
		 * Should be overrided
		 * */
		protected override function initialize():void
		{
			populatePerson();
			initializeButtons();
			
			addEventListener("REFRESH", function(e:Event):void{
				populatePerson();
			});
			
		}
		
		/**
		 * Layer for preloader
		 * */
		public override function loaderLayot():MovieClip
		{
			return content.content.loader;
		} 
		
		private function initializeButtons():void
		{
			
			gong.addEventListener(Gong.ON_FIGHT_CLICK, onFight);
			gong.addEventListener(Gong.ON_ANIMATION_DONE, onFightCallback);
			gong.y = MAX_HEIGHT/2 - 45;
			gong.x = -45; 
			content.content.work_layout.addChild(gong);
			
			infoPanel.x -= infoPanel.width/2;
			infoPanel.y = MAX_HEIGHT - infoPanel.height - 5; 
			content.content.work_layout.addChild(infoPanel);
			
		}
		
		private function resetNotifyPosition():void {
			
			_notifiContainer.x = -50;
			_notifiContainer.y = MAX_HEIGHT - _notifiContainer.height - 25;
			_notifiContainer.draw();			
		}
		
		private function onFight(e:Event):void
		{
			savedSeparator.x = content.content.mcSeparator.x;
			savedSeparator.width = content.content.mcSeparator.width;
			
			savedOpponentMask.x = content.content.mask_opponent.x;
			savedOpponentMask.width = content.content.mask_opponent.width;
			
			if(parameters.is_dragon) {
				new FightService(onFightCallback).fight_dragon({dragon_level:opponentModel.dto.a_level});
			} else {
				new FightService(onFightCallback).fight({id:parameters.user_id, u_md5:userModel.dto.attr_md5, o_md5:opponentModel.dto.attr_md5});
			}
						
			attackeMessage.visible = false;
			infoPanel.visible = false;
			
		}
		
		private function onFightCallback(e:Event):void
		{
			if(e is CallbackEvent) {
				fightResult = ((e as CallbackEvent).dto as FightDTO);
			}
			
			if(fightResult == null || gong.isAnimated) return;
			
			if(fightResult.success()) {
				
				separatorMove = SEPARATOR_MOVE_RIGHT;
				
				animationManager = new AnimationManager(userModel, opponentModel, userPet, opponentPet);
				animationManager.startAnimations();
				
				content.addEventListener(Event.ENTER_FRAME, onEnterFrame);

				animationManager.addEventListener(AnimationManager.ANIMATION_COMPLEATED_USER_PET, onOpponentPetFightStart);
				animationManager.addEventListener(AnimationManager.ANIMATION_COMPLEATED_OPPONENT_PET, onUserFightStart);
				animationManager.addEventListener(AnimationManager.ANIMATION_COMPLEATED_USER, onOpponentFightStart);
				animationManager.addEventListener(AnimationManager.ANIMATION_COMPLEATED_OPPONENT, onOpponentFightStop);
				
				showFightResult();
				
				
			} else {
				try {
	        		attackeMessage.visible = true;
					infoPanel.visible = true;
					gong.reset();
					
					if(fightResult.refresh) {
						setTimeout(function():void{
							populatePerson();
						}, 1000);
					
			       	}
			       
	        		flash.external.ExternalInterface.call("notice_error", fightResult.message());
	    	    } catch(e:Error) {
    	    		trace(e)
        		}
			}
		}
		
		private function onEnterFrame(e:Event):void
		{
			
			if(animationManager) {
				animationManager.dispatchEvent(new Event(Event.ENTER_FRAME));
			}
			
			//show user animation
			//move opponent mask right, need hide
			if(separatorMove == SEPARATOR_MOVE_RIGHT)
			{
				content.content.mcSeparator.x += _speed;
				content.content.mask_opponent.x += _speed;
			}
			
			//Show opponent animation
			//Move opponent mask to left
			if(separatorMove == SEPARATOR_MOVE_LEFT)
			{
				content.content.mcSeparator.x -= _speed;	
				content.content.mask_opponent.x -= _speed;
			}
			
			//stop separator animation
			if(content.content.mcSeparator.x >= MAX_WIDTH + content.content.mcSeparator.width)
			{
				content.content.mcSeparator.x = MAX_WIDTH + content.content.mcSeparator.width;
				content.content.mask_opponent.x = MAX_WIDTH + content.content.mcSeparator.width;
				separatorMove = SEPARATOR_MOVE_STOP;
			} 
			
			if(content.content.mcSeparator.x + content.content.mcSeparator.width + 10 < 0)
			{
				content.content.mcSeparator.x = -content.content.mcSeparator.width;
				content.content.mask_opponent.x = -content.content.mcSeparator.width;
				separatorMove = SEPARATOR_MOVE_STOP;
			}
			
		}
		
		private function onOpponentPetFightStart(e:Event):void {
			content.content.mcSeparator.width *= 2; 
			content.content.mask_opponent.width *= 2;
			content.content.mask_opponent.width += content.content.mcSeparator.width*2;
			
			_speed *= 4;
			separatorMove = SEPARATOR_MOVE_LEFT;
			
		}
		
		private function onUserFightStart(e:Event):void {
			separatorMove = SEPARATOR_MOVE_RIGHT;
		}
		
		private function onOpponentFightStart(e:Event):void {
			separatorMove = SEPARATOR_MOVE_LEFT;
		}
		
		private function onOpponentFightStop(e:Event):void {
			isAnimated = false;
			showFightResult();
		}
		
		private function populatePerson():void
		{
			new ProfileService(onUserDataResult).getClothes();
		}
		
		private function onUserDataResult(e:CallbackEvent):void
		{
			if(parameters.is_dragon) {
				new ProfileService(onDragonDataResult).getClothes({is_dragon:true});
			} else {
				new ProfileService(onOpponentDataResult).getClothes({id:parameters.user_id});
			}
			
			userModel = new PersonModel();
			userModel.setPersonData(e.dto);
			userModel.modelType = DefaultModelsFactory.MOVE_MODEL;
			content.content.user_content.addChild(userModel);
			
			if(userModel.hasPet) {
				userPet = new PetModel(userModel.dto.pet_kind);
				userPet.refresh();
				content.content.user_content.addChild(userPet);
			}
			
			userModel.scaleX = userModel.scaleY = Config.PERSON_SCALE;
			
			//cut very lonh name
			var name:String = userModel.dto.name;
			if(name.length > 13) {
				name = name.substr(0, 13);
			}
			infoPanel.content.mcUserText.text = name + Strings.substitute(" ({0})", userModel.dto.a_level);
			infoPanel.content.mcUserText.addEventListener(MouseEvent.CLICK, onNavigateUserProfile);
			
			MovieButton.decorateField(infoPanel.content.mcUserText, new ArialFont());
		}
		
		private function onDragonDataResult(e:CallbackEvent):void
		{
			opponentModel = new DragonModel();
			opponentModel.addEventListener(PersonModel.PERSON_CREATED, onOpponentCreated); 
			opponentModel.setPersonData(e.dto);
			
			opponentModel.modelType = DefaultModelsFactory.MOVE_MODEL;
			opponentModel.scaleX = opponentModel.scaleY = Config.PERSON_SCALE;
			opponentModel.scaleX *= -1
			
			content.content.opponent_content.addChild(opponentModel);
			
			infoPanel.content.mcOpponentText.text = opponentModel.dto.name + Strings.substitute(" ({0})", opponentModel.dto.a_level) || "";
			
			MovieButton.decorateField(infoPanel.content.mcOpponentText, new ArialFont());
			
		}
		
		private function onOpponentDataResult(e:CallbackEvent):void
		{
			opponentModel = new PersonModel();
			opponentModel.addEventListener(PersonModel.PERSON_CREATED, onOpponentCreated); 
			opponentModel.setPersonData(e.dto);
			
			opponentModel.modelType = DefaultModelsFactory.MOVE_MODEL;
			opponentModel.scaleX = opponentModel.scaleY = Config.PERSON_SCALE;
			opponentModel.scaleX *= -1
			
			content.content.opponent_content.addChild(opponentModel);
			
			_hasBothPets = opponentModel.hasPet && userModel.hasPet;
			 
			//if user has no pet but has antipet , opponent pet is not active
			if(opponentModel.hasPet) {
				opponentPet = new PetModel(opponentModel.dto.pet_kind);
				opponentPet.refresh();
				opponentPet.scaleX *= -1
				opponentPet.visible = false;
				content.content.opponent_content.addChild(opponentPet);
			}
			
			attackeMessage.x = MAX_WIDTH/2;
			attackeMessage.y = 10;
			attackeMessage.mcText.text = parameters.attacker_message || "";
			content.addChild(attackeMessage);
			
			//cut very lonh name
			var name:String = opponentModel.dto.name;
			if(name.length > 13) {
				name = name.substr(0, 13);
			}
			
			infoPanel.content.mcOpponentText.text = name + Strings.substitute(" ({0})", opponentModel.dto.a_level) || "";
			infoPanel.content.mcOpponentText.addEventListener(MouseEvent.CLICK, onNavigateOpponentProfile);
			
			MovieButton.decorateField(infoPanel.content.mcOpponentText, new ArialFont());
			
			content.content.opponent_content.addChild(_notifiContainer);
			
			if(opponentModel.dto.is_clan) {
				_opponentClanBtn = new OpponentClanBtn();
				_opponentClanBtn.useHandCursor = false;
				_notifiContainer.addChild(_opponentClanBtn);
			}
			
			if(opponentModel.dto.is_friend) {
				_opponentFriendBtn = new OpponentFriendBtn();
				_opponentFriendBtn.useHandCursor = false;
				_notifiContainer.addChild(_opponentFriendBtn);
			}
			
			if(opponentModel.dto.is_war) {
				_opponentWarBtn = new OpponentWarBtn();
				_opponentWarBtn.useHandCursor = false;
				_notifiContainer.addChild(_opponentWarBtn);
			}
			resetNotifyPosition();
			
		}
		
		private function onOpponentCreated(e:Event):void
		{
			loader.hide();
			
			if(opponentModel && opponentModel.hasEventListener(PersonModel.PERSON_CREATED)) {
				opponentModel.removeEventListener(PersonModel.PERSON_CREATED, onOpponentCreated);
			}
			
		}
		
		private function onNavigateUserProfile(e:Event):void {
			flash.external.ExternalInterface.call("wizards.navigateToProfile", userModel.dto.user_id);
		}
		
		private function onNavigateOpponentProfile(e:Event):void {
			flash.external.ExternalInterface.call("wizards.navigateToProfile", opponentModel.dto.user_id);
		}
		
		
		private function showFightResult():void
		{
			if(fightResult == null || isAnimated) return;
			
			try {
				
				if(!Strings.isBlank(fightResult.description)) {
					flash.external.ExternalInterface.call("setDescription", fightResult.description);
				}
				
				//Populate html content with fight results
				
	        	flash.external.ExternalInterface.call("fight_result", fightResult.log_id, parameters.is_dragon);
	        	
	        	if(fightResult.user_pet_killed)  userPet = null;
	        	if(fightResult.opponent_pet_killed)  opponentPet = null;
	        	
	        	
    	    } catch(e:Error) {
        		trace(e)
        	}
        	
        	
			if(fightResult.won)
			{
				
				winLoseMovie = new McWin();
				separatorMove = SEPARATOR_MOVE_RIGHT;
				
			} else {
				
				winLoseMovie = new McLoose();
				separatorMove = SEPARATOR_MOVE_LEFT;
			}
			
			winLoseMovie.x = MAX_WIDTH/2 - winLoseMovie.width;
			winLoseMovie.y = MAX_HEIGHT/2 - winLoseMovie.height;
			winLoseMovie.visible = true;
			
			content.addChild(winLoseMovie);
			
			resetModels();
			
			setTimeout(function():void{
				gong.reset();
				resetScreen();
				
			}, 4000);
			
			if(fightResult && fightResult.refresh) {
				setTimeout(function():void{
					populatePerson();
				}, 4000);
			
	       }
		}
		
		private function resetScreen():void
		{
			isAnimated = true;
			fightResult = null;
			_speed = 100;
			
			if(winLoseMovie)
			{
				try {
					content.removeChild(winLoseMovie);
				} catch(e:Error) {
					//ignore
				}
			}
			
			infoPanel.visible = true;
			
			if(opponentPet) {
				opponentPet.visible = false;
			}
			
			if(userPet) {
				userPet.visible = true;
			}
		
			content.content.mcSeparator.x = savedSeparator.x;
			content.content.mcSeparator.width = savedSeparator.width;
			
			content.content.mask_opponent.x = savedOpponentMask.x;
			content.content.mask_opponent.width = savedOpponentMask.width;
			
			content.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			if(animationManager)
			{
				animationManager.removeEventListener(AnimationManager.ANIMATION_COMPLEATED_USER_PET, onOpponentPetFightStart);
				animationManager.removeEventListener(AnimationManager.ANIMATION_COMPLEATED_OPPONENT_PET, onUserFightStart);
				animationManager.removeEventListener(AnimationManager.ANIMATION_COMPLEATED_USER, onOpponentFightStart);
				animationManager.removeEventListener(AnimationManager.ANIMATION_COMPLEATED_OPPONENT, onOpponentFightStop);
			}
				
		}
		
		private function resetModels():void
		{
			
			if(userPet) {
				userPet.modelType = DefaultModelsFactory.MOVE_MODEL;
				userPet.refresh();
			}
			
			if(opponentPet) {
				opponentPet.modelType = DefaultModelsFactory.MOVE_MODEL;
				opponentPet.refresh();
			}
			userModel.visible = true;
			userModel.modelType = DefaultModelsFactory.MOVE_MODEL;
			userModel.refresh();

			opponentModel.visible = true;
			opponentModel.modelType = DefaultModelsFactory.MOVE_MODEL;
			opponentModel.refresh();
			
			if(!_opponentFightBtn) {
				_opponentFightBtn = new OpponentFightBtn();
				_opponentFightBtn.useHandCursor = false;
//				_opponentFightBtn.addEventListener(MouseEvent.CLICK, onNavigateOpponentProfile);
				_notifiContainer.addChild(_opponentFightBtn);
				resetNotifyPosition();
			}
			
		}

	}
}