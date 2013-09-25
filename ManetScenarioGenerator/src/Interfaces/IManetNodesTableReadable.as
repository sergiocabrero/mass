package Interfaces
{
	import Entities.ManetNode;
	import Entities.Movement;
	import Entities.NodeState;
	import Entities.TimestampPositionCheckpoint;
	
	public interface IManetNodesTableReadable
	{
		/**
		 * @param idNode:String, the id of the ManetNode to search
		 * @return ManetNode, a copy of the ManetNode found in the table, null otherwise
		 **/ 
		function getManetNode(idNode:String):ManetNode;
		
		/**
		 * @returns Array, a collection of ids of the ManetNode objects in the table
		 **/		
		function getIdManetNodesArray():Array;
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns int, the value of the current range
		 **/			
		function getManetNodeRange(nodeId:String):int;
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns int, the value of the current direction
		 **/			
		function getManetNodeDirection(nodeId:String):int;	
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns String, the value of the current pattern
		 **/		
		function getManetNodePattern(nodeId:String):String;	
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param timestamp:Date, receives the time related to the requested state
		 * @returns a NodeState object, a copy of the state in the table corresponding with the requested time or null if it does not exist
		 **/		
		function getManetNodeStateByTimestamp(nodeId:String, timestamp:Date):NodeState;
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param nodeStateId:int, receives the id of the requested state
		 * @returns a NodeState object, a copy of the state in the table corresponding with the requested id or null if it does not exist
		 **/		
		function getManetNodeState(nodeId:String, nodeStateId:int):NodeState;
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns a NodeState object, a copy of the first state of the table (chronologically ordered) 
		 **/		
		function getManetNodeFirstState(nodeId:String):NodeState;
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns a NodeState object, a copy of the last state of the table (chronologically ordered) 
		 **/		
		function getManetNodeLastState(nodeId:String):NodeState	;
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param nodeStateId:int, receives the id of the previous state of the requested
		 * @returns a NodeState object, a copy of the state of the table corresponding with the next state 
		 * to the requested id or null if it does not exist
		 **/		
		function getManetNodeNextState(nodeId:String, nodeStateId:int):NodeState;
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param nodeStateId:int, receives the id of the previous state of the requested
		 * @returns a NodeState object, a copy of the state of the table corresponding with the previous state 
		 * to the requested id or null if it does not exist
		 **/		
		function getManetNodePreviousState(nodeId:String, nodeStateId:int):NodeState;	
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param nodeStateId:int, the id of the state to check
		 * @returns Boolean, true if the provided nodeStateId corresponds to the first state of the list (chronologically ordered)   
		 **/			
		function isManetNodeFirstState(nodeId:String, nodeStateId:int):Boolean;
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param nodeStateId:int, the id of the state to check
		 * @returns Boolean, true if the provided nodeStateId corresponds to the last state of the list (chronologically ordered)   
		 **/		
		function isManetNodeLastState(nodeId:String, nodeStateId:int):Boolean;	
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param movementId:int, the id of the movement to check
		 * @returns Boolean, true if the provided nodeStateId corresponds to the first movement of the list (chronologically ordered)   
		 **/		
		function isManetNodeFirstMovement(nodeId:String, movementId:int):Boolean;	
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param movementId:int, the id of the movement to check
		 * @returns Boolean, true if the provided nodeStateId corresponds to the last movement of the list (chronologically ordered)   
		 **/			
		function isManetNodeLastMovement(nodeId:String, movementId:int):Boolean;
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns Movement, the first movement of the list (chronologically ordered), null if the list is empty
		 **/		
		function getManetNodeFirstMovement(nodeId:String):Movement;
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns Movement, the last movement of the list (chronologically ordered), null if the list is empty
		 **/		
		function getManetNodeLastMovement(nodeId:String):Movement;	
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param timestampInit:Date, receives the start time of the previous movement of the requested
		 * @param timestampEnd:Date, receives the start time of the previous movement of the requested
		 * @returns Movement object, a copy of the movement of the table corresponding with the next movement 
		 * of the movement starting and ending at the requested timestamps or null otherwise
		 **/	
		function getManetNodeNextMovementByInitEnd(nodeId:String, timestampInit:Date, timestampEnd:Date):Movement;	
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param timestamp:Date, receives the time of a checkpoint
		 * @returns TimestampPositionCheckpoint object, a copy of the checkpoint corresponding with the first match,
		 * being a movement start or end point 
		 **/		
		function getManetNodeTimestampPositionCheckpoint(nodeId:String, timestamp:Date):TimestampPositionCheckpoint;	
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param timestampInit:Date, receives the start time of the next movement of the requested
		 * @param timestampEnd:Date, receives the start time of the next movement of the requested
		 * @returns Movement object, a copy of the movement of the table corresponding with the previous movement 
		 * of the movement starting and ending at the requested timestamps or null otherwise
		 **/			
		function getManetNodePreviousMovementByInitEnd(nodeId:String, timestampInit:Date, timestampEnd:Date):Movement;	
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param movementId:int, receives the id of the previous movement of the requested
		 * @returns Movement object, a copy of the movement of the table corresponding with the next movement 
		 * to the requested id or null if it does not exist
		 **/
		function getManetNodeNextMovement(nodeId:String, movementId:int):Movement;	
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param movementId:int, receives the id of the next movement of the requested
		 * @returns Movement object, a copy of the movement of the table corresponding with the next movement 
		 * to the requested id or null if it does not exist
		 **/		
		function getManeNodePreviousMovement(nodeId:String, movementId:int):Movement;	
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param timestamp:Date, the time to search in the list of PositionCheckpoints
		 * @returns TimestampPositionCheckpoint, in case the searched time is found it returns a copy of the position.
		 * If is not found but the time is between two existing time checkpoints it returns a interpolated TimestampPositionCheckpoint,
		 * null otherwise
		 **/					
		function getManetNodeEstimatedTimestampPositionCheckpoint(nodeId:String, timestamp:Date):TimestampPositionCheckpoint;	
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param movementId:int, the id of the requested movement
		 * @returns Movement, in case the searched id is found it returns a copy of the movement, null otherwise.
		 **/		
		function getManetNodeMovement(nodeId:String, movementId:int):Movement;
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param timestamp:Date, the time of the requested movement
		 * @returns Movement, in case the searched id is found it returns a copy of the movement, null otherwise.
		 **/		
		function getManetNodeMovementByTimestamp(nodeId:String, timestamp:Date):Movement;	
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param timestampInit:Date, the start time of the requested movement
		 * @param timestampEnd:Date, the arrival time of the requested movement 
		 * @returns Movement, in case the searched movement according to timestamps is found it returns 
		 * a copy of the movement, null otherwise.
		 **/		
		function getManetNodeMovementByInitEnd(nodeId:String, timestampInit:Date, timestampEnd:Date):Movement;	
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns TimestampPositionCheckpoint, the first timestamp found in the list of checkpoints if the list
		 * is not empty, null otherwise
		 **/ 		
		function getManetNodeFirstTimestampPositionCheckpoint(nodeId:String):TimestampPositionCheckpoint;	
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns TimestampPositionCheckpoint, the last timestamp found in the list of checkpoints if the list 
		 * is not empty, null otherwise
		 **/ 		
		function getManetNodeLastTimestampPositionCheckpoint(nodeId:String):TimestampPositionCheckpoint;		
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param timestamp:Date, receives the time of the previous checkpoint of the requested
		 * @returns TimestampPositionCheckpoint, the next checkpoint according to the provided timestamp parameter,
		 * null otherwise
		 **/ 		
		function getManetNodeNextTimestampPositionCheckpoint(nodeId:String, timestamp:Date):TimestampPositionCheckpoint;	
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @param timestamp:Date, receives a timestamp
		 * @returns TimestampPositionCheckpoint, the immediate previous checkpoint according to the provided timestamp
		 * parameter if that checkpoint exists, null otherwise
		 **/ 		
		function getManetNodePreviousTimestampPositionCheckpoint(nodeId:String, timestamp:Date):TimestampPositionCheckpoint;		
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns int, the size of the movements list (the amount of movements)
		 **/																																										
		function getManetNodeMovementsSize(nodeId:String):int;
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns int, the size of the movements list (the amount of states)
		 **/		
		function getManetNodeStatesSize(nodeId:String):int;	
		
		/**
		 * @returns int, the size of the ManetNode objects list (the amount of ManetNode objects)
		 **/			
		function getManetNodeTableSize():int;	
		
		/**
		 * @param nodeId:String, the id of the ManetNode
		 * @returns Array, a collection of ids of the states in the list
		 **/
		function getManetNodeIdStatesArray(nodeId:String):Array;
																																									
	}
}