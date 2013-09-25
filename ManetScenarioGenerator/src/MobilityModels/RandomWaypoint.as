package MobilityModels
{
	import Classes.DisplayPropertiesSingleton;
	import Classes.ModelSingleton;
	
	import flash.geom.Point;
	
	import mx.controls.Alert;

	public class RandomWaypoint extends RandomWalk implements MobilityModel
	{
		//Pausa entre Movimientos
		protected var pauseTime:Date;
		protected var totalTime:Date;
		
		//Constructor
		public function RandomWaypoint(newNodeId:String)
		{
			super(newNodeId);
		}
		
		//Funcion SET para el tiempo de pausa
		override public function setPauseTime(newPauseTime:Date):void
		{
			pauseTime = newPauseTime;
			typeParameter=false;
		}	
		
		/**Metodo que implementa el calculo de los checkpoints, se sobreescribe al
		 * de RandomWalk ya que hereda de esta
		 **/
		override public function calculateNextCheckpoint():Boolean
		{		
			this._modelInstance = ModelSingleton.getSingletonInstance();
			
			try
			{
				lastPoint=calculateNextPosition();
			}
			//capturamos el error en caso que no calcule bien la nueva posicion
			catch(e:Error) 
			{
				throw new Error("Error calculating new position");
				return true;
			}	
								
			//tiempos de llegada y salida al checkpoint
			var arrivalTime:Date;
			var startTime:Date;
			var totalTime:Date;
			
			//Si es el primer checkpoint
			if (lastMovementTime == null)
			{
				arrivalTime = new Date();
				arrivalTime.setHours(pauseTime.hours,pauseTime.minutes,pauseTime.seconds);
				startTime = new Date();
				startTime.setHours(pauseTime.hours,pauseTime.minutes,pauseTime.seconds);		
				
				try
				{
					//Creamos un ultimo checkpoint provisional para poder añadir el retardo a los checkpoint intermedios
					if (nodeId != null)
					{	
						totalTime = globalFinalTime;
						totalTime.setHours(totalTime.hours+movementDuration.hours+pauseTime.hours,
						totalTime.minutes+movementDuration.minutes+pauseTime.minutes,
						totalTime.seconds+movementDuration.seconds+pauseTime.seconds);
									
						var lastCheckpointPos:Point = calculateNextPosition();
						if (this._modelInstance.manetNodesTableCallableProxy.addManetNodeDoubleTimestampPositionCheckpoint(nodeId,
							totalTime, totalTime, lastCheckpointPos.x, lastCheckpointPos.y) == false)
						{
							Alert.show("Error calculating last checkpoint", DisplayPropertiesSingleton.APPLICATION_TITLE);
							return true;
						}
					}	
				}
				catch(e:Error) 
				{
					throw new Error("Error calculating new position");
					return true;
				}	
			}
			//Si no es el primer checkpoint
			else
			{
				arrivalTime = new Date(lastMovementTime.time);
				startTime = new Date(lastMovementTime.time);
			}
			
			//Calculamor los tiempo de llegada y salida del checkpoint
			arrivalTime.setHours(arrivalTime.hours+movementDuration.hours,arrivalTime.minutes+movementDuration.minutes,
									 arrivalTime.seconds+movementDuration.seconds);
			
			startTime.setHours(startTime.hours+movementDuration.hours+pauseTime.hours,
								startTime.minutes+movementDuration.minutes+pauseTime.minutes,
								startTime.seconds+movementDuration.seconds+pauseTime.seconds);	
									 	
			//Actualizamos el ultimo tiempo				 
			lastMovementTime = startTime;		
			
			if (globalFinalTime.getTime() > startTime.getTime())
			{		
				if (this._modelInstance.manetNodesTableCallableProxy.addManetNodeDoubleTimestampPositionCheckpoint(nodeId,
					arrivalTime, startTime, lastPoint.x, lastPoint.y) == false)
				{
					throw new Error("Error calculating new checkpoint");
				}
			}
			else if (globalFinalTime.getTime() > arrivalTime.getTime())
			{
				//Añadimos el ultimo checkpoint con arrivalTime
				if (this._modelInstance.manetNodesTableCallableProxy.addManetNodeExtremeTimestampPositionCheckpoint(nodeId,
					arrivalTime,lastPoint.x, lastPoint.y))
				{
					//Eliminamos el ultimo checkpoint provisional
					if(!this._modelInstance.manetNodesTableCallableProxy.removeManetNodeMovementByTimestamp(nodeId,
						this._modelInstance.manetNodesTableCallableProxy.getManetNodeLastMovement(nodeId).toTimestampPositionCheckpoint.pointTime))
					{
						throw new Error("Error erasing last position");
					}
					return true;
				}
			}
			
			else
			{
				//Eliminamos el ultimo checkpoint provisional
				if(!this._modelInstance.manetNodesTableCallableProxy.removeManetNodeMovementByTimestamp(nodeId,
						this._modelInstance.manetNodesTableCallableProxy.getManetNodeLastMovement(nodeId).toTimestampPositionCheckpoint.pointTime))
				{
					throw new Error("Error erasing last position");
				}
				return true;
			}
			
			return false;
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
			
			//Generamos un punto aleatorio del escenario
			var rand:RandomValues=new RandomValues();
			var newPoint:Point=new Point(rand.createRandomPosition(x_From,x_To),rand.createRandomPosition(y_From,y_To));
			
			//Calculamos velocidad aleatoria
			speed=rand.calculateRandomSpeed(minSpeed,maxSpeed);
			
			//Calculamos la distancia entre los puntos
			movementDistance=Point.distance(newPoint,lastPoint);
			//Calculamos la duracion del movimiento
			calculateDurationOrDistance();
						
			return newPoint;
		}
			
	}
}