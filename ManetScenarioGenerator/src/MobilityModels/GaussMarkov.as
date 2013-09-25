/** Modelo de mobilidad de Gauss-Markov
 * En este modelo deberan seleccionarse un rango de velocidades
 * y fijarse uno tiempo entre movimientos.
 * Para cada rango de tiempo el modelo calculara
 * una velocidad y direccion siguiendo las ecuaciones del modelo.
 **/

package MobilityModels
{
	import flash.geom.Point;

	public class GaussMarkov extends RandomWalk implements MobilityModel
	{
		private var tuningParam:Number;
		
		//Velocidad y direccion anteriores
		private var lastSpeed:Number;
		private var lastDirection:Number;
		//Direccion media
		private var meanDirection:Number;
		
		//Margen que damos para que un nodo viaje cerca del borde
		public const BORDER_DISTANCE:Number = 10;
		
		public function GaussMarkov(newNodeId:String)
		{
			super(newNodeId);
		}
		
		override public function setTuningParam(newTuninParam:Number):void
		{
			tuningParam = newTuninParam;
		}
		
		/** Metodo que calcula las coordenadas del siguiente Checkpoint
		 * @throw: arroja un error en caso de no poder calcular correctamente la posicion
		 * @return Point, coordenadas cartesianas del siguiente Checkpoint
		 **/ 
		override public function calculateNextPosition():Point
		{			
			//Cargamos el area de aplicacion
			var x_From:int = 0;
			var x_To:int = this._modelInstance.scenarioPropertiesCallableProxy.width;
			var y_From:int = 0;
			var y_To:int = this._modelInstance.scenarioPropertiesCallableProxy.height;
			
			if (myArea != null)	//generar modelo en todo el escenario
			{
				x_From = myArea[0];
				x_To = myArea[1];
				y_From = myArea[2];
				y_To = myArea[3];
			}
			
			//Calculamos velocidad y direccion aleatorias en el instante n 
			//aplicando los procesos de Markov
			var rand:RandomValues=new RandomValues();
			if (lastMovementTime == null)
			{
				speed=rand.calculateRandomSpeed(minSpeed,maxSpeed);
				direction=rand.calculateRandomDirection();
				lastSpeed = speed;
				lastDirection = direction;
				meanDirection = Math.PI;
			}
			else 
			{
				speed=tuningParam*lastSpeed + (1+tuningParam)*((maxSpeed-minSpeed)/2) + 
					Math.sqrt((1-tuningParam*tuningParam))*rand.calculateRandomSpeed(minSpeed,maxSpeed);
				
				direction=tuningParam*lastDirection + (1+tuningParam)*meanDirection + 
					Math.sqrt((1-tuningParam*tuningParam))*rand.calculateRandomDirection();
			}
			
			//Calculamos la posicion de destino	en el instante n		
			var newPoint:Point=new Point();
			newPoint.x = lastPoint.x + lastSpeed*Math.cos(lastDirection);
			newPoint.y = lastPoint.y + lastSpeed*Math.sin(lastDirection);
			
			//Comprobamos que no caiga fuera del area del modelo
			var iter:int;
			while (newPoint.x>x_To || newPoint.y>y_To || newPoint.x<x_From || newPoint.y<y_From )
			{
				iter++;
				direction=rand.calculateRandomDirection();
				newPoint.x = lastPoint.x + lastSpeed*Math.cos(direction);
				newPoint.y = lastPoint.y + lastSpeed*Math.sin(direction);
				//En caso que no encuentre una posicion adecuada arrojamos un Error
				if (iter > 1000)
					throw new Error("Error calculating new position");
			}
			
			//Comprobamos si el checkpoint cae cercano al borde, si es asi actualizamos
			//la media de direcciones como dice el modelo Gauss-Markov para evitar que se quede cercano al borde
			if (newPoint.x < x_From+BORDER_DISTANCE && newPoint.y < y_From+BORDER_DISTANCE)
				meanDirection = 315*Math.PI/180;
			else if (newPoint.x < x_From+BORDER_DISTANCE && newPoint.y > y_To-BORDER_DISTANCE)
				meanDirection = 45*Math.PI/180;
			else if (newPoint.x > x_To-BORDER_DISTANCE && newPoint.y < y_From+BORDER_DISTANCE)
				meanDirection = 225*Math.PI/180;
			else if (newPoint.x > x_To-BORDER_DISTANCE && newPoint.y > y_To-BORDER_DISTANCE)
				meanDirection = 135*Math.PI/180;	
			else if (newPoint.x < x_From+BORDER_DISTANCE)
				meanDirection = 0;
			else if (newPoint.y < y_From+BORDER_DISTANCE) 
				meanDirection = 270*Math.PI/180;
			else if (newPoint.x > x_To-BORDER_DISTANCE)
				meanDirection = 180*Math.PI/180;
			else if (newPoint.y > y_To-BORDER_DISTANCE)
				meanDirection = 90*Math.PI/180;
			else
				meanDirection = Math.PI; 
			
			//Calculamos la distancia con la velocidad y direccion halladas
			calculateDurationOrDistance();
			
			//Actualizamos los valores anteriores
			lastSpeed = speed;
			lastDirection = direction;
			
			//Retornamos la posicion del checkpoint en el instante n
			return newPoint;
		}
	}
}