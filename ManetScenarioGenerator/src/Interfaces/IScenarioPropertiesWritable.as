package Interfaces
{
	import Entities.ScenarioProperties;
	import Entities.GoogleInfo;	//FR
	
	public interface IScenarioPropertiesWritable
	{
		/**
		 * @param newTime:Date, the new initial time of the scenario
		 * @changes the initTime property of the scenario
		 **/ 		
		function set initTime(newTime:Date):void;

		/**
		 * @param newTime:Date, the new end time of the scenario
		 * @changes the endTime property of the scenario
		 **/ 			
		function set endTime(newTime:Date):void;

		/**
		 * @param newWidth:int, the new width of the scenario
		 * @changes the width property of the scenario
		 **/ 			
		function set width(newWidth:int):void;

		/**
		 * @param newHeight:int, the new height of the scenario
		 * @changes the height property of the scenario
		 **/ 			
		function set height(newHeight:int):void;

		/**
		 * @param newDepth:int, the new depth of the scenario
		 * @changes the depth property of the scenario
		 **/ 			
		function set depth(newDepth:int):void;
		
		/**
		 * @param newBackgroundImagePath:String, the new initial time of the scenario
		 * @changes the backgroundImagePath property of the scenario (the path of the background image file)
		 **/ 	 		
		function set backgroundImagePath(newBackgroundImagePath:String):void;
		
		//FR
		/**
		 * @param newGoogleData:GoogleInfo
		 * @changes the googleData of the scenario
		 **/ 			
		function set googleMapsInfo(newGoogleData:GoogleInfo):void;
	}
}