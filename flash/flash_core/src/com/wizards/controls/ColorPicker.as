package com.wizards.controls
{
	import com.wizards.Global;
	import com.wizards.utils.GraphUtils;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	public class ColorPicker extends EventDispatcher
	{
		public static const picker_metal:String = "picker_metal";
		public static const picker_color:String = "picker_color";
		public static const picker_default:String = picker_color;
			
		public static const CHANGE_COLOR:String = "on_color_change";
		public static const PICKER_REALESE:String = "on_color_reales";
		
		static public const DEFAULT_COLOR:int = 0xFFFFFF;
		
		private var _content:MovieClip;
		private var _color:int = DEFAULT_COLOR;
		
		public function ColorPicker(content:MovieClip)
		{
			_content = content;
			_content.buttonMode = true;
			_content.gamma.colors.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_content.close_button.addEventListener(MouseEvent.CLICK, onClose);
			_content.visible = false;
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			Global.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			Global.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			dispatchColor();
		}
		
		private function onClose(e:MouseEvent):void
		{
			hide();
		}
		
		private function onMouseMove(e:MouseEvent):void
		{
			dispatchColor();
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			Global.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			Global.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			dispatchEvent(new Event(PICKER_REALESE));
		}
		
		private function dispatchColor():void
		{
			_color = GraphUtils.getPixel(_content, _content.mouseX, _content.mouseY);
			dispatchEvent(new Event(CHANGE_COLOR));
		}
		
		public function get color():int
		{
			 return _color;
		}
		
		public function get content():Sprite
		{
			 return _content;
		}
		
		public function show():void
		{
			_content.visible = true;
		}
		
		public function hide():void
		{
			_content.visible = false;
		}
		
	}
}