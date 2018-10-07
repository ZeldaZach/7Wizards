package com.wizards
{
	import com.wizards.controls.MovieButton;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class Gong extends MovieClip
	{
		private var gongStay:McGongStay   = new McGongStay();
		private var gongHover:McGongHover = new McGongHover();
		private var gongFight:McGongFight = new McGongFight();
		private var fightText:String = "Fight!";
		
		private var fightProcess:Boolean = false;
		
		private const GONG_SCALE:Number = 0.4;
		public  static const ON_FIGHT_CLICK:String = "on_fight_click";
		public  static const ON_ANIMATION_DONE:String = "on_animation_done"
		public  var isAnimated:Boolean = false;
		
		public function Gong()
		{
			this.scaleX = this.scaleY = GONG_SCALE;
			addEventListener(MouseEvent.CLICK, onFight);
			addEventListener(MouseEvent.MOUSE_OVER, onOver);
			addEventListener(MouseEvent.MOUSE_OUT, onOut);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			addChildAt(gongStay, 0)
			addChildAt(gongHover, 1)
			addChildAt(gongFight, 2)
			
			gongHover.visible = false;
			gongFight.visible = false;
			
			useHandCursor = true;
			buttonMode = true;
			mouseChildren = false;
			
			gongFight.gotoAndStop(1);
			
		}
		
		private function onFight(e:Event):void {
			this.isAnimated = true;
			
			gongStay.visible  = false;
			gongFight.gotoAndStop(1);
			
			gongHover.visible = false;
			gongHover.gotoAndStop(1);
			
			gongFight.visible = true;
			gongFight.gotoAndPlay(1);
			
			fightProcess = true;
			dispatchEvent(new Event(ON_FIGHT_CLICK));
		}
		
		private function onOver(e:Event):void {
			if(!fightProcess) {
				
				gongStay.visible  = false;
				gongStay.gotoAndStop(1);
				
				gongFight.visible = false;
				gongFight.gotoAndStop(1);
					
				gongHover.visible = true;
				gongHover.gotoAndPlay(1);
			}
		}
		
		private function onOut(e:Event):void {
			if(!fightProcess) {
				
				gongHover.visible = false;
				gongHover.gotoAndStop(1);
				
				gongFight.visible = false;
				gongFight.gotoAndStop(1);
				
				gongStay.visible  = true;
				gongStay.gotoAndPlay(1);
			}
		}
		
		public function reset():void {
			
			fightProcess = false;
			
			gongHover.visible = false;
			gongHover.gotoAndStop(1);
			
			gongFight.visible = false;
			gongFight.gotoAndStop(1);
			
			gongStay.visible  = true;
			gongStay.gotoAndPlay(1);
			
		}
		
		private function onEnterFrame(e:Event):void {
			if (gongFight.currentFrame == gongFight.totalFrames ) {
				
				this.isAnimated = false;
				gongFight.visible = false;
				gongFight.gotoAndStop(1);
				
				dispatchEvent(new Event(ON_ANIMATION_DONE));
				
			}
		}
		
		

	}
}