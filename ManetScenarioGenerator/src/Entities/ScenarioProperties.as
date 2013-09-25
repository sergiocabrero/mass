package Entities
{
	import Classes.ModelPropertyChangeEventKind;
	import Classes.ModelPropertyChangeEventType;
	import Classes.ModelSingleton;
	
	import flash.events.EventDispatcher;
	
	import mx.events.PropertyChangeEvent;
	
	public class ScenarioProperties extends EventDispatcher
	{
		protected var _initTime:Date;
		protected var _endTime:Date;
		protected var _width:int = 400;
		protected var _height:int = 300;
		protected var _depth:int = 100;
		protected var _backgroundImagePath:String = "";
		protected var _googleData:GoogleInfo;	//FR
		protected var _eastern:Number;			//FR
		protected var _southern:Number;			//FR
		protected var _tracesData:Array;		//FR
		protected var _connectedToInternet:Boolean; //FR
		protected var _googleMobilityValue:Number; //FR
		
		//public function ScenarioProperties(initTime:Date = "01/01/2009", width:int = 100, height:int = 100, depth:int = 100, backgroundImagePath:String = "")
		public function ScenarioProperties(initTime:Date, width:int, height:int, depth:int, backgroundImagePath:String, endTime:Date = null,
		data:GoogleInfo = null, eastern:Number = -1, southern:Number = -1, tracesData:Array = null, connectedToInternet:Boolean = false,
		googleMobilityValue:Number = -1)//FR
		//public function ScenarioProperties(initTime:Date, width:int, height:int, depth:int, backgroundImagePath:String, endTime:Date = null)
		{
			if (initTime != null)
			{
				this._initTime = new Date(initTime.time);
			}else{
			    this._initTime=null; 
			}

			this._width = width;
			this._height = height;
			this._depth = depth;
			this._backgroundImagePath = backgroundImagePath;
			if (endTime != null)
			{
				this._endTime = new Date(endTime.time);
			}
			if (data != null)//FR
				this._googleData = data;//FR
			if (eastern != -1)//FR
				this._eastern = eastern;//FR	
			if (southern != -1)//FR
				this._southern = southern;//FR
			if (tracesData != null)//FR
				this._tracesData = tracesData;//FR
			this._connectedToInternet = connectedToInternet;//FR
			this._googleMobilityValue = googleMobilityValue;//FR		
				
		}

		public function clone():ScenarioProperties
		{
			/*var newScenarioProperties:ScenarioProperties = new ScenarioProperties(this._initTime, this._width, this._height, this._depth, 
				this._backgroundImagePath, this._endTime);*/
			var newScenarioProperties:ScenarioProperties = new ScenarioProperties(this._initTime, this._width, this._height, this._depth, 
				this._backgroundImagePath, this._endTime, this._googleData, this._eastern, this._southern, this._tracesData,
				this._connectedToInternet, this._googleMobilityValue);
			return newScenarioProperties;
		}	

		public function get initTime():Date
		{
			return this._initTime;
		}
		
		public function set initTime(newTime:Date):void
		{
			var oldValue:ScenarioProperties = this.clone();
			if (newTime != null)
			{
				this._initTime = new Date(newTime.time);
			}
			else
			{
				this._initTime = null;
			}
			if(!ModelSingleton.getSingletonInstance().isLocked())
			{				
				var newValue:ScenarioProperties = this.clone();	
				var newPropertyChangeEvent:PropertyChangeEvent = new PropertyChangeEvent(ModelPropertyChangeEventType.SCENARIOPROPERTIES_CHANGE_EVENT,
					false, false, ModelPropertyChangeEventKind.SET_SCENARIO_INIT_TIME, this._initTime, oldValue, newValue, this);	
				this.dispatchEvent(newPropertyChangeEvent);
			}		
		}
		
		public function get endTime():Date
		{
			return this._endTime;	
		}
		
		public function set endTime(newTime:Date):void
		{
			var oldValue:ScenarioProperties = this.clone();
			if (newTime != null)
			{
				this._endTime = new Date(newTime.time);
			}
			else
			{
				this._endTime = null;
			}	
			if(!ModelSingleton.getSingletonInstance().isLocked())
			{			
				var newValue:ScenarioProperties = this.clone();
				var newPropertyChangeEvent:PropertyChangeEvent = new PropertyChangeEvent(ModelPropertyChangeEventType.SCENARIOPROPERTIES_CHANGE_EVENT,
					false, false, ModelPropertyChangeEventKind.SET_SCENARIO_END_TIME, this._endTime, oldValue, newValue, this);	
				this.dispatchEvent(newPropertyChangeEvent);	
			}				
		}
		
		public function get width():int
		{
			return this._width;
		}
		
		public function set width(newWidth:int):void
		{
			var oldValue:ScenarioProperties = this.clone();
			this._width = newWidth;
			if(!ModelSingleton.getSingletonInstance().isLocked())
			{			
				var newValue:ScenarioProperties = this.clone();
				var newPropertyChangeEvent:PropertyChangeEvent = new PropertyChangeEvent(ModelPropertyChangeEventType.SCENARIOPROPERTIES_CHANGE_EVENT,
					false, false, ModelPropertyChangeEventKind.SET_SCENARIO_WIDTH, this._width, oldValue, newValue, this);	
				this.dispatchEvent(newPropertyChangeEvent);	
			}					
		}

		public function get height():int
		{
			return this._height;
		}
		
		public function set height(newHeight:int):void
		{
			var oldValue:ScenarioProperties = this.clone();
			this._height = newHeight;
			if(!ModelSingleton.getSingletonInstance().isLocked())
			{			
				var newValue:ScenarioProperties = this.clone();
				var newPropertyChangeEvent:PropertyChangeEvent = new PropertyChangeEvent(ModelPropertyChangeEventType.SCENARIOPROPERTIES_CHANGE_EVENT,
					false, false, ModelPropertyChangeEventKind.SET_SCENARIO_HEIGHT, this._height, oldValue, newValue, this);	
				this.dispatchEvent(newPropertyChangeEvent);		
			}			
		}

		public function get depth():int
		{
			return this._depth;
		}
		
		public function set depth(newDepth:int):void
		{
			var oldValue:ScenarioProperties = this.clone();
			this._depth = newDepth;
			if(!ModelSingleton.getSingletonInstance().isLocked())
			{			
				var newValue:ScenarioProperties = this.clone();
				var newPropertyChangeEvent:PropertyChangeEvent = new PropertyChangeEvent(ModelPropertyChangeEventType.SCENARIOPROPERTIES_CHANGE_EVENT,
					false, false, ModelPropertyChangeEventKind.SET_SCENARIO_DEPTH, this._depth, oldValue, newValue, this);	
				this.dispatchEvent(newPropertyChangeEvent);	
			}				
		}
		
		public function get backgroundImagePath():String
		{
			return this._backgroundImagePath;
		}
		
		public function set backgroundImagePath(newBackgroundImagePath:String):void
		{
			var oldValue:ScenarioProperties = this.clone();
			this._backgroundImagePath = newBackgroundImagePath;
			if(!ModelSingleton.getSingletonInstance().isLocked())
			{			
				var newValue:ScenarioProperties = this.clone();
				var newPropertyChangeEvent:PropertyChangeEvent = new PropertyChangeEvent(ModelPropertyChangeEventType.SCENARIOPROPERTIES_CHANGE_EVENT,
					false, false, ModelPropertyChangeEventKind.SET_SCENARIO_BACKGROUND_IMAGE_PATH, this._backgroundImagePath, oldValue, newValue, this);	
				this.dispatchEvent(newPropertyChangeEvent);	
			}				
		}
		
		public function initialize():void
		{		
			this.initTime = null;
			this.endTime = null;
			this.width = 400;
			this.height = 300;
			this.depth = 100;
			this.backgroundImagePath = null;
			//this._googleData = null; //FR	
			this.googleData = null;		//FR
			this.eastern = -1; //FR
			this.southern = -1; //FR
			//this._tracesData = null; //FR
			//this._connectedToInternet = null; //FR
			this._googleMobilityValue = -1; //FR
		}
		
		//FR
		public function set googleData(newGoogleData:GoogleInfo):void
		{
			var oldValue:ScenarioProperties = this.clone();
			this._googleData = newGoogleData;
			if(!ModelSingleton.getSingletonInstance().isLocked())
			{			
				var newValue:ScenarioProperties = this.clone();
				var newPropertyChangeEvent:PropertyChangeEvent = new PropertyChangeEvent(ModelPropertyChangeEventType.SCENARIOPROPERTIES_CHANGE_EVENT,
					false, false, ModelPropertyChangeEventKind.SET_GOOGLEMAP, this._googleData, oldValue, newValue, this);	
				this.dispatchEvent(newPropertyChangeEvent);	
			}		
		}
		
		public function get googleData():GoogleInfo
		{
			return this._googleData;
		}
		
		public function get eastern():Number
		{
			return this._eastern;	
		}
		
		public function set eastern(newEastern:Number):void
		{
			var oldValue:ScenarioProperties = this.clone();
			if (newEastern != -1)
			{
				this._eastern = newEastern;
			}
			else
			{
				this._eastern = -1;
			}	
			if(!ModelSingleton.getSingletonInstance().isLocked())
			{			
				var newValue:ScenarioProperties = this.clone();
				var newPropertyChangeEvent:PropertyChangeEvent = new PropertyChangeEvent(ModelPropertyChangeEventType.SCENARIOPROPERTIES_CHANGE_EVENT,
					false, false, ModelPropertyChangeEventKind.SET_SCENARIO_EASTERN_POSITION, this._eastern, oldValue, newValue, this);	
				this.dispatchEvent(newPropertyChangeEvent);	
			}				
		}
		
		public function get southern():Number
		{
			return this._southern;	
		}
		
		public function set southern(newSouthern:Number):void
		{
			var oldValue:ScenarioProperties = this.clone();
			if (newSouthern != -1)
			{
				this._southern = newSouthern;
			}
			else
			{
				this._southern = -1;
			}	
			if(!ModelSingleton.getSingletonInstance().isLocked())
			{			
				var newValue:ScenarioProperties = this.clone();
				var newPropertyChangeEvent:PropertyChangeEvent = new PropertyChangeEvent(ModelPropertyChangeEventType.SCENARIOPROPERTIES_CHANGE_EVENT,
					false, false, ModelPropertyChangeEventKind.SET_SCENARIO_SOUTHERN_POSITION, this._southern, oldValue, newValue, this);	
				this.dispatchEvent(newPropertyChangeEvent);	
			}				
		}
		
		public function get tracesData():Array
		{
			return this._tracesData;	
		}
		
		public function set tracesData(newTraces:Array):void
		{
			var oldValue:ScenarioProperties = this.clone();
			this._tracesData = newTraces;
				
			if(!ModelSingleton.getSingletonInstance().isLocked())
			{			
				var newValue:ScenarioProperties = this.clone();
				var newPropertyChangeEvent:PropertyChangeEvent = new PropertyChangeEvent(ModelPropertyChangeEventType.SCENARIOPROPERTIES_CHANGE_EVENT,
					false, false, ModelPropertyChangeEventKind.SET_TRACES, this._tracesData, oldValue, newValue, this);
				this.dispatchEvent(newPropertyChangeEvent);	
			}				
		}
		
		public function get connectedToInternet():Boolean
		{
			return this._connectedToInternet;	
		}
		
		public function set connectedToInternet(connected:Boolean):void
		{
			var oldValue:ScenarioProperties = this.clone();
			this._connectedToInternet = connected;
				
			if(!ModelSingleton.getSingletonInstance().isLocked())
			{			
				var newValue:ScenarioProperties = this.clone();
				var newPropertyChangeEvent:PropertyChangeEvent = new PropertyChangeEvent(ModelPropertyChangeEventType.SCENARIOPROPERTIES_CHANGE_EVENT,
					false, false, ModelPropertyChangeEventKind.SET_CONNECTED, this._tracesData, oldValue, newValue, this);
				this.dispatchEvent(newPropertyChangeEvent);	
			}				
		}
		
		public function get googleMobilityValue():Number
		{
			return this._googleMobilityValue;	
		}
		
		public function set googleMobilityValue(googleMobValue:Number):void
		{
			var oldValue:ScenarioProperties = this.clone();
			this._googleMobilityValue = googleMobValue;
				
			if(!ModelSingleton.getSingletonInstance().isLocked())
			{			
				var newValue:ScenarioProperties = this.clone();
				var newPropertyChangeEvent:PropertyChangeEvent = new PropertyChangeEvent(ModelPropertyChangeEventType.SCENARIOPROPERTIES_CHANGE_EVENT,
					false, false, ModelPropertyChangeEventKind.GOOGLE_MOBILITY_VALUE, this._tracesData, oldValue, newValue, this);
				this.dispatchEvent(newPropertyChangeEvent);	
			}				
		}
	

	}
}