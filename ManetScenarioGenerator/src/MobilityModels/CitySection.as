package MobilityModels
{
	import flash.geom.Point;

	public class CitySection extends RandomWalk implements MobilityModel
	{
		//constante que fija a que distancia del borde 
		//se situan las calles de alta velocidad
		private var numberHSStreet:int;
		
		//distancia entre calles
		private var streetLong:Number;
		
		//direccion anterior, para asegurar que no vuelva atras
		private var lastDirection:Number;
		
		//Constructor
		public function CitySection(newNodeId:String)
		{
			super(newNodeId);
		}
		
		//Metodos SET
		public override function setStreetLong(newStreetLong:Number):void
		{
			streetLong = newStreetLong;
		}
		
		public override function setNumberHSStreets(newHSS:int):void
		{
			numberHSStreet = newHSS;
		}
		
		/** Metodo que calcula las coordenadas del siguiente Checkpoint
		 * @throw: arroja un error en caso de no poder calcular correctamente la posicion
		 * @return Point, coordenadas cartesianas del siguiente Checkpoint
		 **/ 
		override public function calculateNextPosition():Point
		{
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
			
			var hightSpeedWidth:int = streetLong*numberHSStreet;
			var hightSpeedHeight:int = streetLong*numberHSStreet;
	
			
			//Calculamos una direccion destino en el cruce
			var rand:RandomValues = new RandomValues();			
			var newPoint:Point=checkNewDirection();
			
			//el nodo se mueve hasta un cruce
			function checkNewDirection():Point
			{
				var tmpPoint:Point;
				var tmpPoint2:Point;
				var movPoint:Point;
				var movPoint2:Point;
				var i:int;
				
				if (lastMovementTime == null)
				{
					direction = rand.calculateRandomCrossing();
					i=1;
					while (true)
					{
						movPoint = Point.polar(i,direction);
						tmpPoint = lastPoint.add(movPoint);
						tmpPoint.x = Math.ceil(tmpPoint.x);
						tmpPoint.y = Math.ceil(tmpPoint.y);
						
						//si llega a un cruce ponemos el checkpoint
						if(((tmpPoint.x % streetLong) == 0) || ((tmpPoint.y % streetLong) == 0))
							break;
						//si llega sale del escenario cambiamos la direccion
						else if (tmpPoint.x>x_To || tmpPoint.y>y_To || tmpPoint.x<x_From || tmpPoint.y<y_From )
						{
							direction += Math.PI/2;
							i=1;
						}
						else
						{
							i++;
						}
					}
				}
				//si estamos en un cruce nos movemos hacia otro
				else if (((lastPoint.y % streetLong) == 0) && ((lastPoint.x % streetLong) == 0))
				{
					direction = lastDirection + rand.calculateRandomCrossing();
					movPoint = Point.polar(streetLong,direction);
					tmpPoint = lastPoint.add(movPoint);
					tmpPoint.x = Math.ceil(tmpPoint.x);
					tmpPoint.y = Math.ceil(tmpPoint.y);
					
					//comprobamos que no nos salimos del area
					if (tmpPoint.x>x_To || tmpPoint.y>y_To || tmpPoint.x<x_From || tmpPoint.y<y_From )
					{
						direction += Math.PI;
						tmpPoint = checkNewDirection();
					}
				}
				
				//si estamos en una calle pero no en un cruce nos movemos hacia el cruce
				else if (((lastPoint.y % streetLong) != 0) && ((lastPoint.x % streetLong) == 0))
				{
					i=1;
					movPoint = new Point();
					movPoint2 = new Point();
					while (true)
					{
						movPoint.y = i;
						movPoint2.y= -i;
						tmpPoint = lastPoint.add(movPoint);
						tmpPoint.x = Math.ceil(tmpPoint.x);
						tmpPoint.y = Math.ceil(tmpPoint.y);
						tmpPoint2 = lastPoint.add(movPoint2);
						tmpPoint2.x = Math.ceil(tmpPoint.x);
						tmpPoint2.y = Math.ceil(tmpPoint.y);
						
						//si llega a un cruce ponemos el checkpoint
						if((tmpPoint.y % streetLong) == 0)
							break;
						else if((tmpPoint2.y % streetLong) == 0)
						{
							tmpPoint = tmpPoint2;
							break;
						}
						else
						{
							i++;
						}
					}
				}
				else if (((lastPoint.x % streetLong) != 0) && ((lastPoint.y % streetLong) == 0))
				{
					i=1;
					movPoint = new Point();
					movPoint2 = new Point();
					while (true)
					{
						movPoint.x = i;
						movPoint2.x= -i;
						tmpPoint = lastPoint.add(movPoint);
						tmpPoint.x = Math.ceil(tmpPoint.x);
						tmpPoint.y = Math.ceil(tmpPoint.y);
						tmpPoint2 = lastPoint.add(movPoint2);
						tmpPoint2.x = Math.ceil(tmpPoint.x);
						tmpPoint2.y = Math.ceil(tmpPoint.y);
						
						//si llega a un cruce ponemos el checkpoint
						if((tmpPoint.x % streetLong) == 0)
							break;
						else if((tmpPoint2.x % streetLong) == 0)
						{
							tmpPoint = tmpPoint2;
							break;
						}
						else
						{
							i++;
						}
					}
				}
				return tmpPoint;
			}
			
			//Ajustamos posibles problemas con el redondeo
			if ((newPoint.x-1)%streetLong == 0)	newPoint.x -=1;
			else if((newPoint.x+1)%streetLong == 0) newPoint.x +=1;
			if ((newPoint.y-1)%streetLong == 0) newPoint.y -=1;
			else if ((newPoint.y+1)%streetLong == 0) newPoint.y +=1;
											
			//Calculamos la distancia a recorrer
			movementDistance = Point.distance(lastPoint, newPoint);
			
			//Comprobamos si esta en una carretera de alta o baja velocidad
			if(newPoint.x < x_From+hightSpeedWidth || newPoint.y < y_From+hightSpeedHeight ||
				newPoint.x > x_To-hightSpeedWidth || newPoint.y > y_To-hightSpeedHeight)
					speed = maxSpeed;
			else 
					speed = minSpeed;
			
			//Calculamos la duracion del movimiento
			calculateDurationOrDistance();
			
			//actualizamos la direccion anterior
			lastDirection=direction;
			
			return newPoint;			
		}
	}
}