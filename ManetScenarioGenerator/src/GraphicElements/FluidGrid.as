package GraphicElements
{

	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	
	import mx.containers.Canvas;
	import mx.core.*;
	//import flash.utils.Timer;



	public class FluidGrid extends Sprite {


		public var sw:Number;
		public var sh:Number;


		public var grid:Sprite = new Sprite();
		public var horzLines:Sprite = new Sprite();
		public var vertLines:Sprite = new Sprite();
		public var gridLines:Array = new Array();
		public var spacing:Number = 20;
		public var lineColor:int = 0x333333;
		public var lineWeight:Number = 1;
		public var lineAlpha:Number = 0.08;
		public var lineHinting:Boolean = true;
		public var lineScale:String = "none";


		public var xAxis:Sprite = new Sprite();
		public var yAxis:Sprite = new Sprite();
		public var xAxisColor:int = 0xeeeeee;
		public var yAxisColor:int = 0xeeeeee;

		public var hLine:Shape = new Shape();
		public var vLine:Shape = new Shape();

		public var numVertLines:int = Math.floor(sw/spacing);
		public var numHorzLines:int = Math.floor(sh/spacing);

		public var xOffset:Number = 0;
		public var yOffset:Number = 0;


		private var _scnCnv:Canvas;
		private var _spacingFactor:Number = 1;
		
		

		private var i:int;

		public function FluidGrid(scenarioCanvasRef:Canvas) {
			
			this._scnCnv = scenarioCanvasRef;
			
			this.sw = this._scnCnv.width;
			this.sh = this._scnCnv.height;
						

			drawGridLines();
			addChild(grid);
			grid.addChild(horzLines);
			grid.addChild(vertLines);

			this._scnCnv.addEventListener(Event.RESIZE, resizeListener);

		}

		public function set spacingFactor(newValue:Number):void
		{
			this._spacingFactor = newValue;
			this.spacing = newValue;
			sh = this._scnCnv.height;
			sw = this._scnCnv.width;
			redrawGridLines();			
		}
		
		public function get spacingFactor():Number
		{
			return this._spacingFactor;	
		}
		
		protected function resizeListener(e:Event):void {
			sh = this._scnCnv.height;
			sw = this._scnCnv.width;

			redrawGridLines();
		
		}

		protected function resizeAxes():void {

			yAxis.height = sh;
			yAxis.x = sw/2;
			xAxis.width = sw;
			xAxis.y = sh/2;
			
		}

		protected function redrawGridLines():void {
			numHorzLines = Math.floor(sh/spacing);
			numVertLines = Math.floor(sw/spacing);

			 xOffset = 0;
			 yOffset = 0;

			for (i = 0; i < horzLines.numChildren; i++) {
				horzLines.getChildAt(i).width = sw;
				horzLines.getChildAt(i).y = i * spacing + yOffset;
			}

			for (i = 0; i < vertLines.numChildren; i++) {
				vertLines.getChildAt(i).height = sh;
				vertLines.getChildAt(i).x = i * spacing + xOffset;
			}

			if (numHorzLines > horzLines.numChildren) {

				for (i = horzLines.numChildren - 1; i <= numHorzLines; i++) {
					gridLines[i] = new Shape();
					gridLines[i].name = "hLine" + i;
					drawHorzLine(gridLines[i]);
					gridLines[i].y = (i + 1) * spacing + yOffset;
				}
			}
			
			else if (numHorzLines < horzLines.numChildren)
			{
				for (i = horzLines.numChildren-1; i >= numHorzLines; i--) {
					horzLines.getChildAt(i).width = 0;
					horzLines.getChildAt(i).y = 0;
				}
			}
			

			if (numVertLines > vertLines.numChildren) {

				for (i = vertLines.numChildren - 1; i <= numVertLines; i++) {
					gridLines[i] = new Shape();
					gridLines[i].name = "vLine" + i;
					drawVertLine(gridLines[i]);
					gridLines[i].x = (i + 1) * spacing + xOffset;
				}
			}
			
			else if (numVertLines < vertLines.numChildren)
			{
				for (i = vertLines.numChildren-1; i >= numVertLines; i--) {
					vertLines.getChildAt(i).height = 0;
					vertLines.getChildAt(i).x = 0;
				}
			}
						
			
		}

		protected function drawAxes():void {

			var yg:Graphics = yAxis.graphics;
			var xg:Graphics = xAxis.graphics;

			yg.lineStyle(lineWeight, yAxisColor, lineAlpha, lineHinting, lineScale);
			yg.moveTo(0,0);
			yg.lineTo(0,sh);
			yAxis.x = sw/2;

			xg.lineStyle(lineWeight, xAxisColor, lineAlpha, lineHinting, lineScale);
			xg.moveTo(0,0);
			xg.lineTo(sw,0);
			xAxis.y = sh/2;

			addChild(yAxis);
			addChild(xAxis);
		}

		protected function drawHorzLine(horzLine:Shape):void {
			var hl:Graphics = horzLine.graphics;
			hl.lineStyle(lineWeight, lineColor, lineAlpha, lineHinting, lineScale);
			hl.moveTo(0,0);
			hl.lineTo(sw,0);
			horzLines.addChild(horzLine);
		}

		protected function drawVertLine(vertLine:Shape):void {
			var vl:Graphics = vertLine.graphics;
			vl.lineStyle(lineWeight, lineColor, lineAlpha, lineHinting, lineScale);
			vl.moveTo(0,0);
			vl.lineTo(0,sh);
			vertLines.addChild(vertLine);
		}

		protected function drawGridLines():void {

			numHorzLines = Math.floor(sh/spacing);
			numVertLines = Math.floor(sw/spacing);

			 xOffset = 0;
			 yOffset = 0;


			for (i = 0; i <= numHorzLines; i++) {
				gridLines[i] = new Shape();
				gridLines[i].name = "hLine" + i;
				drawHorzLine(gridLines[i]);
				gridLines[i].y = i * spacing + yOffset;
			}


			for (i = 0; i <= numVertLines; i++) {
				gridLines[i] = new Shape();
				gridLines[i].name = "vLine" + i;
				drawVertLine(gridLines[i]);
				gridLines[i].x = i * spacing + xOffset;
			}
		}
	}
}