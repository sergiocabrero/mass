package Classes
{
	import Entities.GoogleInfo;
	import Entities.ScenarioProperties;
	
	import Interfaces.IScenarioPropertiesReadable;
	import Interfaces.IScenarioPropertiesWritable;
	
	import mx.utils.ObjectProxy;

	//Proxy de acceso a las propiedades del escenario
	public class CallableScenarioPropertiesProxy extends ObjectProxy implements IScenarioPropertiesReadable, IScenarioPropertiesWritable
	{
		private var _item:ScenarioProperties;
		
		public function CallableScenarioPropertiesProxy(item:Object=null, uid:String=null, proxyDepth:int=-1)
		{
			super(item, uid, proxyDepth);
			this._item = ScenarioProperties(item);
		}

		public function get initTime():Date
		{
			return this._item.initTime;
		}
		
		public function set initTime(newTime:Date):void
		{
			this._item.initTime = newTime;	
		}
		
		public function get endTime():Date
		{
			return this._item.endTime;
		}
		
		public function set endTime(newTime:Date):void
		{
			this._item.endTime = newTime;	
		}
		
		public function get width():int
		{
			return this._item.width;
		}
		
		public function set width(newWidth:int):void
		{
			this._item.width = newWidth;	
		}

		public function get height():int
		{
			return this._item.height;
		}
		
		public function set height(newHeight:int):void
		{
			this._item.height = newHeight;
		}

		public function get depth():int
		{
			return this._item.depth;
		}
		
		public function set depth(newDepth:int):void
		{
			this._item.depth = newDepth;
		}
		
		public function get backgroundImagePath():String
		{
			return this._item.backgroundImagePath;
		}
		
		public function set backgroundImagePath(newBackgroundImagePath:String):void
		{
			this._item.backgroundImagePath = newBackgroundImagePath;
		}		

		//FR
		public function get googleMapsInfo():GoogleInfo
		{
			return this._item.googleData;
		}
		public function set googleMapsInfo(googleData:GoogleInfo):void
		{
			this._item.googleData = googleData;
		}
		public function get eastern():Number
		{
			return this._item.eastern;
		}
		public function set eastern(newEastern:Number):void
		{
			this._item.eastern = newEastern;
		}
		public function get southern():Number
		{
			return this._item.southern;
		}
		public function set southern(newSouthern:Number):void
		{
			this._item.southern = newSouthern;
		}
		public function get tracesData():Array
		{
			return this._item.tracesData;
		}
		public function set tracesData(newTraces:Array):void
		{
			this._item.tracesData = newTraces;
		}
		public function get connectedToInternet():Boolean
		{
			return this._item.connectedToInternet;
		}
		public function set connectedToInternet(connectedToInternet:Boolean):void
		{
			this._item.connectedToInternet = connectedToInternet;
		}
		public function get googleMobilityValue():Number
		{
			return this._item.googleMobilityValue;
		}
		public function set googleMobilityValue(googleMobilityValue:Number):void
		{
			this._item.googleMobilityValue = googleMobilityValue;
		}
		
	}
}