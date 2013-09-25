// ActionScript file
import Classes.DisplayPropertiesSingleton;
import Classes.DisplayPropertyChangeEventKind;
import Classes.ModelPropertyChangeEventKind;
import Classes.ModelPropertyChangeEventType;
import Classes.ModelSingleton;
import Classes.TimePresentation;

import Entities.ScenarioProperties;

import flash.events.Event;
import flash.utils.Timer;

import mx.events.PropertyChangeEvent;
import mx.events.PropertyChangeEventKind;

private var _displayPropertiesSingletonInstance:DisplayPropertiesSingleton;
private var _modelSingletonInstance:ModelSingleton;

private var _sliderTimer:Timer;



private function creationComplete_handler(event:Event):void
{
	this._modelSingletonInstance = ModelSingleton.getSingletonInstance();
	this._displayPropertiesSingletonInstance = DisplayPropertiesSingleton.getSingletonInstance();
	
	this._modelSingletonInstance.addEventListener(ModelPropertyChangeEventType.MODEL_UNLOCKED_EVENT, modelUnlocked_handler);
	this._modelSingletonInstance.addEventListener(ModelPropertyChangeEventType.TRACES_MODEL_UNLOCKED_EVENT, tracesModelUnlocked_handler);
	this._modelSingletonInstance.addEventListener(ModelPropertyChangeEventType.SCENARIOPROPERTIES_CHANGE_EVENT, scenarioProperties_changeEvent_handler);
	this._displayPropertiesSingletonInstance.addEventListener(DisplayPropertyChangeEventKind.CLEAR_SCENARIO_EVENT, clearScenarioEvent_handler);
	this._displayPropertiesSingletonInstance.addEventListener(PropertyChangeEventKind.UPDATE, _displayPropertiesSingletonInstanceUpdateEvent_handler);
	
	if (this._modelSingletonInstance.scenarioPropertiesCallableProxy.initTime != null)
	{
		this.hslTime.minimum = this._modelSingletonInstance.scenarioPropertiesCallableProxy.initTime.time/1000;
		this.lblInitTime.text = TimePresentation.transformTimeToDigits2(this._modelSingletonInstance.scenarioPropertiesCallableProxy.initTime.time);
	}
	if (this._modelSingletonInstance.scenarioPropertiesCallableProxy.endTime != null)
	{	
		this.hslTime.maximum = this._modelSingletonInstance.scenarioPropertiesCallableProxy.endTime.time/1000;
		this.lblEndTime.text = TimePresentation.transformTimeToDigits2(this._modelSingletonInstance.scenarioPropertiesCallableProxy.endTime.time);
	}	
	
	this._sliderTimer = new Timer(1000, 0);
	this._sliderTimer.addEventListener(TimerEvent.TIMER, _sliderTimerHandler);
	
	//PRUEBAS
	this.teElapsedTime.addEventListener(Event.CHANGE, teElapsedTimeChange_handler);
}

private function sliderTimeChange_handler(event:Event):void
{
	this._displayPropertiesSingletonInstance = DisplayPropertiesSingleton.getSingletonInstance();
	this._modelSingletonInstance = ModelSingleton.getSingletonInstance();	

	
	this._displayPropertiesSingletonInstance.timePositionToShow = new Date(this.hslTime.value * 1000);
}


private function clearScenarioEvent_handler(event:Event):void
{
	this.clearPanel();
}

private function _displayPropertiesSingletonInstanceUpdateEvent_handler(event:PropertyChangeEvent):void
{
	if (event.kind == DisplayPropertyChangeEventKind.TIME_POSITION_TO_SHOW_CHANGE_EVENT)
	{
		this._displayPropertiesSingletonInstance = DisplayPropertiesSingleton.getSingletonInstance();
		var tempCurrentDate:Date = new Date(event.newValue);
		this.lblElapsedTime.text = TimePresentation.transformTimeToDigits2(tempCurrentDate.time);
		
		/*
		var timeObj:Object = new Object();
		timeObj.hour = tempCurrentDate.getHours();
		timeObj.minute = tempCurrentDate.getMinutes();
		timeObj.second = tempCurrentDate.getSeconds();
		this.teElapsedTime.timeValue = timeObj;
		*/
		if (tempCurrentDate.time == 0)
		{
			this.teElapsedTime.hour = 0;
			this.teElapsedTime.minute = 0;
			this.teElapsedTime.second = 0;			
		}
		else
		{
			this.teElapsedTime.hour = tempCurrentDate.getHours();
			this.teElapsedTime.minute = tempCurrentDate.getMinutes();
			this.teElapsedTime.second = tempCurrentDate.getSeconds();
		}	
		
		
		this.hslTime.value = this._displayPropertiesSingletonInstance.timePositionToShow.time/1000; 
	}	
}


private function scenarioProperties_changeEvent_handler(event:PropertyChangeEvent):void
{
	try
	{
		if (event.kind == ModelPropertyChangeEventKind.SET_SCENARIO_INIT_TIME)
		{
			if (ScenarioProperties(event.newValue).initTime != null)
			{
				this.hslTime.minimum = ScenarioProperties(event.newValue).initTime.time/1000;
				this.lblInitTime.text = TimePresentation.transformTimeToDigits2(ScenarioProperties(event.newValue).initTime.time);
			}
			else
			{
				this.hslTime.minimum = 0;
				this.lblInitTime.text = TimePresentation.transformTimeToDigits2(0);			
			}	
		}
		else if (event.kind == ModelPropertyChangeEventKind.SET_SCENARIO_END_TIME)
		{
			if (ScenarioProperties(event.newValue).endTime != null)	
			{	
				this.hslTime.maximum = ScenarioProperties(event.newValue).endTime.time/1000;
				this.lblEndTime.text = TimePresentation.transformTimeToDigits2(ScenarioProperties(event.newValue).endTime.time);
			}
			else
			{
				this.hslTime.maximum = 0;
				this.lblEndTime.text = TimePresentation.transformTimeToDigits2(0);			
			}	
		}
	}
	catch(thrownError:Error)
	{
		trace("Error al inicializar tiempos: " + thrownError.message);
	}
}

