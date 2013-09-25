package Entities
{
	import Classes.ModelSingleton;
	
	import de.polygonal.ds.Cloneable;
	import de.polygonal.ds.DLL;
	import de.polygonal.ds.DLLNode;//FR
	
	public class ManetNode implements Cloneable
	{
		protected var _id:String;
		protected var _range:int;
		protected var _colour:String;
		protected var _direction:int;
		protected var _name:String;	
		protected var _pattern:String;
		protected var _dlistMovements:DLL;
		protected var _dlistStates:DLL;
		

		/**
		 * @param name:String, receives the name of the new node as a string literal
		 * @param range:int, receives the range of the node as a integer between -10000 and 10000 (meters)
		 * @param colour:String, receives the colour of the node for its representation as an hex string ("0x012DEF")
		 * @param direction:int, receives the direction of the node as an integer between 0 and 360 (degrees)
		 * @param pattern:string
		 * @param id:int, receives the identifier of the node
		 **/
		 //Propiedades colour y name se almacenan pero no están habilitadas
		public function ManetNode(...args)
		{
			try
			{
				switch(args.length){
					case 0:
						this._range = 10;
						this._colour = "0x55555";
						this._direction = 0;
						break;
					case 1:
						this._name = args[0];
						break;
					case 2:
						this._name = args[0];
						if (args[1] > -10000 && args[1] < 10000)
						{
							this._range = args[1];
						}
						break;					
					case 3:
						this._name = args[0];
						if (args[1] > -10000 && args[1] < 10000)
						{
							this._range = args[1];
						}
						this._colour = args[2];
						break;
					case 4:
						this._name = args[0];
						if (args[1] > -10000 && args[1] < 10000)
						{
							this._range = args[1];
						}
						this._colour = args[2];	
						if (args[3] >= 0 && args[3] <= 360)
						{				
							this._direction = args[3];
						}	
						break;
					case 5:
						this._name = args[0];
						if (args[1] > -10000 && args[1] < 10000)
						{
							this._range = args[1];
						}
						this._colour = args[2];					
						if (args[3] >= 0 && args[3] <= 360)
						{				
							this._direction = args[3];
						}
						
						//FR
						if(args[4]==0){
							this._pattern = "circular";
						}
						else
							this._pattern = args[4];
						//this._pattern = args[4];
						//FR
						break;	
					case 6:
						this._name = args[0];
						if (args[1] > -10000 && args[1] < 10000)
						{
							this._range = args[1];
						}
						this._colour = args[2];					
						if (args[3] >= 0 && args[3] <= 360)
						{				
							this._direction = args[3];
						}
						//FR
						if(args[4]==0){
							this._pattern = "circular";
						}
						else
							this._pattern = args[4];
						//this._pattern = args[4];
						//FR	
						if (args[5] != undefined && args[5].toString() != "")
						{
							this._id = args[5];
						}	
						break;						
																				
					default:
						this._name = args[0];
						if (args[1] > -10000 && args[1] < 10000)
						{
							this._range = args[1];
						}
						this._colour = args[2];					
						if (args[3] >= 0 && args[3] <= 360)
						{				
							this._direction = args[3];
						}
						//FR
						if(args[4]==0){
							this._pattern = "circular";
						}
						else
							this._pattern = args[4];
						//this._pattern = args[4];
						//FR
						if (args[5] != undefined && args[5].toString() != "")
						{
							this._id = args[5];
						}					
						break;
				}//End switch
				
				//The lists are created
				this._dlistMovements = new DLL();
				this._dlistStates = new DLL();
			}
			catch(thrownError:Error)
			{
				
			}
			
		}
		
		/**
		 * @returns Object (ManetNode), as a copy of the current state of the object and its properties
		 **/
		public function clone():Object
		{
			var newManetNode:ManetNode = new ManetNode();
			newManetNode.name = this._name;
			newManetNode.colour = this._colour;
			newManetNode.range = this._range
			newManetNode.direction = this._direction;
			newManetNode.pattern = this._pattern;
			newManetNode.id = this._id;
			
			return newManetNode;
		}
		
		
		/**
		 * @param newRange:int, receives the value of the new range for the current node as a integer 
		 * between -10000 and 10000 (meters)
		 * @changes the range of the object is updated
		 **/
		public function set range(newRange:int):void
		{
			if (newRange > -10000 && newRange < 10000)
			{
				this._range = newRange; 
			}
		}
		
		/**
		 * @returns int, the value of the current range
		 **/
		public function get range():int
		{
			return this._range;
		}

		/**
		 * @param newColour:int, receives the value of the new colour for the current node as a string 
		 * as an hex "0x123DEF"
		 * @changes the colour of the object is updated
		 **/		
		public function set colour(newColour:String):void
		{
			this._colour = newColour;							
		}

		/**
		 * @returns String, the value of the current colour
		 **/		
		public function get colour():String
		{
			return this._colour;
		}	
		
		/**
		 * @param newDirection:int, receives the value of the new direction for the current node as a integer 
		 * between 0 and 360 (degrees)
		 * @changes the direction of the object is updated
		 **/			
		public function set direction(newDirection:int):void
		{
			if (newDirection > 0 && newDirection < 360)
			{
				this._direction = newDirection;				
			}	
		}

		/**
		 * @returns int, the value of the current direction
		 **/		
		public function get direction():int
		{
			return this._direction;
		}

		/**
		 * @param newName:String, receives the value of the new name for the current node as a String 
		 * @changes the name of the object is updated
		 **/		
		public function set name(newName:String):void
		{
			this._name = newName;				
		}

		/**
		 * @returns String, the value of the current name
		 **/			
		public function get name():String
		{
			return this._name;
		}
		
		/**
		 * @param newValue:String, receives the value of the new node pattern as a String
		 * @changes the pattern of the object is updated
		 **/ 
		public function set pattern(newValue:String):void
		{
			this._pattern = newValue;
		}						
		
		/**
		 * @return String, the value of the current pattern
		 **/ 
		public function get pattern():String
		{
			return this._pattern;
		}

		/**
		 * @param newManetNodeId:String, receives the value of the new name for the current node
		 * @changes the id of the object is updated
		 **/
		public function set id(newManetNodeId:String):void
		{
			this._id = newManetNodeId;			
		}
		
		/**
		 * @return String, the value of the current id
		 **/		
		public function get id():String
		{
			return this._id;
		}
		

		/**
		 * @param timestamp:Date, receives the time for the state
		 * @param isSwitchedOn:Boolean, represents the current state of the node device
		 * @param xCoord:int, receives the X coordinate of the point where the state was established
		 * @param yCoord:int, receives the Y coordinate of the point where the state was established
		 * @param zCoord:int, receives the Z coordinate of the point where the state was established
		 * @param args[0]:Boolean, receives true if the id will be automatically generated, false if not
		 * @param args[1]:int, receives the id for the new state (ignored if args[0] is false)
		 * @changes the list of states, adding a new state
		 * @returns a Boolean value, true if the operation was successful, false otherwise
		 **/
		public function setManetNodeState(timestamp:Date, isSwitchedOn:Boolean, xCoord:int = -1, yCoord:int = -1, zCoord:int = -1, ...args):Boolean
		{
			try
			{
				var stId:int;
				//Si args[0] es true se asigna un id automaticamente
				if (args[0] == true)
				{
					stId = this.getFirstFreeNodeStateId();
				}
				else
				{
					stId = args[1];
				}					
				var newState:NodeState = new NodeState(timestamp, isSwitchedOn, stId, xCoord, yCoord, zCoord);
				this._dlistStates.append(newState);
				
			}
			catch(thrownError:Error)
			{
				return false;
			}
			return true;
		}
		
		/**
		 * @param timestamp:Date, receives the time related to the requested state
		 * @returns a NodeState object, a copy of the state in the table corresponding with the requested time or null if it does not exist
		 **/		
		public function getManetNodeStateByTimestamp(timestamp:Date):NodeState
		{
			try
			{
				if (this._dlistStates== null || this._dlistStates.isEmpty())
				{
					return null;
				}				
				var iterNode:DLLNode = this._dlistStates.head();
				while(iterNode)
				{
					var tempState:NodeState = NodeState(iterNode.val);
					if (tempState.timestamp >= timestamp && NodeState(iterNode.next.val).timestamp < timestamp)
					{
						return tempState.clone();
					}
					else
					{
						iterNode = iterNode.next;
					}
				}
				
			}
			catch(thrownError:Error)
			{
				return null;
			}
			return null;						
		}

		/**
		 * @param nodeStateId:int, receives the id of the requested state
		 * @returns a NodeState object, a copy of the state in the table corresponding with the requested id or null if it does not exist
		 **/		
		public function getManetNodeState(nodeStateId:int):NodeState
		{
			try
			{
				if (this._dlistStates== null || this._dlistStates.isEmpty())
				{
					return null;
				}				
				var iterNode:DLLNode = this._dlistStates.head();
				while(iterNode)
				{
					var tempNodeState:NodeState = NodeState(iterNode.val);
					if (tempNodeState.id == nodeStateId)
					{
						return tempNodeState.clone();
					}
					else
					{
						iterNode = iterNode.next;
					}
				}
				
			}
			catch(thrownError:Error)
			{
				return null;
			}	
			return null;							
		}
		
		/**
		 * @returns a NodeState object, a copy of the first state of the table (chronologically ordered) 
		 **/			
		public function getFirstNodeState():NodeState
		{
			if (this._dlistStates== null || this._dlistStates.isEmpty())
			{
				return null;
			}	
			else
			{
				return NodeState(this._dlistStates.head().val).clone();
			}			
		}
		
		/**
		 * @returns a NodeState object, a copy of the last state of the table (chronologically ordered) 
		 **/		
		public function getLastNodeState():NodeState
		{
			if (this._dlistStates== null || this._dlistStates.isEmpty())
			{
				return null;
			}	
			else
			{
				return NodeState(this._dlistStates.tail().val).clone();
			}			
		}

		/**
		 * @param nodeStateId:int, receives the id of the previous state of the requested
		 * @returns a NodeState object, a copy of the state of the table corresponding with the next state 
		 * to the requested id or null if it does not exist
		 **/		
		public function getNextNodeState(nodeStateId:int):NodeState
		{
			try
			{
				if (this._dlistStates== null || this._dlistStates.isEmpty())
				{
					return null;
				}				
				var iterNode:DLLNode = this._dlistStates.head();
				while(iterNode)
				{
					var tempNodeState:NodeState = NodeState(iterNode.val);
					if (tempNodeState.id == nodeStateId)
					{
						if(iterNode.hasNext())
						{
							return NodeState(iterNode.next.val).clone();	
						}
						else
						{
							return null;
							break;
						}
					}
					else
					{
						iterNode = iterNode.next;
					}				
				}
				
			}
			catch(thrownError:Error)
			{
				return null;
			}	
			return null;										
		}	

		/**
		 * @param nodeStateId:int, receives the id of the previous state of the requested
		 * @returns a NodeState object, a copy of the state of the table corresponding with the previous state 
		 * to the requested id or null if it does not exist
		 **/
		public function getPreviousNodeState(nodeStateId:int):NodeState
		{
			try
			{
				if (this._dlistStates== null || this._dlistStates.isEmpty())
				{
					return null;
				}			
				var iterNode:DLLNode = this._dlistStates.tail();
				while(iterNode)
				{
					var tempNodeState:NodeState = NodeState(iterNode.val);
					if (tempNodeState.id == nodeStateId)
					{
						if(iterNode.hasPrev())
						{
							return NodeState(iterNode.prev.val).clone();	
						}
						else
						{
							return null;
							break;
						}
					}
					else
					{
						iterNode = iterNode.next;
					}				
				}
				
			}
			catch(thrownError:Error)
			{
				return null;
			}
			return null;							
		}
			
		/**
		 * @param timestamp:Date, receives the time instant of the checkpoint
		 * @param xCoordinate:int, receives the x-axis coordinate of the checkpoint
		 * @param yCoordinate:int, receives the y-axis coordinate of the checkpoint
		 * @param args[0]:Boolean, receives true if the id will be automatically generated, false if not
		 * @param args[1]:int, receives the id for the new movement (ignored if args[0] is false)
		 * @changes the list of movements, adding the movement
		 * @returns Boolean, true if the operation was successful, false otherwise
		 **/
		public function setMovement(timestampInit:Date, timestampEnd:Date, xCoordinateInit:int, yCoordinateInit:int, 
			xCoordinateEnd:int, yCoordinateEnd:int, trajectory:int, acceleration:int, ...args):Boolean
		{
			try
			{
				var movId:int;
				//Si args[0] es true se asigna un id automaticamente
				if (args[0] == true)
				{
					movId = this.getFirstFreeMovementId();
				}
				else
				{
					movId = args[1];
				}		
				var newMovement:Movement = new Movement(xCoordinateInit, yCoordinateInit, xCoordinateEnd, yCoordinateEnd, timestampInit,
					timestampEnd, trajectory, acceleration, movId);
				this._dlistMovements.append(newMovement);

			}
			catch(thrownError:Error)
			{
				return false;
			}
			return true;				
		}


		/**
		 * @param timestampArrival:Date, receives the time instant of the checkpoint
		 * @param timestampStart:Date, receives the time instant of the checkpoint
		 * @param xCoordinate:int, receives the x-axis coordinate of the checkpoint
		 * @param yCoordinate:int, receives the y-axis coordinate of the checkpoint
		 * @param args[0]:Boolean, receives true if the id will be automatically generated, false if not
		 * @param args[1]:int, receives the id for the new movement (ignored if args[0] is false)
		 * @changes the list of movements, adding or updating the checkpoint
		 * @returns Boolean, true if the operation was successful, false otherwise
		 **/		
		//Si añade por el principio de la lista, se usará el timestampStart, 
		//si añade por el final, timestampArrival, si añade por el medio, ambos
		//Añade un checkpoint al principio, al medio o al final, lo que generara nuevos movimientos
		public function addDoubleTimestampPositionCheckpoint(timestampArrival:Date, timestampStart:Date, xCoordinate:int, yCoordinate:int):Boolean
		{
			try
			{
				if (timestampArrival.time > timestampStart.time)
				{
					return false;
				}
				
				//Si aun no hay ningun movimiento, añadimos un movimiento con solo checkpoint inicial (por convenio cogemos el timestampSTART)
				if (this._dlistMovements.isEmpty())
				{
					var movIdE:int = this.getFirstFreeMovementId();
					var newMovementE:Movement = new Movement(xCoordinate, yCoordinate, xCoordinate, yCoordinate, timestampStart, timestampStart, 0, 0, movIdE);
					this._dlistMovements.append(newMovementE);
					return true;
				}
				
				//Si hay solo un movimiento con igual checkpoint inicial y final
				var tempMov:Movement = Movement(this._dlistMovements.head().val);
				if (this._dlistMovements.size() == 1 && this.isNullMovement(tempMov))
				{
					
					if (tempMov.fromTimestampPositionCheckpoint.pointTime.time > timestampStart.time)
					{
						tempMov.toTimestampPositionCheckpoint.pointTime = new Date(tempMov.fromTimestampPositionCheckpoint.pointTime.time);
						tempMov.toTimestampPositionCheckpoint.xCoordinate = tempMov.fromTimestampPositionCheckpoint.xCoordinate;
						tempMov.toTimestampPositionCheckpoint.yCoordinate = tempMov.fromTimestampPositionCheckpoint.yCoordinate;
						
						tempMov.fromTimestampPositionCheckpoint.pointTime = timestampStart;
						tempMov.fromTimestampPositionCheckpoint.xCoordinate = xCoordinate;
						tempMov.fromTimestampPositionCheckpoint.yCoordinate = yCoordinate;
						return true;
					}
					else if (tempMov.toTimestampPositionCheckpoint.pointTime.time < timestampArrival.time)
					{
						tempMov.toTimestampPositionCheckpoint.pointTime = new Date(timestampArrival.time);
						tempMov.toTimestampPositionCheckpoint.xCoordinate = xCoordinate;
						tempMov.toTimestampPositionCheckpoint.yCoordinate = yCoordinate;
						return true;					
					}
					return false;
				}
				
				var iterNode:DLLNode = this._dlistMovements.head();
				var tempMovement0:Movement = Movement(iterNode.val);
				if (tempMovement0.fromTimestampPositionCheckpoint.pointTime.time > timestampStart.time)
				{
					//Añadir movimiento al principio con fromTimestampPosition el timestamp dado y toTimestampPosition el from del primer movimiento
					var movId0:int = this.getFirstFreeMovementId();	
					var newMovement0:Movement = new Movement(xCoordinate, yCoordinate, tempMovement0.fromTimestampPositionCheckpoint.xCoordinate, 
						tempMovement0.fromTimestampPositionCheckpoint.yCoordinate, timestampStart, tempMovement0.fromTimestampPositionCheckpoint.pointTime, 
						tempMovement0.trajectory, tempMovement0.acceleration, movId0);
					this._dlistMovements.prepend(newMovement0);	
					return true;
				}
								
				while(iterNode != null)
				{
					var tempMovement:Movement = Movement(iterNode.val);
	
					if (tempMovement.fromTimestampPositionCheckpoint.pointTime.time < timestampArrival.time && timestampStart.time <= tempMovement.toTimestampPositionCheckpoint.pointTime.time)
					{
						//Modificar movimiento y añadir otro	
						var movId:int = this.getFirstFreeMovementId();		
						var newMovement:Movement = new Movement(tempMovement.fromTimestampPositionCheckpoint.xCoordinate, tempMovement.fromTimestampPositionCheckpoint.yCoordinate,
							xCoordinate, yCoordinate, tempMovement.fromTimestampPositionCheckpoint.pointTime, timestampArrival, tempMovement.trajectory, tempMovement.acceleration,
							movId);
							
						tempMovement.fromTimestampPositionCheckpoint.xCoordinate = xCoordinate;
						tempMovement.fromTimestampPositionCheckpoint.yCoordinate = yCoordinate;
						tempMovement.fromTimestampPositionCheckpoint.pointTime = timestampStart;						
							
						this._dlistMovements.insertBefore(iterNode, newMovement);
						return true;				
					}
					else if((tempMovement.toTimestampPositionCheckpoint.pointTime.time < timestampArrival.time) && !iterNode.hasNext())
					{
						//Añadir movimiento al final con toTimestampPosition el timestamp dado y fromTimestampPosition el to del ultimo movimiento
						var movId1:int = this.getFirstFreeMovementId();	
						
						var newMovement1:Movement = new Movement(tempMovement.toTimestampPositionCheckpoint.xCoordinate, tempMovement.toTimestampPositionCheckpoint.yCoordinate, 
							xCoordinate, yCoordinate, tempMovement.toTimestampPositionCheckpoint.pointTime, timestampArrival, 
							tempMovement.trajectory, tempMovement.acceleration, movId1);
						this._dlistMovements.append(newMovement1);
						return true;						
					}
					else
					{
						iterNode = iterNode.next;
					}
				}
				
			}
			catch(thrownError:Error)
			{
				return false;
			}	
			return false;									
		}
		
	
	
		/**
		 * @param timestamp:Date, receives the time instant of the checkpoint
		 * @param xCoordinate:int, receives the x-axis coordinate of the checkpoint
		 * @param yCoordinate:int, receives the y-axis coordinate of the checkpoint
		 * @changes the list of movements, adding a movement starting at the point and time determinated by parameters
		 * and ending at the starting point of the first movement; or adding a movement ending at the point and time 
		 * determinated by parameters and starting at the ending point of the last movement
		 * @returns Boolean, true if the operation was successful, false otherwise
		 **/	
		//Añadir un checkpoint al principio o al final, lo que generaria nuevas trayectorias
		public function addExtremeTimestampPositionCheckpoint(timestamp:Date, xCoordinate:int, yCoordinate:int):Boolean
		{
			try
			{
				//Si aun no hay ningun movimiento, se añade un movimiento con solo checkpoint inicial
				if (this._dlistMovements.isEmpty())
				{
					if (timestamp != null)
					{
						var movIdE:int = this.getFirstFreeMovementId();
						var newMovementE:Movement = new Movement(null, null, xCoordinate, yCoordinate, null, timestamp, 0, 0, movIdE);
						this._dlistMovements.append(newMovementE);
						return true;					
					}	
					else
					{
						//Este caso no es aceptado
						return false;	
					}
				}
				
				//Si hay solo un movimiento y tiene solo checkpoint inicial (from)
				if (this._dlistMovements.size() == 1 && Movement(this._dlistMovements.head().val).toTimestampPositionCheckpoint.pointTime == null)
				{
					var tempMov:Movement = Movement(this._dlistMovements.head().val);
					
					//Si el checkpoint a añadir es anterior al from
					if (tempMov.fromTimestampPositionCheckpoint.pointTime > timestamp)
					{
						//Se guarda en toTimestampPositionCheckpoint lo que habia en fromTimestampPositionCheckpoint
						tempMov.toTimestampPositionCheckpoint.pointTime = new Date(tempMov.fromTimestampPositionCheckpoint.pointTime.time);
						tempMov.toTimestampPositionCheckpoint.xCoordinate = tempMov.fromTimestampPositionCheckpoint.xCoordinate;
						tempMov.toTimestampPositionCheckpoint.yCoordinate = tempMov.fromTimestampPositionCheckpoint.yCoordinate;
						
						//Se guarda en fromTimestampPositionCheckpoint el checkpoint nuevo
						tempMov.fromTimestampPositionCheckpoint.pointTime = timestamp;
						tempMov.fromTimestampPositionCheckpoint.xCoordinate = xCoordinate;
						tempMov.fromTimestampPositionCheckpoint.yCoordinate = yCoordinate;
						return true;
					}
					//Si el checkpoint a añadir es posterior al from
					else
					{
						//Se deja lo que habia en fromTimestampPositionCheckpoint y se añade el toTimestampPositionCheckpoint
						tempMov.toTimestampPositionCheckpoint.pointTime = new Date(timestamp.time);
						tempMov.toTimestampPositionCheckpoint.xCoordinate = xCoordinate;
						tempMov.toTimestampPositionCheckpoint.yCoordinate = yCoordinate;
						return true;					
					}
				}
				//Si hay solo un movimiento y tiene solo checkpoint final
				else if (this._dlistMovements.size() == 1 && Movement(this._dlistMovements.head().val).fromTimestampPositionCheckpoint.pointTime == null)
				{
					var tempMov2:Movement = Movement(this._dlistMovements.head().val);
					
					//Si el checkpoint a añadir es posterior al to
					if (tempMov2.toTimestampPositionCheckpoint.pointTime < timestamp)
					{
						//Se cambia al fromTimestampPositionCheckpoint lo que habia en toTimestampPositionCheckpoint
						tempMov2.fromTimestampPositionCheckpoint.pointTime = new Date(tempMov2.toTimestampPositionCheckpoint.pointTime.time);
						tempMov2.fromTimestampPositionCheckpoint.xCoordinate = tempMov2.toTimestampPositionCheckpoint.xCoordinate;
						tempMov2.fromTimestampPositionCheckpoint.yCoordinate = tempMov2.toTimestampPositionCheckpoint.yCoordinate;
						
						//Se guarda en toTimestampPositionCheckpoint el checkpoint nuevo
						tempMov2.toTimestampPositionCheckpoint.pointTime = timestamp;
						tempMov2.toTimestampPositionCheckpoint.xCoordinate = xCoordinate;
						tempMov2.toTimestampPositionCheckpoint.yCoordinate = yCoordinate;
						return true;
					}
					//Si el checkpoint a añadir es anterior al to
					else
					{
						//Se deja lo que habia en toTimestampPositionCheckpoint y añadimos el fromTimestampPositionCheckpoint
						tempMov2.fromTimestampPositionCheckpoint.pointTime = new Date(timestamp.time);
						tempMov2.fromTimestampPositionCheckpoint.xCoordinate = xCoordinate;
						tempMov2.fromTimestampPositionCheckpoint.yCoordinate = yCoordinate;
						return true;					
					}
				}
				//Si ya hay movimiento entero, y ha de colocarse al final
				else if (timestamp > Movement(this._dlistMovements.tail().val).toTimestampPositionCheckpoint.pointTime)
				{		 
					var movIdF:int = this.getFirstFreeMovementId();
					var tempMov4:Movement = new Movement(Movement(this._dlistMovements.tail().val).toTimestampPositionCheckpoint.xCoordinate,
						Movement(this._dlistMovements.tail().val).toTimestampPositionCheckpoint.yCoordinate,
						xCoordinate,
						yCoordinate,
						new Date(Movement(this._dlistMovements.tail().val).toTimestampPositionCheckpoint.pointTime.time),
						timestamp,
						0, 0, movIdF);
					this._dlistMovements.append(tempMov4);
					return true;
					
				}
				//Si ya hay movimiento entero y el nuevo va al principio de la lista
				else if	(timestamp < Movement(this._dlistMovements.head().val).fromTimestampPositionCheckpoint.pointTime)
				{
					var movIdIn:int = this.getFirstFreeMovementId();
					var tempMov5:Movement = new Movement(
						xCoordinate,
						yCoordinate,				
						Movement(this._dlistMovements.head().val).fromTimestampPositionCheckpoint.xCoordinate,
						Movement(this._dlistMovements.head().val).fromTimestampPositionCheckpoint.yCoordinate,
						timestamp,					
						new Date(Movement(this._dlistMovements.tail().val).fromTimestampPositionCheckpoint.pointTime.time),
						0, 0, movIdIn);
					this._dlistMovements.prepend(tempMov5);
					return true;
					
				}		
				
			}
			catch(thrownError:Error)
			{
				return false;
			}
			return false;				
		}	
	
		/**
		 * @param timestampArrival:Date, receives the time of the arrival to the checkpoint
		 * @param timestampStart:Date, receives the time of start from the checkpoint
		 * @param xCoordinate:int, receives the x-axis coordinate of the checkpoint
		 * @param yCoordinate:int, receives the y-axis coordinate of the checkpoint
		 * @changes the list of movements, adding a movement based on the entered checkpoint, 
		 * and in cases modifying other existing movement
		 * @returns Boolean, true if the operation was succesful, false otherwise
		 **/		
		public function addDoubleIntermediateTimestampPositionCheckpoint(timestampArrival:Date, timestampStart:Date, xCoordinate:int, yCoordinate:int):Boolean
		{
			try
			{
				if (this._dlistMovements.isEmpty() || (this.getNextTimestampPositionCheckpoint(timestampStart) == null && this.getPreviousTimestampPositionCheckpoint(timestampArrival) == null))
				{			
					//No cumple las condiciones, se invoca a addExtremeTimestampPositionCheckpoint
					//llamamos a addExtremeTimestampPositionCheckpoint. Como convenio COGEREMOS SIEMPRE EL TIMESTAMPSTART
					return this.addExtremeTimestampPositionCheckpoint(timestampStart, xCoordinate, yCoordinate);
				}

				//Si va al final
				else if (this.getNextTimestampPositionCheckpoint(timestampStart) == null && this.getPreviousTimestampPositionCheckpoint(timestampArrival) != null)
				{
					//Se invoca addExtremeTimestampPositionCheckpoint
					return this.addExtremeTimestampPositionCheckpoint(timestampArrival, xCoordinate, yCoordinate);
				}
				//Si va al principio
				else if (this.getNextTimestampPositionCheckpoint(timestampStart) != null && this.getPreviousTimestampPositionCheckpoint(timestampArrival) == null)
				{
					//Se invoca addExtremeTimestampPositionCheckpoint
					return this.addExtremeTimestampPositionCheckpoint(timestampStart, xCoordinate, yCoordinate);
				}
				
				
				if (this.getNextTimestampPositionCheckpoint(timestampStart).pointTime <= timestampStart)
				{
					//ESTE CASO NO SE PUEDE DAR
				}
				if	(this.getPreviousTimestampPositionCheckpoint(timestampArrival).pointTime >= timestampArrival)
				{
					//ESTE CASO NO SE PUEDE DAR
				}
				
						
				
				var iterNode:DLLNode = this._dlistMovements.head();				
				while(iterNode != null)
				{
					var tempMovement:Movement = Movement(iterNode.val);
	
					if (tempMovement.fromTimestampPositionCheckpoint.pointTime < timestampArrival && timestampStart < tempMovement.toTimestampPositionCheckpoint.pointTime)
					{
						//Modificar movimiento y añadir otro	
						var movId:int = this.getFirstFreeMovementId();		
						var newMovement:Movement = new Movement(tempMovement.fromTimestampPositionCheckpoint.xCoordinate, tempMovement.fromTimestampPositionCheckpoint.yCoordinate,
							xCoordinate, yCoordinate, tempMovement.fromTimestampPositionCheckpoint.pointTime, timestampArrival, tempMovement.trajectory, tempMovement.acceleration,
							movId);
							
						tempMovement.fromTimestampPositionCheckpoint.xCoordinate = xCoordinate;
						tempMovement.fromTimestampPositionCheckpoint.yCoordinate = yCoordinate;
						tempMovement.fromTimestampPositionCheckpoint.pointTime = timestampStart;						
							
						this._dlistMovements.insertBefore(iterNode, newMovement);
						return true;				
					}
					else
					{
						iterNode = iterNode.next;
					}
				}
				
			}
			catch(thrownError:Error)
			{
				return false;
			}
			return false;													
		}	
		
		
		/**
		 * @param timestamp:Date, the time to search in the list of PositionCheckpoints
		 * @returns TimestampPositionCheckpoint, in case the searched time is found it returns a copy of the position.
		 * If is not found but the time is between two existing time checkpoints it returns a interpolated TimestampPositionCheckpoint,
		 * null otherwise
		 **/
		//Calcula la posicion en la que esta el nodo en un momento concreto, si no esta guardada como un extremo de un movimiento, 
		//se calcula (si corresponde a un punto intermedio de un movimiento)
		public function getEstimatedTimestampPositionCheckpoint(timestamp:Date):TimestampPositionCheckpoint
		{
			try
			{			
				if (this._dlistMovements == null || this._dlistMovements.isEmpty())
				{
					return null;
				}	
				
				//Si se solicita un tiempo inferior al primer checkpoint
				if ( Movement(this._dlistMovements.head().val).fromTimestampPositionCheckpoint.pointTime.time >= timestamp.time )
				{
					return Movement(this._dlistMovements.head().val).fromTimestampPositionCheckpoint.clone();
				}
				//Si se solicita un tiempo superior al ultimo checkpoint
				else if ( Movement(this._dlistMovements.tail().val).toTimestampPositionCheckpoint.pointTime.time <= timestamp.time )
				{
					return Movement(this._dlistMovements.tail().val).toTimestampPositionCheckpoint.clone();	
				}
				else
				{	
					//Se busca si existe el instante de tiempo en la lista de movimientos como inicio o fin de un movimiento
					var iterNode:DLLNode = this._dlistMovements.head();
					while(iterNode)
					{					
						var tempMovement:Movement = Movement(iterNode.val);
						
						//Si coincide con el inicio de un movimiento
						if(tempMovement.fromTimestampPositionCheckpoint.pointTime.time == timestamp.time)
						{
							return tempMovement.fromTimestampPositionCheckpoint.clone();
						}
						//Si coincide con el final de un movimiento
						else if (tempMovement.toTimestampPositionCheckpoint.pointTime.time == timestamp.time)
						{
							return tempMovement.toTimestampPositionCheckpoint.clone();
						}
						//Si esta comprendido entre el inicio y el fin de un movimiento
						else if (tempMovement.fromTimestampPositionCheckpoint.pointTime.time < timestamp.time && timestamp.time < tempMovement.toTimestampPositionCheckpoint.pointTime.time)
						{
							//Se tienen en cuenta los checkpoint de inicio y fin para calcular la posicion
							var newXcoord:int;
							var newYcoord:int;
							var timeDifferenceInSecsBetweenNodes:Number = 
								Math.abs(tempMovement.toTimestampPositionCheckpoint.pointTime.time - tempMovement.fromTimestampPositionCheckpoint.pointTime.time) / 1000 ;
							var xDifferenceBetweenNodes:Number = tempMovement.toTimestampPositionCheckpoint.xCoordinate - tempMovement.fromTimestampPositionCheckpoint.xCoordinate;
							var yDifferenceBetweenNodes:Number = tempMovement.toTimestampPositionCheckpoint.yCoordinate - tempMovement.fromTimestampPositionCheckpoint.yCoordinate;

							newXcoord = Math.round( tempMovement.fromTimestampPositionCheckpoint.xCoordinate + (xDifferenceBetweenNodes/timeDifferenceInSecsBetweenNodes)  *  (Math.abs(timestamp.time - tempMovement.fromTimestampPositionCheckpoint.pointTime.time)/1000)   );
							newYcoord = Math.round( tempMovement.fromTimestampPositionCheckpoint.yCoordinate + (yDifferenceBetweenNodes/timeDifferenceInSecsBetweenNodes)  *  (Math.abs(timestamp.time - tempMovement.fromTimestampPositionCheckpoint.pointTime.time)/1000)   );
							
							var estimatedPositionCheckPoint:TimestampPositionCheckpoint = new TimestampPositionCheckpoint(timestamp, newXcoord, newYcoord);
							return estimatedPositionCheckPoint;
							break;
						}
						//Si esta comprendido entre el fin de un movimiento y el inicio del siguiente
						else if(iterNode.hasNext() && 
							(tempMovement.toTimestampPositionCheckpoint.pointTime.time < timestamp.time && timestamp.time < Movement(iterNode.next.val).fromTimestampPositionCheckpoint.pointTime.time))
						{

							return tempMovement.toTimestampPositionCheckpoint.clone();
							break;																		
						}
						else
						{
							iterNode = iterNode.next;
						}
						
					}//end while				
				}//end else
			}
			catch(thrownError:Error)
			{
				return null;
			}
			return null;				
		}

		/**
		 * @param movementId:int, the id of the requested movement
		 * @returns Movement, in case the searched id is found it returns a copy of the movement, null otherwise.
		 **/
		public function getMovement(movementId:int):Movement
		{
			try
			{
				if (this._dlistMovements == null || this._dlistMovements.isEmpty())
				{
					return null;
				}			
				var iterNode:DLLNode = this._dlistMovements.head();
				while(iterNode)
				{
					var tempMovement:Movement = Movement(iterNode.val);
					if (tempMovement.id == movementId)
					{
						return tempMovement.clone();
					}
					else
					{
						iterNode = iterNode.next;
					}
				}
				
			}
			catch(thrownError:Error)
			{
				return null;
			}	
			return null;					
		}

		/**
		 * @param timestamp:Date, the time of the requested movement
		 * @returns Movement, in case the searched id is found it returns a copy of the movement, null otherwise.
		 **/
		//Dado un timestamp se calcula el primer movimiento en el que esta incluido (tiempoInicial < timestamp <= tiempoFinal)
		public function getMovementByTimestamp(timestamp:Date):Movement
		{
			if (this._dlistMovements == null || this._dlistMovements.isEmpty())
			{
				return null;
			}			
			var iterNode:DLLNode = this._dlistMovements.head();
			while(iterNode)
			{
				var tempMovement:Movement = Movement(iterNode.val);
				if (tempMovement.fromTimestampPositionCheckpoint.pointTime < timestamp && timestamp <= tempMovement.toTimestampPositionCheckpoint.pointTime)
				{
					return tempMovement.clone();
				}
				else
				{
					iterNode = iterNode.next;
				}
			}
			return null;
		}
		
		/**
		 * @param timestampInit:Date, the start time of the requested movement
		 * @param timestampEnd:Date, the arrival time of the requested movement 
		 * @returns Movement, in case the searched movement according to timestamps is found it returns 
		 * a copy of the movement, null otherwise.
		 **/		
		public function getMovementByInitEnd(timestampInit:Date, timestampEnd:Date):Movement
		{
			if (this._dlistMovements == null || this._dlistMovements.isEmpty())
			{
				return null;
			}			
			var iterNode:DLLNode = this._dlistMovements.head();
			while(iterNode)
			{
				var tempMovement:Movement = Movement(iterNode.val);
				if (tempMovement.fromTimestampPositionCheckpoint.pointTime == timestampInit && tempMovement.toTimestampPositionCheckpoint.pointTime == timestampEnd)
				{
					return tempMovement.clone();
				}
				else
				{
					iterNode = iterNode.next;
				}				
			}
			return null;			
		}

		/**
		 * @returns Movement, the first movement of the list (chronologically ordered), null if the list is empty
		 **/
		public function getFirstMovement():Movement
		{
			if (this._dlistMovements == null || this._dlistMovements.isEmpty())
			{
				return null;
			}
			else
			{
				var ppp:Movement = Movement(this._dlistMovements.head().val).clone();
				return Movement(this._dlistMovements.head().val).clone();
			}
		}

		/**
		 * @returns Movement, the last movement of the list (chronologically ordered), null if the list is empty
		 **/		
		public function getLastMovement():Movement
		{
			
			if (this._dlistMovements == null || this._dlistMovements.isEmpty())
			{
				return null;
			}
			else
			{
				return Movement(this._dlistMovements.tail().val).clone();
			}			
		}

		/**
		 * @param movementId:int, receives the id of the previous movement of the requested
		 * @returns Movement object, a copy of the movement of the table corresponding with the next movement 
		 * to the requested id or null if it does not exist
		 **/		
		public function getNextMovement(movementId:int):Movement
		{
			if (this._dlistMovements == null || this._dlistMovements.isEmpty())
			{
				return null;
			}			
			var iterNode:DLLNode = this._dlistMovements.head();
			while(iterNode)
			{
				var tempMovement:Movement = Movement(iterNode.val);
				if (tempMovement.id == movementId)
				{
					if(iterNode.hasNext())
					{
						return Movement(iterNode.next.val).clone();	
					}
					else
					{
						return null;
						break;
					}
				}
				else
				{
					iterNode = iterNode.next;
				}				
			}
			return null;					
		}	


		/**
		 * @param movementId:int, receives the id of the next movement of the requested
		 * @returns Movement object, a copy of the movement of the table corresponding with the next movement 
		 * to the requested id or null if it does not exist
		 **/			
		public function getPreviousMovement(movementId:int):Movement
		{
			if (this._dlistMovements == null || this._dlistMovements.isEmpty())
			{
				return null;
			}			
			var iterNode:DLLNode = this._dlistMovements.tail();
			while(iterNode)
			{
				var tempMovement:Movement = Movement(iterNode.val);
				if (tempMovement.id == movementId)
				{
					if(iterNode.hasPrev())
					{
						return Movement(iterNode.prev.val).clone();	
					}
					else
					{
						return null;
						break;
					}
				}
				else
				{
					iterNode = iterNode.prev;
				}				
			}
			return null;						
		}

		/**
		 * @param timestampInit:Date, receives the start time of the previous movement of the requested
		 * @param timestampEnd:Date, receives the start time of the previous movement of the requested
		 * @returns Movement object, a copy of the movement of the table corresponding with the next movement 
		 * of the movement starting and ending at the requested timestamps or null otherwise
		 **/			
		public function getNextMovementByInitEnd(timestampInit:Date, timestampEnd:Date):Movement
		{
			if (this._dlistMovements == null || this._dlistMovements.isEmpty())
			{
				return null;
			}			
			var iterNode:DLLNode = this._dlistMovements.head();
			while(iterNode)
			{
				var tempMovement:Movement = Movement(iterNode.val);
				if (tempMovement.fromTimestampPositionCheckpoint.pointTime == timestampInit && tempMovement.toTimestampPositionCheckpoint.pointTime == timestampEnd)
				{
					if(iterNode.hasNext())
					{
						return Movement(iterNode.next.val).clone();	
					}
					else
					{
						return null;
						break;
					}
				}
				else
				{
					iterNode = iterNode.next;
				}				
			}
			return null;						
		}

		/**
		 * @param timestampInit:Date, receives the start time of the next movement of the requested
		 * @param timestampEnd:Date, receives the start time of the next movement of the requested
		 * @returns Movement object, a copy of the movement of the table corresponding with the previous movement 
		 * of the movement starting and ending at the requested timestamps or null otherwise
		 **/	
		public function getPreviousMovementByInitEnd(timestampInit:Date, timestampEnd:Date):Movement
		{
			if (this._dlistMovements == null || this._dlistMovements.isEmpty())
			{
				return null;
			}				
			var iterNode:DLLNode = this._dlistMovements.tail();
			while(iterNode)
			{
				var tempMovement:Movement = Movement(iterNode.val);
				if (tempMovement.fromTimestampPositionCheckpoint.pointTime == timestampInit && tempMovement.toTimestampPositionCheckpoint.pointTime == timestampEnd)
				{
					if(iterNode.hasPrev())
					{
						return Movement(iterNode.prev.val).clone();	
					}
					else
					{
						return null;
						break;
					}
				}
				else
				{
					iterNode = iterNode.prev;
				}				
			}
			return null;				
		}

		/**
		 * @param timestamp:Date, receives the time of a checkpoint
		 * @returns TimestampPositionCheckpoint object, a copy of the checkpoint corresponding with the first match,
		 * being a movement start or end point 
		 **/
		public function getTimestampPositionCheckpoint(timestamp:Date):TimestampPositionCheckpoint
		{
			if (this._dlistMovements == null || this._dlistMovements.isEmpty())
			{
				return null;
			}			
			var iterNode:DLLNode = this._dlistMovements.head();
				
			while(iterNode)
			{
				var tempMovement:Movement = Movement(iterNode.val);

				if (tempMovement.fromTimestampPositionCheckpoint.pointTime == timestamp)
				{
					return tempMovement.fromTimestampPositionCheckpoint.clone();
				}
				else if (tempMovement.toTimestampPositionCheckpoint.pointTime == timestamp)
				{
					return tempMovement.toTimestampPositionCheckpoint.clone();
				}
				else
				{
					iterNode = iterNode.next;
				}
			}
			return null						
		}
		
		/**
		 * @returns TimestampPositionCheckpoint, the first timestamp found in the list of checkpoints if the list
		 * is not empty, null otherwise
		 **/ 
		 //Se extrae el inicio, del primer movimiento
		public function getFirstTimestampPositionCheckpoint():TimestampPositionCheckpoint
		{
			if (this._dlistMovements != null && this._dlistMovements.isEmpty() == false)
			{
				return Movement(this._dlistMovements.head().val).fromTimestampPositionCheckpoint;
			}
			return null;
		}
		
		/**
		 * @returns TimestampPositionCheckpoint, the last timestamp found in the list of checkpoints if the list 
		 * is not empty, null otherwise
		 **/ 
		 //Se extrae el fin, del ultimo movimiento
		public function getLastTimestampPositionCheckpoint():TimestampPositionCheckpoint
		{
			if (this._dlistMovements != null && this._dlistMovements.isEmpty() == false)
			{
				return Movement(this._dlistMovements.tail().val).toTimestampPositionCheckpoint;
			}
			return null;
		}			
	
		/**
		 * @param timestamp:Date, receives the time of the previous checkpoint of the requested
		 * @returns TimestampPositionCheckpoint, the next checkpoint according to the timestamp param,
		 * null otherwise
		 **/ 
		//dado un intante de tiempo, nos devuelve cual es el siguiente instante guardado como inicio o fin de un movimiento
		public function getNextTimestampPositionCheckpoint(timestamp:Date):TimestampPositionCheckpoint
		{
			if (this._dlistMovements == null && this._dlistMovements.isEmpty())
			{
				return null;
			}			
			var iterNode:DLLNode = this._dlistMovements.head();

			var tempMovement0:Movement = Movement(iterNode.val);
			if (tempMovement0.fromTimestampPositionCheckpoint.pointTime > timestamp)
			{
				return tempMovement0.fromTimestampPositionCheckpoint.clone();
			}
							
			while(iterNode)
			{
				var tempMovement:Movement = Movement(iterNode.val);

				if (tempMovement.fromTimestampPositionCheckpoint.pointTime <= timestamp && timestamp < tempMovement.toTimestampPositionCheckpoint.pointTime)
				{
					return tempMovement.toTimestampPositionCheckpoint.clone();
				}
				else
				{
					iterNode = iterNode.next;
				}
			}
			return null			
		}
		
		
		
		
		/**
		 * @param timestampArrival:Date, receives the time of the previous checkpoint of the requested
		 * @param timestampStart:Date, receives the time of the previous checkpoint of the requested
		 * @param newTimestampArrival:Date, receives the time of the previous checkpoint of the requested
		 * @param newTimestampStart:Date, receives the time of the previous checkpoint of the requested
		 * @param newXCoordinate:int, receives the x-axis coordinate for the checkpoint to update
		 * @param newYCoordinate:int, receives the y-axis coordinate for the checkpoint to update
		 * @changes the list of movements, updating the movement corresponding with the provided timestamps
		 * @returns Boolean, true if the operation was succesful, false otherwise
		 **/ 		
		public function updateTimestampPositionCheckpoint(timestampArrival:Date, timestampStart:Date, newTimestampArrival:Date, newTimestampStart:Date, newXCoordinate:int, newYCoordinate:int):Boolean
		{
			try
			{
				if (this._dlistMovements == null || this._dlistMovements.isEmpty())
				{
					return false;
				}			

				var iterNode:DLLNode = this._dlistMovements.head();
				var tempMovement0:Movement = Movement(iterNode.val);
				if (this._dlistMovements.size() == 1 && this.isNullMovement(tempMovement0))
				{
					//SE COGE POR CONVENIO EL timestampStart PARA ACTUALIZARLO
					tempMovement0.toTimestampPositionCheckpoint.pointTime = timestampStart;
					tempMovement0.toTimestampPositionCheckpoint.xCoordinate = newXCoordinate;
					tempMovement0.toTimestampPositionCheckpoint.yCoordinate = newYCoordinate;	
					tempMovement0.fromTimestampPositionCheckpoint.pointTime = timestampStart;
					tempMovement0.fromTimestampPositionCheckpoint.xCoordinate = newXCoordinate;
					tempMovement0.fromTimestampPositionCheckpoint.yCoordinate = newYCoordinate;								
					return true;

				}

				else if (tempMovement0.fromTimestampPositionCheckpoint.pointTime == timestampStart)
				{
					if (newTimestampStart.time >= tempMovement0.toTimestampPositionCheckpoint.pointTime.time)
					{
						return false;
					}
					tempMovement0.fromTimestampPositionCheckpoint.pointTime = new Date(newTimestampStart.time);
					tempMovement0.fromTimestampPositionCheckpoint.xCoordinate = newXCoordinate;
					tempMovement0.fromTimestampPositionCheckpoint.yCoordinate = newYCoordinate;
					return true;
				}
				while(iterNode)
				{
					var tempMovement:Movement = Movement(iterNode.val);
	
					if (tempMovement.fromTimestampPositionCheckpoint.pointTime == timestampStart)
					{
						if (newTimestampStart > tempMovement.toTimestampPositionCheckpoint.pointTime || 
							(iterNode.hasPrev() && newTimestampArrival < Movement(iterNode.prev.val).fromTimestampPositionCheckpoint.pointTime))
						{
							return false;
						}
											
						tempMovement.fromTimestampPositionCheckpoint.pointTime = new Date(newTimestampStart.time);
						tempMovement.fromTimestampPositionCheckpoint.xCoordinate = newXCoordinate;
						tempMovement.fromTimestampPositionCheckpoint.yCoordinate = newYCoordinate;
						if (iterNode.hasPrev())
						{
							if (ModelSingleton.getSingletonInstance().scenarioPropertiesCallableProxy.googleMapsInfo._visible){
								
								var previousDate:Date = new Date(Movement((iterNode.prev).val).toTimestampPositionCheckpoint.pointTime);//FR
								Movement((iterNode.prev).val).toTimestampPositionCheckpoint = tempMovement.fromTimestampPositionCheckpoint.clone();
								Movement((iterNode.prev).val).toTimestampPositionCheckpoint.pointTime = previousDate;//FR
								
							}
							else{
								
								Movement((iterNode.prev).val).toTimestampPositionCheckpoint = tempMovement.fromTimestampPositionCheckpoint.clone();
								Movement((iterNode.prev).val).toTimestampPositionCheckpoint.pointTime = new Date(newTimestampArrival.time);
								
							}
							
						}	
						return true;
					}
					else if (tempMovement.toTimestampPositionCheckpoint.pointTime == timestampArrival && !iterNode.hasNext())
					{
						if (newTimestampArrival < tempMovement.fromTimestampPositionCheckpoint.pointTime)
						{
							return false;
						}
						tempMovement.toTimestampPositionCheckpoint.pointTime = new Date(newTimestampArrival.time);
						tempMovement.toTimestampPositionCheckpoint.xCoordinate = newXCoordinate;
						tempMovement.toTimestampPositionCheckpoint.yCoordinate = newYCoordinate;
						return true;
					}
					else
					{
						iterNode = iterNode.next;
					}
				}
				
			}	
			catch(thrownError:Error)
			{
				return false;
			}	
			return false;							
		}		
		
		
		
		
		
		/**
		 * @param timestamp:Date, receives a timestamp
		 * @returns TimestampPositionCheckpoint, the immediate previous checkpoint according to the timestamp param
		 * if that checkpoint exists, null otherwise
		 **/ 		
		//dado un instante de tiempo, nos devuelve cual es el anterior instante guardado como inicio o fin de un movimiento
		public function getPreviousTimestampPositionCheckpoint(timestamp:Date):TimestampPositionCheckpoint
		{
			if (this._dlistMovements == null || this._dlistMovements.isEmpty())
			{
				return null;
			}			
			var iterNode:DLLNode = this._dlistMovements.tail();
			var tempMovement0:Movement = Movement(iterNode.val);
			if (tempMovement0.toTimestampPositionCheckpoint.pointTime < timestamp)
			{
				return tempMovement0.toTimestampPositionCheckpoint.clone();
			}
							
			while(iterNode)
			{
				var tempMovement:Movement = Movement(iterNode.val);

				if (tempMovement.fromTimestampPositionCheckpoint.pointTime <= timestamp && timestamp < tempMovement.toTimestampPositionCheckpoint.pointTime)
				{
					return tempMovement.fromTimestampPositionCheckpoint.clone();
				}
				else
				{
					iterNode = iterNode.prev;
				}
			}
			return null;				
		}
		

		/**
		 * @param timestamp:Date, receives a timestamp corresponding with the checkpoint to remove
		 * @changes the list of movements, removing a movement if exists, and updating movements if necessary
		 * @returns Boolean, true if the operation was succesful, false otherwise
		 **/ 		
		//Dado un timestamp, si corresponde a un checkpoint se borra de la/s trayectoria/s correspondiente/s y se rehacen si es necesario
		public function removeTimestampPositionCheckpoint(timestamp:Date):Boolean
		{
			try
			{
				if (this._dlistMovements == null || this._dlistMovements.isEmpty())
				{
					return false;
				}
				var iterNode:DLLNode = this._dlistMovements.head();
				var tempMovement0:Movement = Movement(iterNode.val);
				if (tempMovement0.fromTimestampPositionCheckpoint.pointTime > timestamp)
				{
					return false;
				}
				else if (tempMovement0.fromTimestampPositionCheckpoint.pointTime == timestamp)
				{
					if (this._dlistMovements.size() == 1)
					{
						if(this.isNullMovement(tempMovement0))
						{
							iterNode.remove();
							return true;
						}
						tempMovement0.fromTimestampPositionCheckpoint.pointTime = tempMovement0.toTimestampPositionCheckpoint.pointTime;
						tempMovement0.fromTimestampPositionCheckpoint.xCoordinate = tempMovement0.toTimestampPositionCheckpoint.xCoordinate;
						tempMovement0.fromTimestampPositionCheckpoint.yCoordinate = tempMovement0.toTimestampPositionCheckpoint.yCoordinate;
						return true; 
					}
					//Quitar el primer movimiento
					iterNode.remove();
					return true;
				}
				else if (tempMovement0.toTimestampPositionCheckpoint.pointTime == timestamp && this._dlistMovements.size() == 1)
				{
					if(this.isNullMovement(tempMovement0))
					{
						iterNode.remove();
						return true;
					}					
					tempMovement0.toTimestampPositionCheckpoint.pointTime = tempMovement0.fromTimestampPositionCheckpoint.pointTime;
					tempMovement0.toTimestampPositionCheckpoint.xCoordinate = tempMovement0.fromTimestampPositionCheckpoint.xCoordinate;
					tempMovement0.toTimestampPositionCheckpoint.yCoordinate = tempMovement0.fromTimestampPositionCheckpoint.yCoordinate;
					return true; 				
				}
								
				while(iterNode)
				{
					var tempMovement:Movement = Movement(iterNode.val);
	
					if (tempMovement.fromTimestampPositionCheckpoint.pointTime == timestamp)
					{
						Movement((iterNode.prev).val).toTimestampPositionCheckpoint = tempMovement.toTimestampPositionCheckpoint.clone();
						iterNode.remove();
						return true;
					}
					else if (tempMovement.toTimestampPositionCheckpoint.pointTime.time == timestamp.time && !iterNode.hasNext())
					{
						iterNode.remove();
						return true;
					}
					else
					{
						iterNode = iterNode.next;
					}
				}//end while
						
			}//end try
			catch(thrownError:Error)
			{
				return false;
			}	
			return false;					
}
		
		
		
		/**
		 * @param timestamp:Date, the timestamp related to the checkpoint to be removed from the list of checkpoints
		 * @changes the list of movements, removing a movement if exists, and updating movements if necessary
		 * @return Boolean, true if the movement was deleted from the list, false otherwise
		 **/ 
		//Dado un timestamp se borra el primer movimiento en el que cae (tiempoInicial < time <= tiempoFinal)
		public function removeMovementByTimestamp(timestamp:Date):Boolean
		{
			try
			{
				if (this._dlistMovements == null || this._dlistMovements.isEmpty())
				{
					return false;
				}			
				var iterNode:DLLNode = this._dlistMovements.head();
				while(iterNode)
				{
					var tempMovement:Movement = Movement(iterNode.val);
					if (tempMovement.fromTimestampPositionCheckpoint.pointTime < timestamp && timestamp <= tempMovement.toTimestampPositionCheckpoint.pointTime)
					{
						//Si no es el ultimo hay que recolocar
						if (iterNode.hasNext())
						{
							var newMovement:Movement = Movement(iterNode.next.val).clone();
							newMovement.fromTimestampPositionCheckpoint = tempMovement.fromTimestampPositionCheckpoint.clone();
							//FALTA DAR LAS DEMAS NUEVAS PROPIEDADES AL NUEVO MOVIMIENTO
							
							//Se borra el siguiente e insertamos el nuevo modificado 
							iterNode.next.remove();
							this._dlistMovements.insertAfter(iterNode, newMovement);						
						}
						iterNode.remove();					
						return true;
						break;
					}
					else
					{
						iterNode = iterNode.next;
					}
				}
					
			}
			catch(thrownError:Error)
			{
				return false;
			}	
			return false;									
		}
		
		/**
		 * @param timestampInit:Date, the start timestamp of the movement to be removed
		 * @param timestampEnd:Date, the end timestamp of the movement to be removed
		 * @changes the list of movements, removing a movement if exists, and updating movements if necessary
		 * @returns Boolean, true if the movement was deleted from the list, false otherwise
		 **/		
		public function removeMovement(timestampInit:Date, timestampEnd:Date):Boolean
		{
			try
			{
				if (this._dlistMovements == null || this._dlistMovements.isEmpty())
				{
					return false;
				}			
				var iterNode:DLLNode = this._dlistMovements.head();
				while(iterNode)
				{
					var tempMovement:Movement = Movement(iterNode.val);
					if (tempMovement.fromTimestampPositionCheckpoint.pointTime == timestampInit && tempMovement.toTimestampPositionCheckpoint.pointTime == timestampEnd)
					{
						//Si no es el ultimo hay que recolocar
						if (iterNode.hasNext())
						{
							var newMovement:Movement = Movement(iterNode.next.val).clone();
							newMovement.fromTimestampPositionCheckpoint = tempMovement.fromTimestampPositionCheckpoint.clone();
							//FALTA DAR LAS DEMAS NUEVAS PROPIEDADES AL NUEVO MOVIMIENTO
							
							//Se borra el siguiente e insertamos el nuevo modificado 
							iterNode.next.remove();
							this._dlistMovements.insertAfter(iterNode, newMovement);
							
						}					
						iterNode.remove();					
						return true;
						break;
					}
					else
					{
						iterNode = iterNode.next;
					}				
				}
					
			}
			catch(thrownError:Error)
			{
				return false;
			}	
			return false;								
		}
		
		/**
		 * @returns int, the size of the movements list (the amount of movements)
		 **/		
		public function getManetNodeMovementsSize():int
		{
			if (this._dlistMovements != null)
			{
				return this._dlistMovements.size();
			}
			else
			{
				return -1;
			}	
		}

		/**
		 * @returns int, the size of the movements list (the amount of states)
		 **/
		//Devuelve el tamaño de la tabla de estados (entero)
		public function getManetNodeStatesSize():int
		{
			if (this._dlistStates != null)
			{
				return this._dlistStates.size();
			}
			else
			{
				return -1;
			}	
		}

		/**
		 * @returns Array, a collection of ids of the movements in the list
		 **/
		//Devuelve un array con los id de cada movimiento de la tabla
		public function getIdMovementsArray():Array
		{
			var movementsArray:Array = new Array();
			var iterNode:DLLNode = this._dlistMovements.head();
			while (iterNode)
			{
				var tempMovement:Movement = Movement(iterNode.val);
				movementsArray.push(tempMovement.id);
				iterNode = iterNode.next;	
			}			
			return movementsArray;			
		}
		
		/**
		 * @returns Array, a collection of ids of the states in the list
		 **/		
		//Devuelve un array con los id de cada estado de la tabla
		public function getIdNodeStatesArray():Array
		{
			var nodeStatesArray:Array = new Array();
			var iterNode:DLLNode = this._dlistStates.head();
			while (iterNode)
			{
				var tempNodeState:NodeState = NodeState(iterNode.val);
				nodeStatesArray.push(tempNodeState.id);
				iterNode = iterNode.next;	
			}			
			return nodeStatesArray;			
		}
		
		/**
		 * @returns int, the first free id (from zero onwards) not asigned to a movement
		 **/ 		
		//Devuelve el primer id (entero) libre disponible en la tabla de movimientos
		protected function getFirstFreeMovementId():int
		{
			if (this._dlistMovements != null && this._dlistMovements.isEmpty() == false)
			{
				var firstId:int = 0;
				for(firstId; firstId <= this._dlistMovements.size(); firstId++)
				{
					var iterNode:DLLNode = this._dlistMovements.head();
					var idFound:Boolean = false;	
					while(iterNode)
					{
						var tempMovement:Movement = Movement(iterNode.val);
						if(firstId == tempMovement.id)
						{
							idFound = true;
							break;
						}
						else
						{
							iterNode = iterNode.next;	
						}
					}//end while
					
					if (idFound)
					{
						//hay que seguir buscando
						idFound = false;
					}
					else
					{
						//ya lo tenemos, devolvemos firstId
						//return firstId;
						break;
					}
				}//end for	
				return firstId;
			}//end if
			else
			{
				return 0;
			}			

		}

		/**
		 * @returns int, the first free id (from zero onwards) not asigned to a state
		 **/ 
		//Devuelve el primer id (entero) libre disponible en la tabla de estados
		protected function getFirstFreeNodeStateId():int
		{
			if (this._dlistStates != null && this._dlistStates.isEmpty() == false)
			{
				var firstId:int = 0;
				for(firstId; firstId <= this._dlistStates.size(); firstId++)
				{
					var iterNode:DLLNode = this._dlistStates.head();
					var idFound:Boolean = false;	
					while(iterNode)
					{
						var tempState:NodeState = NodeState(iterNode.val);
						if(firstId == tempState.id)
						{
							idFound = true;
							break;
						}
						else
						{
							iterNode = iterNode.next;	
						}
					}//end while
					
					if (idFound)
					{
						//hay que seguir buscando
						idFound = false;
					}
					else
					{
						//ya lo tenemos, devolvemos firstId
						//return firstId;
						break;
					}
				}//end for	
				return firstId;
			}//end if
			else
			{
				return 0;
			}						

		}
		
		/**
		 * @param mov:Movement, a movement to test if is null
		 * @returns Boolean, true if start and end coordinates are equal and also the timestamps
		 **/ 		
		//Funcion que devuelve true si un movimiento tiene iguales coordenadas iniciales y finales y el mismo timestamp en ambos puntos, false si no		
		protected function isNullMovement(mov:Movement):Boolean
		{
			return mov.isNullMovement();
			/*
			if ((mov.fromTimestampPositionCheckpoint.xCoordinate == mov.toTimestampPositionCheckpoint.xCoordinate) 
				&& (mov.fromTimestampPositionCheckpoint.yCoordinate == mov.toTimestampPositionCheckpoint.yCoordinate)
				&& (mov.fromTimestampPositionCheckpoint.pointTime.time == mov.toTimestampPositionCheckpoint.pointTime.time))
			{
				return true;
			}	
			else
			{
				return false;
			}
			*/
		}
		
/******************************************************************************************************************************/
//FR
/**
		 * @param switchOn:Boolean, receives the status of the nodeState: On/Off
		 * @param timestamp:Date, receives the time of the nodeState
		 * @param xPosition:int=-1, receives the x-axis coordinate for the nodeState to update
		 * @param yPosition:int=-1, receives the y-axis coordinate for the nodeStante to update
		 * @param zPosition:int=-1, receives the z-axis coordinate for the nodeState to update
		 * @changes the list of movements, updating the movement corresponding with the provided timestamps
		 * @returns Boolean, true if the operation was succesful, false otherwise
		 **/ 		
		public function updateManetNodeState(switchOn:Boolean,timestamp:Date, xPosition:int=-1, yPosition:int=-1, zPosition:int=-1):Boolean
		{
			try
			{
				if (this._dlistStates == null || this._dlistStates.isEmpty())
				{
					return false;
				}			

				var iterNode:DLLNode = this._dlistStates.head();
				
				while(iterNode)
				{
					var tempNodeState:NodeState = NodeState(iterNode.val);
					
					if(tempNodeState.switchedOn == switchOn){
						
						tempNodeState.switchedOn = switchOn;
						tempNodeState.timestamp = timestamp;
						tempNodeState.xCoordinate = xPosition;
						tempNodeState.yCoordinate = yPosition;
						tempNodeState.zCoordinate = zPosition;
						this._dlistStates.remove(iterNode);
						if (switchOn)
							this._dlistStates.prepend(tempNodeState);
						else
							this._dlistStates.append(tempNodeState);
						
						return true;
					}
					else
						iterNode = iterNode.next;
				}
	
			}	
			catch(thrownError:Error)
			{
				return false;
			}	
			return false;							
		}		
				
	}
}