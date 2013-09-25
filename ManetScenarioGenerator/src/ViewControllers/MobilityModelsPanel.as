// ActionScript file

/** MobilityModelsPanel.as
 *  Controlador del panel de Mobility Model
 * **/
 
import Classes.DisplayPropertiesSingleton;
import Classes.DisplayPropertyChangeEventKind;
import Classes.ModelSingleton;

import Entities.ManetNode;

import InterfaceComponents.SelectAreaPopUp;

import MobilityModels.*;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.Application;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;

//////////////////////////////////////////////////////////////
////////////// CONSTANTES ///////////////////////////////////
/////////////////////////////////////////////////////////////
//Tiempo entre calculo de checkpoints (ms)
public const REFRESH_TIME:int = 10;
//Intentos de repeticion de calculo si un nodo es erroneo
public const MAX_ATTEMPTS:int = 5;

//////////////////////////////////////////////////////////////
////// VARIABLES GLOBALES ///////////////////////////////////
/////////////////////////////////////////////////////////////
private var _displayPropertiesInstance:DisplayPropertiesSingleton;
private var _modelInstance:ModelSingleton;

//Variable que implementa el modelo elegido
private var model:MobilityModel;

//Numero de nodos a crear
private var numNode:int;
private var totalNodes:int;

//Id del nodo actual
private var nodeId:String;
private var nodeType:int;

//Temporizador para calcular el siguiente checkpoint 
//y permitir refrescar la pantalla
private var t:Timer;

//Tiempo total del movimiento
private var globalFinalTime:Date

//Intento de repeticion de calculo actual
private var attempt:int=1;

//PopUp que permite seleccionar un area de aplicacion del modelo
private var windowArea:SelectAreaPopUp;
//Coordenadas del Area donde se generara el modelo [xFron xTo yFrom yTo]
private var myArea:Array;
private var x_From:int;
private var x_To:int;
private var y_From:int;
private var y_To:int;

//Zonas para el modelo Disaster Area [xFron xTo yFrom yTo]
private var incidentZone:Array;
private var treatmentZone:Array;
private var waitZone:Array;

//Variables para el caso de que se esté utilizando Google Maps
private var googleLoaded:Boolean;//FR
private var googleMinFootSpeed:Number;//FR
private var googleMaxFootSpeed:Number;//FR
private var googleMinVehicleSpeed:Number;//FR
private var googleMaxVehicleSpeed:Number;//FR

//Lista de los diferentes Modelos de Mobilidad
[Bindable]
public var EnumMobilityTypes:ArrayCollection = new ArrayCollection(
    [ {label:"Random Walk", data:0}, 
      {label:"Random Waypoint", data:1}, 
      {label:"Random Direction", data:2},
      {label:"Gauss-Markov", data:3},
      {label:"City Section", data:4},
      {label:"Disaster Area", data:5},
      {label:"Incident Area", data:6}
      ]);


///////////////////////////////////////////////////////////
//  METODOS del Controlador Mobility Models  //////////////
///////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////
///////////  MANEJADORES DE EVENTOS  //////////////////////
///////////////////////////////////////////////////////////
/** Manejador de inicializacion del panel**/
private function creationComplete_handler(event:Event):void
{
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	this._displayPropertiesInstance.addEventListener(DisplayPropertyChangeEventKind.CLEAR_SCENARIO_EVENT, clearScenarioEvent_handler);
	this.chkCompleteScenario.addEventListener(MouseEvent.CLICK,setCompleteAcenarioArea);
}

/**Manejador para borrar el panel**/
private function clearScenarioEvent_handler(event:Event):void
{
	this.clearPanel();
}     


/**Manejador del boton Create Model
 * @chages: pasa al estado Generating Model y llama a createModel**/
public function btnCreateModelClick_handler(event:Event):void
{	
	this.currentState = "Generating Model"; 
	numNode = 0;
	
	//Si es Disaster Area comprobamos el tipo de nodo a generar
	if (this.cmbModelSelection.selectedLabel == "Disaster Area")
	{
		if(this.numFirefighters.value == 0 && this.numParamedics.value == 0 &&
			this.numTransportsToTreatment.value == 0 && this.numTransportsToIncident.value == 0)
		{
			Alert.show("Enter number of units", DisplayPropertiesSingleton.APPLICATION_TITLE);
			currentState = this.cmbModelSelection.selectedLabel;
			return;
		}
		else if (this.numFirefighters.value != 0) nodeType=MobilityModels.DisasterArea.FIREFIGHTER_UNIT;
		else if (this.numParamedics.value != 0) nodeType=MobilityModels.DisasterArea.PARAMEDIC_UNIT;
		else if (this.numTransportsToTreatment.value != 0) nodeType=MobilityModels.DisasterArea.TRANSPORT_UNIT_TREATMENT;
		else if (this.numTransportsToIncident.value != 0) nodeType=MobilityModels.DisasterArea.TRANSPORT_UNIT_INCIDENT;
	}
	
	//Comenzamos la creacion del modelo
	createModel();
}

