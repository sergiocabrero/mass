// ActionScript file
import Classes.DisplayPropertiesSingleton;
import Classes.DisplayPropertyChangeEventKind;
import Classes.ModelSingleton;

import Entities.Movement;
import Entities.NodeState;

import GraphicElements.GraphicCircle;

import flash.events.Event;

import mx.controls.Alert;

private var _modelInstance:ModelSingleton;
private var _displayPropertiesInstance:DisplayPropertiesSingleton;

public function clearPanel():void
{	
	this.nsXcoord.value = 0;
	this.nsYcoord.value = 0;
	this.nsNewXcoord.value = 0;
	this.nsNewYcoord.value = 0;
	this.teTimestampArrival.second = 0;
	this.teTimestampArrival.minute = 0;
	this.teTimestampArrival.hour = 0;
	this.teTimestampStart.second = 0;
	this.teTimestampStart.minute = 0;
	this.teTimestampStart.hour = 0;
	this.teNewTimestampArrival.second = 0;
	this.teNewTimestampArrival.minute = 0;
	this.teNewTimestampArrival.hour = 0;
	this.teNewTimestampStart.second = 0;
	this.teNewTimestampStart.minute = 0;
	this.teNewTimestampStart.hour = 0;
	this.cmbNodeId.selectedIndex = -1;	
}


private function creationComplete_handler(event:Event):void
{
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	this._displayPropertiesInstance.addEventListener(DisplayPropertyChangeEventKind.CLEAR_SCENARIO_EVENT, clearScenarioEvent_handler);
}

private function clearScenarioEvent_handler(event:Event):void
{
	this.clearPanel();
}

private function btnAddCheckpointClick_handler(event:Event):void
{
	//if (this.cmbNodeId.selectedIndex == -1 || this.cmbNodeId.selectedItem.toString())
	if (this.cmbNodeId.selectedIndex == -1)
	{
		Alert.show("Select a node from the list", DisplayPropertiesSingleton.APPLICATION_TITLE);
		return;
	}	
	
	this._modelInstance = ModelSingleton.getSingletonInstance();	
		
	var finalTime:Date = new Date(this._modelInstance.scenarioPropertiesCallableProxy.initTime.time);
	var instantTimeObject:Object = this.teNewTimestampStart.timeValue;

	finalTime.setHours(instantTimeObject.hour, instantTimeObject.minute, instantTimeObject.second);		
	
	
	var initTime:Date = new Date(this._modelInstance.scenarioPropertiesCallableProxy.initTime.time);
	var instantTimeObject2:Object = this.teNewTimestampArrival.timeValue;

	initTime.setHours(instantTimeObject2.hour, instantTimeObject2.minute, instantTimeObject2.second);		
	
	if (initTime.time > finalTime.time)
	{
		Alert.show("Insert an earlier arrival time than start time", DisplayPropertiesSingleton.APPLICATION_TITLE);
		return;
	}
	
	var scHeight:int = this._modelInstance.scenarioPropertiesCallableProxy.height;
	var scWidth:int = this._modelInstance.scenarioPropertiesCallableProxy.width;	
	
	if (this.nsNewXcoord.value > scWidth || this.nsNewYcoord.value > scHeight)
	{
		Alert.show("Insert point coordinates inside the scenario", DisplayPropertiesSingleton.APPLICATION_TITLE);
		return;		
	}
	
	if (this.cmbNodeId.selectedItem != null)
	{
		this._modelInstance = ModelSingleton.getSingletonInstance();
		
		//FR
		var nodeId:String = this.cmbNodeId.selectedItem.toString();
		var xPosition:int = this.nsNewXcoord.value;
		var yPosition:int = this.nsNewYcoord.value;
		var firstState:NodeState = this._modelInstance.manetNodesTableCallableProxy.getManetNodeFirstState(nodeId);
		var lastState:NodeState = this._modelInstance.manetNodesTableCallableProxy.getManetNodeLastState(nodeId);
		
		if (finalTime.time < firstState.timestamp.time){
			
			if((this._modelInstance.manetNodesTableCallableProxy.updateManetNodeState(nodeId,firstState.switchedOn,finalTime,
				xPosition,yPosition))==false){
					
					Alert.show("Invalid nodeState", DisplayPropertiesSingleton.APPLICATION_TITLE);
					return;	
				}
			
		}
		else if (initTime.time > lastState.timestamp.time){
			
			if((this._modelInstance.manetNodesTableCallableProxy.updateManetNodeState(nodeId,lastState.switchedOn,initTime))==false){
					
					Alert.show("Invalid nodeState", DisplayPropertiesSingleton.APPLICATION_TITLE);
					return;
				
				}
			
		}
		if (this._modelInstance.manetNodesTableCallableProxy.addManetNodeDoubleTimestampPositionCheckpoint(nodeId,
			initTime, finalTime, xPosition, yPosition) == false)	
		/*if (this._modelInstance.manetNodesTableCallableProxy.addManetNodeDoubleTimestampPositionCheckpoint(this.cmbNodeId.selectedItem.toString(),
			initTime, finalTime, this.nsNewXcoord.value, this.nsNewYcoord.value) == false)*/
		//FR
		{
			Alert.show("Invalid checkpoint", DisplayPropertiesSingleton.APPLICATION_TITLE);
			return;
		}	
						
	}	
}

