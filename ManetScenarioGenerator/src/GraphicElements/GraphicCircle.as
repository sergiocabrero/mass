package GraphicElements
{
	import Classes.DisplayPropertiesSingleton;
	import Classes.ModelSingleton;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	import mx.formatters.DateFormatter;
	import mx.managers.CursorManagerPriority;

    public class GraphicCircle extends Image
    {
        protected var _radius:Number=10;
        protected var _graphics:Graphics;
        protected var _fillColour:uint=0x99cc00;
        protected var _strokeColour:uint=0x000000;
        protected var _selectionColour:uint = 0xFFFFFF;
        protected var _popup:Object;
        protected var _popper:Popper = new Popper;
        
        protected var _initTime:Date = null;
        protected var _endTime:Date = null;
        protected var _previousTrajectory:GraphicTrajectory = null;
        protected var _nextTrajectory:GraphicTrajectory = null;
        protected var _textPos:String = "";
        protected var _isDragging:Boolean = false; 
        protected var _manetNodeParentId:String;
        protected var _isSelected:Boolean = false;
		protected var _currentCursorId:int;
		protected var _canvasToPopUp:Canvas;
        
        protected var displayPropertiesInstance:DisplayPropertiesSingleton;
        protected var modelInstance:ModelSingleton;
        
        public function GraphicCircle(radius:Number = 10, colourFill:uint = 0x99cc00, colourStroke:uint = 0x000000, 
        	initTime:Date = null, endTime:Date = null, previousTrajectory:GraphicTrajectory = null, 
        	nextTrajectory:GraphicTrajectory = null, checkpointManetNodeParentId:String = "", canvasToPopUp:Canvas = null)
        {
            super();
            this.width = (radius*2)+10;
            this.height = (radius*2)+10;
            this._radius = radius;
            this._fillColour = colourFill;
            this._strokeColour = colourStroke;
            
            this._initTime = initTime;
            this._endTime = endTime;
            this._previousTrajectory = previousTrajectory;
            this._nextTrajectory = nextTrajectory;
            this._manetNodeParentId = checkpointManetNodeParentId;
            
            this.buttonMode = true;
            
          	this._popup = new Object();
            
            this._canvasToPopUp = canvasToPopUp;

           	this._popup.color = colourFill;
            this.addEventListener(MouseEvent.ROLL_OVER, rollOver_handler,false,0,true);    
            this.addEventListener(MouseEvent.ROLL_OUT, rollOut_handler,false,0,true);
			this.addEventListener(MouseEvent.MOUSE_OVER, mouseOver_handler);
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseOut_handler);
              
            this.addEventListener(FlexEvent.CREATION_COMPLETE, doCircle,false,0,true);
            this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown_handler,false,0,true);
            this.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove_handler);
            this.addEventListener(MouseEvent.MOUSE_UP, mouseUp_handler,false,0,true);        
        }
        
        public function set canvasToPopUp(newCanvas:Canvas):void
        {
        	this._canvasToPopUp = newCanvas;
        }
        
        public function get canvasToPopUp():Canvas
        {
        	return this._canvasToPopUp;
        }
        
        public function get radius():Number
        {
        	return this._radius;
        }
        
        public function set radius(newRadius:Number):void
        {
        	this._radius = newRadius;
        }
        
        public function get previousTrajectory():GraphicTrajectory
        {
        	return this._previousTrajectory;	
        }
        
        public function set previousTrajectory(newPreviousTrajectory:GraphicTrajectory):void
        {
        	this._previousTrajectory = newPreviousTrajectory;
        }
        
        public function get nextTrajectory():GraphicTrajectory
        {
        	return this._nextTrajectory;
        }
        
        public function set nextTrajectory(newNextTrajectory:GraphicTrajectory):void
        {
        	this._nextTrajectory = newNextTrajectory;
        }
        
        public function get initTime():Date
        {
        	return this._initTime;
        }
        
        public function set initTime(newInitTime:Date):void
        {
        	this._initTime = newInitTime;
        }
        
        public function get endTime():Date
        {
        	return this._endTime;
        }
        
        public function set endTime(newEndTime:Date):void
        {
        	this._endTime = newEndTime;
        }        
        
        
        public function get manetNodeParentId():String
        {
        	return this._manetNodeParentId;
        }
        [Bindable (event="manetNodeParentIdChanged")]
        public function getManetNodeParentId():String
        {
        	return this._manetNodeParentId;
        }
        
        public function set manetNodeParentId(newManetNodeParentId:String):void
        {
        	this._manetNodeParentId = newManetNodeParentId;
        	dispatchEvent(new PropertyChangeEvent("manetNodeParentIdChanged"));
        }         
        
        protected function mouseOver_handler(evt:MouseEvent):void
        {
        	this.displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
        	this._currentCursorId = this.cursorManager.setCursor(this.displayPropertiesInstance.customCursorHand, CursorManagerPriority.HIGH, -5, -2);
        }
        
        protected function mouseOut_handler(evt:MouseEvent):void
        {
        	//this.cursorManager.removeAllCursors();
        	this.cursorManager.removeCursor(this._currentCursorId);
        }
        
        protected function rollOver_handler(evt:MouseEvent):void 
        { 
       		
        	this.displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
        	this._popper = new Popper();     
        	     
			this._popper.x = this.mouseX - (_popper.width/2);
			this._popper.y = this.mouseY - (_popper.height + this.height);
			

			this._popper.x = this.x - (_popper.width/2);
			this._popper.y = this.y - (_popper.height + this.height);	
					
			if (this._canvasToPopUp != null)
			{
				this._canvasToPopUp.addChild(_popper);
			}
			else
			{
				this.addChild(_popper);
			}	
			
			
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "JJ:NN:SS";
			this._textPos = "x = " + (this.x/this.displayPropertiesInstance.scaleFactor).toString() +
				 "\ny = " + (this.y/this.displayPropertiesInstance.scaleFactor).toString();
			var textTimeInit:String;
			var textTimeEnd:String;
			if (this.initTime)
			{
				textTimeInit = dateFormatter.format(this.initTime);
			}
			if (this.endTime)
			{
				textTimeEnd = dateFormatter.format(this.endTime);
			}
			
			
			//this._popper.show(_popup.color, _popup.texto);
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
			this._popper.show(_popup.color, _textPos + "\nArrival t: " + textTimeInit + "\nStart t: " + textTimeEnd, messagePosition);
			
        }
        
        protected function rollOut_handler(evt:MouseEvent):void 
        {
        	try
        	{
        		if (this._canvasToPopUp != null)
        		{
        			this._canvasToPopUp.removeChild(this._popper);
        		}
        		else
        		{
        			this.removeChild(this._popper);
        		}	
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
            //var shadow:DropShadowFilter = new DropShadowFilter;
            //shadow.distance = 5;
            //shadow.alpha = .5;
            //shadow.angle = 90;

             this._graphics = this.graphics;
             if (this._isSelected)
             {
             	_graphics.beginFill(this._selectionColour, 1);
             }
             else
             {
             	_graphics.beginFill(this._fillColour, 1);
             }	
             _graphics.lineStyle(1, this._strokeColour);
             //_graphics.drawCircle(5, 5, this._radius);
             _graphics.drawCircle(0, 0, this._radius);
             //this.filters = [shadow];
         }
         
         public function setAsSelected(isSet:Boolean):void
         {
           //var shadow:DropShadowFilter = new DropShadowFilter;
           //shadow.distance = 5;
           //shadow.alpha = .5;
           //shadow.angle = 90;         	
             this._graphics = this.graphics;
             if (isSet)
             {
             	this._graphics.beginFill(this._selectionColour, 1);
             }
             else
             {
             	this._graphics.beginFill(this._fillColour, 1);
             }	
             this._isSelected = isSet;
             this._graphics.lineStyle(1, this._strokeColour);
             //this._graphics.drawCircle(5, 5, this._radius);         	
             this._graphics.drawCircle(0, 0, this._radius);
             //this.filters = [shadow];
         }
         
         public function isSelected():Boolean
         {
         	return this._isSelected;
         }
         
         public function set fillColour(newColour:uint):void
         {
             this._graphics = this.graphics;
             this._graphics.beginFill(newColour, 1);
             this._graphics.lineStyle(1, this._strokeColour);
             //this._graphics.drawCircle(5, 5, this._radius); 
             this._graphics.drawCircle(0, 0, this._radius);
             this._fillColour = newColour; 
             this._popup.color = newColour;       	
         }
         
         public function get fillColour():uint
         {
         	return this._fillColour;
         }         
         
         protected function mouseDown_handler(evt:MouseEvent):void 
         {
         	//Se comienza el arrastre
         	this.displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
            this.startDrag();
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "JJ:NN:SS";
			var textTimeInit:String;
			var textTimeEnd:String;
			if (this.initTime)
			{
				textTimeInit = dateFormatter.format(this.initTime);
			}
			 if (this.endTime)
			{
				textTimeEnd = dateFormatter.format(this.endTime);
			}            
            this._textPos = "x = " + (this.x/this.displayPropertiesInstance.scaleFactor).toString() + "\ny = " + 
            	(this.y/this.displayPropertiesInstance.scaleFactor).toString();
            this._popper.updateText(this._textPos + "\nArrival t: " + textTimeInit + "\nStart t: " + textTimeEnd);
            
            this._isDragging = true;
            this.displayPropertiesInstance.isDraggingCheckpoint = true;
            
            //Seleccion
        	this.displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
         	this.displayPropertiesInstance.graphicCheckpointSelected = this;            
         } 
         
         
         protected function mouseUp_handler(evt:MouseEvent):void 
         {
         	//Se termina el arrastre
         	this.displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
            this.stopDrag();
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "JJ:NN:SS";
			var textTimeInit:String;
			var textTimeEnd:String;
			if (this.initTime)
			{
				textTimeInit = dateFormatter.format(this.initTime);
			}
			 if (this.endTime)
			{
				textTimeEnd = dateFormatter.format(this.endTime);
			}               
            this._textPos = "x = " + (this.x/this.displayPropertiesInstance.scaleFactor).toString() + 
            	"\ny = " + (this.y/this.displayPropertiesInstance.scaleFactor).toString();
            this._popper.updateText(this._textPos + "\nArrival t: " + textTimeInit + "\nStart t: " + textTimeEnd);
            
            this._isDragging = false;
            this.displayPropertiesInstance.isDraggingCheckpoint = false;
         }
         
         public function forceMouseUp_handler():void
         {
         	this.displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
            this.stopDrag();
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "JJ:NN:SS";
			var textTimeInit:String;
			var textTimeEnd:String;
			if (this.initTime)
			{
				textTimeInit = dateFormatter.format(this.initTime);
			}
			 if (this.endTime)
			{
				textTimeEnd = dateFormatter.format(this.endTime);
			}               
            this._textPos = "x = " + (this.x/this.displayPropertiesInstance.scaleFactor).toString() + 
            	"\ny = " + (this.y/this.displayPropertiesInstance.scaleFactor).toString();
            this._popper.updateText(this._textPos + "\nArrival t: " + textTimeInit + "\nStart t: " + textTimeEnd);
            
            this._isDragging = false;
            this.displayPropertiesInstance.isDraggingCheckpoint = false;         	
         }
         
         protected function mouseMove_handler(evt:MouseEvent):void
         {
         	this.displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "JJ:NN:SS";
			var textTimeInit:String;
			var textTimeEnd:String;
			if (this.initTime)
			{
				textTimeInit = dateFormatter.format(this.initTime);
			}
			 if (this.endTime)
			{
				textTimeEnd = dateFormatter.format(this.endTime);
			}               
            this._textPos = "x = " + (this.x/this.displayPropertiesInstance.scaleFactor).toString() + 
            	"\ny = " + (this.y/this.displayPropertiesInstance.scaleFactor).toString();
            this._popper.updateText(this._textPos + "\nArrival t: " + textTimeInit + "\nStart t: " + textTimeEnd); 
            this._isDragging = true;       	
         }
                
         
    }
}