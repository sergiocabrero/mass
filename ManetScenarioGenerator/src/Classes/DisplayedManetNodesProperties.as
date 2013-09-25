package Classes
{
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.containers.Canvas;
	import mx.events.PropertyChangeEvent;
	
	public class DisplayedManetNodesProperties
	{
		[Bindable]
		private var _displayedManetNodesPropertiesAC:ArrayCollection;
		
		
		public function DisplayedManetNodesProperties(rootAC:ArrayCollection = null)
		{
			if (rootAC != null)
			{
				this._displayedManetNodesPropertiesAC = rootAC;
			}
			else
			{
				this._displayedManetNodesPropertiesAC = new ArrayCollection();
			}	
		}

		[Bindable (event = "DisplayedManetNodePropertyACChanged")]
		public function getDisplayedManetNodesPropertiesAC():ArrayCollection
		{
			
			var sort:Sort = new Sort();
            var sortField:SortField = new SortField("node_id", false, false);                        
            sort.fields = [sortField];        
			this._displayedManetNodesPropertiesAC.sort = sort;
            this._displayedManetNodesPropertiesAC.refresh();                                   			
			return this._displayedManetNodesPropertiesAC;
		}
		
		public function setDisplayedManetNodesPropertiesAC(newAC:ArrayCollection):void
		{
			this._displayedManetNodesPropertiesAC = newAC;
		}
		
		public function addDisplayedManetNodePropertiesItem(nodeId:String, nodeColour:uint, nodeVisibility:Boolean, rangeVisibility:Boolean, canvasReference:Canvas, canvasTimePosReference:Canvas):void
		{
			var tempObj:Object = {node_id:nodeId, node_colour:nodeColour, node_trajectory_visibility:nodeVisibility, node_range_visibility:rangeVisibility,
				canvas_reference:canvasReference, canvas_timepos_reference:canvasTimePosReference};
			this._displayedManetNodesPropertiesAC.addItem(tempObj);
			dispatchEvent(new PropertyChangeEvent("DisplayedManetNodePropertyACChanged"));
		}
		
		public function getDisplayedManetNodesProperties():DisplayedManetNodesProperties
		{
			var newDMNP:DisplayedManetNodesProperties = new DisplayedManetNodesProperties(this.copyPropertiesAC(this._displayedManetNodesPropertiesAC));
			return newDMNP;
		}
		
		
		public function clearDisplayedAllManetNodesProperties():Boolean
		{
			this._displayedManetNodesPropertiesAC.removeAll();
			dispatchEvent(new PropertyChangeEvent("DisplayedManetNodePropertyACChanged"));
			return true;
		}
		
		public function clearDisplayedManetNodeProperties(nodeId:String):Boolean
		{
			try
			{
				for (var i:String in this._displayedManetNodesPropertiesAC)
				{
					if(this._displayedManetNodesPropertiesAC[i].node_id == nodeId)
					{
						this._displayedManetNodesPropertiesAC.removeItemAt(parseInt(i,10));
						dispatchEvent(new PropertyChangeEvent("DisplayedManetNodePropertyACChanged"));
						return true;
					}
				}
				return false;
			}
			catch(thrownError:Error)
			{
				return false;
			}	
			return false;
		}

		public function setManetNodeId(nodeId:String, newNodeId:String):Boolean
		{
			try
			{
				//Buscar en el AC el nodo y cambiar su id
				for (var i:String in this._displayedManetNodesPropertiesAC)
				{
					if(this._displayedManetNodesPropertiesAC[i].node_id == nodeId){
						this._displayedManetNodesPropertiesAC[i].node_id = newNodeId;
						dispatchEvent(new PropertyChangeEvent("DisplayedManetNodePropertyACChanged"));
						return true;
						break;
					}
				}
				return false;
			}
			catch(thrownError:Error)
			{
				return false;
			}
			return false;			
		}

		/* PARA LA OCULTACION TOTAL DEL NODO (Trayectorias + Checkpoints + Rango)
		public function setManetNodeVisibility(nodeId:String, isVisible:Boolean):Boolean
		{
			return true;
		}
		
		public function getManetNodeVisibility(nodeId:String):Boolean
		{
			return true;
		}
		*/
	
		public function setManetNodeTrajectoryVisibility(nodeId:String, isVisible:Boolean):Boolean
		{
			try
			{
				//Buscar en el AC el nodo y cambiar la visibilidad
				for (var i:String in this._displayedManetNodesPropertiesAC)
				{
					if(this._displayedManetNodesPropertiesAC[i].node_id == nodeId){
						this._displayedManetNodesPropertiesAC[i].node_trajectory_visibility = isVisible;
						dispatchEvent(new PropertyChangeEvent("DisplayedManetNodePropertyACChanged"));
						return true;
						break;
					}
				}
				return false;
			}
			catch(thrownError:Error)
			{
				return false;
			}
			return false;				
		}
		
		public function getManetNodeTrajectoryVisibility(nodeId:String):Boolean
		{
			try
			{
				//Buscar y devolver visibilidad
				for (var i:String in this._displayedManetNodesPropertiesAC)
				{
					if(this._displayedManetNodesPropertiesAC[i].node_id == nodeId){
						return this._displayedManetNodesPropertiesAC[i].node_trajectory_visibility;
						break;
					}
				}
				return true;
			}
			catch(thrownError:Error)
			{
				return true;
			}	
			return true;				
		}
		
		public function getManetNodeCanvasTimePosReferenceVisibilityRange(nodeId:String):Boolean
		{
			try
			{
				//Buscar y devolver visibilidad
				for (var i:String in this._displayedManetNodesPropertiesAC)
				{
					if(this._displayedManetNodesPropertiesAC[i].node_id == nodeId){
						return this._displayedManetNodesPropertiesAC[i].node_range_visibility;
						break;
					}
				}
				return true;
			}
			catch(thrownError:Error)
			{
				return true;
			}	
			return true;			
		}
		
		public function setManetNodeCanvasTimePosReferenceVisibilityRange(nodeId:String, isVisible:Boolean):Boolean
		{
			try
			{
				//Buscar en el AC el nodo y cambiar la visibilidad
				for (var i:String in this._displayedManetNodesPropertiesAC)
				{
					if(this._displayedManetNodesPropertiesAC[i].node_id == nodeId){
						this._displayedManetNodesPropertiesAC[i].node_range_visibility = isVisible;
						dispatchEvent(new PropertyChangeEvent("DisplayedManetNodePropertyACChanged"));
						return true;
						break;
					}
				}
				return false;
			}
			catch(thrownError:Error)
			{
				return false;
			}	
			return false;				
		}
		
		public function setManetNodeColour(nodeId:String, nodeColour:uint):Boolean
		{
			try
			{
				//Buscar en el AC el nodo y cambiar el color
				for (var i:String in this._displayedManetNodesPropertiesAC)
				{
					if(this._displayedManetNodesPropertiesAC[i].node_id == nodeId){
						this._displayedManetNodesPropertiesAC[i].node_colour = nodeColour;
						dispatchEvent(new PropertyChangeEvent("DisplayedManetNodePropertyACChanged"));
						return true;
						break;
					}
				}
				return false;
			}
			catch(thrownError:Error)
			{
				return false;
			}
			return false;					
		}
		
		public function getManetNodeColour(nodeId:String):uint
		{
			try
			{
				//Buscar nodo y devolver color
				for (var i:String in this._displayedManetNodesPropertiesAC)
				{
					if(this._displayedManetNodesPropertiesAC[i].node_id == nodeId)
					{
						return this._displayedManetNodesPropertiesAC[i].node_colour;
						break;
					}
				}
				return 0x000000;
			}
			catch(thrownError:Error)
			{
				return 0x000000;
			}	
			return 0x000000;				
		}
		
		public function setManetNodeCanvasReference(nodeId:String, canvasRef:Canvas):Boolean
		{
			try
			{
				//Buscar nodo y asignar referencia canvas
				for (var i:String in this._displayedManetNodesPropertiesAC)
				{
					if(this._displayedManetNodesPropertiesAC[i].node_id == nodeId)
					{
						this._displayedManetNodesPropertiesAC[i].canvas_reference = canvasRef;
						dispatchEvent(new PropertyChangeEvent("DisplayedManetNodePropertyACChanged"));
						return true;
						break;
					}
				}
				return false;
			}
			catch(thrownError:Error)
			{
				return false;
			}	
			return false;			
		}
		
		public function getManetNodeCanvasReference(nodeId:String):Canvas
		{
			try
			{
				//Buscar nodo y devolver referencia al canvas donde esta dibujado
				for (var i:String in this._displayedManetNodesPropertiesAC)
				{
					if(this._displayedManetNodesPropertiesAC[i].node_id == nodeId){
						return this._displayedManetNodesPropertiesAC[i].canvas_reference;
						break;
					}
				}
				return null;			
			}
			catch(thrownError:Error)
			{
				return null;
			}	
			return null;
		}

		public function setManetNodeCanvasTimePosReference(nodeId:String, canvasRef:Canvas):Boolean
		{
			try
			{
				//Buscar nodo y asignar referencia canvas
				for (var i:String in this._displayedManetNodesPropertiesAC)
				{
					if(this._displayedManetNodesPropertiesAC[i].node_id == nodeId)
					{
						this._displayedManetNodesPropertiesAC[i].canvas_timepos_reference = canvasRef;
						dispatchEvent(new PropertyChangeEvent("DisplayedManetNodePropertyACChanged"));
						return true;
						break;
					}
				}
				return false;		
			}
			catch(thrownError:Error)
			{
				return false;
			}	
			return false;	
		}

		public function getManetNodeCanvasTimePosReference(nodeId:String):Canvas
		{
			try
			{
				//Buscar nodo y devolver referencia al canvas donde esta dibujado
				for (var i:String in this._displayedManetNodesPropertiesAC)
				{
					if(this._displayedManetNodesPropertiesAC[i].node_id == nodeId){
						return this._displayedManetNodesPropertiesAC[i].canvas_timepos_reference;
						break;
					}
				}
				return null;
			}
			catch(thrownError:Error)
			{
				return null;
			}	
			return null;			
		}

		public function getUsedColoursArray():Array
		{
			var arrayColours:Array = new Array();
			for (var i:String in this._displayedManetNodesPropertiesAC)
			{
				arrayColours.push(this._displayedManetNodesPropertiesAC[i].node_colour)
			}
			return arrayColours;			
		}

		protected function copyPropertiesAC(ACtoCopy:ArrayCollection):ArrayCollection
		{
			try
			{
				var newPropertiesAC:ArrayCollection = new ArrayCollection();
				for (var i:String in ACtoCopy)
				{
					var tempObj:Object = 
					{node_id:ACtoCopy[i].node_id, 
					node_colour:ACtoCopy[i].node_colour, 
					node_trajectory_visibility:ACtoCopy[i].node_trajectory_visibility,
					node_range_visibility:ACtoCopy[i].node_range_visibility, 
					canvas_reference:ACtoCopy[i].canvas_reference};
					
					newPropertiesAC.addItem(tempObj);	
				}
				return newPropertiesAC;
			}
			catch(thrownError:Error)
			{
				return null;	
			}	
			return null;							
		}



	}
}