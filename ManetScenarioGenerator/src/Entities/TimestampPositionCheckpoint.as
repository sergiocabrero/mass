package Entities
{
	public class TimestampPositionCheckpoint
	{
		protected var _time:Date;
		protected var _xCoordinate:int;
		protected var _yCoordinate:int;
		
		public function TimestampPositionCheckpoint(time:Date, x:int = 0, y:int = 0)
		{
			if (x>=0 && x<500000 && y>=0 && y<500000)
			{
				this._xCoordinate = x;
				this._yCoordinate = y;
			}
			else
			{
				this._xCoordinate = 0;
				this._yCoordinate = 0;
			}
			
			this._time = time;
		}
		
		public function clone():TimestampPositionCheckpoint
		{
			var newPositionCheckpoint:TimestampPositionCheckpoint = new TimestampPositionCheckpoint(this._time, this._xCoordinate,
				this._yCoordinate);
			return newPositionCheckpoint;
		}

		public function set xCoordinate(x:int):void
		{
			if (x>=0 && x<500000)
			{
				this._xCoordinate = x;
			}
		}
		
		public function get xCoordinate():int
		{
			return this._xCoordinate;
		}

		public function set yCoordinate(y:int):void
		{
			if (y>0 && y<500000)
			{
				this._yCoordinate = y;
			}			
		}
		
		public function get yCoordinate():int
		{
			return this._yCoordinate;
		}

		public function set pointTime(time:Date):void
		{
			this._time = time;
		}
		
		public function get pointTime():Date
		{
			return this._time;
		}

	}
}