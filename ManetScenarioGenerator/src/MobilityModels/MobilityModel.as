/** Interface para la generacion de los modelos de movilidad
 * dependiendo el modelo seleccionado sera implementada por
 * la clase correspondiente del paquete MobilityModels
 **/

package MobilityModels
{
	import flash.geom.Point;
	
	public interface MobilityModel
	{
				
		 function MobilityModel(newNodeId:String,newGlobalTime:Date);
		
		 function calculateNextCheckpoint():Boolean;
		 
		 function getLastMvTime():Date;
		 
		 function getLastPoint():Point;
		 
		 function setMovementDuration(movementDuration:Date):void;
		 
		 function setGlobalDuration(globalFinalTime:Date):void;
		 
		 function setLastPoint(newPoint:Point):void;
		 
		 function setDistance(movementDistance:int):void;
		 
		 function setMinSpeed(newMinSpeed:int):void;
		 
		 function setMaxSpeed(newMaxSpeed:int):void;
		 
		 function setTypeParameter(newType:Boolean):void;
		 
		 function setArea(myArea:Array):void;
		 
		 //RandomWayPoint
		 function setPauseTime(newPauseTime:Date):void;
		 
		 //Gauss-Markov
		 function setTuningParam(newTuninParam:Number):void;
		 
		 //CitySection
		 function setStreetLong(newStreetLong:Number):void;
		 function setNumberHSStreets(newHSS:int):void;
		 
		 //Disaster Area
		 function setNodeType(newNodeType:int):void;
		 function setUnitSpeed(newUnitSpeed:Boolean):void;
		 function setPauseTime2(newPauseTime2:Object):void;
		 function setZones(newIncidentZone:Array,newTretmentZone:Array,newWaitZone:Array):void;
		 function setSpeedLimits(newMinFoot:int,newMaxFoot:int,newMinCar:int,newMaxCar:int):void;
		 
		 //Incident Area
		 function setNumFirefighters(newNumFirefighters:int):void;
		 function createTeam(newNodeId:String, newTime:Date, newXCoor:int, newYCoor:int):Boolean;
		 function setRestLimits(newMinRestDuration:Object, newMaxRestDuration:Object, 
				newMinInterventionDuration:Object, newMaxInterventionDuration:Object):Boolean;
	}
}