package Classes
{
	import Entities.GoogleInfo;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.controls.Alert;
	
	public class KMLScenarioParser
	{
		public function KMLScenarioParser()
		{
		}
		
		//Parsea un txt de un escenario. Se le pasan el objeto file del txt, y la referencia a la instancia manetNodesTable del singleton Y FALTAN
		//LAS PROPIEDADES DEL ESCENARIO EN EL SINGLETON
		public static function parseKMLScenario(scenarioFile:File, manetNodesTable:CallableManetNodesTableProxy, scenarioProperties:CallableScenarioPropertiesProxy):Boolean
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
				
				return parseKMLFieldsToScenario(scenarioXMLObject, manetNodesTable, scenarioProperties, directoryPath);
			}
			catch(thrownError:Error)
			{
				trace("Error loading kml scenario" + thrownError.message);
				return false;
			}
			return true;	
		}
		
		
		public static function parseKMLFieldsToScenario(XMLScenario:XML, manetNodesTable:CallableManetNodesTableProxy, scenarioProperties:CallableScenarioPropertiesProxy, directoryPath:String = ""):Boolean
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
					
					var dato:String = "";
					var etiqueta:String = "";
					var file:String = "";
					
					for each(var Document:XML in XMLScenario.elements()){
						for each(var Element:XML in Document.elements()){
							
							etiqueta = Element.name().localName;
							if(etiqueta=="Placemark"){
								
								dato = Element.toString();
								
								var name:String="";
								var TimeStampLine:String="";
								var TimeStampArray:Array;
								var fecha:String="";
								var fechaArray:Array;
								var hora:String="";
								var horaArray:Array;
								var Point:String="";
								var ExtendedData:String="";
								var nodeRange:String = "";
								var instante:Date;
								
								for each(var Placemark:XML in Element.elements()){
								
									dato = Placemark.toString();
									etiqueta = Placemark.name().localName;
									
									if (etiqueta == "name"){
										name = Placemark.toString();
									}
									else if (etiqueta == "TimeStamp"){
										for each(var when:XML in Placemark.elements()){
											
											TimeStampLine = when.toString();
											TimeStampArray = TimeStampLine.split("T");
											fecha = TimeStampArray[0];
											fechaArray = fecha.split("-");
											var anho:Number = parseInt(fechaArray[0],10);
											var mes:Number = parseInt(fechaArray[1],10)-1; //Se resta 1 porque month=[0,...,11]
											var dia:Number = parseInt(fechaArray[2],10);
											
											if (TimeStampArray.length == 2){
												
												hora = TimeStampArray[1];
												var horas:Number;
												var minutos:Number;
												var segundos:Number;
												
												if (hora.charAt(hora.length-1) == "Z"){
													horaArray = hora.split(":"); //HH:MM:SSZ
													horaArray[2] = horaArray[2].toString().substr(0,2);
													horas = parseInt(horaArray[0],10);
													minutos = parseInt(horaArray[1],10);
													segundos = parseInt(horaArray[2],10);
													
													instante = new Date(anho,mes,dia,horas,minutos,segundos);
													instante.setUTCHours(horas,minutos,segundos,0);
													instante.setUTCFullYear(anho,mes,dia);
													
												}
												else{
													horaArray = hora.substr(0,8).split(":"); //HH:MM:SS+HH:MM ó HH:MM:SS-HH:MM
													
													var sumar:Boolean = false;
													if (hora.charAt(8) == "+")
														sumar = true;

													hora = hora.substr(10,hora.length-9);
													
													horas = parseInt(horaArray[0],10);
													minutos = parseInt(horaArray[1],10);
													segundos = parseInt(horaArray[2],10);
													
													instante = new Date(anho,mes,dia,horas,minutos,segundos);
													
													if (sumar){
													
														instante.minutesUTC = instante.minutes + parseInt(hora.substr(3,2),10);
														instante.hoursUTC = instante.hours + parseInt(hora.substr(0,2),10);
													}
													else{
														
														instante.minutesUTC = instante.minutes - parseInt(hora.substr(3,2),10);
														instante.hoursUTC = instante.hours - parseInt(hora.substr(0,2),10);
														
													}
													
												}
											
											}//if
											else{
												
												if (fechaArray.length == 3){	
													
													instante = new Date(anho,mes,dia);
													instante.setUTCHours(0,0,0,0);
													instante.setUTCFullYear(anho,mes,dia);
																																																			
													
												}
												else if (fechaArray.length == 2){													
													
													instante = new Date(anho,mes,1);
													instante.setUTCHours(0,0,0,0);
													instante.setUTCFullYear(anho,mes,1);
													
												}	
												else if (fechaArray.length == 1){													
													
													instante = new Date(anho,1,1);
													instante.setUTCHours(0,0,0,0);
													instante.setUTCFullYear(anho,1,1);
													
												}
				
											}//else
											
											TimeStampLine = instante.time.toString();
											
										}//for each
									}
									else if (etiqueta == "Point"){
										for each(var coordinates:XML in Placemark.elements()){
											Point = coordinates.toString();
											var coma:int = Point.indexOf(",");
											var longitud:String = Point.substring(0,Point.indexOf(","));
											var latitud:String = Point.substring(coma+1,Point.length);
											Point = longitud.concat("\t",latitud);
										}
									}
									else if (etiqueta == "ExtendedData"){
										for each(var Data:XML in Placemark.elements()){
											ExtendedData= Data.@name;
											
											if (ExtendedData == "range"){
												
												for each(var range:XML in Data.elements())
													nodeRange = range.toString();
													
											}
										}
									}
								
								}
								file = file.concat(name,"\t",Point,"\t",TimeStampLine,"\t",nodeRange,"\r\n");

							}
						}
					}
					
					var lines:Array = file.split("\r\n");
					lines.pop();
					/*for (var j:Number = 0; j < lines.length; j++)
						lines[j] = lines[j].concat("000");*/
						
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
				Alert.show("Error parsing the kml scenario", DisplayPropertiesSingleton.APPLICATION_TITLE);
				return false;
			}
			return true;
		}//end function
		
		
		
		public static function saveKMLScenario(fileTarget:File, manetNodesTable:CallableManetNodesTableProxy, scenarioProperties:CallableScenarioPropertiesProxy):Boolean
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
					
					var KMLDocument:XML = <Document></Document>;
					var nombre:String = fileTarget.name.substr(0,fileTarget.name.length-4);
					
					var KMLName:XML = <name></name>;
					
					KMLName.setChildren(nombre);
					KMLDocument.appendChild(KMLName);

					ModelSingleton.getSingletonInstance().lockDispatchKMLorGPXSaveEvent(false);
						
					var file:Array = ModelSingleton.getSingletonInstance().scenarioPropertiesCallableProxy.tracesData;
					var line:String;
					var lineInfo:Array;
					var nodeName:String;
					var nodeLongitude:Number;
					var nodeLatitude:Number;
					var nodeTimestamp:Number;
					var nodeRange:Number;
					
					for (var i:Number = 0; i < file.length; i++){
						line = file[i];
						lineInfo = line.split("\t");
						nodeName = lineInfo[0];
						nodeLongitude = lineInfo[1];
						nodeLatitude = lineInfo[2];
						nodeTimestamp = lineInfo[3];
						nodeRange = lineInfo[4];
						
						var Placemark:XML = <Placemark></Placemark>
						
						for (var j:Number = 0; j < lineInfo.length; j++){
							
							if (j==0){
								var nodeId:XML = <name></name>;
								nodeId.setChildren(nodeName);
								Placemark.appendChild(nodeId);
							}
							else if (j==1){
								var tStamp:XML = <TimeStamp></TimeStamp>;
								var instante:XML = <when></when>;
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
								
								instante.setChildren(marcaTemporal);
								tStamp.appendChild(instante);
								Placemark.appendChild(tStamp);
							}
							else if (j==2){
								continue;
							}
							else if (j==3){
								var posicion:XML = <Point></Point>;
								var coord:XML = <coordinates></coordinates>
								coord.setChildren(nodeLongitude.toString()+","+nodeLatitude.toString());
								posicion.appendChild(coord);
								Placemark.appendChild(posicion);
							}
							else if (j==4){
								var extData:XML = <ExtendedData></ExtendedData>;
								var variable:XML = <Data></Data>
								variable.@name = "range";
								var valor:XML = <value></value>;
								valor.setChildren(nodeRange);
								variable.appendChild(valor);
								extData.appendChild(variable);
								Placemark.appendChild(extData);					
							}						
						}
						KMLDocument.appendChild(Placemark);
						
					}
					ModelSingleton.getSingletonInstance().scenarioPropertiesCallableProxy.tracesData = null; 
					
				}
				catch(err:Error)
				{
					Alert.show("Error in saveKMLScenario", DisplayPropertiesSingleton.APPLICATION_TITLE);
					return false;					
				}
				//Se escribe el archivo
			    var strToWrite:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + "\r\n" +
			    	"<kml xmlns=\"http://earth.google.com/kml/2.2\">" + "\r\n" + 
			    	"<!--TimeStamp is recommended for Point. Each Point represents a sample from a GPS.-->" +
			    	"\r\n\r\n" + KMLDocument.toString() + "\r\n\r\n" + "</kml>";

			    var stream:FileStream = new FileStream();
			    stream.open(fileTarget, FileMode.WRITE);
			    stream.writeUTFBytes(strToWrite);
			    stream.close();

							
			}//end try
			catch(thrownError:Error)
			{
				Alert.show("Error while saving kml scenario", DisplayPropertiesSingleton.APPLICATION_TITLE);
				return false;
			}
			return true;
		}//end SAVE

	}//end Class
	
}//end Package