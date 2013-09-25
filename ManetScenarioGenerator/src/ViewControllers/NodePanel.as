// ActionScript file
import Classes.DisplayPropertiesSingleton;
import Classes.DisplayPropertyChangeEventKind;
import Classes.ModelSingleton;

import Entities.ManetNode;

import GraphicElements.GraphicCircle;

import flash.events.Event;

import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.events.DataGridEvent;
import mx.events.PropertyChangeEvent;
import mx.events.PropertyChangeEventKind;

private var _displayPropertiesInstance:DisplayPropertiesSingleton;
private var _modelInstance:ModelSingleton;

private function btnEraseNodeClick_handler(event:MouseEvent):void
{
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	this._modelInstance = ModelSingleton.getSingletonInstance();
	if (this._displayPropertiesInstance.graphicCheckpointSelected)
	{	
		this._modelInstance.manetNodesTableCallableProxy.removeManetNode(this._displayPropertiesInstance.graphicCheckpointSelected.manetNodeParentId);
	}	
}

private function creationComplete_handler(event:Event):void
{
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	this._displayPropertiesInstance.addEventListener(PropertyChangeEventKind.UPDATE, displayProperties_changeEvent_handler);
	this._displayPropertiesInstance.addEventListener(DisplayPropertyChangeEventKind.CLEAR_SCENARIO_EVENT, clearScenarioEvent_handler);
	//this.mdgNodesList.dispatchEvent(new DataGridEvent(DataGridEvent.HEADER_RELEASE, false, true, 0, null, 0, null, null, 0));
}



public function clearPanel():void
{
	//this.mdgNodesList.dataProvider = null;
	this.nsXcoord.value = 0;
	this.nsYcoord.value = 0;
	this.nsAddRange.value = 0;
	this.nsUpdateRange.value = 0;
	this.teTimestamp.hour = 0;
	this.teTimestamp.minute = 0;
	this.teTimestamp.second = 0;
	this.txtNewNodeId.text = "";
	this.cpColour.selectedColor = 0xe8350b;	
}

private function clearScenarioEvent_handler(event:Event):void
{
	this.clearPanel();
}

internal function cpManetNodeChange_handler(event:Event, nodeId:String, value:uint):void
{
	if (this.mdgNodesList.selectedItem != null)
	{
		DisplayPropertiesSingleton.getSingletonInstance().dispatchColourUserRequestNodeDisplayChange(nodeId, value);
	}	
}


internal function chkVisibilityChange_handler(event:Event, nodeId:String, selected:Boolean):void
{
	if (this.mdgNodesList.selectedItem != null)
	{
		DisplayPropertiesSingleton.getSingletonInstance().dispatchVisibilityUserRequestNodeDisplayChange(nodeId, selected);
	}		
}

internal function chkVisibilityHeaderChange_handler(event:Event, selected:Boolean):void
{
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	this._modelInstance = ModelSingleton.getSingletonInstance();
	var arrayIdNodes:Array = this._modelInstance.manetNodesTableCallableProxy.getIdManetNodesArray();
	for (var i:int = 0; i < arrayIdNodes.length; i++) 
	{
		this._displayPropertiesInstance.dispatchVisibilityUserRequestNodeDisplayChange(arrayIdNodes[i], selected);
	}	
}

internal function chkRangeVisibilityChange_handler(event:Event, nodeId:String, selected:Boolean):void
{
	if (this.mdgNodesList.selectedItem != null)
	{
		DisplayPropertiesSingleton.getSingletonInstance().dispatchRangeVisibilityUserRequestNodeDisplayChange(nodeId, selected);
	}		
}

internal function chkRangeVisibilityHeaderChange_handler(event:Event, selected:Boolean):void
{
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	this._modelInstance = ModelSingleton.getSingletonInstance();
	var arrayIdNodes:Array = this._modelInstance.manetNodesTableCallableProxy.getIdManetNodesArray();
	for (var i:int = 0; i < arrayIdNodes.length; i++) 
	{
		this._displayPropertiesInstance.dispatchRangeVisibilityUserRequestNodeDisplayChange(arrayIdNodes[i], selected);
	}	
}