/**Manejador del boton Cancelar generacion de modelo
 * @chages: captura pulsacion del boton cancel y saca un dialogo
 * para que el usuario ratifique que quiere cancelar la generacion
 **/ 
public function btnCancelModelGeneration_handler(e:Event):void
{
	Alert.show("Are you sure to cancel the model generation?", DisplayPropertiesSingleton.APPLICATION_TITLE,
		 (Alert.YES | Alert.NO), null, eraseNode);
}

/**Manejador del evento Cancelar generacion del modelo
 * @chages: si el usurio ratifica la cancelacion borra el nodo que
 * esta generando y vuelve al estado de creacion de modelo
 **/
private function eraseNode(event:CloseEvent):void
{
	if(event.detail == Alert.YES)
	{
		t.stop();
		this._modelInstance.manetNodesTableCallableProxy.removeManetNode(nodeId);
		currentState = this.cmbModelSelection.selectedLabel;
		Alert.show("Model generation canceled", DisplayPropertiesSingleton.APPLICATION_TITLE);
	}
}

/**Metodo que captura el evento del Timer encargado de repetir
 * la generacion del modelo hasta llegar al tiempo global
 **/
public function continueModelCreation(e:Event):void
{
	generateMobilityModel(nodeId);
}

/** Metodo que borra el panel**/
public function clearPanel():void
{
	attempt=1;
	model = null;
	myArea= null;
	globalFinalTime = null;
	this.chkCompleteScenario.selected = true;
	this.AreaButton.enabled=false;
	Application.application.scenarioField.selectRectCanvas.visible = false;
	this.cmbModelSelection.selectedIndex = 0;
	this.currentState = "Random Walk";
	this.nsAddRange.value = 0;
	this.nodeNumber.value = 1;
	this.minSpeed.value = 1;
	this.maxSpeed.value = 10;
	this.movDuration.hour = 0;
	this.movDuration.minute = 0;
	this.movDuration.second = 0;
	this.mvDistance.value = 1;
	this.globalTime.hour = 0;
	this.globalTime.minute = 0;
	this.globalTime.second = 0;
	if (this.pauseTime != null)
	{
		this.pauseTime.hour = 0;
		this.pauseTime.minute = 0;
		this.pauseTime.second = 0;
	}
	if (this.tunningParam != null)
		this.tunningParam.value = 0.5;
	if (this.streetLong != null)
		this.streetLong.value = 50;
	nodeType = MobilityModels.DisasterArea.FIREFIGHTER_UNIT;
	if (this.numFirefighters != null)
	{
		this.numFirefighters.value = 0;
		this.numParamedics.value = 0;
		this.numTransportsToTreatment.value = 0;
		this.numTransportsToIncident.value = 0;
	}
	incidentZone = treatmentZone = waitZone = null;
	if (this.numFifreFightersIA != null)
	{
		this.numFifreFightersIA.value = 0;
		this.interventionMinTime.hour = 0;
		this.interventionMinTime.minute = 10;
		this.interventionMinTime.second = 0;
		this.interventionMaxTime.hour = 0;
		this.interventionMaxTime.minute = 25;
		this.interventionMaxTime.second = 0;
		this.restMinTime.hour = 0;
		this.restMinTime.minute = 5;
		this.restMinTime.second = 0;
		this.restMaxTime.hour = 0;
		this.restMaxTime.minute = 10;
		this.restMaxTime.second = 0;
	}
	this.minFootSpeed.value = 1;
	this.maxFootSpeed.value = 2;
	this.minVehicleSpeed.value = 5;
	this.maxVehicleSpeed.value = 12;
	this.pauseTime2.hour=0;
	this.pauseTime2.minute=0;
	this.pauseTime2.second=5;
	this.selectAdvParam.visible=false;
	//FR
	this.googleLoaded = false;
	this.googleMinFootSpeed = 1;
	this.googleMaxFootSpeed = 2;
	this.googleMinVehicleSpeed = 5;
	this.googleMaxVehicleSpeed = 12;
	//FR
}

/** Creacion del popup de ayuda para el modelo seleccionado en cada momento **/
private function helpPopUp_handler(event:Event):void
{
    [Embed(source='Images/helpIcon48.png')]
	var Icon:Class;
	
	Alert.show(MobilityModelsHelp(this.cmbModelSelection.selectedIndex),
		 "HELP: "+this.cmbModelSelection.selectedLabel+" Mobility Model",4,null,null,Icon);
}


