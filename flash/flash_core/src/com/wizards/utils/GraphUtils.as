package com.wizards.utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class GraphUtils
	{
		
		public static function getAllChildren(object:DisplayObjectContainer,
			requirement:NameRequirement = null, recursive:Boolean = true):Array
		{
			var result:Array = [];
			
			for (var i:int = 0; i < object.numChildren; i++)
			{
				var child:DisplayObject;
				try
				{
					child = object.getChildAt(i);
				}
				catch(e : SecurityError)
				{
					//Ok. can be thrown if child is loaded from another domain
				}
				if (child && (requirement == null || requirement.meet(child)))
					result.push(child)
				
				if (recursive && child is DisplayObjectContainer)
					result = result.concat(getAllChildren(DisplayObjectContainer(child), requirement));
					
			}
			
			return result;
		}
		
		public static function toRGB(color:uint):Object
		{
			return { r: color >> 16, g: color >> 8 & 0x0000FF, b: color & 0x0000FF };  
		}
		
		static public function getPixel(item:DisplayObject, x:int, y:int):int
		{
			var bitmapData:BitmapData = new BitmapData(4, 4);
			var matrix:Matrix = new Matrix();
			matrix.tx = -x;
			matrix.ty = -y;
			
			bitmapData.draw(item, matrix,
				item.transform.colorTransform,
				item.blendMode);
			
			return bitmapData.getPixel(1, 1);
		}
		
		static public function removeAllChilds(sprite:Sprite):void
		{
			
			if(sprite == null) return;
			
			while (sprite.numChildren > 0)
			{
				sprite.removeChildAt(0);
			}
		}
		
		public static function duplicateDisplayObject(target:DisplayObject):DisplayObject 
		{

			// create duplicate
	        var targetClass:Class = Object(target).constructor;
	        var duplicate:DisplayObject = new targetClass();

	        // duplicate properties
	        duplicate.transform = target.transform;
	        duplicate.filters = target.filters;
	        duplicate.cacheAsBitmap = target.cacheAsBitmap;
	        duplicate.opaqueBackground = target.opaqueBackground;
	        if (target.scale9Grid) {
	            var rect:Rectangle = target.scale9Grid;
	            // Flash 9 bug where returned scale9Grid is 20x larger than assigned
	            rect.x /= 20, rect.y /= 20, rect.width /= 20, rect.height /= 20;
	            duplicate.scale9Grid = rect;
	        }

	        return duplicate;
    	}

	}
}