internal function txtNodeIdFocusOut_handler(event:Event, nodeId:String, text:String):void
{
	if (nodeId != text)
	{
		this._modelInstance = ModelSingleton.getSingletonInstance();
		if(!this._modelInstance.manetNodesTableCallableProxy.setManetNodeId(nodeId, text)){
			
			Alert.show("Error while updating node name", DisplayPropertiesSingleton.APPLICATION_TITLE);
		
		}
	}	
	
}

private function mdgNodesListValueCommit_handler(event:Event):void
{
	if(this.mdgNodesList.selectedItem != null)
	{
		this._modelInstance = ModelSingleton.getSingletonInstance();
		this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
		
		this.nsUpdateRange.value = this._modelInstance.manetNodesTableCallableProxy.getManetNodeRange(this.mdgNodesList.selectedItem.node_id);
		//Si hay checkpoint seleccionado y no pertenece al nodo seleccionado en la tabla
		if (this._displayPropertiesInstance.getGraphicCheckpointSelected() != null && 
			GraphicCircle(this._displayPropertiesInstance.getGraphicCheckpointSelected()).manetNodeParentId != this.mdgNodesList.selectedItem.node_id)
		{
			this._displayPropertiesInstance.graphicCheckpointSelected = null;	
		}
	}	
}


private function btnUpdateNodeClick_handler(event:Event):void
{
	if (this.mdgNodesList.selectedItem != null)
	{
		this._modelInstance = ModelSingleton.getSingletonInstance();
		if (!this._modelInstance.manetNodesTableCallableProxy.setManetNodeRange(this.mdgNodesList.selectedItem.node_id, this.nsUpdateRange.value))
		{
			Alert.show("Error while updating node range", DisplayPropertiesSingleton.APPLICATION_TITLE);
		}
	}	
}

private function btnUpdateAllNodesClick_handler(event:Event):void
{
	try
	{
		this._modelInstance = ModelSingleton.getSingletonInstance();
		if (this._modelInstance.manetNodesTableCallableProxy.getManetNodeTableSize() == 0)
		{
			Alert.show("There are no nodes to update its range", DisplayPropertiesSingleton.APPLICATION_TITLE);
			return;
		}
		else
		{
			Alert.show("Are you sure to update the ranges for all manet nodes?", DisplayPropertiesSingleton.APPLICATION_TITLE, (Alert.YES | Alert.CANCEL), null, updateAllNodesRange);
				function updateAllNodesRange(event:CloseEvent):void{
					if(event.detail == Alert.YES)
					{
	
						_modelInstance = ModelSingleton.getSingletonInstance();
						var arrayIdNodes:Array = _modelInstance.manetNodesTableCallableProxy.getIdManetNodesArray();
						for (var i:int = 0; i < arrayIdNodes.length; i++) 
						{
							_modelInstance.manetNodesTableCallableProxy.setManetNodeRange(arrayIdNodes[i], nsUpdateRange.value);
						}
						
						
					}
				}	
		}
	}
	catch(thrownError:Error)
	{
		
	}	
}




