package com.wizards.models
{
	import flash.display.MovieClip;
	
	public interface IModelsFactory
	{
		function getModel(modelType : String) : MovieClip;
	}
}