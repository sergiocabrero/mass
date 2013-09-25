package Entities
{	
	public class Movement
	{
		protected var _fromTimestampPositionCheckpoint:TimestampPositionCheckpoint;
		protected var _toTimestampPositionCheckpoint:TimestampPositionCheckpoint;
		protected var _timestampInit:Date;		
		protected var _trajectory:int;
		protected var _acceleration:int;
		protected var _id:int;
		
		//x from
		//y from
		//x to
		//y to
		//time init
		//time end
		//trajectory
		//acceleration
		//id
		public function Movement(...args)
		{
			switch(args.length){

				case 6:
					this._fromTimestampPositionCheckpoint = new TimestampPositionCheckpoint(args[4], args[0], args[1]);
					this._toTimestampPositionCheckpoint = new TimestampPositionCheckpoint(args[5], args[2], args[3]);
					this._timestampInit = args[4];
					break;
				case 7:
					this._fromTimestampPositionCheckpoint = new TimestampPositionCheckpoint(args[4], args[0], args[1]);
					this._toTimestampPositionCheckpoint = new TimestampPositionCheckpoint(args[5], args[2], args[3]);
					this._timestampInit = args[4];
					this._trajectory = args[6];				
					break;
				case 8:
					this._fromTimestampPositionCheckpoint = new TimestampPositionCheckpoint(args[4], args[0], args[1]);
					this._toTimestampPositionCheckpoint = new TimestampPositionCheckpoint(args[5], args[2], args[3]);
					this._timestampInit = args[4];
					this._trajectory = args[6];
					this._acceleration = args[7];				
					break;	
				case 9:
					this._fromTimestampPositionCheckpoint = new TimestampPositionCheckpoint(args[4], args[0], args[1]);
					this._toTimestampPositionCheckpoint = new TimestampPositionCheckpoint(args[5], args[2], args[3]);
					this._timestampInit = args[4];
					this._trajectory = args[6];
					this._acceleration = args[7];
					this._id = args[8];				
					break;										
				default:
					//FALTA ESTO!!!!!!!!!!!!
					break;
			}							
		}

		public function clone():Movement
		{
			var movementCopy:Movement = new Movement(this._fromTimestampPositionCheckpoint.xCoordinate, this._fromTimestampPositionCheckpoint.yCoordinate,
				this._toTimestampPositionCheckpoint.xCoordinate, this._toTimestampPositionCheckpoint.yCoordinate, this._fromTimestampPositionCheckpoint.pointTime,
				this._toTimestampPositionCheckpoint.pointTime, this._trajectory, this._acceleration, this._id);
				return movementCopy;
		}
		
		public function get fromTimestampPositionCheckpoint():TimestampPositionCheckpoint
		{
			return this._fromTimestampPositionCheckpoint;
		}
		
		public function set fromTimestampPositionCheckpoint(newTimestampPositionCheckpoint:TimestampPositionCheckpoint):void
		{
			this._fromTimestampPositionCheckpoint = newTimestampPositionCheckpoint;
		}
		
		public function get toTimestampPositionCheckpoint():TimestampPositionCheckpoint
		{
			return this._toTimestampPositionCheckpoint;
		}		
		
		public function set toTimestampPositionCheckpoint(newTimestampPositionCheckpoint:TimestampPositionCheckpoint):void
		{
			this._toTimestampPositionCheckpoint = newTimestampPositionCheckpoint;
		}
		
		public function get trajectory():int
		{
			return this._trajectory;
		}
		
		public function set trajectory(newTrajectory:int):void
		{
			this._trajectory = newTrajectory;
		}	
		
		public function get acceleration():int
		{
			return this._acceleration;
		}		
				
		public function set acceleration(newAcceleration:int):void
		{
			this._acceleration = newAcceleration;
		}
		
		public function get id():int
		{
			return this._id;
		}
		
		public function set id(newId:int):void
		{
			this._id = newId;
		}

		public function isNullMovement():Boolean
		{
			if ((this.fromTimestampPositionCheckpoint.xCoordinate == this.toTimestampPositionCheckpoint.xCoordinate) 
				&& (this.fromTimestampPositionCheckpoint.yCoordinate == this.toTimestampPositionCheckpoint.yCoordinate)
				&& (this.fromTimestampPositionCheckpoint.pointTime.time == this.toTimestampPositionCheckpoint.pointTime.time))
			{
				return true;
			}	
			else
			{
				return false;
			}
		}
		
	}
}