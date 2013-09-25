package GraphicElements
{
    import mx.controls.Image;
    import mx.core.UIComponent;
    import mx.events.FlexEvent;
	import flash.display.Graphics;

    public class GraphicTrajectory extends Image
    {
        protected var _graphics:Graphics;
        protected var _dependencies:Array;
        protected var _lineColour:uint;
        
        public function GraphicTrajectory(lineColour:uint = 0x000000, dependencies:Array = null)
        {
            super();
            this._graphics = this.graphics;
            this._dependencies = new Array();
            this._dependencies = dependencies;
            this._lineColour = lineColour;
            this.addEventListener(FlexEvent.CREATION_COMPLETE, designTrajectory, false, 0, true);
        }
        
        protected function designTrajectory(evt:FlexEvent):void 
        {
            //var shadow:DropShadowFilter = new DropShadowFilter;
            //shadow.distance = 5;
            //shadow.alpha = .5;
            //shadow.angle = 90;
            //this.filters = [shadow];
        	this.update();    
        }
        
        public function getDependencies():Array
        {
        	return this._dependencies;
        }
        
        public function update():void 
        {

	        if(_dependencies.length>0)
	        {
		        this._graphics.clear();
		        var tempTo:UIComponent;
		        var tempFrom:UIComponent=_dependencies[0] as UIComponent;
		        
		        this._graphics.lineStyle(1,_lineColour);
		        for(var x:uint = 1; x < _dependencies.length; x++) 
		        {
					//this._graphics.moveTo(tempFrom.x + (tempFrom.width/2) -5, tempFrom.y + (tempFrom.height/2) - 5);
					this._graphics.moveTo(tempFrom.x  , tempFrom.y );
					
					tempTo = _dependencies[x] as UIComponent;
					
					//this._graphics.lineTo(tempTo.x + 2,tempTo.y + 2);
					this._graphics.lineTo(tempTo.x,tempTo.y);         
		        }
	        }        
        }
        
        public function getDependenciesArray():Array
        {
        	return this._dependencies;
        }
        
        //Devolvera true o false dependiendo si tienen las mismas dependencias
        public function isBasicEquivalentTrajectory(otherTrajectory:GraphicTrajectory):Boolean
        {
        	if (this._dependencies.length != otherTrajectory.getDependenciesArray().length)
        	{
        		return false;
        	}
        	
        	for (var x:int = 0; x < this._dependencies.length; x++)
        	{
				if (otherTrajectory.getDependenciesArray().lastIndexOf(this._dependencies[x]) == -1)
				{
					return false;
				}
        	}
        	return true;
        }
        
        
        
    }
}