/** Modelo de mobilidad Random Walk
 * En este modelo deberan seleccionarse un rango de velocidades
 * y fijarse una distancia o tiempo entre movimientos.
 * Para cada rango de tiempo/distancia el modelo calculara
 * una velocidad y direccion aleatorias para el nodo
 **/

package MobilityModels
{
	import Classes.DisplayPropertiesSingleton;
	import Classes.ModelSingleton;
	
	import flash.geom.Point;
	
	import mx.controls.Alert;
	
	public class RandomWalk implements MobilityModel
	{
		protected var _modelInstance:ModelSingleton;
		protected var _displayPropertiesInstance:DisplayPropertiesSingleton;
		
		protected var nodeId:String;
		
		//Velocidad y direccion instantaneas
		protected var speed:Number;
		protected var direction:Number;
		
		//Velocidades maxima y minima
		protected var minSpeed:int;
		protected var maxSpeed:int;
		
		//Tiempo total del modelo
		protected var globalFinalTime:Date;

		//Variables para el tipo de parametro fijado
		protected var typeParameter:Boolean;	//False si fijamos 'd' True si fijamos 't'
		protected var movementDistance:int;
		protected var movementDuration:Date;
		
		//Estado del ultimo checkpoint
		protected var lastMovementTime:Date;
		protected var lastPoint:Point;
		
		//Area en el que se generara el modelo [xFron xTo yFrom yTo]
		protected var myArea:Array;
		
		
		//Constructor
		public function RandomWalk(newNodeId:String)
		{
			this._modelInstance = ModelSingleton.getSingletonInstance();
			speed=0;
			direction=0;
			minSpeed=0;
			maxSpeed=0;
			nodeId=newNodeId;
			globalFinalTime=null;
			typeParameter=true;
			movementDistance=0;	
			movementDuration=null;
			lastMovementTime=null;
			lastPoint=null;
			myArea=null;
		}
		
		//Funciones GET
		public function getLastMvTime():Date
		{
			return lastMovementTime;
		}
		
		public function getLastPoint():Point
		{
			return lastPoint;
		}
		
		//Funciones SET
		public function setMovementDuration(newMovDuration:Date):void
		{
			movementDuration=newMovDuration;			
		}
		
		public function setDistance(newMvDistance:int):void
		{
			movementDistance = newMvDistance;
		}
		
		public function setMinSpeed(newMinSpeed:int):void
		{
			minSpeed=newMinSpeed;
		}
		
		public function setMaxSpeed(newMaxSpeed:int):void
		{
			maxSpeed = newMaxSpeed;
		}
		
		public function setGlobalDuration(newGlobalTime:Date):void
		{
			globalFinalTime=newGlobalTime;
		}
		
		public function setLastPoint(newPoint:Point):void
		{
			lastPoint = newPoint;
		}
		
		public function setTypeParameter(newType:Boolean):void
		{
			typeParameter=newType;
		}
		
		public function setArea(newArea:Array):void
		{
			myArea = newArea;
		}
		
		//Metodos set que utilizan otras clases que heredan de esta
		public function setPauseTime(newPauseTime:Date):void {}
		
		public function setTuningParam(newTuninParam:Number):void {}
		
		public function setStreetLong(newStreetLong:Number):void {}
		
		public function setNumberHSStreets(newHSS:int):void	{}
		
		public function setNodeType(newNodeType:int):void {}
		
		public function setUnitSpeed(newUnitSpeed:Boolean):void {}
		
		public function setSpeedLimits(newMinFoot:int,newMaxFoot:int,newMinCar:int,newMaxCar:int):void {}
		
		public function setZones(newIncidentZone:Array,newTretmentZone:Array,newWaitZone:Array):void {}
		
		public function setNumFirefighters(newNumFirefighters:int):void {}
		
		public function setPauseTime2(newPauseTime2:Object):void {}
		
		public function createTeam(newNodeId:String, newTime:Date, newXCoor:int, newYCoor:int):Boolean {return true;}
		
		public function setRestLimits(newMinRestDuration:Object, newMaxRestDuration:Object, 
				newMinInterventionDuration:Object, newMaxInterventionDuration:Object):Boolean {return false;}
		
		
		////////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////

		
		/** Metodo que calcula las coordenadas del siguiente Checkpoint
		 * @throw: arroja un error en caso de no poder calcular correctamente la posicion
		 * @return Point, coordenadas cartesianas del siguiente Checkpoint
		 **/ 
		public function calculateNextPosition():Point
		{			
			//Calculamos velocidad y direccion aleatorias
			var rand:RandomValues=new RandomValues();
			direction=rand.calculateRandomDirection();
			speed=rand.calculateRandomSpeed(minSpeed,maxSpeed);
			
			//Calculamos la distancia o la duracion con la nueva velocidad
			calculateDurationOrDistance();
			
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
			
			//Aplicamos el movimiento y comprobamos que es corecto
			var newMovement:Point=Point.polar(movementDistance,direction);
			var newPoint:Point=lastPoint.add(newMovement);
			var iter:int;
			
			//Si no cae dentro del area del modelo recalculamos direccion y velocidad
			while (newPoint.x>x_To || newPoint.y>y_To || newPoint.x<x_From || newPoint.y<y_From )
			{
				iter++;
				direction=rand.calculateRandomDirection();
				newMovement=Point.polar(movementDistance,direction);
				newPoint=lastPoint.add(newMovement);
				//En caso que no encuentre una posicion adecuada arrojamos un Error
				if (iter > 1000)
					throw new Error("Error calculating new position");
			}
			
			return newPoint;
		}
		
		/** Metodo que calcula el siguiente Checkpoint segun el modelo
		 * @param newLastMvTime:Date, instante final del checkpoint anterior
		 * @throw: arroja un error en caso de no poder calcular correctamente el checkpoint
		 * @return boolean, true si ha llegado al tiempo final del modelo
		 **/ 
		public function calculateNextCheckpoint():Boolean
		{	
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
			
			//variable que controla si se ha llegado al final del tiempo
			var sentinel:Boolean=false;	
			
			//tiempos de llegada y salida al checkpoint
			var arrivalTime:Date;
			var startTime:Date;
			
			if (lastMovementTime == null)
			{
				arrivalTime = new Date();
				arrivalTime.setHours(0,0,0);
				startTime = new Date();
				startTime.setHours(0,0,0);
			}
			else
			{
				arrivalTime = new Date(lastMovementTime.time);
				startTime = new Date(lastMovementTime.time);
			}
			
			arrivalTime.setHours(arrivalTime.hours+movementDuration.hours,arrivalTime.minutes+movementDuration.minutes,
									 arrivalTime.seconds+movementDuration.seconds);
			
			startTime.setHours(startTime.hours+movementDuration.hours,startTime.minutes+movementDuration.minutes,
								 startTime.seconds+movementDuration.seconds);	
									 					 
			lastMovementTime = startTime;
			
			//Añadimos el chechkpoint si los parametros son correctos		
			if (nodeId != null)
			{
				this._modelInstance = ModelSingleton.getSingletonInstance();
				
				if (this._modelInstance.manetNodesTableCallableProxy.addManetNodeDoubleTimestampPositionCheckpoint(nodeId,
					arrivalTime, startTime, lastPoint.x, lastPoint.y) == false)
				{
					Alert.show("Invalid checkpoint", DisplayPropertiesSingleton.APPLICATION_TITLE);
					return true;
				}					
			}
			
			//Comprobamos si se ha alcanzado el tiempo final del modelo
			if (globalFinalTime.getTime() < arrivalTime.getTime() || globalFinalTime.getTime() < startTime.getTime())
			{
				arrivalTime.time = globalFinalTime.time;
				startTime = null;
				return true;
			}
			
			return sentinel;
		}	
		
		/**Funcion que calcula el parametro que falta en el modelo,
		 *  distancia o duracion del movimiento.
		 * **/
		public function calculateDurationOrDistance():void
		{
			if (!typeParameter)
			{
				movementDuration=new Date();
				var totalSeconds:int = 0;
				var totalMinutes:int = 0;
				var totalHours:int = 0;
				
				if (speed != 0)
					totalSeconds=movementDistance/speed;
				
				while (totalSeconds > 60)
				{
					if(totalSeconds >3600)
					{
						totalHours++;
						totalSeconds = totalSeconds-3600;
					}
					else
					{
						totalMinutes++;
						totalSeconds = totalSeconds-60;
					}
					
				}
				movementDuration.setHours(totalHours,totalMinutes,totalSeconds);
			}
			//Si fijamos el tiempo calculamos la distancia
			else 
			{
				movementDistance=(movementDuration.hours*3600+movementDuration.minutes*60+
									movementDuration.seconds)*speed;
			}	
		}
	}
}