package Classes
{
	import Entities.GoogleInfo;
	import Entities.ManetNode;
	import Entities.Movement;
	import Entities.NodeState;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.controls.Alert; //FR
	
	public class XMLScenarioParser
	{		
		public function XMLScenarioParser()
		{
		}
		
		//Parsea un xml de un escenario. Se le pasan el objeto file del xml, y la referencia a la instancia manetNodesTable del singleton Y FALTAN
		//LAS PROPIEDADES DEL ESCENARIO EN EL SINGLETON
		public static function parseXMLScenario(scenarioFile:File, manetNodesTable:CallableManetNodesTableProxy, scenarioProperties:CallableScenarioPropertiesProxy):Boolean
		{
			try
			{
				var scenarioFileStream:FileStream = new FileStream();
				var scenarioXMLObject:XML;
				
				scenarioFileStream.open(scenarioFile, FileMode.READ);
				scenarioXMLObject = new XML(scenarioFileStream.readMultiByte(scenarioFile.size, File.systemCharset));

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
				
				return parseXMLFieldsToScenario(scenarioXMLObject, manetNodesTable, scenarioProperties, directoryPath);
			}
			catch(thrownError:Error)
			{
				return false;
			}
			return true;	
		}
		
		//Genera un xml de un escenario. Se le pasan la referencia a la instancia manetNodesTable del singleton y las propiedades del escenario
		public static function saveXMLScenario(fileTarget:File, manetNodesTable:CallableManetNodesTableProxy, scenarioProperties:CallableScenarioPropertiesProxy):Boolean
		{
			try
			{	
				if (manetNodesTable == null || scenarioProperties == null)
				{
					Alert.show("Table of nodes or scenario properties not found", DisplayPropertiesSingleton.APPLICATION_TITLE);
					return false;
				}
								
				try
				{
					ModelSingleton.getSingletonInstance().lockDispatchModelEvents(true); //FR
					
					var XMLScenario:XML = <scenario></scenario>;
					XMLScenario.@t = scenarioProperties.initTime.toLocaleString();
					XMLScenario.@X = scenarioProperties.width;
					XMLScenario.@Y = scenarioProperties.height;
					XMLScenario.@Z = scenarioProperties.depth;
					
					//FR
					//var tempArray:Array = scenarioProperties.backgroundImagePath.split("\\");
					//XMLScenario.@background = tempArray[tempArray.length-1];
					if (scenarioProperties.backgroundImagePath ==null)
						XMLScenario.@background = "";
					else{
						var tempArray:Array = scenarioProperties.backgroundImagePath.split("\\");
						XMLScenario.@background = tempArray[tempArray.length-1];
					}
										
					ModelSingleton.getSingletonInstance().lockDispatchSaveEvent(false);
					if ((scenarioProperties.googleMapsInfo != null)&&(scenarioProperties.googleMapsInfo._visible == true)
						&&(scenarioProperties.connectedToInternet)){
						XMLScenario.@X = "";
						XMLScenario.@Y = "";
						XMLScenario.@Z = "";
						var lati:Number = scenarioProperties.googleMapsInfo._latitude;
						var lngi:Number = scenarioProperties.googleMapsInfo._longitude;
						var k:Number = Math.pow(10, 6);
		   				lati = Math.round(lati*k)/k;
						lngi = Math.round(lngi*k)/k;
						XMLScenario.@latitude = lati;
						XMLScenario.@longitude = lngi;
						XMLScenario.@maptype = scenarioProperties.googleMapsInfo._mapType;
						XMLScenario.@mapenabled = scenarioProperties.googleMapsInfo._visible;
					}
					//FR
					
				}
				catch(err:Error)
				{
					Alert.show("Error in scenario properties", DisplayPropertiesSingleton.APPLICATION_TITLE);
					return false;					
				}
				
				var arrayIdNodes:Array = manetNodesTable.getIdManetNodesArray(); 
				for (var i:int = 0; i < arrayIdNodes.length; i++) 
				{
					//Se comprueban tiempos y si hay que intercalar un cambio de estado (switchOn, switchOff) o movimiento
					var XMLManetNode:XML = <node></node>;
					XMLManetNode.@id = manetNodesTable.getManetNode(arrayIdNodes[i]).id;
					XMLManetNode.@range = manetNodesTable.getManetNode(arrayIdNodes[i]).range;
					XMLManetNode.@pattern = manetNodesTable.getManetNode(arrayIdNodes[i]).pattern;
					
					var tempMovement:Movement = manetNodesTable.getManetNodeFirstMovement(arrayIdNodes[i]);
					var tempNodeState:NodeState = manetNodesTable.getManetNodeFirstState(arrayIdNodes[i]);

					while (tempMovement != null || tempNodeState != null)
					{									
						//si es el instante de un cambio de estado
						if (tempMovement == null || ( tempNodeState != null && (tempNodeState.timestamp.time <= tempMovement.fromTimestampPositionCheckpoint.pointTime.time)))
						{
							if (tempNodeState.switchedOn)
							{
								var XMLSwitchOn:XML = <switchOn></switchOn>;
								XMLSwitchOn.@t = (tempNodeState.timestamp.time - scenarioProperties.initTime.time).toString();
								XMLSwitchOn.@x = tempNodeState.xCoordinate.toString();
								XMLSwitchOn.@y = tempNodeState.yCoordinate.toString();
								//XMLSwitchOn.@z = tempNodeState.zCoordinate.toString();
								XMLSwitchOn.@z = 0; //FR
																				
								XMLManetNode.appendChild(XMLSwitchOn);
							}
							else
							{
								var XMLSwitchOff:XML = <switchOff></switchOff>;
								XMLSwitchOff.@t = (tempNodeState.timestamp.time - scenarioProperties.initTime.time).toString();								
								XMLManetNode.appendChild(XMLSwitchOff);
							}

							tempNodeState = manetNodesTable.getManetNodeNextState(arrayIdNodes[i], tempNodeState.id);								
											
						}
						//si es el instante de un movimiento nulo (inicio y fin en las mismas coordenadas y mismo instante) se ignora
						else if (!tempMovement.isNullMovement())
						//else
						{
							var XMLMovement:XML = <moveTo></moveTo>;
							XMLMovement.@path = "line";
							XMLMovement.@start = (tempMovement.fromTimestampPositionCheckpoint.pointTime.time - scenarioProperties.initTime.time).toString();
							XMLMovement.@end = (tempMovement.toTimestampPositionCheckpoint.pointTime.time - scenarioProperties.initTime.time).toString();
							XMLMovement.@x = (tempMovement.toTimestampPositionCheckpoint.xCoordinate).toString();
							XMLMovement.@y = (tempMovement.toTimestampPositionCheckpoint.yCoordinate).toString();
							XMLMovement.@z = 0;
							XMLMovement.@acceleration = "";
							XMLManetNode.appendChild(XMLMovement);
							
							tempMovement = manetNodesTable.getManetNodeNextMovement(arrayIdNodes[i], tempMovement.id);								
																		
						}	
						else
						{
							tempMovement = manetNodesTable.getManetNodeNextMovement(arrayIdNodes[i], tempMovement.id);
						}
					}//end while
					
					//Se escribe la informacion del nodo
					XMLScenario.appendChild(XMLManetNode);
									
				}//end for
					
				if ((scenarioProperties.googleMapsInfo != null)&&(scenarioProperties.googleMapsInfo._visible == true)){//FR
					
					ModelSingleton.getSingletonInstance().lockDispatchMapAfterSavingEvent(false);		//FR
				
				} // FR
				
				//Se escribe el archivo
			    var strToWrite:String = "<?xml version=\"1.0\"?>" + XMLScenario.toString();

			    var stream:FileStream = new FileStream();
			    stream.open(fileTarget, FileMode.WRITE);
			    stream.writeUTFBytes(strToWrite);
			    stream.close();

							
			}//end try
			catch(thrownError:Error)
			{
				Alert.show("Error while saving scenario xml", DisplayPropertiesSingleton.APPLICATION_TITLE);
				return false;
			}
			return true;
		}
		
		public static function parseXMLFieldsToScenario(XMLScenario:XML, manetNodesTable:CallableManetNodesTableProxy, scenarioProperties:CallableScenarioPropertiesProxy, directoryPath:String = ""):Boolean
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
				ModelSingleton.getSingletonInstance().lockDispatchModelEvents(true);
				
				try
				{	
						
					if (XMLScenario.@X == undefined || XMLScenario.@Y == undefined || XMLScenario.@t == undefined)
					{
						throw(new Error("ERROR"));
					}
					
					/*
					if ( !(Date.parse(XMLScenario.@t.toString()) is Number) || 
						!(Number(XMLScenario.@X) is Number) ||
						!(Number(XMLScenario.@Y) is Number) )
					{
						throw(new Error("ERROR"));
					}
					*/
					
					if (isNaN(Date.parse(XMLScenario.@t.toString())) ||
						isNaN(Number(XMLScenario.@X)) ||
						isNaN(Number(XMLScenario.@Y)) )
					{
						throw(new Error("ERROR"));
					}
					var tempEndTime:Date = new Date(XMLScenario.@t.toString());
							
					scenarioProperties.width = Math.ceil(parseInt(XMLScenario.@X, 10));
					scenarioProperties.height = Math.ceil(parseInt(XMLScenario.@Y, 10));
					scenarioProperties.depth = Math.ceil(parseInt(XMLScenario.@Z, 10));
					scenarioProperties.initTime = new Date(XMLScenario.@t.toString());	
					
					//FR
					//scenarioProperties.backgroundImagePath = directoryPath + "\\" + XMLScenario.@background;
					if (XMLScenario.@background != "")
						scenarioProperties.backgroundImagePath = directoryPath + "\\" + XMLScenario.@background;
					
					var lat:Number = Number(XMLScenario.@latitude);
					var lon:Number = Number(XMLScenario.@longitude);
					var maptype:String = String(XMLScenario.@maptype);
					var enabled:String = String(XMLScenario.@mapenabled);
					var googledata:GoogleInfo;
					if (enabled=="true"){
						if (ModelSingleton.getSingletonInstance().scenarioPropertiesCallableProxy.connectedToInternet){
							scenarioProperties.width = 1000;
							scenarioProperties.height = 572;
							googledata = new GoogleInfo(maptype,"Coordinates",10,lat,lon,"",true);
						}
						else{
							scenarioProperties.width = 400;
							scenarioProperties.height = 300;
							googledata = new GoogleInfo(maptype,"Coordinates",10,-1000,-1000,"",true);
						}
					}
					else
						googledata = new GoogleInfo(maptype,"Coordinates",10,lat,lon,"",false);					
					scenarioProperties.googleMapsInfo = googledata;
					//FR
					//var tempEndTime:Date = new Date(XMLScenario.@t.toString());	
				}
				catch(err:Error)
				{
					Alert.show("Error in the scenario properties", DisplayPropertiesSingleton.APPLICATION_TITLE);
					return false;
				}
				//se recorren todos los nodos que aparecen en el xml del escenario
				var southern:Number = -1;//FR
				var eastern:Number = -1;//FR
				var range:Number = 0; //FR
				
				if ( ((enabled)&&(ModelSingleton.getSingletonInstance().scenarioPropertiesCallableProxy.connectedToInternet))||
					(!enabled) ){
						
					for each(var nodeElement:XML in XMLScenario.elements())
					{
						
						range = nodeElement.@range; //FR				
						//Cada elemento es un nodo, con todos sus movimientos y estados
						var newManetNode:ManetNode = new ManetNode("", nodeElement.@range, "", 0, nodeElement.@pattern, nodeElement.@id);
						if (manetNodesTable.getManetNode(nodeElement.@id) != null)
						{
							Alert.show("Error parsing the xml scenario: node id repeated", DisplayPropertiesSingleton.APPLICATION_TITLE);
							return false;						
						}
						
						manetNodesTable.addManetNode(newManetNode, false);
						
						var prevXcoord:int = -1;
						var prevYcoord:int = -1;
						var prevZcoord:int = -1;
	
						var nodeWithMovements:Boolean = false;
						var tempSwitchOnTime:Date;
						var tempSwitchOffTime:Date;
						
						//se recorren todos los nodos del manetnode (eventos y estados)
						for each(var nodeSubElement:XML in nodeElement.elements())
						{
	
							switch (nodeSubElement.name().localName)
							{
								case "switchOn":
									prevXcoord = parseInt(nodeSubElement.@x, 10);
									prevYcoord = parseInt(nodeSubElement.@y, 10);
									prevZcoord = parseInt(nodeSubElement.@z, 10);
									
									/*
									if (nodeSubElement.@t == undefined || 
										!(nodeSubElement.@t.toString() is Number))
									{
										throw(new Error("ERROR"));
									}	
									*/
									
									//FR
									if (eastern < (prevXcoord + 1.5*range))
										eastern = prevXcoord + 1.5*range;
									if (southern < (prevYcoord + 1.5*range))
										southern = prevYcoord + 1.5*range;
									//FR
									
									var tempDate1:Date = new Date(scenarioProperties.initTime.time + parseInt(nodeSubElement.@t, 10)); 
									tempSwitchOnTime = new Date(scenarioProperties.initTime.time + parseInt(nodeSubElement.@t, 10)); 
									if (tempDate1.time > tempEndTime.time)
									{						
										tempEndTime = new Date(scenarioProperties.initTime.time + parseInt(nodeSubElement.@t, 10));
									}	 
	
									manetNodesTable.setManetNodeState(nodeElement.@id, tempDate1, true, prevXcoord, prevYcoord, prevZcoord);								
									break;
									
								case "switchOff":
									if (prevXcoord == -1 && prevYcoord == -1 && prevZcoord == -1)
									{
										prevXcoord = parseInt(nodeSubElement.@x, 10);
										prevYcoord = parseInt(nodeSubElement.@y, 10);
										prevZcoord = parseInt(nodeSubElement.@z, 10);
									}
									
									/*
									if (nodeSubElement.@t == undefined || 
										!(nodeSubElement.@t.toString() is Number))
									{
										throw(new Error("ERROR"));
									}								
									*/
									
									var tempDate2:Date = new Date(scenarioProperties.initTime.time + parseInt(nodeSubElement.@t, 10)); 
									tempSwitchOffTime = new Date(scenarioProperties.initTime.time + parseInt(nodeSubElement.@t, 10));
									if (tempDate2.time > tempEndTime.time)
									{						
										tempEndTime = new Date(scenarioProperties.initTime.time + parseInt(nodeSubElement.@t, 10));
									}										
																					
									manetNodesTable.setManetNodeState(nodeElement.@id, tempDate2, false);
									break;
									
								case "moveTo":
									nodeWithMovements = true;
									if (prevXcoord == -1 && prevYcoord == -1 && prevZcoord == -1)
									{
										prevXcoord = 0;
										prevYcoord = 0;
										prevZcoord = 0;
									}
									/*
									if (nodeSubElement.@start == undefined || 
										!(nodeSubElement.@start.toString() is Number))
									{
										throw(new Error("ERROR"));
									}
									if (nodeSubElement.@end == undefined || 
										!(nodeSubElement.@end.toString() is Number))
									{
										throw(new Error("ERROR"));
									}								
									*/
									var tempDateStart:Date = new Date(scenarioProperties.initTime.time + parseInt(nodeSubElement.@start, 10));
									var tempDateEnd:Date = new Date(scenarioProperties.initTime.time + parseInt(nodeSubElement.@end, 10));							
									if (tempDateEnd.time > tempEndTime.time)
									{						
										tempEndTime = new Date(scenarioProperties.initTime.time + parseInt(nodeSubElement.@end, 10));
									}	
	
									manetNodesTable.setManetNodeMovement(nodeElement.@id.toString(), tempDateStart, tempDateEnd, prevXcoord, prevYcoord, parseInt(nodeSubElement.@x, 10),
										parseInt(nodeSubElement.@y, 10), nodeSubElement.@path.toString(), parseInt(nodeSubElement.@acceleration, 10), true);
	
									prevXcoord = parseInt(nodeSubElement.@x, 10);
									prevYcoord = parseInt(nodeSubElement.@y, 10);
									prevZcoord = parseInt(nodeSubElement.@z, 10);
									
									//FR
									if (eastern < (prevXcoord + 1.5*range))
										eastern = prevXcoord + 1.5*range;
									if (southern < (prevYcoord + 1.5*range))
										southern = prevYcoord + 1.5*range;
									//FR
									break;
									
								default:
									
									break;			
							}//end switch
		
						}//end for 
						
						//Si el nodo no tiene movimientos se añade un movimiento nulo para que el nodo sea representado con un checkpoint en el escenario
						if (nodeWithMovements == false)
						{
							manetNodesTable.setManetNodeMovement(nodeElement.@id.toString(), tempSwitchOnTime, tempSwitchOnTime, prevXcoord, prevYcoord, prevXcoord,
								prevYcoord, 0, 0, true);
								
								//FR
								if (eastern < (prevXcoord + 1.5*range))
									eastern = prevXcoord + 1.5*range;
								if (southern < (prevYcoord + 1.5*range))
									southern = prevYcoord + 1.5*range;
								//FR							
						}					
						
					}//end for
				
				scenarioProperties.endTime = new Date(tempEndTime.time);
				}//end if
				
				//FR
				if ((eastern != -1) && (southern != -1)){
					scenarioProperties.eastern = eastern;
					scenarioProperties.southern = southern;
				}
				//FR
				
				//Se llama al singleton para desbloquear el despacho de eventos del modelo
				ModelSingleton.getSingletonInstance().lockDispatchModelEvents(false);				
				
			}//end try
			catch(thrownError:Error)
			{
				Alert.show("Error parsing the xml scenario", DisplayPropertiesSingleton.APPLICATION_TITLE);
				return false;
			}
			return true;
		}//end function

	}
}


