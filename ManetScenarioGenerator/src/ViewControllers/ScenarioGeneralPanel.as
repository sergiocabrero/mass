// ActionScript file
import Classes.DisplayPropertiesSingleton;
import Classes.DisplayPropertyChangeEventKind;
import Classes.ModelPropertyChangeEventKind;
import Classes.ModelPropertyChangeEventType;
import Classes.ModelSingleton;

import Entities.ScenarioProperties;

import flash.events.Event;
import flash.filesystem.File;

import mx.controls.CheckBox;
import mx.events.PropertyChangeEvent;
import mx.controls.Alert; //FR

private var imageToOpen:File = new File();
private var documentsDirectoryToBrowse:File = File.documentsDirectory;
private var _modelInstance:ModelSingleton;
private var _displayPropertiesInstance:DisplayPropertiesSingleton;


private function creationComplete_handler(event:Event):void
{
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	this._modelInstance = ModelSingleton.getSingletonInstance();
	
	this.chkBackgroundImage.selected = false;
	//this.chkShowGrid.selected = true;
	this._modelInstance.addEventListener(ModelPropertyChangeEventType.SCENARIOPROPERTIES_CHANGE_EVENT, modelScenarioProperties_handler);	
	this._displayPropertiesInstance.addEventListener(DisplayPropertyChangeEventKind.CLEAR_SCENARIO_EVENT, clearScenarioEvent_handler);
	this._modelInstance.addEventListener(ModelPropertyChangeEventType.SCENARIOPROPERTIES_CHANGE_EVENT, scenarioBackgroundChange_handler);
	this._modelInstance.addEventListener(ModelPropertyChangeEventType.MODEL_UNLOCKED_EVENT, modelUnlocked_handler);
	this._modelInstance.addEventListener(ModelPropertyChangeEventType.TRACES_MODEL_UNLOCKED_EVENT, tracesModelUnlocked_handler);//FR
}

public function clearPanel():void
{
	/*
	this.nsHeight.value = 300;
	this.nsWidth.value = 400;
	//this.imgThumb.source = "";
	this.chkBackgroundImage.selected = true;
	this.chkShowGrid.selected = false;
	*/
}

private function clearScenarioEvent_handler(event:Event):void
{
	//this.clearPanel();

	this._modelInstance = ModelSingleton.getSingletonInstance();
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	
	this._modelInstance.manetNodesTableCallableProxy.clearAll();
	//this._modelInstance.scenarioPropertiesCallableProxy.initTime = new Date(0);	
	//this._modelInstance.scenarioPropertiesCallableProxy.endTime = new Date(0);
	//this._modelInstance.scenarioPropertiesCallableProxy.initTime = null;	
	//this._modelInstance.scenarioPropertiesCallableProxy.endTime = null;	
	this._modelInstance.scenarioPropertiesCallableProxy.backgroundImagePath = "";
	this._modelInstance.scenarioPropertiesCallableProxy.depth = 100;
	this._modelInstance.scenarioPropertiesCallableProxy.height = 300;
	this._modelInstance.scenarioPropertiesCallableProxy.width = 400;

	this._displayPropertiesInstance.clearDisplayedAllManetNodesProperties();	
	
	
}

private function scenarioBackgroundChange_handler(event:PropertyChangeEvent):void
{
	try
	{
		if (event.kind == ModelPropertyChangeEventKind.SET_SCENARIO_BACKGROUND_IMAGE_PATH)
		{
			if (ScenarioProperties(event.newValue).backgroundImagePath != null)
			{
				this.imgThumb.load(ScenarioProperties(event.newValue).backgroundImagePath);
			}
			else
			{
				this.imgThumb.unloadAndStop();
			}	

		}	
	}
	catch (thrownError:Error)
	{
		trace("Error!!: " + thrownError.message);
	}	
}



private function btnUpdateDimensionsClick_handler(event:Event, newHeight:int, newWidth:int):void
{
	this._modelInstance = ModelSingleton.getSingletonInstance();
	this._modelInstance.scenarioPropertiesCallableProxy.height = newHeight;
	this._modelInstance.scenarioPropertiesCallableProxy.width = newWidth;	
}


private function btnClearImageClick_handler(event:Event):void
{
	try
	{
		this._modelInstance = ModelSingleton.getSingletonInstance();
		this._modelInstance.scenarioPropertiesCallableProxy.backgroundImagePath = null;
	}
	catch (thrownError:Error)
	{
		this._modelInstance.scenarioPropertiesCallableProxy.backgroundImagePath = null;
	}	
}


