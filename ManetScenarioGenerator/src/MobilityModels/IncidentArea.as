package MobilityModels
{
	import Classes.DisplayPropertiesSingleton;
	import Classes.ModelSingleton;
	
	import Entities.ManetNode;
	
	import flash.geom.Point;
	
	import mx.controls.Alert;

	public class IncidentArea extends DisasterArea implements MobilityModel
	{		
		//Id del jefe de operaciones
		private var chiefId:String;	
		
		//Tiempos de intervencion y descanso
		private var restDuration:Date;
		private var initRestTime:Date;
		private var endRestTime:Date;
		private var interventionDuration:Date;
		private var initInterventionTime:Date;
		private var endInterventionTime:Date;
		
		//Limites de tiempos
		private var minRestTime:Date;
		private var maxRestTime:Date;
		private var minInterventionTime:Date;
		private var maxInterventionTime:Date;
		
		//Miembros de un equipo de trabajo
		private var membersTeam:Array;
		private var numFirefighters:int;
		private var numTeam:int;
		
		//Lugar e instante en el que aparco el vehiculo
		private var parkPoint:Point;
		private var parkTime:Date;
		
		//Variable que indica si los bomberos deben retornar al vehiculo
		private var ff2Vehicle:Boolean;
		
		/////////////////////////////////////////////////////////////////////
		//Constructor
		public function IncidentArea(newNodeId:String, newNumTeam:int)
		{
			super(newNodeId);
			transportDirection = true;
			numTeam=newNumTeam;
		}
		
		//SET
		override public function setNumFirefighters(newNumFirefighters:int):void
		{
			numFirefighters=newNumFirefighters;
		}
		
		override public function setRestLimits(newMinRestDuration:Object, newMaxRestDuration:Object, 
				newMinInterventionDuration:Object, newMaxInterventionDuration:Object):Boolean
		{	
			//Tiempo de descanso
			minRestTime = new Date();
			maxRestTime = new Date();
			minRestTime.setHours(newMinRestDuration.hour, newMinRestDuration.minute, newMinRestDuration.second);
			maxRestTime.setHours(newMaxRestDuration.hour, newMaxRestDuration.minute, newMaxRestDuration.second);
						
			//Comprobamos que sea correcto
			if (minRestTime.time > maxRestTime.time)
			{
				Alert.show("Wrong Rest limits", DisplayPropertiesSingleton.APPLICATION_TITLE);
				return false;
			}
			
			//Tiempo de intervencion
			minInterventionTime = new Date();
			maxInterventionTime = new Date();
			minInterventionTime.setHours(newMinInterventionDuration.hour, newMinInterventionDuration.minute, newMinInterventionDuration.second);
			maxInterventionTime.setHours(newMaxInterventionDuration.hour, newMaxInterventionDuration.minute, newMaxInterventionDuration.second);
			//Comprobamos que sea correcto
			if (minInterventionTime.time > maxInterventionTime.time)
			{
				Alert.show("Wrong Intervention limits", DisplayPropertiesSingleton.APPLICATION_TITLE);
				return false;
			}
			
			if (maxInterventionTime.time > globalFinalTime.time || maxRestTime.time > globalFinalTime.time)
			{
				Alert.show("Enter a larger total time", DisplayPropertiesSingleton.APPLICATION_TITLE);
				return false;
			}
			
			//Comprobamos que se han introducido todos los tiempos
			if((minInterventionTime.seconds ==0 && minInterventionTime.minutes==0 && minInterventionTime.hours==0) && 
				(maxInterventionTime.seconds ==0 && maxInterventionTime.minutes==0 && maxInterventionTime.hours==0))
			{
				Alert.show("Enter intervention duration limits", DisplayPropertiesSingleton.APPLICATION_TITLE);
				return false;
			}
			
			return true;
		}
		
		/**Metodo que implementa el calculo de los checkpoints, se sobreescribe al
		 * de RandomWalk ya que hereda de esta
		 **/
		override public function calculateNextCheckpoint():Boolean
		{		
			//Iterador para recorrer el vector de miembros del equipo
			var i:int;
			
			this._modelInstance = ModelSingleton.getSingletonInstance();								
			//tiempos de llegada y salida al checkpoint
			var arrivalTime:Date;
			var startTime:Date;
			var totalTime:Date;
			var backTime:Date = new Date();
			
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
						var lastCheckpointPos:Point = calculateNextPosition();
						for (var k:int=0; k<membersTeam.length; k++)
						{
							totalTime = new Date();
							totalTime.setHours(globalFinalTime.hours+maxInterventionTime.hours+maxRestTime.hours,
								globalFinalTime.minutes+maxInterventionTime.minutes+maxRestTime.minutes,
								globalFinalTime.seconds+maxInterventionTime.seconds+maxRestTime.seconds);
								
							if (this._modelInstance.manetNodesTableCallableProxy.addManetNodeDoubleTimestampPositionCheckpoint(membersTeam[k],
								totalTime, totalTime, lastCheckpointPos.x, lastCheckpointPos.y) == false)
							{
								Alert.show("Error calculating last checkpoint", DisplayPropertiesSingleton.APPLICATION_TITLE);
								return true;
							}
						}
					}	
				}
				catch(e:Error) 
				{
					deleteTeam();
					throw new Error("Error calculating new position");
					return true;
				}	
				//Actualizamos el ultimo tiempo	y el tipo de unidad			 
				lastMovementTime = startTime;
				setNodeType(TRANSPORT_UNIT_INCIDENT);
			}
			
			//Si no es el primer movimiento
			else
			{	
				arrivalTime = new Date(lastMovementTime.time);
				startTime = new Date(lastMovementTime.time);
				
				//Si es una UNIDAD DE TRANSPORTE
				if (nodeType == TRANSPORT_UNIT_INCIDENT)
				{
					//Si es transportDirection=TRUE sale de wait Zone
					if (transportDirection)
					{
						try
						{	
							//Calculamos la nueva posicion
							lastPoint=calculateNextPosition();
							
							//Calculamos los tiempos de inicio y finalizacion de la intervencion
							interventionDuration = RandomValues.calculateRandomTime(minInterventionTime,maxInterventionTime);
							initInterventionTime = new Date();
							endInterventionTime = new Date();
							initInterventionTime.setHours(arrivalTime.hours+movementDuration.hours,
										arrivalTime.minutes+movementDuration.minutes,
										arrivalTime.seconds+movementDuration.seconds);
							endInterventionTime.setHours(initInterventionTime.hours+interventionDuration.hours,
										initInterventionTime.minutes+interventionDuration.minutes,
										initInterventionTime.seconds+interventionDuration.seconds);
						}
						catch(e:Error) 
						{
							deleteTeam();
							throw new Error("Error calculating new position");
							return true;
						}
						
						
						//Si el final de la intervencion NO supera el tiempo de simulacion 
						if (endInterventionTime.getTime() < globalFinalTime.getTime())
						{
							//Añadimos el checkpoint del vehiculo
							if(!this._modelInstance.manetNodesTableCallableProxy.addManetNodeDoubleTimestampPositionCheckpoint(membersTeam[0],
									initInterventionTime, initInterventionTime, lastPoint.x, lastPoint.y))
							{
								deleteTeam();
								throw new Error("Error calculating vehicle checkpoint");
							}							
							
							//Calculamos los tiempo de llegada y salida del checkpoint
							arrivalTime.setHours(arrivalTime.hours+movementDuration.hours,
												arrivalTime.minutes+movementDuration.minutes,
												arrivalTime.seconds+movementDuration.seconds);
												
							startTime.setHours(startTime.hours+movementDuration.hours+pauseTime.hours,
												startTime.minutes+movementDuration.minutes+pauseTime.minutes,
												startTime.seconds+movementDuration.seconds+pauseTime.seconds);
							
							//Añadimos los bomberos que viajan el en vehiculo
							for (i=1; i<membersTeam.length; i++)
							{
								if (this._modelInstance.manetNodesTableCallableProxy.addManetNodeDoubleTimestampPositionCheckpoint(membersTeam[i],
								arrivalTime, startTime, lastPoint.x, lastPoint.y) == false)
								{
									deleteTeam();
									throw new Error("Error calculating firefighter checkpoint");
								}
							}
							
							//Actualizamos la direccion del vehiculo para cuando se acabe la intervencion
							transportDirection = false;
							
							//Actualizamos el momento en el que aparco el vehiculo
							parkTime = startTime;
							//Actualizamos el ultimo tiempo				 
							lastMovementTime = startTime;
							//Actualizamos el punto en el que aparco el vehiculo
							parkPoint = lastPoint;
							
							//Bajamos la variable de retorno al vehiculo
							ff2Vehicle = false;
							//Cambiamos el tipo de nodo
							setNodeType(FIREFIGHTER_UNIT);
								
						}
						//Si la intervencion dura mas que el tiempo global
						else
						{
							//Eliminamos el ultimo checkpoint provisional de todos los miembros del equipo
							for (i=0; i<membersTeam.length; i++)
							{
								if(!this._modelInstance.manetNodesTableCallableProxy.removeManetNodeMovementByTimestamp(membersTeam[i],
										this._modelInstance.manetNodesTableCallableProxy.getManetNodeLastMovement(membersTeam[i]).toTimestampPositionCheckpoint.pointTime))
								{
									deleteTeam();
									throw new Error("Error erasing last position");
								}
							}
							return true;
						}
					}
					//Si sale de la zona del incidente va a la de espera y descansa durante el restTime
					else
					{
						try
						{
							//Calculamos la nueva posicion
							lastPoint=calculateNextPosition();
							
							//Calculamos los tiempos de inicio y finalizacion de la intervencion
							restDuration = RandomValues.calculateRandomTime(minRestTime,maxRestTime);
							initRestTime = new Date();
							endRestTime = new Date();
							initRestTime.setHours(arrivalTime.hours+movementDuration.hours,
										arrivalTime.minutes+movementDuration.minutes,
										arrivalTime.seconds+movementDuration.seconds);
							endRestTime.setHours(initRestTime.hours+restDuration.hours,
										initRestTime.minutes+restDuration.minutes,
										initRestTime.seconds+restDuration.seconds);
						}
						catch(e:Error) 
						{
							deleteTeam();
							throw new Error("Error calculating new position");
							return true;
						}
						transportDirection = true;
						
						//Si el final del descanso NO supera el tiempo de simulacion 
						if (endRestTime.getTime() < globalFinalTime.getTime())
						{
							for (i=0; i<membersTeam.length; i++)
							{
								if(!this._modelInstance.manetNodesTableCallableProxy.addManetNodeDoubleTimestampPositionCheckpoint(membersTeam[i],
									initRestTime, endRestTime, lastPoint.x, lastPoint.y))
								{
									deleteTeam();
									throw new Error("Error calculating rest position");
								}
							}
							
							//Actualizamos la direccion del vehiculo para cuando se acabe la intervencion
							transportDirection = true;
							
							//Actualizamos el ultimo tiempo				 
							lastMovementTime = endRestTime;	
						}
						//si el descanso supera el tiempo total
						else
						{
							for (i=0; i<membersTeam.length; i++)
							{
								//Eliminamos el ultimo checkpoint provisional
								if(!this._modelInstance.manetNodesTableCallableProxy.removeManetNodeMovementByTimestamp(membersTeam[i],
										this._modelInstance.manetNodesTableCallableProxy.getManetNodeLastMovement(membersTeam[i]).toTimestampPositionCheckpoint.pointTime))
								{
									deleteTeam();
									throw new Error("Error erasing last position");
								}
							}
							return true;
						}						
					}
				}
				//Si es de tipo BOMBERO
				else
				{
					//Creamos los vectores de ultimas posiciones
					var ffLastTimes:Array = new Array(numFirefighters+1);
					var ffLastPoints:Array = new Array(numFirefighters+1);
					
					//La posicion 0 corresponde al vehiculo, almacenamos los valores
					ffLastTimes[0]=initInterventionTime;
					ffLastPoints[0]=parkPoint;
								
					//Para cada miembro del equipo						
					for (i=1; i<membersTeam.length; i++)
					{						
						//Ponemos el tiempo y posicion al inicio de la intervencion			
						lastMovementTime = parkTime;
						startTime = parkTime;
						lastPoint = parkPoint;
						
						//Añadimos checkpoints al bombero hasta que alcance el final de la intervencion
						while(startTime.getTime() < endInterventionTime.getTime())
						{
							//Si está en tiempo de intervencion calculamos su posicion en la zona del incidente
							//si no la posicion vendra definida por la del nodo de transporte anterior
							arrivalTime = new Date(lastMovementTime.time);
							startTime = new Date(lastMovementTime.time);
							
							try
							{
								lastPoint=calculateNextPosition();
							}
							catch(e:Error) 
							{
								deleteTeam();
								throw new Error("Error calculating new position");
								return true;
							}						
							
							//Calculamos los tiempo de llegada y salida del checkpoint
							arrivalTime.setHours(arrivalTime.hours+movementDuration.hours,
												arrivalTime.minutes+movementDuration.minutes,
												arrivalTime.seconds+movementDuration.seconds);
												
							startTime.setHours(startTime.hours+movementDuration.hours+pauseTime.hours,
												startTime.minutes+movementDuration.minutes+pauseTime.minutes,
												startTime.seconds+movementDuration.seconds+pauseTime.seconds);
							
							//Si es el final de la simulacion
							if (startTime.getTime() > globalFinalTime.getTime())
							{
								for (i=0; i<membersTeam.length; i++)
								{
									//Eliminamos el ultimo checkpoint provisional
									if(!this._modelInstance.manetNodesTableCallableProxy.removeManetNodeMovementByTimestamp(membersTeam[i],
											this._modelInstance.manetNodesTableCallableProxy.getManetNodeLastMovement(membersTeam[i]).toTimestampPositionCheckpoint.pointTime))
									{
										deleteTeam();
										throw new Error("Error erasing last position");
									}
								}
								return true;
							}
							else
							{
								if (this._modelInstance.manetNodesTableCallableProxy.addManetNodeDoubleTimestampPositionCheckpoint(membersTeam[i],
									arrivalTime, startTime, lastPoint.x, lastPoint.y) == false)
								{
									deleteTeam();
									throw new Error("Error calculating new checkpoint");
								}
								//Actualizamos el ultimo checkpoint
								lastMovementTime = startTime;
							}	
						}
						//Almacenamos las ultimas posiciones de cada bombero
						ffLastTimes[i]=new Date(startTime.time);
						ffLastPoints[i]=new Point(lastPoint.x,lastPoint.y);
					}
					
					//Retornamos cada bombero hasta el vehiculo
					ff2Vehicle = true;
					var maxArrivalTime:Date=new Date(0);
					
					for (i=1; i<membersTeam.length; i++)
					{
						//Cargamos el ultimo tiempo y posicion del bombero
						lastPoint = ffLastPoints[i];
						arrivalTime = ffLastTimes[i];
						
						//Calculamos la nueva posicion, que sera el punto parkTime
						calculateNextPosition();
						
						//Con el tiempo de movimiento obtenido actualizamos el tiempo de llegada 
						arrivalTime.setHours(arrivalTime.hours+movementDuration.hours,
												arrivalTime.minutes+movementDuration.minutes,
												arrivalTime.seconds+movementDuration.seconds);
						
						//Actualizamos el teimpo de llegada maximo si es superior al anterior
						if (arrivalTime.getTime() > maxArrivalTime.getTime())
							maxArrivalTime = arrivalTime;
						
						//Añadimos el checkpoint
						if (this._modelInstance.manetNodesTableCallableProxy.addManetNodeDoubleTimestampPositionCheckpoint(membersTeam[i],
							arrivalTime, arrivalTime, parkPoint.x, parkPoint.y) == false)
						{
							deleteTeam();
							throw new Error("Error calculating new checkpoint");
						}
						
						//Almacenamos este valor para luego poder actualizar el instante de salida
						ffLastTimes[i] = arrivalTime;
					}
					
					//Ajustamos el tiempo de salida de todos los bomberos y del vehiculo de tal manera que coincidan 
					//con la llegada del ultimo bombero al mismo
					for (i=0; i<membersTeam.length; i++)
					{	
						if(!this._modelInstance.manetNodesTableCallableProxy.updateManetNodeTimestampPositionCheckpoint(membersTeam[i],
							ffLastTimes[i],ffLastTimes[i],ffLastTimes[i],maxArrivalTime,parkPoint.x,parkPoint.y,false))
							{
								deleteTeam();
								throw new Error("Error modifiying last checkpoint");
							}
					}
					
					//Actualizamos el tiempo del ultimo CP
					lastMovementTime = maxArrivalTime;
					
					//Cambiamos a unidad de transporte
					setNodeType(TRANSPORT_UNIT_INCIDENT);
				}
			}									 	
			
			return false;
		}
		
		/** Metodo que calcula las coordenadas del siguiente Checkpoint
		 * @throw: arroja un error en caso de no poder calcular correctamente la posicion
		 * @return Point, coordenadas cartesianas del siguiente Checkpoint
		 **/ 
		override public function calculateNextPosition():Point
		{
			var rand:RandomValues=new RandomValues();
			var newPoint:Point;
			
			//Si esta activa la marca de ff2Vehicle, los bomberos retornan al coche
			if(nodeType == FIREFIGHTER_UNIT && ff2Vehicle)
			{
				minSpeed = minFootSpeed;
				maxSpeed = maxFootSpeed;
				newPoint = parkPoint;
			}
			//si es un bombero se mueve por la del incidente
			else if(nodeType == FIREFIGHTER_UNIT)
			{
				minSpeed = minFootSpeed;
				maxSpeed = maxFootSpeed;
				newPoint = new Point(rand.createRandomPosition(incidentZone[0],incidentZone[1]),
						rand.createRandomPosition(incidentZone[2],incidentZone[3]));
			}
			//Si es unidad de transporte va desde la zona del jefe a la del incidente
			else
			{
				minSpeed = minCarSpeed;
				maxSpeed = maxCarSpeed;
				
				if (lastPoint.x >= waitZone[0] && lastPoint.x <= waitZone[1] && lastPoint.y >= waitZone[2] && lastPoint.y <= waitZone[3])
				{
					newPoint = new Point(rand.createRandomPosition(incidentZone[0],incidentZone[1]),
							rand.createRandomPosition(incidentZone[2],incidentZone[3]));
				}
				else
				{
					newPoint = new Point(rand.createRandomPosition(waitZone[0],waitZone[1]),
							rand.createRandomPosition(waitZone[2],waitZone[3]));
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
		
		override public function createTeam(newNodeId:String, newTime:Date, newXCoor:int, newYCoor:int):Boolean
		{
			//Almacenamos los miembros del equipo en un vector
			membersTeam = new Array(numFirefighters+1);
			membersTeam[0] = newNodeId;
			
			//Obtenemos el rango
			var nodeRange:int = this._modelInstance.manetNodesTableReadableProxy.getManetNodeRange(newNodeId);
			
			//Creamos los miembros del equipo
			var newManetNode:ManetNode;
			var rand:RandomValues = new RandomValues();			
			var newNodeTeamId:String;			
			var memberNum:int=1;
			while (memberNum < numFirefighters+1)
			{
				rand.generateRandomColor();
				newManetNode = new ManetNode("", nodeRange, rand.value.toString(), "", 0, newNodeId+"-"+memberNum);
				newNodeTeamId = this._modelInstance.manetNodesTableCallableProxy.addManetNode(newManetNode, false);
				if (!this._modelInstance.manetNodesTableCallableProxy.addManetNodeDoubleTimestampPositionCheckpoint(newNodeTeamId,
						newTime, newTime, newXCoor, newYCoor))
				{
					this._modelInstance.manetNodesTableCallableProxy.removeManetNode(newNodeTeamId);
					return false;
				}
				membersTeam[memberNum]=newNodeTeamId;
				memberNum++;
			}
			
			//Si es el primer equipo creamos al jefe de operaciones, fijo en la zona de espera
			if(numTeam == 1)
			{
				addChief();
			}
	
			return true;
		}
		
		private function addChief():Boolean
		{
			//Obtenemos el rango
			var nodeRange:int = this._modelInstance.manetNodesTableReadableProxy.getManetNodeRange(nodeId);
			
			var newManetNode:ManetNode;
			var rand:RandomValues = new RandomValues();			
			
			//Lo colocamos en un punto fijo de la zona de espera durante todo el tiempo de simulacion
			var chiefPos:Point = new Point(rand.createRandomPosition(waitZone[0],waitZone[1]),
										rand.createRandomPosition(waitZone[2],waitZone[3]));
			var chiefTime:Date = new Date();
			chiefTime.setHours(0,0,0);
			
			rand.generateRandomColor();
			newManetNode = new ManetNode("", nodeRange, rand.value.toString(), "", 0, "");
			chiefId = this._modelInstance.manetNodesTableCallableProxy.addManetNode(newManetNode, true);
			if (!this._modelInstance.manetNodesTableCallableProxy.addManetNodeDoubleTimestampPositionCheckpoint(chiefId,
					chiefTime, chiefTime,chiefPos.x, chiefPos.y))
			{
				this._modelInstance.manetNodesTableCallableProxy.removeManetNode(chiefId);
				return false;
			}
			
			return true;
		}
		
		private function deleteTeam():void
		{
			this._modelInstance.manetNodesTableCallableProxy.removeManetNode(chiefId);
			for (var j:int=1; j<membersTeam.length; j++)
				this._modelInstance.manetNodesTableCallableProxy.removeManetNode(membersTeam[j]);
		}
	}
}