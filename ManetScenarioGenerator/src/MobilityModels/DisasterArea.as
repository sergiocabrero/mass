package MobilityModels
{
	import flash.geom.Point;

	public class DisasterArea extends RandomWaypoint implements MobilityModel
	{
		//Tipos de unidades para el modelo DISASTER AREA
		static public const FIREFIGHTER_UNIT:int = 0;
		static public const PARAMEDIC_UNIT:int = 1;
		static public const TRANSPORT_UNIT_TREATMENT:int = 2;
		static public const TRANSPORT_UNIT_INCIDENT:int = 3;
		
		//Tiempo de pausa por defecto si no se selecciona otro
		protected const PAUSE_TIME:int = 5;
		
		//Velocidades
		protected const FOOT_UNITS_SPEED_MIN:int = 1;
		protected const FOOT_UNITS_SPEED_MAX:int = 2;
		protected const VEHICLES_SPEED_MIN:int = 5;
		protected const VEHICLES_SPEED_MAX:int = 12;
		
		//Tiempo de pausa cargado
		protected var loadedPauseTime:Date;
		
		//Typo de unidades 
		//	true= unidades a pie
		//	false= vehiculos
		protected var unitSpeed:Boolean=true;
		
		//Límites de velocidad de los nodos
		protected var minFootSpeed:int;
		protected var maxFootSpeed:int;
		protected var minCarSpeed:int;
		protected var maxCarSpeed:int;	
		
		//Tipo de nodo
		protected var nodeType:int;
		
		//Zona en la que se mueve cada nodo
		//[xFrom xTo yFrom yTo]
		protected var incidentZone:Array;
		protected var waitZone:Array;
		private var treatmentZone:Array;
		
		//Puntos de salida
		private var incidentExit:Point;
		private var treatmentExit:Point;
		private var waitToIncidentExit:Point;
		private var waitToTreatmentExit:Point;
		
		//Direccion: 
		//	true = wait -> fuera
		//	false = fuera -> wait
		protected var transportDirection:Boolean;
		
		//Constructor
		public function DisasterArea(newNodeId:String)
		{
			super(newNodeId);
		}
		
		//Funciones SET
		override public function setNodeType(newNodeType:int):void
		{
			nodeType=newNodeType;
		}
		
		override public function setPauseTime2(newPauseTime:Object):void
		{
			//Tiempo de pausa entre movimientos
			pauseTime = new Date();
			pauseTime.setHours(newPauseTime.hour, newPauseTime.minute, newPauseTime.second);
		}
		
		override public function setSpeedLimits(newMinFoot:int,newMaxFoot:int,newMinCar:int,newMaxCar:int):void
		{
			minFootSpeed = newMinFoot;
			maxFootSpeed = newMaxFoot;
			minCarSpeed = newMinCar;
			maxCarSpeed = newMaxCar;
		}
		
		override public function setUnitSpeed(newUnitSpeed:Boolean):void
		{
			unitSpeed = newUnitSpeed;
		}
		
		override public function setZones(newIncidentZone:Array,newTreatmentZone:Array,newWaitZone:Array):void
		{
			incidentZone=newIncidentZone;
			treatmentZone=newTreatmentZone;
			waitZone=newWaitZone;
			
			if (incidentZone != null && treatmentZone != null && waitZone != null)
				calculateExitPoints();
			loadedPauseTime = new Date(pauseTime.time);
		}
		
		/** Metodo que calcula las coordenadas del siguiente Checkpoint
		 * @throw: arroja un error en caso de no poder calcular correctamente la posicion
		 * @return Point, coordenadas cartesianas del siguiente Checkpoint
		 **/ 
		override public function calculateNextPosition():Point
		{
			var rand:RandomValues=new RandomValues();
			var newPoint:Point;
			//Seleccionamos el tipo de nodos, a pie o vehiculos
			if(unitSpeed)
			{
				minSpeed = minFootSpeed;
				maxSpeed = maxFootSpeed;
			}
			else
			{
				minSpeed = minCarSpeed;
				maxSpeed = maxCarSpeed;
			}
					
			//Si es Bombero se mueve por la zona del incidente siguiendo RandomWayPoint
			if (nodeType == FIREFIGHTER_UNIT)
			{	
				pauseTime.setHours(loadedPauseTime.hours,loadedPauseTime.minutes,loadedPauseTime.seconds);			
				newPoint = new Point(rand.createRandomPosition(incidentZone[0],incidentZone[1]),
						rand.createRandomPosition(incidentZone[2],incidentZone[3]));
			}	
			//Si es Paramedico se mueve por la zona de tratamiento siguiendo RandomWayPoint
			else if (nodeType == PARAMEDIC_UNIT)
			{
				pauseTime.setHours(loadedPauseTime.hours,loadedPauseTime.minutes,loadedPauseTime.seconds);
				newPoint = new Point(rand.createRandomPosition(treatmentZone[0],treatmentZone[1]),
						rand.createRandomPosition(treatmentZone[2],treatmentZone[3]));
			}	
			//Si es un transporte va desde zona de espera hasta la de tratamiento o la del incidente
			else
			{
				//Si esta en la salida de la zona de espera	
				if(lastPoint.x == waitToTreatmentExit.x && lastPoint.y == waitToTreatmentExit.y)
				{
					//Si sale va a la de tratamiento o incidente, dependiendo el nodo 
					//de transporte que se este generando
					if (transportDirection)
					{
						pauseTime.setHours(0,0,0);
						newPoint = treatmentExit;						
					}
					//Si entra va a un punto aleatorio de la zona de espera
					else
					{
						pauseTime.setHours(loadedPauseTime.hours,loadedPauseTime.minutes,loadedPauseTime.seconds);
						newPoint = new Point(rand.createRandomPosition(waitZone[0],waitZone[1]),
							rand.createRandomPosition(waitZone[2],waitZone[3]));
					}
						
				}
				//Si esta en la salida de la zona de incidente	
				else if(lastPoint.x == waitToIncidentExit.x && lastPoint.y == waitToIncidentExit.y)
				{
					//Si sale va a la de tratamiento o incidente, dependiendo el nodo 
					//de transporte que se este generando
					if (transportDirection)
					{
						pauseTime.setHours(0,0,0);
						newPoint = incidentExit;						
					}
					//Si entra va a un punto aleatorio de la zona de espera
					else
					{
						pauseTime.setHours(loadedPauseTime.hours,loadedPauseTime.minutes,loadedPauseTime.seconds);
						newPoint = new Point(rand.createRandomPosition(waitZone[0],waitZone[1]),
							rand.createRandomPosition(waitZone[2],waitZone[3]));
					}
						
				}
				//Si esta en la salida de tratamiento
				else if(lastPoint.x == treatmentExit.x && lastPoint.y == treatmentExit.y)
				{
					//Si entra va a la de espera
					if(transportDirection)
					{
						pauseTime.setHours(loadedPauseTime.hours,loadedPauseTime.minutes,loadedPauseTime.seconds);
						newPoint = new Point(rand.createRandomPosition(treatmentZone[0],treatmentZone[1]),
							rand.createRandomPosition(treatmentZone[2],treatmentZone[3]));
					}
					//Si sale va a la entrada de la zona de espera
					else
					{
						pauseTime.setHours(0,0,0);
						newPoint = waitToTreatmentExit;
					}
				}
				//Si esta en la salida de tratamiento
				else if(lastPoint.x == incidentExit.x && lastPoint.y == incidentExit.y)
				{
					//Si entra va a la de espera
					if(transportDirection)
					{
						pauseTime.setHours(loadedPauseTime.hours,loadedPauseTime.minutes,loadedPauseTime.seconds);
						newPoint = new Point(rand.createRandomPosition(incidentZone[0],incidentZone[1]),
							rand.createRandomPosition(incidentZone[2],incidentZone[3]));
					}
					//Si sale va a la entrada de la zona de espera
					else
					{
						pauseTime.setHours(0,0,0);
						newPoint = waitToIncidentExit;
					}
				}
				//Si esta en la zona de espera va hasta su punto de salida
				else if (lastPoint.x >= waitZone[0] && lastPoint.x <= waitZone[1] && lastPoint.y >= waitZone[2] && lastPoint.y <= waitZone[3])
				{
					pauseTime.setHours(0,0,0);
					switch(nodeType)
					{
						case TRANSPORT_UNIT_TREATMENT: newPoint = waitToTreatmentExit; break;
						case TRANSPORT_UNIT_INCIDENT: newPoint = waitToIncidentExit; break;
					}
					transportDirection = true;
				}
				//Si esta en la zona de tratamiento va hasta su punto de salida
				else if (lastPoint.x >= treatmentZone[0] && lastPoint.x <= treatmentZone[1] && lastPoint.y >= treatmentZone[2] && lastPoint.y <= treatmentZone[3])
				{
					pauseTime.setHours(0,0,0);
					newPoint = treatmentExit;
					transportDirection = false;
				}
				//Si esta en la zona de incidente va hasta su punto de salida
				else if (lastPoint.x >= incidentZone[0] && lastPoint.x <= incidentZone[1] && lastPoint.y >= incidentZone[2] && lastPoint.y <= incidentZone[3])
				{
					pauseTime.setHours(0,0,0);
					newPoint = incidentExit;
					transportDirection = false;
				}
			}
			
			//Calculamos velocidad aleatoria entre v_max y v_min
			speed=rand.calculateRandomSpeed(minSpeed,maxSpeed);
			//Calculamos la distancia entre los puntos
			movementDistance=Point.distance(newPoint,lastPoint);
			//Calculamos la duracion del movimiento
			calculateDurationOrDistance();
						
			return newPoint;
		}
		
		/** Metodo que calcula los puntos de salida de las zonas del modelo
		 * para que los utilicen los nodos de transporte
		 * Modifica: incidentExit, treatmentExit, waitToIncidentExit, waitToTreatmentExit
		 **/ 		 
		private function calculateExitPoints():void
		{	
			//Hallamos los puntos medios de cada extremo de las zonas
			var middleLeftIncident:Point = new Point(incidentZone[0],(incidentZone[2] + incidentZone[3])/2);
			var middleRightIncident:Point = new Point(incidentZone[1],(incidentZone[2] + incidentZone[3])/2);
			var middleTopIncident:Point = new Point((incidentZone[0] + incidentZone[1])/2,incidentZone[2]);
			var middleBottomIncident:Point = new Point((incidentZone[0] + incidentZone[1])/2,incidentZone[3]);
			
			var middleLeftTreatment:Point = new Point(treatmentZone[0],(treatmentZone[2] + treatmentZone[3])/2);
			var middleRightTreatment:Point = new Point(treatmentZone[1],(treatmentZone[2] + treatmentZone[3])/2);
			var middleTopTreatment:Point = new Point((treatmentZone[0] + treatmentZone[1])/2,treatmentZone[2]);
			var middleBottomTreatment:Point = new Point((treatmentZone[0] + treatmentZone[1])/2,treatmentZone[3]);
			
			var middleLeftWait:Point = new Point(waitZone[0],(waitZone[2] + waitZone[3])/2);
			var middleRightWait:Point = new Point(waitZone[1],(waitZone[2] + waitZone[3])/2);
			var middleTopWait:Point = new Point((waitZone[0] + waitZone[1])/2,waitZone[2]);
			var middleBottomWait:Point = new Point((waitZone[0] + waitZone[1])/2,waitZone[3]);
			
			//Calculamos las distancias entre ellos
			var distanceIncidentWaitVert:Number;
			var distanceIncidentWaitHor:Number;
			var distanceTreatmentWaitVert:Number;
			var distanceTreatmentWaitHor:Number;
			
			if(waitZone[2] < incidentZone[2])
				distanceIncidentWaitVert = Point.distance(middleBottomWait,middleTopIncident);
			else
				distanceIncidentWaitVert = Point.distance(middleTopWait,middleBottomIncident);
				
			if(waitZone[0] > incidentZone[0])
				distanceIncidentWaitHor = Point.distance(middleLeftWait,middleRightIncident);
			else
				distanceIncidentWaitHor = Point.distance(middleRightWait,middleLeftIncident);
				
			if(waitZone[2] < treatmentZone[2])
				distanceTreatmentWaitVert = Point.distance(middleBottomWait,middleTopTreatment);
			else
				distanceTreatmentWaitVert = Point.distance(middleTopWait,middleBottomTreatment);
				
			if(waitZone[0] > treatmentZone[0])
				distanceTreatmentWaitHor = Point.distance(middleLeftWait,middleRightTreatment);
			else
				distanceTreatmentWaitHor = Point.distance(middleRightWait,middleLeftTreatment);
					
			//Puntos de salida entre IncidentZone y WaitZone
			if ((distanceIncidentWaitVert < distanceIncidentWaitHor) && (waitZone[2] < incidentZone[2]))
			{
				incidentExit = middleTopIncident;
				waitToIncidentExit = middleBottomWait;
			}
			else if ((distanceIncidentWaitVert < distanceIncidentWaitHor) && (waitZone[2] > incidentZone[2]))
			{
				incidentExit = middleBottomIncident;
				waitToIncidentExit = middleTopWait;
			}
			else if ((distanceIncidentWaitVert > distanceIncidentWaitHor) && (waitZone[0] < incidentZone[0]))
			{
				incidentExit = middleLeftIncident;
				waitToIncidentExit = middleRightWait;			
			}
			else if ((distanceIncidentWaitVert > distanceIncidentWaitHor) && (waitZone[0] > incidentZone[0]))
			{
				incidentExit = middleRightIncident;
				waitToIncidentExit = middleLeftWait;
			}
			
			//Puntos de salida entre TreatmentZone y WaitZone
			if ((distanceTreatmentWaitVert < distanceTreatmentWaitHor) && (waitZone[2] > treatmentZone[2]))
			{
				treatmentExit = middleBottomTreatment;
				waitToTreatmentExit = middleTopWait;
			}
			else if ((distanceTreatmentWaitVert < distanceTreatmentWaitHor) && (waitZone[2] < treatmentZone[2]))
			{
				treatmentExit = middleTopTreatment;
				waitToTreatmentExit = middleBottomWait;
			}
			else if ((distanceTreatmentWaitVert > distanceTreatmentWaitHor) && (waitZone[0] > treatmentZone[0]))
			{
				treatmentExit = middleRightTreatment;
				waitToTreatmentExit = middleLeftWait;
			}
			else if ((distanceTreatmentWaitVert > distanceTreatmentWaitHor) && (waitZone[0] < treatmentZone[0]))
			{
				treatmentExit = middleLeftTreatment;
				waitToTreatmentExit = middleRightWait;
			}
		}
	}
}