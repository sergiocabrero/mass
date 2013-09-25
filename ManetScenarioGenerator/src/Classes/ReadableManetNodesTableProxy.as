package Classes
{
	import Entities.*;
	import Interfaces.IManetNodesTableReadable;
	import mx.utils.ObjectProxy;	
	
	public class ReadableManetNodesTableProxy extends ObjectProxy implements IManetNodesTableReadable
	{
		private var _item:ManetNodesTable;
		
		public function ReadableManetNodesTableProxy(item:Object=null, uid:String=null, proxyDepth:int=-1)
		{
			super(item, uid, proxyDepth);
			this._item = ManetNodesTable(item);
		}
		
		/**
		 * @param idNode:String, the id of the ManetNode to search
		 * @returns ManetNode, a copy of the ManetNode found in the table, null otherwise
		 **/ 
		public function getManetNode(idNode:String):ManetNode
		{
			return this._item.getManetNode(idNode);
		}


		/**
		 * @returns Array, a collection of ids of the ManetNode objects in the table
		 **/		
		public function getIdManetNodesArray():Array
		{
			return this._item.getIdManetNodesArray();
		}

		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns int, the value of the current range
		 **/			
		public function getManetNodeRange(nodeId:String):int
		{
			return this._item.getManetNodeRange(nodeId);
		}

		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns String, the value of the current colour
		 **/			
		public function getManetNodeColour(nodeId:String):String
		{
			return this._item.getManetNodeColour(nodeId);
		}
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns int, the value of the current direction
		 **/			
		public function getManetNodeDirection(nodeId:String):int
		{
			return this._item.getManetNodeDirection(nodeId);
		}

		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns String, the value of the current name
		 **/		
		public function getManetNodeName(nodeId:String):String
		{
			return this._item.getManetNodeName(nodeId);
		}
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns String, the value of the current pattern
		 **/		
		public function getManetNodePattern(nodeId:String):String
		{
			return this._item.getManetNodePattern(nodeId);
		}

		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param timestamp:Date, receives the time related to the requested state
		 * @returns a NodeState object, a copy of the state in the table corresponding with the requested time or null if it does not exist
		 **/		
		public function getManetNodeStateByTimestamp(nodeId:String, timestamp:Date):NodeState
		{
			return this._item.getManetNodeStateByTimestamp(nodeId, timestamp);
		}

		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param nodeStateId:int, receives the id of the requested state
		 * @returns a NodeState object, a copy of the state in the table corresponding with the requested id or null if it does not exist
		 **/		
		public function getManetNodeState(nodeId:String, nodeStateId:int):NodeState
		{
			return this._item.getManetNodeState(nodeId, nodeStateId);
		}

		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns a NodeState object, a copy of the first state of the table (chronologically ordered) 
		 **/		
		public function getManetNodeFirstState(nodeId:String):NodeState
		{
			return this._item.getManetNodeFirstState(nodeId);
		}

		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns a NodeState object, a copy of the last state of the table (chronologically ordered) 
		 **/		
		public function getManetNodeLastState(nodeId:String):NodeState
		{
			return this._item.getManetNodeLastState(nodeId);
		}

		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param nodeStateId:int, receives the id of the previous state of the requested
		 * @returns a NodeState object, a copy of the state of the table corresponding with the next state 
		 * to the requested id or null if it does not exist
		 **/		
		public function getManetNodeNextState(nodeId:String, nodeStateId:int):NodeState
		{
			return this._item.getManetNodeNextState(nodeId, nodeStateId);
		}

		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param nodeStateId:int, receives the id of the previous state of the requested
		 * @returns a NodeState object, a copy of the state of the table corresponding with the previous state 
		 * to the requested id or null if it does not exist
		 **/		
		public function getManetNodePreviousState(nodeId:String, nodeStateId:int):NodeState
		{
			return this._item.getManetNodePreviousState(nodeId, nodeStateId);	
		}

		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param nodeStateId:int, the id of the state to check
		 * @returns Boolean, true if the provided nodeStateId corresponds to the first state of the list (chronologically ordered)   
		 **/			
		public function isManetNodeFirstState(nodeId:String, nodeStateId:int):Boolean
		{
			return this._item.isManetNodeFirstState(nodeId, nodeStateId);	
		}
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param nodeStateId:int, the id of the state to check
		 * @returns Boolean, true if the provided nodeStateId corresponds to the last state of the list (chronologically ordered)   
		 **/		
		public function isManetNodeLastState(nodeId:String, nodeStateId:int):Boolean
		{
			return this._item.isManetNodeLastState(nodeId, nodeStateId);
		}

		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param movementId:int, the id of the movement to check
		 * @returns Boolean, true if the provided nodeStateId corresponds to the first movement of the list (chronologically ordered)   
		 **/		
		public function isManetNodeFirstMovement(nodeId:String, movementId:int):Boolean
		{
			return this._item.isManetNodeFirstMovement(nodeId, movementId);
		}

		//SIN USO ACTUALMENTE
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param movementId:int, the id of the movement to check
		 * @returns Boolean, true if the provided nodeStateId corresponds to the first movement of a stretch from the list (chronologically ordered)   
		 **/		
		public function isManetNodeFirstStretchMovement(nodeId:String, movementId:int):Boolean
		{
			return this._item.isManetNodeFirstStretchMovement(nodeId, movementId);
		}

		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param movementId:int, the id of the movement to check
		 * @returns Boolean, true if the provided nodeStateId corresponds to the last movement of the list (chronologically ordered)   
		 **/			
		public function isManetNodeLastMovement(nodeId:String, movementId:int):Boolean
		{
			return this._item.isManetNodeLastMovement(nodeId, movementId);
		}

		//SIN USO ACTUALMENTE
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param movementId:int, the id of the movement to check
		 * @returns Boolean, true if the provided nodeStateId corresponds to the last movement of a stretch from the list (chronologically ordered)   
		 **/		
		public function isManetNodeLastStretchMovement(nodeId:String, movementId:int):Boolean
		{
			return this._item.isManetNodeLastStretchMovement(nodeId, movementId);
		}
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns Movement, the first movement of the list (chronologically ordered), null if the list is empty
		 **/		
		public function getManetNodeFirstMovement(nodeId:String):Movement
		{
			return this._item.getManetNodeFirstMovement(nodeId);
		}

		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns Movement, the last movement of the list (chronologically ordered), null if the list is empty
		 **/		
		public function getManetNodeLastMovement(nodeId:String):Movement
		{
			return this._item.getManetNodeLastMovement(nodeId);
		}

		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param timestampInit:Date, receives the start time of the previous movement of the requested
		 * @param timestampEnd:Date, receives the start time of the previous movement of the requested
		 * @returns Movement object, a copy of the movement of the table corresponding with the next movement 
		 * of the movement starting and ending at the requested timestamps or null otherwise
		 **/	
		public function getManetNodeNextMovementByInitEnd(nodeId:String, timestampInit:Date, timestampEnd:Date):Movement
		{
			return this._item.getManetNodeNextMovementByInitEnd(nodeId, timestampInit, timestampEnd);
		}
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param timestamp:Date, receives the time of a checkpoint
		 * @returns TimestampPositionCheckpoint object, a copy of the checkpoint corresponding with the first match,
		 * being a movement start or end point 
		 **/		
		public function getManetNodeTimestampPositionCheckpoint(nodeId:String, timestamp:Date):TimestampPositionCheckpoint
		{
			return this._item.getManetNodeTimestampPositionCheckpoint(nodeId, timestamp);
		}
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param timestampInit:Date, receives the start time of the next movement of the requested
		 * @param timestampEnd:Date, receives the start time of the next movement of the requested
		 * @returns Movement object, a copy of the movement of the table corresponding with the previous movement 
		 * of the movement starting and ending at the requested timestamps or null otherwise
		 **/			
		public function getManetNodePreviousMovementByInitEnd(nodeId:String, timestampInit:Date, timestampEnd:Date):Movement
		{
			return this._item.getManetNodePreviousMovementByInitEnd(nodeId, timestampInit, timestampEnd);
		}

		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param movementId:int, receives the id of the previous movement of the requested
		 * @returns Movement object, a copy of the movement of the table corresponding with the next movement 
		 * to the requested id or null if it does not exist
		 **/
		public function getManetNodeNextMovement(nodeId:String, movementId:int):Movement
		{
			return this._item.getManetNodeNextMovement(nodeId, movementId);
		}
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param movementId:int, receives the id of the next movement of the requested
		 * @returns Movement object, a copy of the movement of the table corresponding with the next movement 
		 * to the requested id or null if it does not exist
		 **/		
		public function getManeNodePreviousMovement(nodeId:String, movementId:int):Movement
		{
			return this._item.getManetNodePreviousMovement(nodeId, movementId);
		}
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param timestamp:Date, the time to search in the list of PositionCheckpoints
		 * @returns TimestampPositionCheckpoint, in case the searched time is found it returns a copy of the position.
		 * If is not found but the time is between two existing time checkpoints it returns a interpolated TimestampPositionCheckpoint,
		 * null otherwise
		 **/					
		public function getManetNodeEstimatedTimestampPositionCheckpoint(nodeId:String, timestamp:Date):TimestampPositionCheckpoint
		{
			return this._item.getManetNodeEstimatedTimestampPositionCheckpoint(nodeId, timestamp);
		}
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param movementId:int, the id of the requested movement
		 * @returns Movement, in case the searched id is found it returns a copy of the movement, null otherwise.
		 **/		
		public function getManetNodeMovement(nodeId:String, movementId:int):Movement
		{
			return this._item.getManetNodeMovement(nodeId, movementId);
		}
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param timestamp:Date, the time of the requested movement
		 * @returns Movement, in case the searched id is found it returns a copy of the movement, null otherwise.
		 **/		
		public function getManetNodeMovementByTimestamp(nodeId:String, timestamp:Date):Movement
		{
			return this._item.getManetNodeMovementByTimestamp(nodeId, timestamp);
		}
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param timestampInit:Date, the start time of the requested movement
		 * @param timestampEnd:Date, the arrival time of the requested movement 
		 * @returns Movement, in case the searched movement according to timestamps is found it returns 
		 * a copy of the movement, null otherwise.
		 **/		
		public function getManetNodeMovementByInitEnd(nodeId:String, timestampInit:Date, timestampEnd:Date):Movement
		{
			return this._item.getManetNodeMovementByInitEnd(nodeId, timestampInit, timestampEnd);
		}
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns TimestampPositionCheckpoint, the first timestamp found in the list of checkpoints if the list
		 * is not empty, null otherwise
		 **/ 		
		public function getManetNodeFirstTimestampPositionCheckpoint(nodeId:String):TimestampPositionCheckpoint
		{
			return this._item.getManetNodeFirstTimestampPositionCheckpoint(nodeId);
		}
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns TimestampPositionCheckpoint, the last timestamp found in the list of checkpoints if the list 
		 * is not empty, null otherwise
		 **/ 		
		public function getManetNodeLastTimestampPositionCheckpoint(nodeId:String):TimestampPositionCheckpoint
		{
			return this._item.getManetNodeLastTimestampPositionCheckpoint(nodeId);
		}
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param timestamp:Date, receives the time of the previous checkpoint of the requested
		 * @returns TimestampPositionCheckpoint, the next checkpoint according to the provided timestamp parameter,
		 * null otherwise
		 **/ 		
		public function getManetNodeNextTimestampPositionCheckpoint(nodeId:String, timestamp:Date):TimestampPositionCheckpoint
		{
			return this._item.getManetNodeNextTimestampPositionCheckpoint(nodeId, timestamp);
		}
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param timestamp:Date, receives a timestamp
		 * @returns TimestampPositionCheckpoint, the immediate previous checkpoint according to the provided timestamp
		 * parameter if that checkpoint exists, null otherwise
		 **/ 		
		public function getManetNodePreviousTimestampPositionCheckpoint(nodeId:String, timestamp:Date):TimestampPositionCheckpoint
		{
			return this._item.getManetNodePreviousTimestampPositionCheckpoint(nodeId, timestamp);
		}			
				
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns int, the size of the movements list (the amount of movements)
		 **/																																										
		public function getManetNodeMovementsSize(nodeId:String):int
		{
			return this._item.getManetNodeMovementsSize(nodeId);
		}
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns int, the size of the movements list (the amount of states)
		 **/		
		public function getManetNodeStatesSize(nodeId:String):int
		{
			return this._item.getManetNodeStatesSize(nodeId);
		}
		
		/**
		 * @returns int, the size of the ManetNode objects list (the amount of ManetNode objects)
		 **/			
		public function getManetNodeTableSize():int
		{
			return this._item.getManetNodeTableSize();
		}

		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns Array, a collection of ids of the states in the list
		 **/
		public function getManetNodeIdStatesArray(nodeId:String):Array
		{
			return this._item.getManetNodeIdStatesArray(nodeId);
		}
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns Array, a collection of ids of the movements in the list
		 **/		
		public function getManetNodeIdMovementsArray(nodeId:String):Array
		{
			return this._item.getManetNodeIdMovementsArray(nodeId);
		}		

	}
}