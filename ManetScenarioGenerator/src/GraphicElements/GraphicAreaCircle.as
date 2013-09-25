package GraphicElements
{
	import Classes.DisplayPropertiesSingleton;
	import Classes.ModelSingleton;
	
	import de.polygonal.ds.DLL;
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.Image;
	import mx.events.FlexEvent;
	import mx.formatters.DateFormatter;

    public class GraphicAreaCircle extends Image
    {
        protected var _radius:Number=10;
        protected var _graphics:Graphics;
        protected var _fillColour:uint=0x99cc00;
        protected var _strokeColour:uint=0x000000;
        protected var _selectionColour:uint = 0xFFFFFF;
        protected var _popup:Object;
        protected var _popper:PopperForArea = new PopperForArea;
        protected var _instantTime:Date = new Date();
		protected var _drawRange:Boolean = true;
        //protected var _previousTrajectory:GraphicTrajectory = null;
       // protected var _nextTrajectory:GraphicTrajectory = null;
        protected var _textPos:String = "";
        protected var _isDragging:Boolean = false; 
        protected var _manetNodeParentId:String;
		protected var _rangeAlpha:Number = 0.3;
		
		protected var _dllAssociatedLinks:DLL;
        
        protected var displayPropertiesInstance:DisplayPropertiesSingleton;
        protected var modelInstance:ModelSingleton;
        
        public function GraphicAreaCircle(radius:Number = 10, colourFill:uint = 0x99cc00, colourStroke:uint = 0x000000, 
        	drawRange:Boolean = true, initTime:Date = null, checkpointManetNodeParentId:String = "", rangeAlpha:Number = 0.3)
        {
            super();
            this._dllAssociatedLinks = new DLL();
            this.width = (radius*2)+10 +150;
            this.height = (radius*2)+10;
            this._radius = radius;
            this._fillColour = colourFill;
            this._strokeColour = colourStroke;
            this._instantTime = initTime;
            this._manetNodeParentId = checkpointManetNodeParentId;
            this._drawRange = drawRange;
          	this._popup = new Object();
			this.enabled = false;
			this._rangeAlpha = rangeAlpha;
           	this._popup.color = colourFill;
            this.addEventListener(MouseEvent.ROLL_OVER, showPop,false,0,true);    
            this.addEventListener(MouseEvent.ROLL_OUT, hidePop,false,0,true);
            this.addEventListener(FlexEvent.CREATION_COMPLETE, doCircle,false,0,true);       
        }
        
        public function isBasicEquivalentCircle(otherCircle:GraphicAreaCircle):Boolean
        {
        	if (this._drawRange == otherCircle.drawRange &&
        		this._fillColour == otherCircle.colourFill &&
        		this._radius == otherCircle.radius &&
        		this._rangeAlpha == otherCircle.rangeAlpha &&
        		this._strokeColour == otherCircle.colourStroke)
        	{
        		return true;
        	}	
        	else
        	{
        		return false;
        	}
        }
        
        public function get radius():Number
        {
        	return this._radius;
        }
        
        public function set radius(newRadius:Number):void
        {
        	this._radius = newRadius;
        }
        
        public function get instantTime():Date
        {
        	return this._instantTime;
        }     
     		
 
        public function set instantTime(newInstantTime:Date):void
        {
        	try
        	{
	        	this._instantTime = new Date(newInstantTime.time); 
	        	this.displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
				var dateFormatter:DateFormatter = new DateFormatter();
				dateFormatter.formatString = "JJ:NN:SS";        	
				var textTimeInstant:String;
				if (this._instantTime)
				{
					textTimeInstant = dateFormatter.format(this._instantTime);
				}        	
				this._textPos = "x = " + (this.x/this.displayPropertiesInstance.scaleFactor).toString() +
					 "\ny = " + (this.y/this.displayPropertiesInstance.scaleFactor).toString();        	
	        	this._popper.updateText(_textPos + "\nt: " + textTimeInstant);
	        }
	        catch(err:Error)
	        {
	        	trace(err.message);
	        }	 
        	   	
        }    
        
        public function get colourFill():uint
        {
        	return this._fillColour;
        }
        
        public function set colourFill(newColour:uint):void
        {
        	this._fillColour = newColour;
        }
        
        public function get colourStroke():uint
        {
        	return this._strokeColour;
        }
        
        public function set colourStroke(newColourStroke:uint):void
        {
        	this._strokeColour = newColourStroke;
        } 
        
        public function get rangeAlpha():Number
        {
        	return this._rangeAlpha
        }
        
        public function set rangeAlpha(newAlpha:Number):void
        {
        	this._rangeAlpha = newAlpha;
        }       
        
        public function get drawRange():Boolean
        {
        	return this._drawRange;
        }
        
        public function set drawRange(drawR:Boolean):void
        {
        	this._drawRange = drawR;
        } 
        
        public function get manetNodeParentId():String
        {
        	return this._manetNodeParentId;
        }
        
        public function set manetNodeParentId(newManetNodeParentId:String):void
        {
        	this._manetNodeParentId = newManetNodeParentId;
        }         
        
        protected function showPop(evt:MouseEvent):void 
        { 
        	this.displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
        	this._popper = new PopperForArea();     
        	     
			this._popper.x=this.mouseX-(_popper.width/2);
			this._popper.y=this.mouseY-(_popper.height + this.height);
			this.addChild(_popper);
			
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "JJ:NN:SS";
			this._textPos = "x = " + (this.x/this.displayPropertiesInstance.scaleFactor).toString() +
				 "\ny = " + (this.y/this.displayPropertiesInstance.scaleFactor).toString();
			var textTimeInstant:String;
			if (this._instantTime)
			{
				textTimeInstant = dateFormatter.format(this._instantTime);
			}
			

			this.modelInstance = ModelSingleton.getSingletonInstance();
			var scenarioWidth:Number = this.modelInstance.scenarioPropertiesCallableProxy.width;
			var scenarioHeight:Number = this.modelInstance.scenarioPropertiesCallableProxy.height;
			var messagePosition:String = "up";
			//Parte izquierda
			if (this.x < 70)
			{
				//Parte superior
				if (this.y < 70)
				{
					messagePosition = "down-right";
				}
				//Parte media
				else if (70 <= this.y < (scenarioHeight -70))
				{
					messagePosition = "right";
				}
				//Parte inferior	 
				else
				{
					messagePosition = "up-right";
				}
			}
			//Parte media
			else if (70 <= this.x < (scenarioWidth - 70))
			{	
				//Parte superior
				if (this.y < 70)
				{
					messagePosition = "down";
				}
				//Resto
				else
				{
					messagePosition = "up";
				}
			}
			//Parte derecha
			else
			{
				//Parte superior
				if (this.y < 70)
				{
					messagePosition = "down-left";
				}
				//Parte media
				else if (70 <= this.y < (scenarioHeight -70))
				{
					messagePosition = "left";
				}
				//Parte inferior
				else
				{
					messagePosition = "up-left";
				}
			}
			this._popper.show(_popup.color, _textPos + "\nt: " + textTimeInstant, messagePosition, this._radius);
        }
        
        protected function hidePop(evt:MouseEvent):void 
        {
        	try
        	{
           		this.removeChild(this._popper);
           		this._popper.removeAllChildren();
         	}
			catch(thrownError:Error)
			{
				return;
			}
			return;
         		
        }
        
	     protected function doCircle(evt:Event):void 
	     {
	         _graphics = this.graphics;
	         if (this._drawRange)
	         {
		         _graphics.lineStyle(1, this._strokeColour, this._rangeAlpha);
		         _graphics.beginFill(this._fillColour, this._rangeAlpha);
		         //_graphics.drawCircle(5, 5, this._radius);
		         _graphics.drawCircle(0, 0, this._radius);
	         }
	         

	         var iconito:Image = new Image();
	         iconito.load("../GraphicElements/iconsPrueba/fireman_avatar.png");
	         iconito.width = 25;
	         iconito.height = 25;
	         //iconito.x = -5;
	         //iconito.y = -5;
	         iconito.x = 0;
	         iconito.y = 0;
	         this.addChild(iconito);
	     }       		       
         
  }	
}