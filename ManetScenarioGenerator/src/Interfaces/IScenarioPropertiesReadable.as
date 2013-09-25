package Interfaces
{
	import Entities.GoogleInfo;
		
	public interface IScenarioPropertiesReadable
	{
		/**
		 * @returns Date, the initTime property of the scenario
		 **/ 		
		function get initTime():Date;

		/**
		 * @returns Date, the endTime property of the scenario
		 **/ 		
		function get endTime():Date;

		/**
		 * @returns int, the width property of the scenario
		 **/ 		
		function get width():int;

		/**
		 * @returns int, the int property of the scenario
		 **/ 		
		function get height():int;

		/**
		 * @returns int, the depth property of the scenario
		 **/ 		
		function get depth():int;

		/**
		 * @returns String, the backgroundImagePath property of the scenario (the path of the background image file)
		 **/ 		
		function get backgroundImagePath():String;
		
		
		//FR
		/**
		 * @returns GoogleInfo
		 **/ 		
		function get googleMapsInfo():GoogleInfo;
														
	}
}