///////////////////////////////////////////////////////////
////////  METODOS  PARA CREAR EL MODELO   /////////////////
///////////////////////////////////////////////////////////  
/**Metodo que manda crear el modelo
 * @changes: crea un numero de nodos determinado con el modelo de movilidad elegido
 **/
private function createModel():void
{
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	this._modelInstance = ModelSingleton.getSingletonInstance();
	
	//FR
	//Se comprueba si hay mapa de Google cargado en el escenario
	if (this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo!=null)
		if (this._modelInstance.scenarioPropertiesCallableProxy.connectedToInternet)
			if (this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._visible)
				if ((this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._location != "") ||
					(this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._centerMapMode == "Coordinates")){
						
						this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue = this.nsAddRange.value;
						this._modelInstance.lockDispatchSetGoogleMobilityValueEvent(false);
						this.googleLoaded = true;		
						
					}
				
	//FR
	
	//Si no estamos en el modelo Disaster Area
	if (this.cmbModelSelection.selectedLabel != "Disaster Area")
		totalNodes=this.nodeNumber.value;
	else
		totalNodes=this.numParamedics.value+this.numFirefighters.value+
			this.numTransportsToTreatment.value+this.numTransportsToIncident.value;
	
	//Actualizamos el numero de nodos creados
	numNode++;
	
	//Creamos el nodo y le aplicamos el modelo de movilidad seleccionado
	nodeId=createNewNode();
	if(nodeId == null)
	{			
		Alert.show("Error adding the Node", DisplayPropertiesSingleton.APPLICATION_TITLE);
		currentState = this.cmbModelSelection.selectedLabel;
		return;
	}
	
	//Mientras no llegue al tiempo Global de simulacion generamos un nuevo Checkpoint
	generateMobilityModel(nodeId);

}

/**Metodo que crea un nuevo nodo en una posicion aleatoria
 * @returns String: La Id del nodo creado
 **/