private function btnAddNodeClick_handler(event:Event):void
{
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	this._modelInstance = ModelSingleton.getSingletonInstance();
	var newManetNode:ManetNode;
	var newNodeId:String;
	
	var scHeight:int = this._modelInstance.scenarioPropertiesCallableProxy.height;
	var scWidth:int = this._modelInstance.scenarioPropertiesCallableProxy.width;	
	
	if (this.nsXcoord.value > scWidth || this.nsYcoord.value > scHeight)
	{
		Alert.show("Insert point coordinates inside the scenario", DisplayPropertiesSingleton.APPLICATION_TITLE);
		return;		
	}	
	
	if (this.txtNewNodeId.text == "")
	{
		newManetNode = new ManetNode("", this.nsAddRange.value, this.cpColour.selectedColor, "", 0, "");
		newNodeId = this._modelInstance.manetNodesTableCallableProxy.addManetNode(newManetNode, true);
	}
	else
	{
		newManetNode = new ManetNode("", this.nsAddRange.value, this.cpColour.selectedColor, "", 0, this.txtNewNodeId.text);
		newNodeId = this._modelInstance.manetNodesTableCallableProxy.addManetNode(newManetNode, false);
	}

	
	if (newNodeId == "-1")
	{
		Alert.show("Error adding the new node to scenario", DisplayPropertiesSingleton.APPLICATION_TITLE);
		return;
	}
	
	this._displayPropertiesInstance.setManetNodeColour(newNodeId, this.cpColour.selectedColor);

	
	var instantTimeObject:Object = this.teTimestamp.timeValue;
	
	var finalTime:Date;
	//initTime y endTime nulos
	if (this._modelInstance.scenarioPropertiesCallableProxy.initTime == null && this._modelInstance.scenarioPropertiesCallableProxy.endTime == null)
	{
		//Si no hay initTime se crea un new Date
		finalTime = new Date();
		finalTime.setHours(instantTimeObject.hour, instantTimeObject.minute, instantTimeObject.second);	
		
	}
	//initTime y endTime existen
	else if(this._modelInstance.scenarioPropertiesCallableProxy.initTime != null && this._modelInstance.scenarioPropertiesCallableProxy.endTime != null)
	{
		//Nos quedamos con la fecha del initTime para establecer el finalTime 
		finalTime = new Date(this._modelInstance.scenarioPropertiesCallableProxy.initTime.time);
		finalTime.setHours(instantTimeObject.hour, instantTimeObject.minute, instantTimeObject.second);			
	}
	//initTime existe, endTime nulo
	else if(this._modelInstance.scenarioPropertiesCallableProxy.initTime != null && this._modelInstance.scenarioPropertiesCallableProxy.endTime == null)
	{
		//Nos quedamos con la fecha del initTime para establecer el finalTime 
		finalTime = new Date(this._modelInstance.scenarioPropertiesCallableProxy.initTime.time);
		finalTime.setHours(instantTimeObject.hour, instantTimeObject.minute, instantTimeObject.second);	
				
	}
	//initTime nulo, endTime existe
	else
	{
		//Si no hay initTime se crea un new Date
		finalTime = new Date();
		finalTime.setHours(instantTimeObject.hour, instantTimeObject.minute, instantTimeObject.second);	
	}
	
	if (!this._modelInstance.manetNodesTableCallableProxy.addManetNodeDoubleTimestampPositionCheckpoint(newNodeId, finalTime, finalTime, this.nsXcoord.value, this.nsYcoord.value))
	{
		Alert.show("Error adding the initial checkpoint", DisplayPropertiesSingleton.APPLICATION_TITLE);
	} 
	//FR
	if (!this._modelInstance.manetNodesTableCallableProxy.setManetNodeState(newNodeId,finalTime,true,this.nsXcoord.value,this.nsYcoord.value))
	{
		Alert.show("Error setting the initial nodeState", DisplayPropertiesSingleton.APPLICATION_TITLE);
	}
	if (!this._modelInstance.manetNodesTableCallableProxy.setManetNodeState(newNodeId,finalTime,false))
	{	
		Alert.show("Error setting the final nodeState", DisplayPropertiesSingleton.APPLICATION_TITLE);
	}
	//FR
}


private function displayProperties_changeEvent_handler(event:PropertyChangeEvent):void
{
	try
	{
		if (event.kind == DisplayPropertyChangeEventKind.NEW_GRAPHIC_CHECKPOINT_SELECTED_EVENT)
		{
			for (var i:String in this.mdgNodesList.dataProvider)
			{
				if (this.mdgNodesList.dataProvider[i].node_id.toString() == GraphicCircle(event.newValue).manetNodeParentId)
				{
					this.mdgNodesList.selectedItem = this.mdgNodesList.dataProvider[i];
					return; 
				}
			}
		}
	}
	catch(thownError:Error)
	{
		if (this.mdgNodesList != null)
		{
			this.mdgNodesList.selectedIndex = -1;
		}
	}
}

