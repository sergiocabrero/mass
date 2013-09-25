package Classes
{
	import Entities.GoogleInfo;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.controls.Alert; //FR
	
	public class TXTScenarioParser
	{
		public function TXTScenarioParser()
		{
		}
		
		//Parsea un txt de un escenario. Se le pasan el objeto file del txt, y la referencia a la instancia manetNodesTable del singleton Y FALTAN
		//LAS PROPIEDADES DEL ESCENARIO EN EL SINGLETON
		public static function parseTXTScenario(scenarioFile:File, manetNodesTable:CallableManetNodesTableProxy, scenarioProperties:CallableScenarioPropertiesProxy):Boolean
		{
			try
			{
				var scenarioFileStream:FileStream = new FileStream();
				//var scenarioXMLObject:XML;
				
				scenarioFileStream.open(scenarioFile, FileMode.READ);
				//scenarioXMLObject = new XML(scenarioFileStream.readMultiByte(scenarioFile.size, File.systemCharset));
				var scenarioTXTObject:String = new String(scenarioFileStream.readMultiByte(scenarioFile.size, File.systemCharset));
				
				var pathArray:Array = scenarioFile.nativePath.split("\\");
				var directoryPath:String = "";
				for (var i:int = 0; i<pathArray.length-1; i++)
				{
					if (i == 0)
					{
						directoryPath = pathArray[i];	
					} 
					else
					{
						directoryPath = directoryPath + "\\" + pathArray[i];
					}
				}
				
				return parseTXTFieldsToScenario(scenarioTXTObject, manetNodesTable, scenarioProperties, directoryPath);
			}
			catch(thrownError:Error)
			{
				return false;
			}
			return true;	
		}
		
		
		public static function parseTXTFieldsToScenario(TXTScenario:String, manetNodesTable:CallableManetNodesTableProxy, scenarioProperties:CallableScenarioPropertiesProxy, directoryPath:String = ""):Boolean
		{
			try
			{
				try
				{			
					manetNodesTable.clearAll();
				}
				catch(err:Error)
				{
					Alert.show("Error clearing manet nodes table", DisplayPropertiesSingleton.APPLICATION_TITLE);
					return false;
				}
				//Se llama al singleton para bloquear el despacho de eventos del modelo (tabla y nodos)
				ModelSingleton.getSingletonInstance().lockDispatchTracesModelEvents(true);
				
				try
				{	
					
					//TXTScenario = TXTScenario.substr(3,TXTScenario.length); // Un 3 porque los 3 primeros caracteres me sobran
					var correctFile:Boolean = false;
					var lines:Array = TXTScenario.split("\r\n");
					for (var j:Number = 0; j < lines.length; j++)
						lines[j] = lines[j].concat("000");
					
						
					scenarioProperties.tracesData = lines;
					
					var highestLatitude:Number = -90;
					var highestLongitude:Number = -180;
					var lowestLatitude:Number = 90;
					var lowestLongitude:Number = 180;
					var lowestTimestamp:Date;
					var highestTimestamp:Date;
					
					var line:String;
					var lineInfo:Array;
					var nodeName:String;
					var nodeLongitude:Number;
					var nodeLatitude:Number;
					var nodeTimestamp:Date;
					
					for (var i:Number = 0; i < lines.length; i++){
						
						line = new String (lines[i]);
						lineInfo = line.split("\t");
						
						if (lineInfo.length == 4){
							//var nodeName:String = lineInfo[0];
							nodeLongitude = lineInfo[1];
							nodeLatitude = lineInfo[2];
							nodeTimestamp = new Date(-1);
							nodeTimestamp = new Date(1000*parseInt(lineInfo[3])); //OJO con el 10000
							
							if ((nodeLongitude>-180)&&(nodeLongitude<180)&&(nodeLatitude>-90)&&(nodeLatitude<90)
								&&(nodeTimestamp.time > -1))
								correctFile = true;
							else
								continue;
								
							if (i == 0){
								
								highestTimestamp = nodeTimestamp;
								lowestTimestamp = nodeTimestamp;
								
							}
							else{
								
								if (nodeTimestamp.time > highestTimestamp.time)
									highestTimestamp = nodeTimestamp;
								if (nodeTimestamp.time < lowestTimestamp.time)
									lowestTimestamp = nodeTimestamp;
								
							}
							
							if (nodeLongitude > highestLongitude)
								highestLongitude = nodeLongitude;
							if (nodeLongitude < lowestLongitude)
								lowestLongitude = nodeLongitude;
							if (nodeLatitude > highestLatitude)
								highestLatitude = nodeLatitude;
							if (nodeLatitude < lowestLatitude)
								lowestLatitude = nodeLatitude;
							
						}
					}
					
					if (correctFile==true){
						scenarioProperties.width = 1000;
						scenarioProperties.height = 572;
						scenarioProperties.depth = 0;
						scenarioProperties.initTime = lowestTimestamp;	
						scenarioProperties.backgroundImagePath = directoryPath + "\\" + "";
						var googleData:GoogleInfo = new GoogleInfo("Normal","Coordinates",
													10,highestLatitude,lowestLongitude,"",true);
						scenarioProperties.googleMapsInfo = googleData;
					}
					else{
						scenarioProperties.tracesData = null;
						Alert.show("Error in the scenario properties", DisplayPropertiesSingleton.APPLICATION_TITLE);
						return false;
					}
						
				}
				catch(err:Error)
				{
					Alert.show("Error in the scenario properties", DisplayPropertiesSingleton.APPLICATION_TITLE);
					return false;
				}
				
				//Se llama al singleton para desbloquear el despacho de eventos del modelo
				ModelSingleton.getSingletonInstance().lockDispatchTracesModelEvents(false);
				
			}//end try
			catch(thrownError:Error)
			{
				Alert.show("Error parsing the txt scenario", DisplayPropertiesSingleton.APPLICATION_TITLE);
				return false;
			}
			return true;
		}//end function

	}
}