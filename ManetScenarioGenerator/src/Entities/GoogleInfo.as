package Entities
{
	public class GoogleInfo
	{
		public var _mapType:Object;
		public var _centerMapMode:Object;
		public var _zoomLevel:int;
		public var _latitude:Number;
		public var _longitude:Number;
		public var _location:String;
		public var _visible:Boolean;
		public var _doubleClickMode:String;
		
		public function GoogleInfo(mapType:Object,MapMethodSelectedValue:Object,zoomSliderValue:Number,
		latitudeStepperValue:Number,longitudeStepperValue:Number,locationCaption:String,visible:Boolean,doubleClickMode:String="Shift")
		{
			this._mapType = mapType;
         	this._centerMapMode = MapMethodSelectedValue;
         	this._zoomLevel = zoomSliderValue;
         	this._latitude = latitudeStepperValue;
         	this._longitude = longitudeStepperValue;
         	this._location = locationCaption;
         	this._visible = visible;
         	this._doubleClickMode = doubleClickMode;
		}

	}
}