private function createNewNode():String
{	
	var pauseTime:Date;
	
	//Capturamos el tiempo Global para la simulacion del modelo
	globalFinalTime = new Date();
	var instantTimeObject:Object;
	instantTimeObject = this.globalTime.timeValue;
	globalFinalTime.setHours(instantTimeObject.hour, instantTimeObject.minute, instantTimeObject.second);
	
	if (globalFinalTime.hours==0 && globalFinalTime.minutes == 0 && globalFinalTime.seconds ==0)
	{
		Alert.show("Enter a Total duration for the model", DisplayPropertiesSingleton.APPLICATION_TITLE);
		currentState = this.cmbModelSelection.selectedLabel;
		return null;
	}
	
	//Creamos el nuevo nodo
	var newManetNode:ManetNode;
	var rand:RandomValues = new RandomValues();
	rand.generateRandomColor();
	
	//FR
	if (this.googleLoaded){
		newManetNode = new ManetNode("", this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue, rand.value.toString(), "", 0, "");
	}
	else{
		newManetNode = new ManetNode("", this.nsAddRange.value, rand.value.toString(), "", 0, "");
	}
	//newManetNode = new ManetNode("", this.nsAddRange.value, rand.value.toString(), "", 0, "");
	//FR
	
	var newNodeId:String = this._modelInstance.manetNodesTableCallableProxy.addManetNode(newManetNode, true);
	
	this._displayPropertiesInstance.setManetNodeColour(newNodeId, rand.value);

	//Inicializamos los tiempos adecuados
	var newTime:Date;
	if (this.pauseTime != null)
	{
		newTime = new Date();
		newTime.setHours(0,0,0);
		//Inicializamos a cero el initTime
		if(this._modelInstance.scenarioPropertiesCallableProxy.initTime == null)
			this._modelInstance.scenarioPropertiesCallableProxy.initTime = newTime;
		//Cargamos en newTime el tiempo de pausa
		newTime = capturePauseTime(newNodeId);
	}
	else
	{
		newTime = new Date();
		newTime.setHours(0,0,0);
	}
	
	if (this.cmbModelSelection.selectedLabel != "Disaster Area" && this.cmbModelSelection.selectedLabel != "Incident Area")
	{
		//Cargamos los limites del area en el que generamos el modelo
		if (myArea == null)	//generar modelo en todo el escenario
		{
			x_From = 0;
			x_To = this._modelInstance.scenarioPropertiesCallableProxy.width;
			y_From = 0;
			y_To = this._modelInstance.scenarioPropertiesCallableProxy.height;
		}
		else	//se han introducido unos limites
		{
			x_From = myArea[0];
			x_To = myArea[1];
			y_From = myArea[2];
			y_To = myArea[3];
		}
	}
	//si es Disaster Area creamos en la zona que corresponda
	else if (this.cmbModelSelection.selectedLabel == "Disaster Area")
	{
		if (incidentZone==null || treatmentZone==null || waitZone==null)
		{
			Alert.show("You must define the 3 zones of the model", DisplayPropertiesSingleton.APPLICATION_TITLE);
			currentState = this.cmbModelSelection.selectedLabel;
			return null;
		}
		if (nodeType == MobilityModels.DisasterArea.FIREFIGHTER_UNIT)
		{
			x_From = incidentZone[0];
			x_To = incidentZone[1];
			y_From = incidentZone[2];
			y_To = incidentZone[3];
		}
		else if (nodeType == MobilityModels.DisasterArea.PARAMEDIC_UNIT)
		{
			x_From = treatmentZone[0];
			x_To = treatmentZone[1];
			y_From = treatmentZone[2];
			y_To = treatmentZone[3];
		}
		else
		{
			x_From = waitZone[0];
			x_To = waitZone[1];
			y_From = waitZone[2];
			y_To = waitZone[3];
		}
	}
	
	//Si estamos en Incident Area cargamos las dos zonas
	else
	{
		if (incidentZone==null || waitZone==null)
		{
			Alert.show("You must define the 2 zones of the model", DisplayPropertiesSingleton.APPLICATION_TITLE);
			currentState = this.cmbModelSelection.selectedLabel;
			return null;
		}
		//Comienzan el movimiento en la zona del Jefe
		x_From = waitZone[0];
		x_To = waitZone[1];
		y_From = waitZone[2];
		y_To = waitZone[3];
	}
	
	//Generamos el primer checkpoint con los parametros seleccionados
	rand = new RandomValues();
	var randomPoint:Point=new Point(rand.createRandomPosition(x_From,x_To), rand.createRandomPosition(y_From,y_To));
	
	if (!this._modelInstance.manetNodesTableCallableProxy.addManetNodeDoubleTimestampPositionCheckpoint(newNodeId,
			 newTime, newTime, randomPoint.x, randomPoint.y))
	{
		this._modelInstance.manetNodesTableCallableProxy.removeManetNode(newNodeId);
		return null;
	}
	
	//Cambiamos el estado del nodo a encendido, 
	//con esto se soluciona el problema al cargar escenarios guardados
	if(!this._modelInstance.manetNodesTableCallableProxy.setManetNodeState(newNodeId,newTime,true,randomPoint.x, randomPoint.y,0))
		Alert.show("Error updating node state", DisplayPropertiesSingleton.APPLICATION_TITLE);
	
	//Una vez generado el primer checkpoint comprobamos que Modelo de mobilidad
	//se quiere simular y se cargan los parametros del mismo
	var selectedModel:int=this.cmbModelSelection.selectedIndex;
	var movementDuration:Date = new Date();
	var instantTimeObject2:Object;
	
	switch(selectedModel)
	{
		//RANDOM WALK
		case 0: model = new RandomWalk(newNodeId); 
				if(!initCommonParam(newNodeId,model,randomPoint))
					return null;
				//Capturamos el tiempo o la distancia que recorre cada nodo
				if (this.chkMvDuration.selected)
				{ 
					instantTimeObject2 = this.movDuration.timeValue;
					movementDuration.setHours(instantTimeObject2.hour, instantTimeObject2.minute, instantTimeObject2.second);
					if ((movementDuration.hours==0 && movementDuration.minutes == 0 && movementDuration.seconds ==0) ||
						(movementDuration.time > globalFinalTime.time))
					{
						Alert.show("Enter correct Movement duration", DisplayPropertiesSingleton.APPLICATION_TITLE);
						this._modelInstance.manetNodesTableCallableProxy.removeManetNode(newNodeId);
						currentState = this.cmbModelSelection.selectedLabel;
						return null;
					}
					model.setTypeParameter(true);
					model.setMovementDuration(movementDuration);
				}
				else if (this.chkMvDistance.selected)
				{
					//FR
					var movementDistance:int = this.mvDistance.value;
					
					if(this.googleLoaded){
						
						this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue = this.mvDistance.value;
						this._modelInstance.lockDispatchSetGoogleMobilityValueEvent(false);
						movementDistance = this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue;
					}
					
					model.setTypeParameter(false);
					model.setDistance(movementDistance);
					/*var movementDistance:int = this.mvDistance.value;
					model.setTypeParameter(false);
					model.setDistance(movementDistance);*/
					//FR	
				}
				break;
		
		//RANDOM WAYPOINT	
		case 1: model = new RandomWaypoint(newNodeId); 
				if(!initCommonParam(newNodeId,model,randomPoint))
					return null;
				pauseTime = capturePauseTime(newNodeId);
				model.setPauseTime(pauseTime);
				break;
				
		//RANDOM DIRECTION
		case 2: model = new RandomDirection(newNodeId); 
				if(!initCommonParam(newNodeId,model,randomPoint))
					return null;
				pauseTime = capturePauseTime(newNodeId);
				model.setPauseTime(pauseTime);
				break;
		
		//GAUSS-MARKOV		
		case 3: model = new GaussMarkov(newNodeId);
				if(!initCommonParam(newNodeId,model,randomPoint))
					return null;
				instantTimeObject2 = this.movDuration.timeValue;
				movementDuration.setHours(instantTimeObject2.hour, instantTimeObject2.minute, instantTimeObject2.second);
				if ((movementDuration.hours==0 && movementDuration.minutes == 0 && movementDuration.seconds ==0) ||
					(movementDuration.time > globalFinalTime.time))
				{
					Alert.show("Enter correct Movement duration", DisplayPropertiesSingleton.APPLICATION_TITLE);
					this._modelInstance.manetNodesTableCallableProxy.removeManetNode(newNodeId);
					currentState = this.cmbModelSelection.selectedLabel;
					return null;
				}
				model.setTypeParameter(true);
				model.setMovementDuration(movementDuration);
				model.setTuningParam(this.tunningParam.value);
				break;
				
		//CITY SECTION
		case 4: model = new CitySection(newNodeId);
				if(!initCommonParam(newNodeId,model,randomPoint))
					return null;
				model.setTypeParameter(false);
				
				//FR
				if(this.googleLoaded){
					this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue = this.streetLong.value;
					this._modelInstance.lockDispatchSetGoogleMobilityValueEvent(false);
					model.setStreetLong(this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue);
				}
				else{
					model.setStreetLong(this.streetLong.value);
				}
				//model.setStreetLong(this.streetLong.value);
				//FR
				
				model.setNumberHSStreets(this.numberHSStreets.value);
				break;
				
		//DISASTER AREA
		case 5: model = new DisasterArea(newNodeId);
				model.setPauseTime2(this.pauseTime2.timeValue);
				model.setLastPoint(randomPoint);
				model.setGlobalDuration(globalFinalTime);
				model.setNodeType(nodeType);
				model.setTypeParameter(false);
				
				//FR
				if(this.googleLoaded){
					this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue = this.minFootSpeed.value;
					this._modelInstance.lockDispatchSetGoogleMobilityValueEvent(false);
					this.googleMinFootSpeed = this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue;
					this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue = this.maxFootSpeed.value;
					this._modelInstance.lockDispatchSetGoogleMobilityValueEvent(false);
					this.googleMaxFootSpeed = this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue;
					this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue = this.minVehicleSpeed.value;
					this._modelInstance.lockDispatchSetGoogleMobilityValueEvent(false);
					this.googleMinVehicleSpeed = this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue;
					this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue = this.maxVehicleSpeed.value;
					this._modelInstance.lockDispatchSetGoogleMobilityValueEvent(false);
					this.googleMaxVehicleSpeed = this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue;
					model.setSpeedLimits(this.googleMinFootSpeed,this.googleMaxFootSpeed,
						this.googleMinVehicleSpeed,this.googleMaxVehicleSpeed);
				}
				else{
					model.setSpeedLimits(this.minFootSpeed.value,this.maxFootSpeed.value,
						this.minVehicleSpeed.value,this.maxVehicleSpeed.value);
				}
				//model.setSpeedLimits(this.minFootSpeed.value,this.maxFootSpeed.value,
				//	this.minVehicleSpeed.value,this.maxVehicleSpeed.value);
				//FR
				
				model.setZones(incidentZone,treatmentZone,waitZone);
				break;
				
		//INCIDENT AREA
		case 6: model = new IncidentArea(newNodeId,numNode);
				model.setPauseTime2(this.pauseTime2.timeValue);
				model.setLastPoint(randomPoint);
				model.setGlobalDuration(globalFinalTime);
				model.setNodeType(DisasterArea.TRANSPORT_UNIT_INCIDENT);
				model.setTypeParameter(false);
				model.setZones(incidentZone,null,waitZone);
				model.setNumFirefighters(this.numFifreFightersIA.value);
				
				//FR
				if(this.googleLoaded){
					this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue = this.minFootSpeed.value;
					this._modelInstance.lockDispatchSetGoogleMobilityValueEvent(false);
					this.googleMinFootSpeed = this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue;
					this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue = this.maxFootSpeed.value;
					this._modelInstance.lockDispatchSetGoogleMobilityValueEvent(false);
					this.googleMaxFootSpeed = this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue;
					this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue = this.minVehicleSpeed.value;
					this._modelInstance.lockDispatchSetGoogleMobilityValueEvent(false);
					this.googleMinVehicleSpeed = this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue;
					this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue = this.maxVehicleSpeed.value;
					this._modelInstance.lockDispatchSetGoogleMobilityValueEvent(false);
					this.googleMaxVehicleSpeed = this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue;
					model.setSpeedLimits(this.googleMinFootSpeed,this.googleMaxFootSpeed,
						this.googleMinVehicleSpeed,this.googleMaxVehicleSpeed);
				}
				else{
					model.setSpeedLimits(this.minFootSpeed.value,this.maxFootSpeed.value,
						this.minVehicleSpeed.value,this.maxVehicleSpeed.value);
				}
				//model.setSpeedLimits(this.minFootSpeed.value,this.maxFootSpeed.value,
				//	this.minVehicleSpeed.value,this.maxVehicleSpeed.value);
				//FR
				
				if (!model.setRestLimits(this.restMinTime.timeValue, this.restMaxTime.timeValue,
					this.interventionMinTime.timeValue,this.interventionMaxTime.timeValue) ||
					(!model.createTeam(newNodeId, newTime, randomPoint.x, randomPoint.y)))
				{
					this._modelInstance.manetNodesTableCallableProxy.removeManetNode(newNodeId);
					return null;
				}
				break;
				
		default: Alert.show("Choose other mobility model", DisplayPropertiesSingleton.APPLICATION_TITLE);
	}
	return newNodeId;
} 

