package com.wizards.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class TaskCounter
	{
		public static var COMPLEATE_TASK:String = "taskCompleate";
		
		private var _numTasks:int = 0;
		private var _completeEvent:EventDispatcher = new EventDispatcher();
		
		public function TaskCounter(numTasks:int = 0)
		{
			_numTasks = numTasks;
		}
		
		public function get isEmpty():Boolean
		{
			return _numTasks == 0;
		}
		
		public function addCount(value:int = 1):void
		{
			_numTasks += value;
		}
		
		public function set numTasks(value:int):void
		{
			 _numTasks = value;
		}
		
		public function completeTask(dummy:Object = null):void
		{
			if (--_numTasks == 0)
			{
				_completeEvent.dispatchEvent(new Event(TaskCounter.COMPLEATE_TASK))
			}
		}
		
		public function get completeEvent():EventDispatcher
		{
			return _completeEvent;
		}

	}
}