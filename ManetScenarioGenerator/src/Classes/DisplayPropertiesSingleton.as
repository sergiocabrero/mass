package Classes
{
	import GraphicElements.GraphicCircle;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	
	

	public class DisplayPropertiesSingleton extends EventDispatcher
	{
		public static var APPLICATION_TITLE:String = "MASS Editor";
		protected static var _instance:DisplayPropertiesSingleton;
		protected var _scaleFactor:Number = 1;
		protected var _backgroundImageVisible:Boolean = true;
		protected var _gridVisible:Boolean = true;
		protected var _backgroundWorkAreaColour:uint = 0xffffff;
		protected var _backgroundImageHeight:Number = 0;
		protected var _backgroundImageWidth:Number = 0;
		protected var _isDraggingCheckpoint:Boolean = false;
		protected var _nodeColours:Object = [0xc71bec, 0xac0be8, 0x9279d1, 0x4f0be8, 0x0b4fe8, 0x5d6eb7, 0x1bbdec, 0x1becaa,
			0x0be98d, 0x0be80b, 0x73ec1b, 0xace80b, 0xccec1b, 0xe8c10b, 0xec911b, 0xa1663f, 0x653f25, 0x9b391b, 0xe8350b, 0xec1b6a];
		protected var _timePositionToShow:Date;
		protected var _rangeAlpha:Number = 0.3;
		protected var _checkpointSize:Number = 2.5;
		protected var _loopMovement:Boolean = false;
		protected var _nodeIconPath:String = null;			
		[Bindable]
		protected var _graphicCheckpointSelected:GraphicCircle;
		protected var _displayManetNodesProperties:DisplayedManetNodesProperties;

		[Embed("../Images/cursor_win_hand_drag.png")]
		protected var _customCursorHandDrag:Class;
		
		[Embed("../Images/cursor_win_hand.png")]
		protected var _customCursorHand:Class; 
		
		protected var _mouseScenarioXcoord:Number;
		protected var _mouseScenarioYcoord:Number;
				
		public function DisplayPropertiesSingleton(target:IEventDispatcher=null)
		{
			super(target);
			this._displayManetNodesProperties = new DisplayedManetNodesProperties();
		}

	    public static function getSingletonInstance():DisplayPropertiesSingleton
	    {
	    	if (DisplayPropertiesSingleton._instance == null)
			{
				DisplayPropertiesSingleton._instance = new DisplayPropertiesSingleton();
			}
			return _instance;
		}
		
		
		
		
		
		//#################  NODE DRAGGING, SELECTING AND MOUSE POSITION  #######################
		[Bindable]
		public function get mouseScenarioXcoord():Number
		{
			return this._mouseScenarioXcoord;
		}
		
		public function set mouseScenarioXcoord(newCoord:Number):void
		{
			if (this._mouseScenarioXcoord != newCoord)
			{
				var oldValue:Number = this._mouseScenarioXcoord;
				this._mouseScenarioXcoord = newCoord;
				dispatchEvent(new PropertyChangeEvent(PropertyChangeEventKind.UPDATE, false, false, DisplayPropertyChangeEventKind.MOUSE_XCOORD_SCENARIO_CHANGE,
					"mouseScenarioXcoord", oldValue, this._mouseScenarioXcoord));
			}					
		}

		[Bindable]
		public function get mouseScenarioYcoord():Number
		{
			return this._mouseScenarioYcoord;
		}
		
		public function set mouseScenarioYcoord(newCoord:Number):void
		{
			if (this._mouseScenarioYcoord != newCoord)
			{			
				var oldValue:Number = this._mouseScenarioYcoord;
				this._mouseScenarioYcoord = newCoord;
				dispatchEvent(new PropertyChangeEvent(PropertyChangeEventKind.UPDATE, false, false, DisplayPropertyChangeEventKind.MOUSE_YCOORD_SCENARIO_CHANGE,
					"mouseScenarioYcoord", oldValue, this._mouseScenarioYcoord));
			}					
		}		
		
		public function get isDraggingCheckpoint():Boolean
		{
			return this._isDraggingCheckpoint;
		}
		
		public function set isDraggingCheckpoint(newState:Boolean):void
		{
			if (newState != this._isDraggingCheckpoint)
			{
				var oldValue:Boolean = this._isDraggingCheckpoint;
				this._isDraggingCheckpoint = newState;
				dispatchEvent(new PropertyChangeEvent(PropertyChangeEventKind.UPDATE, false, false, DisplayPropertyChangeEventKind.IS_DRAGGING_CHECKPOINT_CHANGE_EVENT,
					"isDraggingCheckpoint", oldValue, this._isDraggingCheckpoint));
			}				
		}
		
					
		public function set graphicCheckpointSelected(newCheckpointSelected:GraphicCircle):void
		{
			if (newCheckpointSelected != this._graphicCheckpointSelected)
			{
				var oldCheckpoint:GraphicCircle = this._graphicCheckpointSelected;
				this._graphicCheckpointSelected = newCheckpointSelected;
				dispatchEvent(new PropertyChangeEvent(PropertyChangeEventKind.UPDATE, false, false, DisplayPropertyChangeEventKind.NEW_GRAPHIC_CHECKPOINT_SELECTED_EVENT, 
					"graphicCheckpointSelected", oldCheckpoint, this._graphicCheckpointSelected));
					
				dispatchEvent(new PropertyChangeEvent(DisplayPropertyChangeEventKind.NEW_GRAPHIC_CHECKPOINT_SELECTED_EVENT));				
			}
		}
		
		[Bindable (event = "NewGraphicCheckpointSelectedEvent")]
		public function get graphicCheckpointSelected():GraphicCircle
		{
			return this._graphicCheckpointSelected;
		}
		
		[Bindable (event = "NewGraphicCheckpointSelectedEvent")]
		public function getGraphicCheckpointSelected():GraphicCircle
		{
			return this._graphicCheckpointSelected;
		}

		[Bindable (event = "NewGraphicCheckpointSelectedEvent")]
		public function isGraphicCheckpointSelected():Boolean
		{
			if (this._graphicCheckpointSelected == null)
			{
				return false;
			}
			else
			{
				return true;
			}
		}				
		//###########################################################3
		
		
		
		





		//###################  MANET NODES LIST PROPERTIES  #########################
		public function dispatchVisibilityUserRequestNodeDisplayChange(nodeId:String, newValue:Boolean):void
		{
			var paramEv:ParamEvent = new ParamEvent(DisplayPropertyChangeEventKind.USER_REQUEST_DISPLAY_NODE_PROPERTY_CHANGE);
			paramEv.params.nodeId = nodeId;
			paramEv.params.propertyName = "node_trajectory_visibility";
			paramEv.params.value = newValue;
			dispatchEvent(paramEv);
		}
		
		public function dispatchRangeVisibilityUserRequestNodeDisplayChange(nodeId:String, newValue:Boolean):void
		{
			var paramEv:ParamEvent = new ParamEvent(DisplayPropertyChangeEventKind.USER_REQUEST_DISPLAY_NODE_PROPERTY_CHANGE);
			paramEv.params.nodeId = nodeId;
			paramEv.params.propertyName = "node_range_visibility";
			paramEv.params.value = newValue;
			dispatchEvent(paramEv);
		}		
		
		public function dispatchColourUserRequestNodeDisplayChange(nodeId:String, newValue:uint):void
		{
			var paramEv:ParamEvent = new ParamEvent(DisplayPropertyChangeEventKind.USER_REQUEST_DISPLAY_NODE_PROPERTY_CHANGE);
			paramEv.params.nodeId = nodeId;
			paramEv.params.propertyName = "node_colour";
			paramEv.params.value = newValue;
			dispatchEvent(paramEv);
		}	
	
		public function getDisplayedManetNodesProperties():DisplayedManetNodesProperties
		{
			return this._displayManetNodesProperties.getDisplayedManetNodesProperties();
		}


		[Bindable (event = "DisplayedManetNodePropertyChanged")]
		public function getManetNodesIdAC():ArrayCollection
		{
			var manetNodesIdAC:ArrayCollection = new ArrayCollection();
			var manetNodesPropertiesAC:ArrayCollection = this._displayManetNodesProperties.getDisplayedManetNodesPropertiesAC();
			for (var i:String in manetNodesPropertiesAC)
			{
				manetNodesIdAC.addItem(manetNodesPropertiesAC[i].node_id);
			}
			return manetNodesIdAC;	
		}		


		[Bindable (event = "DisplayedManetNodePropertyChanged")]
		public function getDisplayedManetNodesPropertiesAC():ArrayCollection
		{
			return this._displayManetNodesProperties.getDisplayedManetNodesPropertiesAC();
		}
		
		public function setDisplayedManetNodesPropertiesAC(newAC:ArrayCollection):void
		{
			this._displayManetNodesProperties.setDisplayedManetNodesPropertiesAC(newAC);
			dispatchEvent(new PropertyChangeEvent("DisplayedManetNodePropertyChanged"));
		}
		
		public function addDisplayedManetNodePropertiesItem(nodeId:String, nodeColour:uint, nodeVisibility:Boolean, rangeVisibility:Boolean, canvasReference:Canvas, canvasTimeposReference:Canvas):void
		{
			//var tempObj:Object = {node_id:nodeId, node_colour:nodeColour, node_trajectory_visibility:nodeVisibility, canvas_reference:canvasReference};
			this._displayManetNodesProperties.addDisplayedManetNodePropertiesItem(nodeId, nodeColour, nodeVisibility, rangeVisibility, canvasReference, canvasTimeposReference);
			dispatchEvent(new PropertyChangeEvent("DisplayedManetNodePropertyChanged"));
		}
		
		
		public function clearDisplayedAllManetNodesProperties():Boolean
		{
			var returnedValue:Boolean = this._displayManetNodesProperties.clearDisplayedAllManetNodesProperties();
			dispatchEvent(new PropertyChangeEvent("DisplayedManetNodePropertyChanged"));
			return returnedValue;
		}
		
		public function clearDisplayedManetNodeProperties(nodeId:String):Boolean
		{
			var returnedValue:Boolean = this._displayManetNodesProperties.clearDisplayedManetNodeProperties(nodeId);
			if (returnedValue)
			{
				dispatchEvent(new PropertyChangeEvent("DisplayedManetNodePropertyChanged"));
			}
			return returnedValue;
						
		}

		public function setManetNodeId(nodeId:String, newNodeId:String):Boolean
		{
			var retValue:Boolean = this._displayManetNodesProperties.setManetNodeId(nodeId, newNodeId);
			if (retValue)
			{
				dispatchEvent(new PropertyChangeEvent("DisplayedManetNodePropertyChanged"));
			}	
			return retValue;
		}

		public function setManetNodeTrajectoryVisibility(nodeId:String, isVisible:Boolean):Boolean
		{
			var retValue:Boolean = this._displayManetNodesProperties.setManetNodeTrajectoryVisibility(nodeId, isVisible);	
			if (retValue)
			{
				dispatchEvent(new PropertyChangeEvent("DisplayedManetNodePropertyChanged"));
			}	
			return retValue;				
		}
		
		public function getManetNodeTrajectoryVisibility(nodeId:String):Boolean
		{
			return this._displayManetNodesProperties.getManetNodeTrajectoryVisibility(nodeId);				
		}
		
		public function setManetNodeColour(nodeId:String, nodeColour:uint):Boolean
		{
			var retValue:Boolean = this._displayManetNodesProperties.setManetNodeColour(nodeId, nodeColour);
			if (retValue)
			{
				dispatchEvent(new PropertyChangeEvent("DisplayedManetNodePropertyChanged"));
			}	
			return retValue;							
		}
		
		public function getManetNodeColour(nodeId:String):uint
		{
			return this._displayManetNodesProperties.getManetNodeColour(nodeId);				
		}
		
		public function getUsedColoursArray():Array
		{
			return this._displayManetNodesProperties.getUsedColoursArray();
		}	
		
		public function setManetNodeCanvasReference(nodeId:String, canvasRef:Canvas):Boolean
		{
			var retValue:Boolean = this._displayManetNodesProperties.setManetNodeCanvasReference(nodeId, canvasRef);	
			if (retValue)
			{
				dispatchEvent(new PropertyChangeEvent("DisplayedManetNodePropertyChanged"));
			}	
			return retValue;					
		}
		
		public function getManetNodeCanvasReference(nodeId:String):Canvas
		{
			return this._displayManetNodesProperties.getManetNodeCanvasReference(nodeId);			
		}
		
		public function setManetNodeCanvasTimePosReference(nodeId:String, canvasRef:Canvas):Boolean
		{
			var retValue:Boolean = this._displayManetNodesProperties.setManetNodeCanvasTimePosReference(nodeId, canvasRef);
			if (retValue)
			{
				dispatchEvent(new PropertyChangeEvent("DisplayedManetNodePropertyChanged"));
			}	
			return retValue;			
		}
		
		public function getManetNodeCanvasTimePosReference(nodeId:String):Canvas
		{
			return this._displayManetNodesProperties.getManetNodeCanvasTimePosReference(nodeId);
		}
		
		public function setManetNodeCanvasTimePosReferenceVisibilityRange(nodeId:String, isVisible:Boolean):Boolean
		{
			var retValue:Boolean = this._displayManetNodesProperties.setManetNodeCanvasTimePosReferenceVisibilityRange(nodeId, isVisible);
			if (retValue)
			{
				dispatchEvent(new PropertyChangeEvent("DisplayedManetNodePropertyChanged"));
			}	
			return retValue;					
		}
		
		public function	getManetNodeCanvasTimePosReferenceVisibilityRange(nodeId:String):Boolean
		{
			return this._displayManetNodesProperties.getManetNodeCanvasTimePosReferenceVisibilityRange(nodeId);
		}	
		//#############################################################
		
		
	
	
		




		//#################### GENERAL APP DISPLAY SETTINGS #####################
		[Bindable]
		public function get customCursorHandDrag():Class
		{
			return this._customCursorHandDrag;
		}
		
		public function set customCursorHandDrag(newCursor:Class):void
		{
			
		}

		[Bindable]
		public function get customCursorHand():Class
		{
			return this._customCursorHand;
		}
		
		public function set customCursorHand(newCursor:Class):void
		{
			
		}		
		
		
		[Bindable]
		public function get rangeAlpha():Number
		{
			return this._rangeAlpha;	
		}	
		
		public function set rangeAlpha(newAlpha:Number):void
		{
			if ((newAlpha >= 0 && newAlpha <= 1) && newAlpha != this._rangeAlpha)
			{
				var oldValue:Number = this._rangeAlpha;
				this._rangeAlpha = newAlpha;
				dispatchEvent(new PropertyChangeEvent(PropertyChangeEventKind.UPDATE, false, false, DisplayPropertyChangeEventKind.RANGE_ALPHA_CHANGE, 
					"rangeAlpha", oldValue, this._rangeAlpha));				
			}
		}	
		
		[Bindable]
		public function get checkpointSize():Number
		{
			return this._checkpointSize;
		}
		
		public function set checkpointSize(newSize:Number):void
		{
			if ((newSize >= 1.5 && newSize <= 6) && newSize != this._checkpointSize)
			{
				var oldValue:Number = this._checkpointSize;
				this._checkpointSize = newSize;
				dispatchEvent(new PropertyChangeEvent(PropertyChangeEventKind.UPDATE, false, false, DisplayPropertyChangeEventKind.CHECKPOINT_SIZE_CHANGE, 
					"checkpointSize", oldValue, this._checkpointSize));					
			}
		}
		
		[Bindable]
		public function get loopMovement():Boolean
		{
			return this._loopMovement;
		}
		
		public function set loopMovement(loop:Boolean):void
		{
			if (loop != this._loopMovement)
			{
				this._loopMovement = loop;
			}
		}
		//#######################################################################
		
		
		
		
		

		
		
		
		
		
		
		//####################  SCENARIO PROPERTIES  #####################
		public function getNodeColoursObject():Object
		{
			return this._nodeColours;	
		}
		
		public function get backgroundImageWidth():Number
		{
			return this._backgroundImageWidth;
		}		

		public function set backgroundImageHeight(newHeight:Number):void
		{
			if ((newHeight >= 0) && (newHeight != this._backgroundImageHeight))
			{
				var oldValue:Number = this._backgroundImageHeight;
				this._backgroundImageHeight = newHeight;
				dispatchEvent(new PropertyChangeEvent(PropertyChangeEventKind.UPDATE, false, false, DisplayPropertyChangeEventKind.BACKGROUND_IMAGE_DIMENSIONS_CHANGE_EVENT, 
					"backgroundImageHeight", oldValue, this._backgroundImageHeight));						
			}
		}
		
		public function get backgroundImageHeight():Number
		{
			return this._backgroundImageHeight;
		}
		
		public function get backgroundImageVisible():Boolean
		{
			return this._backgroundImageVisible;
		}
		
		public function set backgroundImageVisible(newState:Boolean):void
		{
			if (newState != this._backgroundImageVisible)
			{
				var oldValue:Boolean = this._backgroundImageVisible;
				this._backgroundImageVisible = newState;
				dispatchEvent(new PropertyChangeEvent(PropertyChangeEventKind.UPDATE, false, false, DisplayPropertyChangeEventKind.BACKGROUND_IMAGE_VISIBLE_CHANGE_EVENT,
					"backgroundImageVisible", oldValue, this._backgroundImageVisible));
			}	
		}

		[Bindable (event="backgroundWorkAreaColour")]
		public function getBackgroundWorkAreaColour():uint
		{
			return this._backgroundWorkAreaColour;
		}
		
		
		public function setBackgroundWorkAreaColour(newColour:uint):void
		{
			if (newColour != this._backgroundWorkAreaColour)
			{
				var oldValue:uint = this._backgroundWorkAreaColour;
				this._backgroundWorkAreaColour = newColour;
				dispatchEvent(new PropertyChangeEvent(PropertyChangeEventKind.UPDATE, false, false, DisplayPropertyChangeEventKind.BACKGROUND_WORK_AREA_COLOUR_CHANGE_EVENT,
					"backgroundWorkAreaColour", oldValue, this._backgroundWorkAreaColour));	
				dispatchEvent(new PropertyChangeEvent("backgroundWorkAreaColour"));				
			}
		}


		public function get gridVisible():Boolean
		{
			return this._backgroundImageVisible;
		}
		
		public function set gridVisible(newState:Boolean):void
		{
			if (newState != this._gridVisible)
			{
				var oldValue:Boolean = this._gridVisible;
				this._gridVisible = newState;
				dispatchEvent(new PropertyChangeEvent(PropertyChangeEventKind.UPDATE, false, false, DisplayPropertyChangeEventKind.GRID_VISIBLE_CHANGE_EVENT,
					"gridVisible", oldValue, this._gridVisible));
			}		
		}
		
		
		public function set scaleFactor(newScaleFactor:Number):void
		{
			if ((0.1 <= newScaleFactor <= 500) && (newScaleFactor != this._scaleFactor))
			{
				var oldValue:Number = this._scaleFactor;
				this._scaleFactor = newScaleFactor;
				dispatchEvent(new PropertyChangeEvent(PropertyChangeEventKind.UPDATE, false, false, DisplayPropertyChangeEventKind.SCALE_FACTOR_CHANGE_EVENT, 
					"scaleFactor", oldValue, this._scaleFactor));
				dispatchEvent(new PropertyChangeEvent("scaleFactorChanged"));	
			}	
		}
		[Bindable (event="scaleFactorChanged")]
		public function get scaleFactor():Number
		{
			return this._scaleFactor;
		}
		
		public function set backgroundImageWidth(newWidth:Number):void
		{
			if ((newWidth >= 0) && (newWidth != this._backgroundImageWidth))
			{
				var oldValue:Number = this._backgroundImageWidth;
				this._backgroundImageWidth = newWidth;
				dispatchEvent(new PropertyChangeEvent(PropertyChangeEventKind.UPDATE, false, false, DisplayPropertyChangeEventKind.BACKGROUND_IMAGE_DIMENSIONS_CHANGE_EVENT, 
					"backgroundImageWidth", oldValue, this._backgroundImageWidth));				
			}
		}	
		
		
		public function set timePositionToShow(newDate:Date):void
		{
			if (this._timePositionToShow == null || newDate.time != this._timePositionToShow.time)
			{
				var oldValue:Date;
				if (this._timePositionToShow != null)
				{
					oldValue = new Date(this._timePositionToShow.time);	
				}
				else
				{
					oldValue = null;
				}
				this._timePositionToShow = newDate;
				dispatchEvent(new PropertyChangeEvent(PropertyChangeEventKind.UPDATE, false, false, DisplayPropertyChangeEventKind.TIME_POSITION_TO_SHOW_CHANGE_EVENT, 
					"timePositionToShow", oldValue, this._timePositionToShow));					
				dispatchEvent(new PropertyChangeEvent("timePositionToShowChanged"));
			}	
		}
		
		[Bindable (event="timePositionToShowChanged")]
		public function get timePositionToShow():Date
		{
			return this._timePositionToShow;
		}
		
		[Bindable (event="nodeIconPathChanged")]
		public function get nodeIconPath():String
		{
			return this._nodeIconPath;
		}
		
		[Bindable (event="nodeIconPathChanged")]
		public function getNodeIconPath():String
		{
			return this._nodeIconPath;
		}	
		
		public function set nodeIconPath(newPath:String):void
		{
			if(newPath != this._nodeIconPath)
			{
				var oldValue:String = this._nodeIconPath;
				this._nodeIconPath = newPath;
				dispatchEvent(new PropertyChangeEvent(PropertyChangeEventKind.UPDATE, false, false, DisplayPropertyChangeEventKind.NODE_ICON_PATH_CHANGE, 
					"nodeIconPath", oldValue, this._nodeIconPath));					
				dispatchEvent(new PropertyChangeEvent("nodeIconPathChanged"));				
			}	
		}
		//######################################################
		
		
		
		//################ OTHER SCENARIO EVENTS ###############
		public function dispatchClearScenarioEvent():void
		{
			dispatchEvent(new Event(DisplayPropertyChangeEventKind.CLEAR_SCENARIO_EVENT));
		}
		//######################################################

		
		
	}
}