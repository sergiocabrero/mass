// ActionScript file
import Classes.DisplayPropertiesSingleton;
import Classes.ModelSingleton;

import flash.events.Event;

import mx.events.NumericStepperEvent;
import Classes.ModelPropertyChangeEventType;//FR
import Classes.ModelPropertyChangeEventKind;//FR
import mx.events.PropertyChangeEvent;//FR
import mx.events.PropertyChangeEventKind;//FR
import mx.controls.Alert; //FR

private var _displayPropertiesInstance:DisplayPropertiesSingleton;
private var imageToOpen:File = new File();
private var _modelInstance:ModelSingleton;//FR

private function creationComplete_handler(event:Event):void
{
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	this.chkShowGrid.selected = true;
	this._modelInstance = ModelSingleton.getSingletonInstance();//FR
	this._modelInstance.addEventListener(ModelPropertyChangeEventType.SCENARIOPROPERTIES_CHANGE_EVENT,scenarioProperties_changeEvent_handler);//FR
}

private function nsRangeAlphaChange_handler(event:NumericStepperEvent):void
{
	try
	{
		this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
		this._displayPropertiesInstance.rangeAlpha = event.value;
	}
	catch(err:Error)
	{
		
	}	
}

private function nsCheckpointSizeChange_handler(event:NumericStepperEvent):void
{	
	try
	{
		this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
		this._displayPropertiesInstance.checkpointSize = event.value;
	}
	catch(err:Error)
	{
		
	}	
}

private function btnBrowseImageClick_handler(event:Event):void
{
	var imageFilter:FileFilter = new FileFilter("Image", "*.jpg;*.gif;*.png");
	var filtersArray:Array = new Array();
	filtersArray.push(imageFilter);
	this.imageToOpen.addEventListener(Event.SELECT, imageToOpenSelect_handler);
	this.imageToOpen.browseForOpen("Select a background image to open", filtersArray);		
}

private function imageToOpenSelect_handler(event:Event):void
{
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	try
	{
		this._displayPropertiesInstance.nodeIconPath = this.imageToOpen.nativePath;
	}
	catch(thrownError:Error)
	{
		this._displayPropertiesInstance.nodeIconPath = null;
	}	
}

private function btnClearImageClick_handler(event:Event):void
{
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	this._displayPropertiesInstance.nodeIconPath = null;
}

private function chkLoopMovementChange_handler(event:Event):void
{
	try
	{
		this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
		this._displayPropertiesInstance.loopMovement = event.target.selected;
	}
	catch(err:Error)
	{
		
	}
}

private function imgThumbNodeIconComplete_handler(event:Event):void
{
	if (this.imgThumbNodeIcon.contentHeight > this.imgThumbNodeIcon.height || this.imgThumbNodeIcon.contentWidth > this.imgThumbNodeIcon.width)
	{
		this.imgThumbNodeIcon.scaleContent = true
	}
	else
	{
		this.imgThumbNodeIcon.scaleContent = false;
	}
}

/*private function cmbScaleChange_handler(event:Event):void
{
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	this._displayPropertiesInstance.scaleFactor = this.cmbScale.selectedItem.data;
}*/

//FR
private function cmbScaleChange_handler(event:Event):void
{
	
	
	var modelInstance:ModelSingleton = ModelSingleton.getSingletonInstance();
	try
	{
		if ((modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo == null)||
			(modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._visible == false)){
				
				this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
				this._displayPropertiesInstance.scaleFactor = this.cmbScale.selectedItem.data;
				
		}
		else{
			
			this.cmbScale.selectedIndex = 3;
			this._displayPropertiesInstance.scaleFactor = this.cmbScale.selectedItem.data;
			Alert.show("The scale factor is 100% if Google Maps is enabled.", DisplayPropertiesSingleton.APPLICATION_TITLE);
			
		}
		
	}
	catch(thrownError:Error)
	{
		Alert.show("Error at AppGeneralPanel.as: " + Error);
	}
}
//FR

protected function chkShowGridValueCommit_handler(event:Event):void
{
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	this._displayPropertiesInstance.gridVisible = CheckBox(event.target).selected;			
}

private function scenarioProperties_changeEvent_handler(event:PropertyChangeEvent):void{

	try{
		
		if (event.kind == ModelPropertyChangeEventKind.SET_GOOGLEMAP){
			
			this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
			this.cmbScale.selectedIndex = 3;
			this._displayPropertiesInstance.scaleFactor = this.cmbScale.selectedItem.data;
		}
		
	}
	catch(thrownError:Error){
		
		Alert.show("Error at AppGeneralPanel.as: " + Error);
		
	}
	
}