private function btnEraseCheckpointClick_handler(event:MouseEvent):void
{
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	this._modelInstance = ModelSingleton.getSingletonInstance();
	if (this._displayPropertiesInstance.graphicCheckpointSelected)
	{
		var timeRequired:Date;
		if (this._displayPropertiesInstance.graphicCheckpointSelected.nextTrajectory)
		{
			timeRequired = this._displayPropertiesInstance.graphicCheckpointSelected.endTime;
		}
		else
		{
			timeRequired = this._displayPropertiesInstance.graphicCheckpointSelected.initTime;
		}
		this._modelInstance.manetNodesTableCallableProxy.removeManetNodeTimestampPositionCheckpoint(
			this._displayPropertiesInstance.graphicCheckpointSelected.manetNodeParentId,
			timeRequired); 		
	}
	else
	{
		Alert.show("Select a checkpoint in the scenario first", DisplayPropertiesSingleton.APPLICATION_TITLE);
	}
}

private function btnUpdateCheckpointClick_handler(event:Event):void
{
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	this._modelInstance = ModelSingleton.getSingletonInstance();
	
	if (this._displayPropertiesInstance.isGraphicCheckpointSelected())
	{	
		var initTime:Date = new Date(this._modelInstance.scenarioPropertiesCallableProxy.initTime.time);
		var instantTimeObject2:Object = this.teTimestampArrival.timeValue;
		initTime.setHours(instantTimeObject2.hour, instantTimeObject2.minute, instantTimeObject2.second);	

		
		var finalTime:Date = new Date(this._modelInstance.scenarioPropertiesCallableProxy.initTime.time);
		var instantTimeObject:Object = this.teTimestampStart.timeValue;
		finalTime.setHours(instantTimeObject.hour, instantTimeObject.minute, instantTimeObject.second);	


		if ((DisplayPropertiesSingleton.getSingletonInstance().getGraphicCheckpointSelected().initTime != null) &&
		(DisplayPropertiesSingleton.getSingletonInstance().getGraphicCheckpointSelected().endTime != null) &&
		(initTime > finalTime))
		{
			Alert.show("Insert to arrival time an earlier time than start time for the selected checkpoint", DisplayPropertiesSingleton.APPLICATION_TITLE);
			return;
		}

		var scHeight:int = this._modelInstance.scenarioPropertiesCallableProxy.height;
		var scWidth:int = this._modelInstance.scenarioPropertiesCallableProxy.width;	
		
		if (this.nsXcoord.value > scWidth || this.nsYcoord.value > scHeight)
		{
			Alert.show("Insert point coordinates inside the scenario", DisplayPropertiesSingleton.APPLICATION_TITLE);
			return;		
		}

		if ((this._modelInstance.scenarioPropertiesCallableProxy.width * this._displayPropertiesInstance.scaleFactor < this.nsXcoord.value) ||
			(this.nsXcoord.value < 0) ||
			(this._modelInstance.scenarioPropertiesCallableProxy.height * this._displayPropertiesInstance.scaleFactor < this.nsYcoord.value) ||
			(this.nsYcoord.value < 0))
		{
			Alert.show("The coordinates introduced are out of the scenario bounds");
			return;	
		}

		
		//FR
		var nodeId:String = GraphicCircle(this._displayPropertiesInstance.graphicCheckpointSelected).manetNodeParentId;
		var firstState:NodeState = this._modelInstance.manetNodesTableCallableProxy.getManetNodeFirstState(nodeId);
		var lastState:NodeState = this._modelInstance.manetNodesTableCallableProxy.getManetNodeLastState(nodeId);
		var size:int = this._modelInstance.manetNodesTableCallableProxy.getManetNodeStatesSize(nodeId);
		var firstMovement:Movement = this._modelInstance.manetNodesTableCallableProxy.getManetNodeFirstMovement(nodeId);
		var lastMovement:Movement = this._modelInstance.manetNodesTableCallableProxy.getManetNodeLastMovement(nodeId);
		var xPosition:int = this.nsXcoord.value;
		var yPosition:int = this.nsYcoord.value;
		 
		if ((finalTime.time <= firstState.timestamp.time)&&(finalTime.time>=this._modelInstance.scenarioPropertiesCallableProxy.initTime.time)){
			if ((this._modelInstance.manetNodesTableCallableProxy.updateManetNodeState(nodeId,true,finalTime,
			xPosition,yPosition))==false){
				
				Alert.show("Invalid nodeState", DisplayPropertiesSingleton.APPLICATION_TITLE);
				return;
				
			}
		}
		else if ((finalTime.time > firstState.timestamp.time)&&(finalTime.time<=firstMovement.toTimestampPositionCheckpoint.pointTime.time)){
			if ((this._modelInstance.manetNodesTableCallableProxy.updateManetNodeState(nodeId,true,firstState.timestamp,
			xPosition,yPosition))==false){
				
				Alert.show("Invalid nodeState", DisplayPropertiesSingleton.APPLICATION_TITLE);
				return;
				
			}
		}
		else if ((initTime.time > lastState.timestamp.time)&&(initTime.time>=lastMovement.fromTimestampPositionCheckpoint.pointTime.time)){
			if ((this._modelInstance.manetNodesTableCallableProxy.updateManetNodeState(nodeId,false,initTime))==false){
					
					Alert.show("Invalid nodeState", DisplayPropertiesSingleton.APPLICATION_TITLE);
					return;
					
				}
		}
		else if ((initTime.time <= lastState.timestamp.time)&&(initTime.time >=this._modelInstance.scenarioPropertiesCallableProxy.initTime.time)){
			if ((this._modelInstance.manetNodesTableCallableProxy.updateManetNodeState(nodeId,false,lastState.timestamp))==false){
					
					Alert.show("Invalid nodeState", DisplayPropertiesSingleton.APPLICATION_TITLE);
					return;
					
				}
		}
		firstState = this._modelInstance.manetNodesTableCallableProxy.getManetNodeFirstState(nodeId);
		lastState = this._modelInstance.manetNodesTableCallableProxy.getManetNodeLastState(nodeId);
		//FR	
		if (this._modelInstance.manetNodesTableCallableProxy.updateManetNodeTimestampPositionCheckpoint(
			GraphicCircle(this._displayPropertiesInstance.graphicCheckpointSelected).manetNodeParentId, 
			GraphicCircle(this._displayPropertiesInstance.graphicCheckpointSelected).initTime,
			GraphicCircle(this._displayPropertiesInstance.graphicCheckpointSelected).endTime,
			initTime,
			finalTime,
			/*this.nsXcoord.value*/xPosition,
			/*this.nsYcoord.value*/yPosition,
			false) == false)
		{
			Alert.show("Invalid checkpoint", DisplayPropertiesSingleton.APPLICATION_TITLE);
			return;
		}			
	}
	else
	{
		Alert.show("Select a checkpoint in the scenario to update", DisplayPropertiesSingleton.APPLICATION_TITLE);
		return;		
	}	
}