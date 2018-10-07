package com.wizards.loaders
{
	import flash.display.MovieClip;
	
	public interface ILoaderView
	{
		function get content():MovieClip;
		function set y(v:Number):void;
		function set x(v:Number):void;
		function show():void
		function hide():void;
	}
}