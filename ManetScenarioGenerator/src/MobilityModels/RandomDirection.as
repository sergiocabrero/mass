package MobilityModels
{
	import Classes.DisplayPropertiesSingleton;
	import Classes.ModelSingleton;
	
	import flash.geom.Point;
	
	import mx.controls.Alert;

	public class RandomDirection extends RandomWaypoint implements MobilityModel
	{
		//Margen que asegura que no se generen checkpoints muy juntos
		private const SECURITY_DISTANCE:Number = 10;
		
		//Constructor
		public function RandomDirection(newNodeId:String)
		{
			super(newNodeId);
		}
		
		/** Metodo que calcula las coordenadas del siguiente Checkpoint
		 * @throw: arroja un error en caso de no poder calcular correctamente la posicion
		 * @return Point, coordenadas cartesianas del siguiente Checkpoint
		 **/ 
		override public function calculateNextPosition():Point
		{			
			
			var newPoint:Point;
			var movPoint:Point;
			
			//Calculamos la posicion del siguiente Checkpoint
			var x_From:int = 0;
			var x_To:int = this._modelInstance.scenarioPropertiesCallableProxy.width;
			var y_From:int = 0;
			var y_To:int = this._modelInstance.scenarioPropertiesCallableProxy.height;
			
			//Comprobamos el area donde generar el modelo
			if (myArea != null)	//generar modelo en todo el escenario
			{
				x_From = myArea[0];
				x_To = myArea[1];
				y_From = myArea[2];
				y_To = myArea[3];
			}	
			
			//Variable que nos dira la mayor distancia posible a recorrer en el area
			var maxDistance:Number = Math.sqrt(((x_From-x_To)*(x_From-x_To))+((y_From-y_To)*(y_From-y_To)));	
			
			//Calculamos velocidad aleatoria
			var rand:RandomValues=new RandomValues();			
			speed=rand.calculateRandomSpeed(minSpeed,maxSpeed);
			
			var iter:int=0;
			checkNewDirection();
			
			//Creamos una funcion para los casos en los que haya que recalcular
			function checkNewDirection():void
			{
				//Valor centinela para asegurar que no se quede recalculando infinitamente
				if(++iter > 1000)
					throw new Error("Error calculating new position");
							
				//Si es el primer punto calculamos una direccion entre 0 y 2pi
				if (lastPoint.x != x_From && lastPoint.x != x_To &&
					lastPoint.y != y_From && lastPoint.y != y_To)
				{
					direction = rand.calculateRandomDirection();
				}
				else //si no solo entre 0 y pi
				{
					direction = rand.calculateRandomDirection(0.1,0.9);
					//Ajustamos la direccion dependiendo en que borde estemos
					if (lastPoint.x <= x_From)
					{
						direction += Math.PI;
					}
					else if (lastPoint.y <= y_From)
					{
						direction += 3*Math.PI/2;
					}	
					else if (lastPoint.y >= y_To)
					{
						direction += Math.PI/2;
					}
				}
				
				//Con la direccion calculada recorremos hasta llegar a un borde			
				for (var i:int=1; i<=maxDistance ;i++)
				{
					movPoint = Point.polar(i,direction);
					newPoint = lastPoint.add(movPoint);
					//Si alcanzamos un borde ajustamos los decimales
					if (newPoint.x <= x_From)
					{
						newPoint.x = x_From;
						newPoint.y = Math.round(newPoint.y);
						break;
					}
					else if (newPoint.x >= x_To)
					{
						newPoint.x = x_To;
						newPoint.y = Math.round(newPoint.y);
						break;
					}
					else if (newPoint.y <= y_From)
					{
						newPoint.y = y_From;
						newPoint.x = Math.round(newPoint.x);
						break;
					}
					else if (newPoint.y >= y_To)
					{
						newPoint.y = y_To;
						newPoint.x = Math.round(newPoint.x);
						break;
					}
				}
				
				//Comprobamos que no se ha alcanzado la distancia maxima
				if (i == maxDistance)
					throw new Error("Error calculating new position");
			}
			
			//Calculamos la distancia a recorrer
			movementDistance = Point.distance(lastPoint, newPoint);
			
			//En caso que el punto este muy cercano lo recalculamos de nuevo
			while (movementDistance < SECURITY_DISTANCE)
			{
				checkNewDirection();
				movementDistance = Point.distance(lastPoint, newPoint);
			}
			
			//Calculamos la duracion del movimiento
			calculateDurationOrDistance();
						
			return newPoint;
		}
	}
}