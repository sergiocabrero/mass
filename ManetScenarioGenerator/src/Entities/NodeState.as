package Entities
{
	import mx.events.IndexChangedEvent;
	
	public class NodeState
	{

		protected var _switchedOn:Boolean;
		protected var _timestamp:Date;
		protected var _id:int;
		protected var _xCoordinate:int = -1;
		protected var _yCoordinate:int = -1;
		protected var _zCoordinate:int = -1;

		public function NodeState(timestamp:Date, isSwitchedOn:Boolean, nodeId:int, xCoord:int = -1, yCoord:int = -1, zCoord:int = -1)
		{
			this._timestamp = timestamp;
			this._switchedOn = isSwitchedOn;		
			this._id = nodeId;
			this._xCoordinate = xCoord;
			this._yCoordinate = yCoord;
			this._zCoordinate = zCoord;
		}
		
		public function clone():NodeState
		{
			var nodeStateCopy:NodeState = new NodeState(this._timestamp, this._switchedOn, this._id, this._xCoordinate, 
				this._yCoordinate, this._zCoordinate);
			return nodeStateCopy;
		}
		
		public function set xCoordinate(newValue:int):void
		{
			this._xCoordinate = newValue;
		}
		
		public function get xCoordinate():int
		{
			return this._xCoordinate;
		}

		public function set yCoordinate(newValue:int):void
		{
			this._yCoordinate = newValue;
		}
		
		public function get yCoordinate():int
		{
			return this._yCoordinate;
		}
		
		public function set zCoordinate(newValue:int):void
		{
			this._zCoordinate = newValue;
		}
		
		public function get zCoordinate():int
		{
			return this._zCoordinate;
		}		
		
		public function set switchedOn(newSwitched:Boolean):void
		{
			this._switchedOn = newSwitched;
		}
		
		public function  get switchedOn():Boolean
		{
			return this._switchedOn;
		}
		
		public function set timestamp(newTimestamp:Date):void
		{
			this._timestamp = newTimestamp;
		}
		
		public function get timestamp():Date
		{
			return this._timestamp;	
		}

		public function get id():int
		{
			return this._id;
		}
		
		public function set id(newId:int):void
		{
			this._id = newId;
		}

	}
}