private function formatTimeSlider(value:Number):String
{
	return TimePresentation.transformTimeToDigits2(value*1000);
}

public function clearPanel():void
{
	/*
	this.lblEndTime.text = "0:00:00";
	this.lblInitTime.text = "0:00:00";
	this.hslTime.maximum = 0;
	this.hslTime.minimum = 0;
	*/
}

private function bibtnPlayClick_handler(event:Event, currentButtonState:String):void
{
	//si esta detenido esperando un play
	if (currentButtonState == "stateOne")
	{
		this._sliderTimer.start();
		this.bibtnPlay.currentState = "stateTwo";
		this.teElapsedTime.visible = false;
		this.lblElapsedTime.visible = true;
	}
	//si esta reproduciendo
	else
	{
		this._sliderTimer.stop();
		this.bibtnPlay.currentState = "stateOne";
		this.teElapsedTime.visible = true;
		this.lblElapsedTime.visible = false;
	}
}

private function _sliderTimerHandler(event:TimerEvent):void
{
	this._displayPropertiesSingletonInstance = DisplayPropertiesSingleton.getSingletonInstance();
	
	if (this.hslTime.value >= this.hslTime.maximum)
	{
		if (this._displayPropertiesSingletonInstance.loopMovement)
		{
			this.hslTime.value = this.hslTime.minimum;
		}
		else
		{
			this._sliderTimer.stop();
			this.bibtnPlay.currentState = "stateOne";
			this.teElapsedTime.visible = true;
			this.lblElapsedTime.visible = false;			
		}
	}
	else
	{
		this.hslTime.value = this.hslTime.value + 1;
	}	
}

//FR
private function tracesModelUnlocked_handler(event:Event):void
{
	var tempDateI:Date = this._modelSingletonInstance.scenarioPropertiesCallableProxy.initTime;
	if (tempDateI != null)
	{
		this.hslTime.minimum = tempDateI.time/1000;
		this.lblInitTime.text = TimePresentation.transformTimeToDigits2(tempDateI.time);
	}
	else
	{
		this.hslTime.minimum = 0;
		this.lblInitTime.text = TimePresentation.transformTimeToDigits(0);			
	}

	var tempDateF:Date = this._modelSingletonInstance.scenarioPropertiesCallableProxy.endTime;
	
	if (tempDateF != null)	
	{	
		this.hslTime.maximum = tempDateF.time/1000;
		this.lblEndTime.text = TimePresentation.transformTimeToDigits2(tempDateF.time);
	}
	else
	{
		this.hslTime.maximum = 0;
		this.lblEndTime.text = TimePresentation.transformTimeToDigits2(0);			
	}
}
//FR

private function modelUnlocked_handler(event:Event):void
{
	this._modelSingletonInstance = ModelSingleton.getSingletonInstance();//FR
	if ((this._modelSingletonInstance.scenarioPropertiesCallableProxy.connectedToInternet)||//FR
		(this._modelSingletonInstance.scenarioPropertiesCallableProxy.googleMapsInfo._visible == false)){//FR
	
			var tempDateI:Date = this._modelSingletonInstance.scenarioPropertiesCallableProxy.initTime;
			if (tempDateI != null)
			{
				this.hslTime.minimum = tempDateI.time/1000;
				this.lblInitTime.text = TimePresentation.transformTimeToDigits2(tempDateI.time);
			}
			else
			{
				this.hslTime.minimum = 0;
				this.lblInitTime.text = TimePresentation.transformTimeToDigits(0);			
			}
		
			var tempDateF:Date = this._modelSingletonInstance.scenarioPropertiesCallableProxy.endTime;
			
			if (tempDateF != null)	
			{	
				this.hslTime.maximum = tempDateF.time/1000;
				this.lblEndTime.text = TimePresentation.transformTimeToDigits2(tempDateF.time);
			}
			else
			{
				this.hslTime.maximum = 0;
				this.lblEndTime.text = TimePresentation.transformTimeToDigits2(0);			
			}
			
		}//FR			
			
}


private function teElapsedTimeChange_handler(event:Event):void
{

	this._modelSingletonInstance = ModelSingleton.getSingletonInstance();
	this._displayPropertiesSingletonInstance = DisplayPropertiesSingleton.getSingletonInstance();
	
	if (this._modelSingletonInstance.scenarioPropertiesCallableProxy.initTime != null)
	{
		var initTime:Date = new Date(this._modelSingletonInstance.scenarioPropertiesCallableProxy.initTime.time);
		var instantTimeObject2:Object = this.teElapsedTime.timeValue;
		
		initTime.setHours(instantTimeObject2.hour, instantTimeObject2.minute, instantTimeObject2.second);	
		this._displayPropertiesSingletonInstance.timePositionToShow = new Date(initTime.time);
	}		
}

