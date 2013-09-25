package Classes
{
	import Entities.GoogleInfo;
	
	import flash.events.Event;

	public class GoogleEvent extends Event
	{
		public static const GOOGLEMAPSEVENT:String="GoogleMapsEvent";
		public var googleData:GoogleInfo;
		
		public function GoogleEvent(type:String,info:GoogleInfo)
		{
			super(type, true, false);
			this.googleData=info;
			
		}

		override public function clone():Event 
		{
			return new GoogleEvent(type,googleData);
		}

	}
}