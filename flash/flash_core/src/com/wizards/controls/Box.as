package com.wizards.controls
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	
	public class Box extends Sprite
	{
		protected var _spacing:Number = 5;
		
		/**
         * Constructor
         * @param xpos The x position to place this component.
         * @param ypos The y position to place this component.
         */
        public function Box(xpos:Number = 0, ypos:Number =  0)
        {
                super.x = xpos;
                super.y = ypos;
        }
        
        /**
         * Override of addChild to force layout;
         */
        override public function addChild(child:DisplayObject) : DisplayObject
        {
            super.addChild(child);
            
            child.addEventListener(Event.RESIZE, onResize);
            
            invalidate();
            
            return child;
        }
        
        /**
	     * Internal handler for resize event of any attached component. Will redo the layout based on new size.
	     */
	    protected function onResize(event:Event):void
	    {
	            invalidate();
	    }
	    
	    public function draw() : void
	    {
	    	throw IllegalOperationError("Method draw should override")
	    }
	    
	    /**
         * Gets / sets the spacing between each sub component.
         */
        public function set spacing(s:Number):void
        {
                _spacing = s;
                invalidate();
        }
        
        public function get spacing():Number
        {
                return _spacing;
        }

		protected function invalidate():void
		{
			draw();
		}


	}
}