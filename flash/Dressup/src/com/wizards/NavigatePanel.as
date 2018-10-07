package com.wizards
{
	import com.wizards.controls.ColorPicker;
	import com.wizards.controls.ExtendedButton;
	import com.wizards.controls.VBox;
	import com.wizards.events.DressupEvent;
	import com.wizards.locale.Localization;
	import com.wizards.locale.ResourceBundle;
	import com.wizards.models.PersonModel;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class NavigatePanel extends VBox
	{
		
		private var picker_body:ColorPicker;
		private var picker_color:ColorPicker;
		private var picker_metal:ColorPicker;
		private var activePicker:ColorPicker;
		private var _colorBtnType:String;
		private var _bodyColorSelect:mcBody2;
		private var _parent:Sprite;
		private var _person:PersonModel;
		private var format:TextFormat = new TextFormat();
		
		private const leftPosition:Number = 400;
		private var _locale:ResourceBundle;
		
		
		public function NavigatePanel(parent:Sprite, person:PersonModel)
		{
			super
			_locale = Localization.getBundle(Config.RESOURCE_BUNDLE_PROFILE);
			_parent = parent;
			_person = person; 
			spacing = 4;
			initialize();
		}
		
		private function initialize():void
		{
			picker_body = new ColorPicker(new PickerBody());
			picker_body.addEventListener(ColorPicker.CHANGE_COLOR, onBodyColorSelect);
			picker_body.addEventListener(ColorPicker.PICKER_REALESE, onPickerHide);
			_parent.addChild(picker_body.content);
			
			picker_color = new ColorPicker(new PickerFull());
			picker_color.addEventListener(ColorPicker.CHANGE_COLOR, onColorSelect);
			picker_color.addEventListener(ColorPicker.PICKER_REALESE, onPickerHide);
			_parent.addChild(picker_color.content);
			
			picker_metal = new ColorPicker(new PickerEquipment());
			picker_metal.addEventListener(ColorPicker.CHANGE_COLOR, onColorSelect);
			picker_metal.addEventListener(ColorPicker.PICKER_REALESE, onPickerHide);
			_parent.addChild(picker_metal.content);
			
			_bodyColorSelect = new mcBody2();
			_bodyColorSelect.addEventListener(MouseEvent.CLICK, onBodyPickerShow);
			
			decorateFont(_bodyColorSelect.mcText, _locale.getMessage("body"));
			
			addChild(_bodyColorSelect);
			
			for each(var item:String in Config.AVAILABLE_PERSON_ITEMS)
			{
				var clothe:Object = _person.available_clothes[item];
				if(clothe)
				{
					addChild(createButtonsGroup(item, _locale.getMessage(item)));
				}
			}
			
		}
		
		private function createButtonsGroup(itemName:String, text:String):DisplayObject
		{
			
			var controls:McControlsButtons = new McControlsButtons();
			
			decorateFont(controls.mcCenter.mcText, text);
			
			var extendedLeft:ExtendedButton = new ExtendedButton(controls.mcLeftButton, itemName);
			extendedLeft.addEventListener(MouseEvent.CLICK, onLeftClick);
			
			var extendedRight:ExtendedButton = new ExtendedButton(controls.mcRightButton, itemName);
			extendedRight.addEventListener(MouseEvent.CLICK, onRightClick);
			
			var extendedColor:ExtendedButton = new ExtendedButton(controls.mcColorButton, itemName);
			extendedColor.addEventListener(MouseEvent.CLICK, onPickerShow);
			
			return controls;
		}
		
		private function decorateFont(field:TextField, text:String):void
		{
			var font:ArialFont = new ArialFont();
			format.font = font.fontName;
			format.size = 17
			
			field.text = text;
			field.autoSize = TextFieldAutoSize.LEFT;
			field.defaultTextFormat = format;
			field.embedFonts = true;
			field.selectable = false;
		}
		
		private function onLeftClick(event:Event):void
		{
			dispatchEvent(new DressupEvent(DressupEvent.PREV_BUTTON_CLICK, event.target.actionName));
		}
		
		private function onRightClick(event:Event):void
		{
			dispatchEvent(new DressupEvent(DressupEvent.NEXT_BUTTON_CLICK, event.target.actionName));
		}
		
		private function onColorSelect(event:Event):void
		{
			_person.setColor(_colorBtnType, activePicker.color)
		}
		
		private function onBodyColorSelect(event:Event):void
		{
			_person.setBodyColor(activePicker.color)
		}
		
		private function onPickerShow(event:Event):void
		{
			if(activePicker)
			{
				activePicker.hide();	
			}
			_colorBtnType = event.target.actionName;
			
			activePicker = Config.METAL_PICKER_CATEGORIES.indexOf(_colorBtnType) >= 0 ? picker_metal : picker_color;
			activePicker.content.y = activePicker.content.height/2;
			activePicker.content.x = leftPosition; 
			activePicker.show();
		}
		
		private function onPickerHide(event:Event):void
		{
			activePicker.hide();
		}
		
		private function onBodyPickerShow(event:Event):void
		{
			if(activePicker)
			{
				activePicker.hide();	
			}
			activePicker = picker_body;
			activePicker.content.y = activePicker.content.height/2;
			activePicker.content.x = leftPosition; 
			activePicker.show();
		}
		

	}
}