/**Funcion que genera los nuevos Checkpoints siguiendo el modelo seleccionado
 * @changes: calcula el siguiente checkpoint y si no se ha completado el tiempo
 * lanza un timer que repetira de nuevo la acciÃ³n
 **/	
private function generateMobilityModel(nodeId:String):void
{
	var isFinal:Boolean;
	try
	{
		//Calculamos el siguiente checkpoint
		isFinal = model.calculateNextCheckpoint();
		
		//Si no se ha llegado al tiempo total lanzamos un timer
		//para calcular el siguiente checkpoint, se hace asi para
		//permitir a la aplicacion refrescar la pantalla
		if(!isFinal)
		{
			t = new Timer(REFRESH_TIME,1);
			t.addEventListener(TimerEvent.TIMER,continueModelCreation);
			t.start();
		}
		//si se llego al final se vuelve al estado de seleccion de modelo
		else
		{
			//Si no es Disaster Model
			if (this.cmbModelSelection.selectedLabel != "Disaster Area")
			{
				if (numNode < totalNodes)
					createModel();
				else
					currentState = this.cmbModelSelection.selectedLabel;
			}
			//Si es Disaster Area comprobamos si hay que cambiar el tipo de nodo
			else
			{
				if (numNode < totalNodes)
				{
					//Cambiamos el tipo de nodo a crear
					if(numNode == this.numFirefighters.value)
						nodeType=MobilityModels.DisasterArea.PARAMEDIC_UNIT;
					else if(numNode == this.numFirefighters.value+this.numParamedics.value)
						nodeType=MobilityModels.DisasterArea.TRANSPORT_UNIT_TREATMENT;
					else if(numNode == this.numFirefighters.value+this.numParamedics.value+this.numTransportsToTreatment.value)
						nodeType=MobilityModels.DisasterArea.TRANSPORT_UNIT_INCIDENT;
					attempt=1;
					createModel();
				}
				else
					currentState = this.cmbModelSelection.selectedLabel;
			}
		}
	}
	catch(e:Error) 
	{
		this._modelInstance.manetNodesTableCallableProxy.removeManetNode(nodeId);
		numNode--;
		//si superamos los intentos de creacion maximos no fue posible 
		if (attempt == MAX_ATTEMPTS)
		{
			Alert.show(e.message+".\nTRY WITH OTHER PARAMETERS", DisplayPropertiesSingleton.APPLICATION_TITLE);
			currentState = this.cmbModelSelection.selectedLabel;
			return;
		}
		//si no superamos los intentos maximos volvemos a intentar crear el modelo
		attempt++;
		createModel();	
	}
}

