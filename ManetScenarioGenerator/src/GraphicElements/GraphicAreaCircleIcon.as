package GraphicElements
{
	import flash.events.Event;
	
	import mx.controls.Image;
		
	public class GraphicAreaCircleIcon extends GraphicAreaCircle
	{
		protected var _nodeIcon:Image;
		protected var _iconPath:String = null;
		protected var _iconHeight:int = 25;
		protected var _iconWidth:int = 25;
		
		public function GraphicAreaCircleIcon(radius:Number=10, colourFill:uint=0x99cc00, colourStroke:uint=0x000000, drawRange:Boolean=true, 
			initTime:Date=null, checkpointManetNodeParentId:String="", rangeAlpha:Number=0.3, iconPath:String = "")
		{
			super(radius, colourFill, colourStroke, drawRange, initTime, checkpointManetNodeParentId, rangeAlpha);
			this._iconPath = iconPath;
			
		}
		
		
	     override protected function doCircle(evt:Event):void 
	     {
	         _graphics = this.graphics;
	         _graphics.clear();
	         if (this._drawRange)
	         {
		         _graphics.lineStyle(1, this._strokeColour, this._rangeAlpha);
		         _graphics.beginFill(this._fillColour, this._rangeAlpha);
		         
		         //_graphics.drawCircle(5, 5, this._radius);
		         _graphics.drawCircle(0, 0, this._radius);
		         
	         }
	         if (this._nodeIcon)
	         {
	         	this._nodeIcon.unloadAndStop();
	         }	
	         if (this._iconPath == null || this._iconPath == "")
	         {
	         	
		         _graphics.lineStyle(1.5, this._fillColour, 1);
		         _graphics.beginFill(this._fillColour, 0.9);
		         //_graphics.drawCircle(5, 5.2, 4);
		         _graphics.drawCircle(0, 0, 4);
		         
		         _graphics.lineStyle(0.5, 0x000000, 0.5);
		         //_graphics.drawCircle(5, 5, 3.5);
		         _graphics.drawCircle(0, 0, 3.5);
		         
		         //_graphics.drawCircle(5, 5, 5.5);
		         _graphics.drawCircle(0, 0, 5.5);
		         
	         }
	         else
	         {
		         this._nodeIcon = new Image();
		         if (this._nodeIcon.hasEventListener(flash.events.Event.COMPLETE))
		         {
		         	this._nodeIcon.removeEventListener(flash.events.Event.COMPLETE, imageLoaded_handler);
		         }
		         this._nodeIcon.addEventListener(flash.events.Event.COMPLETE, imageLoaded_handler);
		         this._nodeIcon.load(this._iconPath);
		         this._nodeIcon.width = this._iconWidth;
		         this._nodeIcon.height = this._iconHeight;
		         this._nodeIcon.x = 0;
		         this._nodeIcon.y = 0;
		         this._nodeIcon.setStyle("verticalAlign", "middle");
		         this._nodeIcon.setStyle("horizontalAlign", "center");
		         this.addChild(this._nodeIcon);
			 } 
	     }		
		
		protected function imageLoaded_handler(event:Event):void
		{
			if (this._nodeIcon.contentWidth < this._iconWidth && this._nodeIcon.contentHeight < this._iconHeight)
			{
				this._nodeIcon.width = this._nodeIcon.contentWidth;
				this._nodeIcon.height = this._nodeIcon.contentHeight;
			}
			//this._nodeIcon.x = -(this._nodeIcon.width/2) +5;
			//this._nodeIcon.y = -(this._nodeIcon.height/2) +5;
			this._nodeIcon.x = -(this._nodeIcon.width/2);
			this._nodeIcon.y = -(this._nodeIcon.height/2);
		}
		
		public function get iconPath():String
		{
			return this._iconPath;
		}
		
		public function set iconPath(newPath:String):void
		{
			this._iconPath = newPath;
			this.doCircle(new Event(""));
		}
		
	}
}