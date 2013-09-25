package GraphicElements
{
    import flash.events.MouseEvent;
    import flash.filters.DropShadowFilter;
    
    import mx.containers.Canvas;
    import mx.controls.Label;
    import mx.controls.Text;

    public class Popper extends Canvas
    {
    	
    	protected var _labelText:Label;
    	
        public function Popper()
        {
            super();
            this.width=110;
            this.height=70;
            this.addEventListener(MouseEvent.CLICK, deleteMe, false, 0, true);
            this._labelText = new Text();
            this._labelText.selectable = false;
        }
        
        public function show(colour:uint = 0x99cc00, text:String = "", side:String = "up"):void 
        {
        	var xRelPos:int;
        	var yRelPos:int;
        	switch (side)
        	{
        		case 'up':
        			xRelPos = 0;
        			yRelPos = 0;
        			break;
        			
        		case 'up-right':
        			xRelPos = 65;
        			yRelPos = 0;        			
        			break;	
        			
        		case 'right':
        			xRelPos = 65;
        			yRelPos = 45;
        			break;
        		
        		case 'down-right':
        			xRelPos = 65;
        			yRelPos = 90;        		
        			break;	        			
        		
        		case 'down':
        			xRelPos = 0;
        			yRelPos = 90;
        			break;
        		
        		case 'down-left':
        			xRelPos = -65;
        			yRelPos = 90;        		
        			break;	
        		
        		case 'left':
        			xRelPos = -65;
        			yRelPos = 45;
        			break;
        		
        		case 'up-left':
        			xRelPos = -65;
        			yRelPos = 0;        		
        			break;	
        			
        		default:
        			xRelPos = 0;
        			yRelPos = 0;        		
        			break;			
        	}
            this.filters = [new DropShadowFilter(5, 90, 0, 0.5)];
            this.graphics.beginFill(colour,1);
            this.graphics.lineStyle(1,0x000000);
            this.graphics.drawRoundRect(xRelPos, yRelPos, this.width, this.height, 5);
            
            this._labelText.text = text;
            this._labelText.includeInLayout = false;
            this._labelText.setStyle("color", 0xffffff);
            this._labelText.setStyle("textAlign", "center");
            this._labelText.width = this.width-2;
            this._labelText.height = this.height-2;
            this._labelText.x = xRelPos + 2;
            this._labelText.y = yRelPos + 5;
            this.addChild(this._labelText);
        }
        
        public function updateText(text:String = ""):void
        {
        	this._labelText.text = text;	
        }
        
        protected function deleteMe(evt:MouseEvent):void 
        {
            this.parent.removeChild(this);
        }
        
    }
}