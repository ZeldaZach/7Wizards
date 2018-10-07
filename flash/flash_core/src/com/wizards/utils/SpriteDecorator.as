package com.wizards.utils
{
	import com.wizards.dto.PersonDTO;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.system.ApplicationDomain;
	
	public class SpriteDecorator
	{
		static public const ASSET_PREFIX:String = 'mc_';
		static public const PART_PREFIX:String = 'ch_';
		static private const COLOR:String = 'mcColor';
		static private const BORDER:String = 'mcBorder';
		static private const DEFAULT_PERCENT:int = 50;
		
		public static function decoratePerson(sprite:Sprite, items:Array, dto:PersonDTO):void
		{
			var parts:Array = GraphUtils.getAllChildren(sprite, new NameRequirement(PART_PREFIX, true));
			var onceCycled:Boolean = false;
			
			
			var domain:ApplicationDomain;
			for each (var item:Object in items)
			{
				domain = item.domain;
				for each (var part:Sprite in parts)
				{
					
					var assetName:String = part.name.substr(PART_PREFIX.length);
					var assetClassName:String = ASSET_PREFIX + assetName.toLowerCase();
								
//					if(assetName != "fon" && !onceCycled) {
//						part.x += dto.position.left;
//						part.y += dto.position.top;
//					}
					
					if (!domain.hasDefinition(assetClassName))
				      continue;
				      
				    var assetClass:Class = Class(domain.getDefinition(assetClassName));
					var asset:Sprite = new assetClass();
					
					//Need to replace part of body
					//Example: "face" or "hair"
					if(PersonDTO.hasPart(assetName))
					{
						setAlpha(part);
					} 
					
					decorateColor(asset, item.color);
					part.addChild(asset);
					
				
				}
				onceCycled = true;
			}
		}
		
		/**
		 * Set default part of body invisible
		 * */
		public static function setAlpha(part:Sprite):void
		{
			var pices:Array = GraphUtils.getAllChildren(part);
			for each(var pice:DisplayObject in pices)
			{
				pice.alpha = 0;
			}
		}
		
		static public function decorateColor(asset:Sprite, color:int):void
		{
			var colorInfo:Object = GraphUtils.toRGB(color);
			var children:Array = GraphUtils.getAllChildren(asset);
			
			for each (var child:DisplayObject in children)
			{
				if (child is Sprite)
				{
					var transform:ColorTransform = null;
					
					if (child.name == COLOR)
					{
						transform = new ColorTransform(
							colorInfo.r/255.0, colorInfo.g/255.0, colorInfo.b/255.0, child.alpha);
					}
					else if (child.name.indexOf(BORDER) == 0)
					{
						var percent:int = parseInt(child.name.substr(BORDER.length));
						if (percent == 0)
							percent = DEFAULT_PERCENT;
						 
						var k:Number = percent / 100.0;
						
						transform = new ColorTransform(0, 0, 0, 1,
							colorInfo.r * k, colorInfo.g * k, colorInfo.b * k, child.alpha);
					}
					
					if (transform)
						child.transform.colorTransform = transform;
				}
			}
		}
	}
}