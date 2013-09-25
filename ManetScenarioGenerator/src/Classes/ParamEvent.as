package Classes
{
	import flash.events.Event;

	public class ParamEvent extends Event
	{
		private var _params:Object;
		
		public function ParamEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._params = new Object();
			
		}

		override public function clone():Event 
		{
			return new ParamEvent(type, bubbles, cancelable);
		}	
		
		public function set params(obj:Object):void
		{				
			for (var i:Object in obj)
				this._params[i] = obj[i];
		}
		
		public function get params():Object
		{
			if (!this._params)
				this._params = {};
				
			return this._params;
		}
		
		
	}
}