/**Funcion que carga los parametros comunes a los modelos**/
private function initCommonParam(newNodeId:String,model:MobilityModel,randomPoint:Point):Boolean
{
	model.setLastPoint(randomPoint);
	model.setGlobalDuration(globalFinalTime);
	if (this.minSpeed.value > this.maxSpeed.value)
	{
		this._modelInstance.manetNodesTableCallableProxy.removeManetNode(newNodeId);
		Alert.show("Enter correct speed values", DisplayPropertiesSingleton.APPLICATION_TITLE);
		currentState = this.cmbModelSelection.selectedLabel;
		return false;
	}
	
	//FR
	if (this.googleLoaded){
		
		this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue = this.minSpeed.value;
		this._modelInstance.lockDispatchSetGoogleMobilityValueEvent(false);
		model.setMinSpeed(this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue);
		this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue = this.maxSpeed.value;
		this._modelInstance.lockDispatchSetGoogleMobilityValueEvent(false);
		model.setMaxSpeed(this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue);

	}
	else{
	
		model.setMinSpeed(this.minSpeed.value);
		model.setMaxSpeed(this.maxSpeed.value);		
	
	}
	//model.setMinSpeed(this.minSpeed.value);
	//model.setMaxSpeed(this.maxSpeed.value);
	//FR
	
	if (this.chkCompleteScenario.selected)
		myArea = null;
	model.setArea(myArea);
	return true;
}

