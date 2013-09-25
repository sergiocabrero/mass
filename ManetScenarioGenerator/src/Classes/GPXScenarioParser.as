package Classes
{
	import Entities.GoogleInfo;
	
	import de.polygonal.ds.Vector;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.controls.Alert;
	
	public class GPXScenarioParser
	{
		public function GPXScenarioParser()
		{
		}
		
		//Parsea un txt de un escenario. Se le pasan el objeto file del txt, y la referencia a la instancia manetNodesTable del singleton Y FALTAN
		//LAS PROPIEDADES DEL ESCENARIO EN EL SINGLETON
		public static function parseGPXScenario(scenarioFile:File, manetNodesTable:CallableManetNodesTableProxy, scenarioProperties:CallableScenarioPropertiesProxy):Boolean
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
				
				return parseGPXFieldsToScenario(scenarioXMLObject, manetNodesTable, scenarioProperties, directoryPath);
			}
			catch(thrownError:Error)
			{
				trace("Error loading gpx scenario" + thrownError.message);
				return false;
			}
			return true;	
		}
		
		
		public static function parseGPXFieldsToScenario(XMLScenario:XML, manetNodesTable:CallableManetNodesTableProxy, scenarioProperties:CallableScenarioPropertiesProxy, directoryPath:String = ""):Boolean
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
				
				try{
					
					var file:String = "";
					var etiqueta:String = "";
					var name:String = "";
					var latitud:String = "";
					var longitud:String = "";
					var TimeStampLine:String="";
					var TimeStampArray:Array;
					var fecha:String="";
					var fechaArray:Array;
					var hora:String="";
					var horaArray:Array;
					var instante:Date;
					var ExtendedData:String="";
					var nodeRange:String = "50";
					
					for each(var Element:XML in XMLScenario.elements()){
						
						etiqueta = Element.name().localName;
							
						if (etiqueta == "trk"){
							
							for each(var track:XML in Element.elements()){
									
									etiqueta = track.name().localName;
									
									if (etiqueta == "name")
										name = track.toString();
									
									else if (etiqueta == "trkseg"){
										
										for each(var trackseg:XML in track.elements()){
											
											etiqueta = trackseg.name().localName;
											
											if (etiqueta == "trkpt"){
												
												latitud = trackseg.@lat;
												longitud = trackseg.@lon;
												
												for each(var trkpt:XML in trackseg.elements()){
													
													etiqueta = trkpt.name().localName;
													
													if (etiqueta == "time"){
														
														TimeStampLine = trkpt.toString();
														TimeStampArray = TimeStampLine.split("T");
														fecha = TimeStampArray[0];
														fechaArray = fecha.split("-");
														var anho:Number = parseInt(fechaArray[0],10);
														var mes:Number = parseInt(fechaArray[1],10)-1;//Se resta 1 porque month=[0,...11]
														var dia:Number = parseInt(fechaArray[2],10);
														hora = TimeStampArray[1];
														horaArray = hora.split(":"); //HH:MM:SSZ
														horaArray[2] = horaArray[2].toString().substr(0,2);
														var horas:Number = parseInt(horaArray[0],10);
														var minutos:Number = parseInt(horaArray[1],10);
														var segundos:Number = parseInt(horaArray[2],10);
													
														instante = new Date(anho,mes,dia,horas,minutos,segundos);
														instante.setUTCHours(horas,minutos,segundos,0);
														instante.setUTCFullYear(anho,mes,dia);
														TimeStampLine = instante.time.toString();
													}//if time
													else if (etiqueta == "desc"){
														
														ExtendedData = trkpt.toString()
														
														if(ExtendedData.substr(0,6) == "Range=")
															nodeRange = ExtendedData.substr(6,ExtendedData.length-6);
													}
													
												}//for trkpt
												
												file = file.concat(name,"\t",longitud,"\t",latitud,"\t",TimeStampLine,
													"\t",nodeRange,"\r\n");
												
											}//if trkpt
											
											
										}//for trkseg
									
									
									}//elseif trkseg	
							
							}//for track
						}//if track
					}//for element
					
					var lines:Array = file.split("\r\n");
					lines.pop();
					//for (var j:Number = 0; j < lines.length; j++)
					//	lines[j] = lines[j].concat("000");
						
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
						//var nodeName:String = lineInfo[0];
						nodeLongitude = lineInfo[1];
						nodeLatitude = lineInfo[2];
						//nodeTimestamp = new Date(1000*parseInt(lineInfo[3])); //OJO con el 10000
						nodeTimestamp = new Date(parseInt(lineInfo[3]));
						
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
					
					scenarioProperties.width = 1000;
					scenarioProperties.height = 572;
					scenarioProperties.depth = 0;
					scenarioProperties.initTime = lowestTimestamp;	
					scenarioProperties.backgroundImagePath = directoryPath + "\\" + "";
					var googleData:GoogleInfo = new GoogleInfo("Normal","Coordinates",
												10,highestLatitude,lowestLongitude,"",true);
					scenarioProperties.googleMapsInfo = googleData;
						
				}
				catch(err:Error)
				{
					Alert.show(err.toString(), DisplayPropertiesSingleton.APPLICATION_TITLE);
					return false;
				}
						
				
				//Se llama al singleton para desbloquear el despacho de eventos del modelo
				ModelSingleton.getSingletonInstance().lockDispatchTracesModelEvents(false);				
				
			}//end try
			catch(thrownError:Error)
			{
				Alert.show("Error parsing the gpx scenario", DisplayPropertiesSingleton.APPLICATION_TITLE);
				return false;
			}
			return true;
		}//end function
		
		public static function saveGPXScenario(fileTarget:File, manetNodesTable:CallableManetNodesTableProxy, scenarioProperties:CallableScenarioPropertiesProxy):Boolean
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
					
					var GPXDocument:XML = <gpx></gpx>;
					GPXDocument.@version = "1.0";
					GPXDocument.@creator = "MASS Editor";
					//GPXDocument.@xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance";
					GPXDocument.addNamespace("http://www.w3.org/2001/XMLSchema-instance");
					GPXDocument.@xmlns="http://www.topografix.com/GPX/1/0";
					GPXDocument.addNamespace("http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd");
					//GPXDocument.@xsi:schemaLocation="http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd";
					
					ModelSingleton.getSingletonInstance().lockDispatchKMLorGPXSaveEvent(false);
					
					
					
					var strToWrite:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + "\r\n" +
			    	"<gpx version=\"1.0\" creator=\"MASS Editor\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"" + "\r\n" 
			    	+ "xmlns=\"http://www.topografix.com/GPX/1/0\" xsi:schemaLocation=\"http://www.topografix.com/GPX/1/0 "
			    	+ "http://www.topografix.com/GPX/1/0/gpx.xsd\">" + "\r\n\r\n";
			    	
					var file:Array = ModelSingleton.getSingletonInstance().scenarioPropertiesCallableProxy.tracesData;
					var line:String;
					var lineInfo:Array;
					var prevNodeName:String = "";
					var nodeName:String = "";
					var nodeLongitude:Number;
					var nodeLatitude:Number;
					var nodeTimestamp:Number;
					var nodeRange:Number;
					
					var numberOfPositions:Vector.<Number>;
					numberOfPositions = new Vector.<Number>();
					
					for (var i:Number = 0; i < file.length; i++){
						
						line = file[i];
						lineInfo = line.split("\t");
						prevNodeName = nodeName;
						nodeName = lineInfo[0];
						
						if (nodeName != prevNodeName)
							numberOfPositions.push(1);
						else
							numberOfPositions[numberOfPositions.length-1]++;
						
					}
					
					var root:Number = 0;
					
					for (var j:Number = 0; j < numberOfPositions.length; j++){
						
						var track:XML = <trk></trk>;
						var trackseg:XML = <trkseg></trkseg>;
						
						for (var k:Number = 0; k < numberOfPositions[j]; k++){
							
							line = file[root+k];
							lineInfo = line.split("\t");
							prevNodeName = nodeName;
							nodeName = lineInfo[0];
							nodeLongitude = lineInfo[1];
							nodeLatitude = lineInfo[2];
							nodeTimestamp = lineInfo[3];
							nodeRange = lineInfo[4];
							
							if (k == 0){
								
								var name:XML = <name></name>;
								name.setChildren(nodeName);
								track.appendChild(name);
								
							}
							
							var trackpoint:XML = <trkpt></trkpt>;
							trackpoint.@lat = nodeLatitude;
							trackpoint.@lon = nodeLongitude;
							
							var time:XML = <time></time>;
							var marca:Date = new Date(nodeTimestamp);
							var marcaTemporal:String = marca.fullYearUTC + "-";
							var mes:Number = marca.monthUTC+1;
							if (mes < 10)
								marcaTemporal = marcaTemporal + "0" + mes + "-";
							else
								marcaTemporal = marcaTemporal + mes + "-";
								
							if (marca.dateUTC < 10)
								marcaTemporal = marcaTemporal + "0" + marca.dateUTC + "T";
							else
								marcaTemporal = marcaTemporal + marca.dateUTC + "T";
							
							if (marca.hoursUTC < 10)
								marcaTemporal = marcaTemporal + "0" + marca.hoursUTC + ":";
							else
								marcaTemporal = marcaTemporal + marca.hoursUTC + ":";
							
							if (marca.minutesUTC < 10)
								marcaTemporal = marcaTemporal + "0" + marca.minutesUTC + ":";
							else
								marcaTemporal = marcaTemporal + marca.minutesUTC + ":";
							
							if (marca.secondsUTC < 10)
								marcaTemporal = marcaTemporal + "0" + marca.secondsUTC + "Z";
							else
								marcaTemporal = marcaTemporal + marca.secondsUTC + "Z";
							
							time.setChildren(marcaTemporal);
							trackpoint.appendChild(time);
							
							var description:XML = <desc></desc>;
							description.setChildren("Range="+nodeRange);
							trackpoint.appendChild(description);
							var sym:XML = <sym></sym>;
							sym.setChildren("Waypoint");
							trackpoint.appendChild(sym);
							
							trackseg.appendChild(trackpoint);
							
						}
						track.appendChild(trackseg);
						//GPXDocument.appendChild(track);
						strToWrite = strToWrite + track.toString() + "\r\n\r\n";
						root = root + numberOfPositions[j];
						
					}
					strToWrite = strToWrite + "\r\n" + "</gpx>";
					ModelSingleton.getSingletonInstance().scenarioPropertiesCallableProxy.tracesData = null;
					
				}
				catch(err:Error)
				{
					Alert.show("Error in saveGPXScenario", DisplayPropertiesSingleton.APPLICATION_TITLE);
					return false;					
				}
				//Se escribe el archivo
				//var strToWrite:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + "\r\n" + GPXDocument.toString();
				
			    /*var strToWrite:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + "\r\n" +
			    "<gpx version=\"1.0\" creator=\"MASS Editor\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance" + "\r\n" 
			    	+ "xmlns=\"http://www.topografix.com/GPX/1/0\" xsi:schemaLocation=\"http://www.topografix.com/GPX/1/0 "
			    	+ "http://www.topografix.com/GPX/1/0/gpx.xsd\">"
			    	"\r\n\r\n" + GPXDocument.toString() + "\r\n\r\n" + "</gpx>";*/

			    var stream:FileStream = new FileStream();
			    stream.open(fileTarget, FileMode.WRITE);
			    stream.writeUTFBytes(strToWrite);
			    stream.close();

							
			}//end try
			catch(thrownError:Error)
			{
				Alert.show("Error while saving gpx scenario", DisplayPropertiesSingleton.APPLICATION_TITLE);
				return false;
			}
			return true;
		}//end SAVE

	}//CLASS
}//Package