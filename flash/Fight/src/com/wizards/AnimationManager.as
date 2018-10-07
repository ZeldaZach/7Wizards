package com.wizards
{
	import com.wizards.models.DefaultModelsFactory;
	import com.wizards.models.PersonModel;
	import com.wizards.models.PetModel;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class AnimationManager extends EventDispatcher
	{
		private const ANIMATION_USER:Number = 1;
		private const ANIMATION_OPPONENT:Number = 2;
		private const ANIMATION_USER_PET:Number = 3;
		private const ANIMATION_OPPONENT_PET:Number = 4;
		
		public static const ANIMATION_COMPLEATED_USER:String = "animation_compleated_user"
		public static const ANIMATION_COMPLEATED_OPPONENT:String = "animation_compleated_opponent"
		public static const ANIMATION_COMPLEATED_USER_PET:String = "animation_compleated_user_pet"
		public static const ANIMATION_COMPLEATED_OPPONENT_PET:String = "animation_compleated_oppoent_pet"
		
		private var _userModel:PersonModel;
		private var _opponentModel:PersonModel;
		private var _userPet:PetModel;
		private var _opponentPet:PetModel;
		
		private var _nextAnimation:Number = 0;
		private var _hasBothPets:Boolean = false;
		
		public function AnimationManager(userModel:PersonModel, opponentModel:PersonModel, userPet:PetModel, opponentPet:PetModel)
		{
			_userModel 		= userModel;
			_opponentModel	= opponentModel;
			
			_hasBothPets    = userModel.hasPet && opponentModel.hasPet;
			 
			if((opponentModel.hasPet && !userModel.dto.antipet && !userModel.hasPet) || _hasBothPets) {
				_opponentPet	= opponentPet;
			}
			
			if((userModel.hasPet && !opponentModel.dto.antipet && !opponentModel.hasPet) || _hasBothPets) {
				_userPet		= userPet;
			}
			
			if(opponentPet) {
				opponentPet.visible = false;
			}
			
			if(userPet) {
				userPet.visible = false;
			}
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);		
		}
		
		public function startAnimations():void 
		{
			changePersonAnimation(_userPet, DefaultModelsFactory.FIGHT_MODEL);
			
			
			_userModel.visible = false;
			_opponentModel.visible = false;
	
			
			_nextAnimation = ANIMATION_USER_PET;
		}
		
		private function onEnterFrame(e:Event):void {
			
			
			//STOP USER PET ANIMATION
			//START OPPONENT PET ANIMATION
			if(_nextAnimation == ANIMATION_USER_PET && (_userPet == null || _userPet.currentFrame == _userPet.totalFrames - 2)) {
				_nextAnimation = ANIMATION_OPPONENT_PET

				if(_userPet) {
					PersonModel.stopAll(_userPet.content);
					_userPet.visible = false;
				}
				
				if(_opponentPet) {
					changePersonAnimation(_opponentPet, DefaultModelsFactory.FIGHT1_MODEL);
				}
				
				dispatchEvent(new Event(ANIMATION_COMPLEATED_USER_PET));
			} 
			
			//STOP OPPONENT PET ANIMATION
			if(_nextAnimation == ANIMATION_OPPONENT_PET && (_opponentPet == null || _opponentPet.currentFrame == _opponentPet.totalFrames - 2)) {
				_nextAnimation = ANIMATION_USER
			
				if(_opponentPet) {
					PersonModel.stopAll(_opponentPet.content);
					_opponentPet.visible = false;
				}
				
				if(_userModel) {
					changePersonAnimation(_userModel, DefaultModelsFactory.FIGHT_MODEL);
				}
				
				if(_userPet) {
					_userPet.visible = false;
				}
				
				dispatchEvent(new Event(ANIMATION_COMPLEATED_OPPONENT_PET));
				
			}
			
			//STOP USER ANIMATION
			//START OPPONENT ANIMATION
			if(_nextAnimation == ANIMATION_USER && _userModel.currentFrame == _userModel.totalFrames - 2) {
				_nextAnimation = ANIMATION_OPPONENT
				
				PersonModel.stopAll(_userModel.content);
				_userModel.visible = false;
				
				var animation_kind:String = DefaultModelsFactory.FIGHT1_MODEL;
				
				if(Math.random() > 0.5) {
					animation_kind = DefaultModelsFactory.FIGHT2_MODEL;
				}
				
				changePersonAnimation(_opponentModel, animation_kind);
				
				if(_opponentPet) {
					_opponentPet.visible = false;
				}
				
				
				dispatchEvent(new Event(ANIMATION_COMPLEATED_USER));
			}
			
			//STOP OPPONENT ANIMATION
			//START USER PET ANIMATION
			if(_nextAnimation == ANIMATION_OPPONENT && _opponentModel.currentFrame == _opponentModel.totalFrames - 2) {
				_nextAnimation = ANIMATION_USER_PET
				
				PersonModel.stopAll(_opponentModel.content);
				_opponentModel.visible = false;

				dispatchEvent(new Event(ANIMATION_COMPLEATED_OPPONENT));
				
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		
		public static function changePersonAnimation(model:*, type:String):void
		{
			if(model) {
				PersonModel.stopAll(model.content);
				model.modelType = type;
				model.refresh();
				model.visible = true;
				PersonModel.playAll(model.content);
			}
		}

	}
}