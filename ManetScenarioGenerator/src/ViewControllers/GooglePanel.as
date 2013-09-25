// ActionScript file
	
import Classes.DisplayPropertiesSingleton;
import Classes.GoogleEvent;
import Classes.ModelPropertyChangeEventKind;
import Classes.ModelPropertyChangeEventType;
import Classes.ModelSingleton;

import Entities.GoogleInfo;
import Entities.ScenarioProperties;

import mx.events.PropertyChangeEvent;

private var _modelInstance:ModelSingleton;
private var _displayPropertiesInstance:DisplayPropertiesSingleton;
private var updating:Boolean = false;
private var firstTimeHere:Boolean = true;


private function GoogleCreationComplete_handler(event:Event):void
{
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	this._modelInstance = ModelSingleton.getSingletonInstance();

	this._modelInstance.addEventListener(ModelPropertyChangeEventType.SCENARIOPROPERTIES_CHANGE_EVENT, scenarioProperties_changeEvent_handler);
	
}

 private function apply(mapType:Object,MapMethodSelectedValue:Object,zoomSliderValue:Number,latitudeStepperValue:Number,
		longitudeStepperValue:Number,locationCaption:String,visible:Boolean,doubleClickMode:String):void {
        
        this._modelInstance = ModelSingleton.getSingletonInstance();
        
        var info:GoogleInfo = new GoogleInfo(mapType,MapMethodSelectedValue,zoomSliderValue,latitudeStepperValue,
		longitudeStepperValue,locationCaption,visible,doubleClickMode);
		
		if ((firstTimeHere)&&(!this._modelInstance.scenarioPropertiesCallableProxy.connectedToInternet)){
			
			this._modelInstance.lockDispatchCheckConnectionEvent(false);
			firstTimeHere = false;
			
		}
		
		updating = true;
		
		if (visible){
				
				
				if (this._modelInstance.scenarioPropertiesCallableProxy.connectedToInternet)
				//this._modelInstance.scenarioPropertiesCallableProxy.backgroundImagePath = null;
					this._modelInstance.scenarioPropertiesCallableProxy.backgroundImagePath = "";
				else{
					
					this.checkBox.selected = false;
					this.latitudeStepper.enabled = false;
					this.longitudeStepper.enabled = false;
					this.modeSelector.selectedItem = "Location";
					this.modeSelector.enabled = false
					this.locationCaption.text = "";
					this.locationCaption.enabled = false;
					this.zoomStepper.enabled = false
					this.doubleClickModeSelector.selectedItem = "Shift";
					this.doubleClickModeSelector.enabled = false;
					
				}
					
		}
		
        var e:GoogleEvent = new GoogleEvent("GoogleMapsEvent",info);
		this.addEventListener("GoogleMapsEvent",GoogleMapsEvent_handler);
		this.dispatchEvent(e);

  }

private function GoogleMapsEvent_handler(event:GoogleEvent):void
{
	try{
		
		this._modelInstance = ModelSingleton.getSingletonInstance();
		this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo = event.googleData;
		updating = false;
	
	}
	catch(thrownError:Error)
	{
		this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo = null;
	}	
}
 
private function scenarioProperties_changeEvent_handler(event:PropertyChangeEvent):void
{
	try
	{
		if (event.kind == ModelPropertyChangeEventKind.SET_GOOGLEMAP)
		{
			
			this._modelInstance = ModelSingleton.getSingletonInstance();
			//Añadida segunda parte del if
			if ( (ScenarioProperties(event.newValue).googleData != null) && 
			( (!updating) || ( (updating)&&(this._modelInstance.manetNodesTableCallableProxy.getManetNodeTableSize()> 0) ) ) ){
				
				if ((updating)&&(this._modelInstance.manetNodesTableCallableProxy.getManetNodeTableSize()> 0)){
					
					updating = false;
					
				}
				else{	
					
					updating = false;
					if (this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._location == ""){
						
						this.checkBox.selected = true;
						this.latitudeStepper.value = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._latitude;
						this.latitudeStepper.enabled = true;
						this.longitudeStepper.value = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._longitude;
						this.longitudeStepper.enabled = true;
						
						this.modeSelector.selectedItem = "Coordinates";
						this.locationCaption.text = "";
						this.locationCaption.enabled = false;
						this.zoomStepper.value = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._zoomLevel;
						
						if (this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._mapType == "Normal")
							this.mapTypeSelector.selectedItem = "Normal";
						else if (this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._mapType == "Satellite")
							this.mapTypeSelector.selectedItem = "Satellite";
						else if (this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._mapType == "Hybrid")
							this.mapTypeSelector.selectedItem = "Hybrid";
						else
							this.mapTypeSelector.selectedItem = "Physical";
						
						this.doubleClickModeSelector.enabled = true;
						if (this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._doubleClickMode == "Shift")
							this.doubleClickModeSelector.selectedItem = "Shift";
						else
							this.doubleClickModeSelector.selectedItem = "Set corner";
							
					}
				}
			}
		}
	}
	catch(thrownError:Error)
	{
		trace("Error at GooglePanel.as: " + thrownError.message);
	}
}