protected function chkBackgroundImageValueCommit_handler(event:Event):void
{
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	this._displayPropertiesInstance.backgroundImageVisible = CheckBox(event.target).selected;
}

/*protected function btnBrowseImageClick_handler(event:Event):void
{
	var imageFilter:FileFilter = new FileFilter("Image", "*.jpg;*.gif;*.png");
	var filtersArray2:Array = new Array();
	filtersArray2.push(imageFilter);
	this.imageToOpen.addEventListener(Event.SELECT, imageToOpenSelect_handler);
	this.imageToOpen.browseForOpen("Select a background image to open", filtersArray2);	
}*/

//FR
protected function btnBrowseImageClick_handler(event:Event):void
{
	
	
	var modelInstance:ModelSingleton = ModelSingleton.getSingletonInstance();
	try
	{
		if ((modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo == null)||
			(modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._visible == false)){
				
				var imageFilter:FileFilter = new FileFilter("Image", "*.jpg;*.gif;*.png");
				var filtersArray2:Array = new Array();
				filtersArray2.push(imageFilter);
				this.imageToOpen.addEventListener(Event.SELECT, imageToOpenSelect_handler);
				this.imageToOpen.browseForOpen("Select a background image to open", filtersArray2);
				
		}
		else{
			
			Alert.show("The background image browser is not available if Google Maps is enabled.", DisplayPropertiesSingleton.APPLICATION_TITLE);
			
		}
		
	}
	catch(thrownError:Error)
	{
		Alert.show("Error at ScenarioGeneralPanel.as: " + Error);
	}		
}//FR

protected function imageToOpenSelect_handler(event:Event):void
{
	var modelInstance:ModelSingleton = ModelSingleton.getSingletonInstance();
	try
	{
		modelInstance.scenarioPropertiesCallableProxy.backgroundImagePath = this.imageToOpen.nativePath;
	}
	catch(thrownError:Error)
	{
		modelInstance.scenarioPropertiesCallableProxy.backgroundImagePath = null;
	}	
}




private function modelScenarioProperties_handler(event:PropertyChangeEvent):void
{
	switch (event.kind)
	{
		case ModelPropertyChangeEventKind.SET_SCENARIO_HEIGHT:
			this.nsHeight.value = ScenarioProperties(event.newValue).height;
			break;
		
		case ModelPropertyChangeEventKind.SET_SCENARIO_WIDTH:
			this.nsWidth.value = ScenarioProperties(event.newValue).width;
			break;	
			
		case ModelPropertyChangeEventKind.SET_SCENARIO_BACKGROUND_IMAGE_PATH:
			//this.imgThumb.source = ScenarioProperties(event.newValue).backgroundImagePath;
	}
}

//FR
private function tracesModelUnlocked_handler(event:Event):void
{
	this._modelInstance = ModelSingleton.getSingletonInstance();
	
	this.nsHeight.value = this._modelInstance.scenarioPropertiesCallableProxy.height;
	this.nsWidth.value = this._modelInstance.scenarioPropertiesCallableProxy.width;
	
	
	if ((this._modelInstance.scenarioPropertiesCallableProxy.backgroundImagePath != null)&&
		(this._modelInstance.scenarioPropertiesCallableProxy.backgroundImagePath != ""))
	{
		this.imgThumb.load(this._modelInstance.scenarioPropertiesCallableProxy.backgroundImagePath);
	}
	else
	{
		this.imgThumb.unloadAndStop();
	}
}
//FR

private function modelUnlocked_handler(event:Event):void
{
	this._modelInstance = ModelSingleton.getSingletonInstance();
	
	this.nsHeight.value = this._modelInstance.scenarioPropertiesCallableProxy.height;
	this.nsWidth.value = this._modelInstance.scenarioPropertiesCallableProxy.width;
	
	
	if ((this._modelInstance.scenarioPropertiesCallableProxy.backgroundImagePath != null)&&
		(this._modelInstance.scenarioPropertiesCallableProxy.backgroundImagePath != ""))
	{
		this.imgThumb.load(this._modelInstance.scenarioPropertiesCallableProxy.backgroundImagePath);
	}
	else
	{
		this.imgThumb.unloadAndStop();
	}	

			
}