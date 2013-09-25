// ActionScript file
import Classes.CallableManetNodesTableProxy;
import Classes.CallableScenarioPropertiesProxy;
import Classes.DisplayPropertiesSingleton;
import Classes.ModelSingleton;
import Classes.TXTScenarioParser;//FR
import Classes.KMLScenarioParser;//FR
import Classes.GPXScenarioParser;//FR
import Classes.XMLScenarioParser;

import flash.events.Event;
import flash.filesystem.File;
import flash.net.FileFilter;

import mx.controls.Alert;
import mx.core.Application;
import mx.events.CloseEvent;

private var documentsDirectoryToBrowse:File = File.documentsDirectory;
private var _modelInstance:ModelSingleton;
private var _displayPropertiesInstance:DisplayPropertiesSingleton;
private var fileToOpen:File = new File();

protected function btnBrowseFileClick_handler(event:Event):void
{
	var scenarioFilter:FileFilter = new FileFilter("MASS file", "*.xml");
	var tracesFilter:FileFilter = new FileFilter("Traces file", "*.txt");//FR
	var kmlFilter:FileFilter = new FileFilter("KML file", "*.kml");//FR
	var gpxFilter:FileFilter = new FileFilter("GPX file", "*.gpx");//FR
	var filtersArray:Array = new Array();
	filtersArray.push(scenarioFilter);
	filtersArray.push(tracesFilter);//FR
	filtersArray.push(kmlFilter);//FR
	filtersArray.push(gpxFilter);//FR
	this.fileToOpen.addEventListener(Event.SELECT, fileToOpenSelect_handler);
	this.fileToOpen.browseForOpen("Select a scenario to open", filtersArray);
}

protected function btnSaveScenarioClick_handler(event:Event):void
{		
	this.documentsDirectoryToBrowse.addEventListener(Event.SELECT, fileToSaveSelect_handler);
    this.documentsDirectoryToBrowse.browseForSave("Save scenario as");					
}

protected function fileToOpenSelect_handler(event:Event):void
{
	this._modelInstance = ModelSingleton.getSingletonInstance();
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	//Se despacha evento para limpiar escenario
	this._displayPropertiesInstance.dispatchClearScenarioEvent();
	
	Application.application.cursorManager.setBusyCursor();
	Application.application.enabled = false;
		
	//Llamamos al parseador, pasandole el file, la tabla de nodos del singleton y las propiedades del escenario
	flash.utils.setTimeout(doScenarioParse, 50, this.fileToOpen, this._modelInstance.manetNodesTableCallableProxy, 
		this._modelInstance.scenarioPropertiesCallableProxy);
}

protected function doScenarioParse(scenarioFile:File, manetNodesTable:CallableManetNodesTableProxy, scenarioProperties:CallableScenarioPropertiesProxy):void
{
	
	//FR
	var extension:String = scenarioFile.extension;
	
	if (extension == "xml"){
		
		if (!XMLScenarioParser.parseXMLScenario(scenarioFile, manetNodesTable, scenarioProperties)){
		
		}
		
	}
	else if (extension == "txt"){
		
		if (!TXTScenarioParser.parseTXTScenario(scenarioFile, manetNodesTable, scenarioProperties)){	
		
		}
		
	}
	else if (extension == "kml"){
		
		if (!KMLScenarioParser.parseKMLScenario(scenarioFile, manetNodesTable, scenarioProperties)){	
		
		}
	}
	else if (extension == "gpx"){
		
		if (!GPXScenarioParser.parseGPXScenario(scenarioFile, manetNodesTable, scenarioProperties)){	
		
		}
		
	}
	/*if (!XMLScenarioParser.parseXMLScenario(scenarioFile, manetNodesTable, scenarioProperties))
	{
		
	}*/
	//FR
	
	Application.application.cursorManager.removeBusyCursor();
	Application.application.enabled = true;		
}


protected function fileToSaveSelect_handler(event:Event):void
{
    var newFile:File = event.target as File;
    if (!newFile.isDirectory)
    {
		if ((newFile.extension != "xml")&&(newFile.extension != "kml")&&(newFile.extension != "gpx")) 
		{
			newFile.nativePath += ".xml";
		}		    	
		Application.application.cursorManager.setBusyCursor();
		Application.application.enabled = false; 
		   	
    	//XMLScenarioParser.saveXMLScenario(newFile, _modelInstance.manetNodesTableCallableProxy, _modelInstance.scenarioPropertiesCallableProxy);
    	this._modelInstance = ModelSingleton.getSingletonInstance();
    	
    	if (newFile.extension == "xml")
    		XMLScenarioParser.saveXMLScenario(newFile, this._modelInstance.manetNodesTableCallableProxy, this._modelInstance.scenarioPropertiesCallableProxy);
    	else if (newFile.extension == "kml")
    		KMLScenarioParser.saveKMLScenario(newFile, this._modelInstance.manetNodesTableCallableProxy, this._modelInstance.scenarioPropertiesCallableProxy);
 		else if (newFile.extension == "gpx")
    		GPXScenarioParser.saveGPXScenario(newFile, this._modelInstance.manetNodesTableCallableProxy, this._modelInstance.scenarioPropertiesCallableProxy);
    		
		Application.application.cursorManager.removeBusyCursor();
		Application.application.enabled = true;	    	
    }				
}

protected function btnClearScenarioClick_handler(event:Event):void
{
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	Alert.show("Are you sure to clear all scenario data?", DisplayPropertiesSingleton.APPLICATION_TITLE, (Alert.YES | Alert.CANCEL), null, clearAlertClick);
	function clearAlertClick(event:CloseEvent):void{
		if(event.detail == Alert.YES)
		{
			this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
			this._displayPropertiesInstance.dispatchClearScenarioEvent();
			
		}
	}
}