/**Funcion que captura el tiempo de pausa entre movimientos si existe**/
private function capturePauseTime(newNodeId:String):Date
{
	var pauseTime:Date = new Date();
	var instantTimeObject3:Object;
	instantTimeObject3 = this.pauseTime.timeValue;
	pauseTime.setHours(instantTimeObject3.hour, instantTimeObject3.minute, instantTimeObject3.second);
	if ((this.pauseTime != null) && (pauseTime.time > globalFinalTime.time))
	{
		Alert.show("Enter correct pause duration", DisplayPropertiesSingleton.APPLICATION_TITLE);
			this._modelInstance.manetNodesTableCallableProxy.removeManetNode(newNodeId);
		currentState = this.cmbModelSelection.selectedLabel;
		return null;
	}
	
	return pauseTime;
}

//////////////////////////////////////////////////////////////////////////////////
/////////// FUNCIONES DE SELECCION DE AREA PARA EL MOVIMIENTO ////////////////////
//////////////////////////////////////////////////////////////////////////////////

/**Manejador del boton Select Area
 * Recibe el tipo de boton que se pulso:
 *  0: Seleccion de area general
 *  1: Incident Area (Disaster Area MM e Incident Area MM)
 *  2: Treatment Area (Disaster Area MM)
 *  3: Wait Area (Disaster Area MM e Incident Area MM)
 * **/
public function btnSelectAreaClick_handler(buttonKind:int):void
{
	//Dejamos el area visible y apagamos los listener mientras la editamos
	this.AreaButton.removeEventListener(MouseEvent.ROLL_OUT,hideArea);
	if(this.cmbModelSelection.selectedLabel == "Disaster Area" || this.cmbModelSelection.selectedLabel == "Incident Area")
	{
		this.incidentArea.removeEventListener(MouseEvent.ROLL_OUT,hideArea);
		this.waitArea.removeEventListener(MouseEvent.ROLL_OUT,hideArea);
		//Si es Disaster Area
		if(treatmentArea != null)
			this.treatmentArea.removeEventListener(MouseEvent.ROLL_OUT,hideArea);
	}
	Application.application.scenarioField.selectRectCanvas.visible = true;
	
	//Creamos el POPUP de seleccion
    windowArea = SelectAreaPopUp(PopUpManager.createPopUp(this, SelectAreaPopUp , false));
    
    //Situamos el PopUp debajo del boton Select Area
    var point1:Point = new Point();
    point1.x = 0;
    point1.y = 0;                
    point1 = btnCreateModel.localToGlobal(point1);
    windowArea.x = point1.x + 450;
    windowArea.y = point1.y + 50;
    
    //Si no es Disaster Area seleccionamod un area completa para el modelo
    if (buttonKind == 0)
    {
    	windowArea.initParam(myArea,0);
    }
    //Si es Disaster Area comprobamos que zona se esta fijando
	else
	{
		var zoneType:Array = new Array(2);
		zoneType[0]=-1;
		switch(buttonKind)
		{
			//Se pulso el boton Incident Area
			case 1:	zoneType[1]=1; 
					this.incidentArea.addEventListener(MouseEvent.ROLL_OVER,showIncidentZone);
					this.waitArea.enabled = false;
					if (this.treatmentArea != null)
						this.treatmentArea.enabled = false;
					windowArea.initParam(incidentZone,1); 
					break;
			//Se pulso el boton Treatment Area
			case 2:	zoneType[1]=2; 
					this.treatmentArea.addEventListener(MouseEvent.ROLL_OVER,showTreatmentZone);
					this.incidentArea.enabled = false;
					this.waitArea.enabled = false;
					windowArea.initParam(treatmentZone,2); 
					break;
			//Se pulso el boton Wait Area
			case 3:	zoneType[1]=3;
					this.waitArea.addEventListener(MouseEvent.ROLL_OVER,showWaitZone);
					this.incidentArea.enabled = false;
					if (this.treatmentArea != null)
						this.treatmentArea.enabled = false;
					windowArea.initParam(waitZone,3); 
					break;
			default: Alert.show("Error during area selection", DisplayPropertiesSingleton.APPLICATION_TITLE);
		}
 	} 
    
    //Esperamos la pulsacion del boton OK
    windowArea.addEventListener(Event.SELECT, setNewArea);
    windowArea.addEventListener(Event.REMOVED, habilitateSelectAreaButton);
    
    this.AreaButton.enabled=false;
    this.chkCompleteScenario.enabled=false;
}

