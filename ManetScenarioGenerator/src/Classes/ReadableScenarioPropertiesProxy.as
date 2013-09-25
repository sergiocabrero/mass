package Classes
{
	import Entities.GoogleInfo;
	import Entities.ScenarioProperties;
	
	import Interfaces.IScenarioPropertiesReadable;
	
	import mx.utils.ObjectProxy;
	
	public class ReadableScenarioPropertiesProxy extends ObjectProxy implements IScenarioPropertiesReadable
	{
		private var _item:ScenarioProperties;
		
		public function ReadableScenarioPropertiesProxy(item:Object=null, uid:String=null, proxyDepth:int=-1)
		{
			super(item, uid, proxyDepth);
			this._item = ScenarioProperties(item);			
		}

		public function get initTime():Date
		{
			return this._item.initTime;
		}
		
		public function get endTime():Date
		{
			return this._item.endTime;
		}
		
		public function get width():int
		{
			return this._item.width;
		}
		
		public function get height():int
		{
			return this._item.height;	
		}
		
		public function get depth():int
		{
			return this._item.depth;	
		}
		
		public function get backgroundImagePath():String
		{
			return this._item.backgroundImagePath;
		}
		
		//FR
		public function get googleMapsInfo():GoogleInfo
		{
			return this._item.googleData;	
		}
	}
}