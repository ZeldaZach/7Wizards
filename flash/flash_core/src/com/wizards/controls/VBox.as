package com.wizards.controls
{
	import flash.display.DisplayObject;
	
	public class VBox extends Box
	{
		/**
         * Constructor
         * @param xpos The x position to place this component.
         * @param ypos The y position to place this component.
         */
        public function VBox(xpos:Number = 0, ypos:Number =  0)
        {
                super(xpos, ypos);
        }

		/**
         * Draws the visual ui of the component, in this case, laying out the sub components.
         */
        public override function draw() : void
        {
                var _width:Number = 0;
                var _height:Number = 0;
                var ypos:Number = 0;
                for(var i:int = 0; i < numChildren; i++)
                {
                    var child:DisplayObject = getChildAt(i);
                    child.y = ypos;
                    ypos += child.height;
                    ypos += _spacing;
                    _height += child.height;
                    
                    width = Math.max(_width,  child.width);
                }
                height = _height + _spacing * (numChildren - 1);
        }
        


	}
}