/**Metodo que captura los valores del Area de aplicacion tras
 * recibir un evento de SELECT del PopUp Select area**/
public function setNewArea(e:Event):void
{
	//Si no es Disaster Area seleccionamod un area completa para el modelo
	if(this.cmbModelSelection.selectedLabel != "Disaster Area" && this.cmbModelSelection.selectedLabel != "Incident Area")
		myArea=windowArea.myArea;
	//si es Disaster Area comprobamos que area esta seleccionando
	else
	{
		if (windowArea.myArea[4] == 1)
			incidentZone = windowArea.myArea;		
		else if (windowArea.myArea[4] == 2)
			treatmentZone = windowArea.myArea;
		else if (windowArea.myArea[4] == 3)
			waitZone = windowArea.myArea;
		else
			Alert.show("Error during area selection", DisplayPropertiesSingleton.APPLICATION_TITLE);
	}
	
	//cerramos el listener
	windowArea.removeEventListener(Event.SELECT, setNewArea);
	this.AreaButton.enabled=true;
	this.chkCompleteScenario.enabled=true;
}

/**Funcion que habilita de nuevo el boton SelectArea**/
public function habilitateSelectAreaButton(e:Event):void
{
	if (this.cmbModelSelection.selectedLabel != "Disaster Area" && this.cmbModelSelection.selectedLabel != "Incident Area")
	{
		this.AreaButton.enabled=true;
		this.chkCompleteScenario.enabled=true;
		this.AreaButton.addEventListener(MouseEvent.ROLL_OVER,showArea);
	}
	else
	{
		this.incidentArea.enabled = true;
		if (treatmentArea != null)
			this.treatmentArea.enabled = true;
		this.waitArea.enabled = true;
	}
	windowArea.removeEventListener(Event.REMOVED, habilitateSelectAreaButton);
}

/**Funcion que resetea el area seleccionada**/
private function setCompleteAcenarioArea(e:Event):void
{
	if(this.chkCompleteScenario.selected)
	{
		myArea=null;
		Application.application.scenarioField.selectRectCanvas.visible = false;
	}
}

/** Funcion que muestra el area de aplicacion al pasar el raton sobre el boton de area**/
private function showArea(e:Event):void
{
	if (this.AreaButton.enabled)
	{
		Mouse.cursor = MouseCursor.BUTTON;
		windowArea.redrawSelectArea(myArea);
		Application.application.scenarioField.selectRectCanvas.visible = true;
		this.AreaButton.addEventListener(MouseEvent.ROLL_OUT,hideArea);
	}
}

/** Para el modelo Disaster Area:
 * Funcion que muestra la zona del incidente al pasar el raton sobre el boton correspondiente**/
private function showIncidentZone(e:Event):void
{
	Mouse.cursor = MouseCursor.BUTTON;
	windowArea.redrawSelectArea(incidentZone);
	Application.application.scenarioField.selectRectCanvas.visible = true;
	this.incidentArea.addEventListener(MouseEvent.ROLL_OUT,hideArea);
}

/** Para el modelo Disaster Area:
 * Funcion que muestra la zona tratamiento al pasar el raton sobre el boton correspondiente**/
private function showTreatmentZone(e:Event):void
{
	Mouse.cursor = MouseCursor.BUTTON;
	windowArea.redrawSelectArea(treatmentZone);
	Application.application.scenarioField.selectRectCanvas.visible = true;
	this.treatmentArea.addEventListener(MouseEvent.ROLL_OUT,hideArea);
}

/** Para el modelo Disaster Area:
 * Funcion que muestra la zona de espera al pasar el raton sobre el boton correspondiente**/
private function showWaitZone(e:Event):void
{
	Mouse.cursor = MouseCursor.BUTTON;
	windowArea.redrawSelectArea(waitZone);
	Application.application.scenarioField.selectRectCanvas.visible = true;
	this.waitArea.addEventListener(MouseEvent.ROLL_OUT,hideArea);
}

/**Funcion que oculta el area al retirar el cursor del boton correspondiente**/
private function hideArea(e:Event):void
{
	if(windowArea != null)
	{
		Mouse.cursor = MouseCursor.AUTO;
		Application.application.scenarioField.selectRectCanvas.visible = false;
		this.AreaButton.removeEventListener(MouseEvent.ROLL_OUT,hideArea);
	}
}

//////////////////////////////////////////////////////////////////////////////
//		Fin MobilityModelsPanel.as
//////////////////////////////////////////////////////////////////////////////