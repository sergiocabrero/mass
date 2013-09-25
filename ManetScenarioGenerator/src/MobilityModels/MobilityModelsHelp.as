// ActionScript file
package MobilityModels
{
	import mx.controls.Alert;
	
	//Help Popup
	public function MobilityModelsHelp(selectedModelIndex:int):String
	{
		var instructions:String = new String();
		switch (selectedModelIndex)
		{
			case 0:	instructions="In Random Walk Mobility Model each MN moves from its current location to a new location by randomly" +
								 " choosing a direction and speed in which to travel. Each movement in occurs in either a constant time" + 
								 " interval or a constant distance traveled, at the end of which a new direction and speed are calculated.\n\n"+
								 "PARAMETERS:\n"+
								 "- Number: Number of MN to create.\n" + 
								 "- Range: Communication range of each MN, in meters.\n"+
								 "- Speed min and Speed max: Speed limits of the MNs, in meters per second.\n"+
								 "- Movement distance: Distance between parameters change, in meters.\n"+
								 "- Movement duration: Duration between parameters change.\n"+
								 "- Total duration: Total simulation duration.\n\n"+
								 "SELECT AREA: You can define an area inside the scenario in which generate the model." + 
								 "You can draw it from the upper left to lower right corner or define the coordinates in the popup." + 
								 " If you do not define the area, the model will generate along the complete scenario.";
					break;
					
			case 1:	instructions="In Random Waypoint Mobility Model each MN chooses a random destination in the simulation area and " + 
								 "a random speed between [minspeed,maxspeed]. The MN then travels toward the newly chosen destination" + 
								 " at the selected speed. Upon arrival, the MN pauses for a specified time period before starting the " + 
								 "process again.\n\n"+
								 "PARAMETERS:\n"+
								 "- Number: Number of MN to create.\n" + 
								 "- Range:  Range of each MN in meters.\n"+
								 "- Speed min and Speed max: Speed limits of the MNs, in meters per second.\n"+
								 "- Pause duration: Duration between movements.\n"+
								 "- Total duration: Total simulation duration.\n\n"+
								 "SELECT AREA: You can define an area inside the scenario in which generate the model." + 
								 "You can draw it from the upper left to lower right corner or define the coordinates in the popup."+
								 " If you do not define the area, the model will generate along the complete scenario.";
					break;
			case 2:	instructions="In Random Direction Mobility Model each MN chooses a random direction in which to travel similar to " + 
								 "the Random Walk Mobility Model. An MN then travels to the border of the simulation area in that direction." + 
								 " Once the simulation boundary is reached, the MN pauses for a specified time, chooses another direction" + 
								 " and continues the process.\n\n"+
								  "PARAMETERS:\n"+
								 "- Number: Number of MN to create.\n" + 
								 "- Range:  Range of each MN in meters.\n"+
								 "- Speed min and Speed max: Speed limits of the MNs, in meters per second.\n"+
								 "- Pause duration: Pause between movements.\n"+
								 "- Total duration: Total simulation duration.\n\n"+
								 "SELECT AREA: You can define an area inside the scenario in which generate the model." + 
								 "You can draw it from the upper left to lower right corner or define the coordinates in the popup."+
								 " If you do not define the area, the model will generate along the complete scenario.";
					break;
			case 3:	instructions="In Gauss-Markov Mobility Model each MN moves from its current location to a new location calculating " + 
								 "a new direction and speed in which to travel. Each speed and direction are calculated according to a " +
								 "Markov process.\n\n"+
								 "PARAMETERS:\n"+
								 "- Number: Number of MN to create.\n" + 
								 "- Range: Communication range of each MN, in meters.\n"+
								 "- Speed min and Speed max: Speed limits of the MNs, in meters per second.\n"+
								 "- Tuning parameter: Parameter to adjust the degree of randomness (0=Totally Random motion, 1=Linear motion).\n"+
								 "- Movement duration: Duration between parameters change.\n"+
								 "- Total duration: Total simulation duration.\n\n"+
								 "SELECT AREA: You can define an area inside the scenario in which generate the model." + 
								 "You can draw it from the upper left to lower right corner or define the coordinates in the popup." + 
								 " If you do not define the area, the model will generate along the complete scenario.";
					break;
			case 4:	instructions="In the City Section Mobility Model, the simulation area is a street network that represents a " + 
								 "section of a city where the MANET exists. The MNs travel along the streets respecting the speed limits." + 
								 " In this model the streets in the centre of the scenario have low speed limits and that ones near the" + 
								 " simulation boundary are high speed streets.\n\n"+
								 "PARAMETERS:\n"+
								 "- Number: Number of MN to create.\n" + 
								 "- Range: Communication range of each MN, in meters.\n"+
								 "- Low speed: Speed limit of the center area streets.\n"+
								 "- High speed: Speed limit of the external streets.\n"+
								 "- Street widht: separation between streets.\n"+
								 "- Number of H.S.S: Number of high speed steets. From the border to the centre.\n"+
								 "- Total duration: Total simulation duration.\n\n"+
								 "SELECT AREA: You can define an area inside the scenario in which generate the model." + 
								 "You can draw it from the upper left to lower right corner or define the coordinates in the popup." + 
								 " If you do not define the area, the model will generate along the complete scenario.";
					break;
			case 5:	instructions="The Disaster Area Mobility Model represents the movements of the rescue units in a disaster area scenario. " + 
								 "The model is based on an analysis of tactical issues of civil protection. The disaster area and its surrounding " + 
								 "is divided into different areas: Incident Zone, Treatment Zone and Wait Zone.\n\n" + 
								 "PARAMETERS:\n"+
								 "- Firefighters: Number of firefighters deployed in the Incident Area.\n" +
								 "- Transport: First Parameter->Transport units between Incident Zone and Wait Zone." +
								 " Second Parameter->Transport units between Wait Zone and Treatment Zone.\n"+
								 "- Paramedics: Number of paramedic units deployed in the Treatment Zone.\n"+
								 "- Range: Communication range of each MN, in meters.\n"+
								 "- Incident Zone: Area where the disaster happened.\n"+
								 "- Wait Zone: Area where the patients wait.\n"+
								 "- Treatment Zone: Area where the patients are treated.\n"+
								 "- Total duration: Total simulation duration.\n\n"+
								 "ADVANCED PARAMETERS (optional):\n"+
								 "- Foot unit speed: Speed limits of the firefighters and the paramedics (min,max). Default: 1-2m/s.\n"+
								 "- Vehicles speed: Speed limits of the transport units (min,max). Default: 5-12m/s.\n"+
								 "- Pause Time: Pause between movements of the unit.\n\n"+
								 "SELECT AREAS: To define the diferent areas inside the scenario you can draw it from the upper left " + 
								 "to lower right corner or define the coordinates in the popup.\n";
					break;
			case 6:	instructions="The Incident Area Mobility Model represents the movements of the rescue units in a disaster area scenario. " + 
								 "The model focus on what happens between the Incident Area and the Intervention Chief. Firefighters travel"+
								 " in a vehicle to the Incident Zone, work along the area during an intervention time and get back to the "+
								 "wait zone to rest during a rest time.\n\n" + 
								 "PARAMETERS:\n"+
								 "- Number of teams: Number of teams deployed in the area. Each team consist of a vehicle and a constant number of firefighters.\n" +
								 "- Range: Communication range of each MN, in meters.\n"+
								 "- Number of firefighters: Number of firefighters per team.\n"+
								 "- Incident Zone: Area where the disaster happened.\n"+
								 "- Wait Zone: Area where the Intervention Chief is and where the units rest.\n"+
								 "- Total duration: Total simulation duration.\n\n"+
								 "ADVANCED PARAMETERS (optional):\n"+
								 "- Intervention duration: Time limits that an intervention can last (min,max). Default: 10-25min.\n"+
								 "- Rest duration: Time limits that the unit rest can last (min,max). Default: 5-10min.\n"+
								 "- Foot unit speed: Speed limits of the firefighters and the paramedics (min,max). Default: 1-2m/s.\n"+
								 "- Vehicles speed: Speed limits of the transport units (min,max). Default: 5-12m/s.\n"+
								 "- Pause Time: Pause between movements of the unit.\n\n"+
								 "SELECT AREAS: To define the diferent areas inside the scenario you can draw it from the upper left " + 
								 "to lower right corner or define the coordinates in the popup.\n";
					break;
		}
		return instructions;
	}
}