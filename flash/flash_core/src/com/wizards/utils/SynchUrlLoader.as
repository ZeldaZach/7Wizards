package com.wizards.utils
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	public class SynchUrlLoader extends URLLoader
	{
		private var _timer:Timer;
		private var _tasks:Array = [];
		
		public var isOpen:Boolean = false;
		public var isCompleated:Boolean = false;
		
		public function SynchUrlLoader()
		{
			_timer = new Timer(10);
			_timer.addEventListener(TimerEvent.TIMER, onTick, false, 0, true);
			
			addEventListener(Event.OPEN, onLoaderOpen);
            addEventListener(Event.COMPLETE, onLoaderComplete);
			
		}
		
		public override function load(request:URLRequest):void
		{
        	_tasks.push(request);
        	
			// Start the timer
             if (!_timer.running)
            {
            	isCompleated = false;
	            _timer.start();
            } 
			
		}
		
		private function onTick(e:Event):void
		{
			if(!isOpen && _tasks.length > 0) {
				
				super.load(_tasks.pop());
			}
				
			if(_tasks.length < 1)
			{
				_timer.stop();
				isCompleated = true;
			} 
		}
		
		private function onLoaderOpen(event:Event):void
        {
                // Mark as open
                isOpen = true;
        }

        private function onLoaderComplete(event:Event):void
        {
                // Mark as closed
                isOpen = false;
        }

	}
}