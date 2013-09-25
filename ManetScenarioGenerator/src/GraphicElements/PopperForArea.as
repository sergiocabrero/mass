package GraphicElements
{
    import flash.events.MouseEvent;
    import flash.filters.DropShadowFilter;
    
    import mx.containers.Canvas;
    import mx.controls.Label;
    import mx.controls.Text;

    public class PopperForArea extends Canvas
    {
    	protected var _rootText:String = "Instant position\n";
    	protected var _labelText:Label;
    	
        public function PopperForArea()
        {
            super();
            this.width=110;
            this.height=70;
            this.addEventListener(MouseEvent.CLICK, deleteMe, false, 0, true);
            this._labelText = new Text();
            this._labelText.selectable = false;
        }
        
        public function show(colour:uint = 0x99cc00, text:String = "", side:String = "up", parentRadius:Number = 5):void 
        {
        	var xRelPos:int;
        	var yRelPos:int;
        	
         			xRelPos = 0;
        			yRelPos = 2 * parentRadius;
 
            this.filters = [new DropShadowFilter(5, 90, 0, 0.5)];
            this.graphics.beginFill(colour, 0.5)
            this.graphics.lineStyle(1,0x000000);
            this.graphics.drawRoundRect(xRelPos, yRelPos, this.width, this.height, 5);
            
            this._labelText.text = this._rootText + text;
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
        	this._labelText.text = this._rootText + text;	
        }
        
        protected function deleteMe(evt:MouseEvent):void 
        {
            this.parent.removeChild(this);
        }
        
    }
}