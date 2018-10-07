package com.wizards.controls
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	public class HBox extends Box
	{
                
        /**
         * Constructor
         * @param xpos The x position to place this component.
         * @param ypos The y position to place this component.
         */
        public function HBox(xpos:Number = 0, ypos:Number =  0)
        {
                super(xpos, ypos)
        }
        
        
        /**
         * Draws the visual ui of the component, in this case, laying out the sub components.
         */
        public override function draw() : void
        {
                var _width:Number = 0;
                var _height:Number = 0;
                var xpos:Number = 0;
                for(var i:int = 0; i < numChildren; i++)
                {
                        var child:DisplayObject = getChildAt(i);
                        child.x = xpos;
                        xpos += child.width;
                        xpos += _spacing;
                        _width += child.width;
                        height = Math.max(_height, child.height);
                }
                width = _width + _spacing * (numChildren - 1);
        }
        
	}
}