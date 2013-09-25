// ActionScript file

/**Controlador del PopUp que controla la seleccion
 * del area en el que se aplicara el modelo de
 * mobilidad correspondiente**/
  
import Classes.DisplayPropertiesSingleton;
import Classes.ModelSingleton;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.controls.Alert;
import mx.core.Application;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;

//Variables de la aplicacion
private var _displayPropertiesInstance:DisplayPropertiesSingleton;
private var _modelInstance:ModelSingleton;
private var sWidht:int;
private var sHeight:int;
private var scaleFactor:Number;

//Array que almacena los limites del area [xFrom xTo yFrom yTo zoneType]
public var myArea:Array;
public var zoneType:int;

private var selectionRectRightBottom:Point;
private var selectionRectLeftTop:Point;

//Iniciamos los parametros
public function initParam(myNewArea:Array,newZoneType:int):void
{
	this._modelInstance = ModelSingleton.getSingletonInstance();
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	
	sWidht = this._modelInstance.scenarioPropertiesCallableProxy.width;
	sHeight = this._modelInstance.scenarioPropertiesCallableProxy.height;
	
	scaleFactor = this._displayPropertiesInstance.scaleFactor;
	
	//Activamos el canvas de seleccion de area y le aplicamos el factor de escala
	Application.application.scenarioField.selectRectCanvas.enabled = true;
	Application.application.scenarioField.selectRectCanvas.visible = true;
	
	this.xTo.maximum = this.xFrom.maximum = sWidht;
	this.yTo.maximum = this.yFrom.maximum = sHeight;
	
	if(myNewArea == null)
	{
		this.xFrom.value = 0;
		this.xTo.value = sWidht;
		this.yFrom.value = 0;
		this.yTo.value = sHeight;
		zoneType = newZoneType;
	}
	//Si ya se habia seleccionado un area se carga
	else
	{
		this.xFrom.value = myNewArea[0];
		this.xTo.value = myNewArea[1];
		this.yFrom.value = myNewArea[2];
		this.yTo.value = myNewArea[3];
		zoneType = newZoneType;
	}
	redrawSelectArea(myNewArea);
	
	//Creamos un listener para capturar el area arrastrando con el raton
	Application.application.scenarioField.canvasScenario.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownS);
	Application.application.scenarioField.canvasScenario.addEventListener(MouseEvent.MOUSE_OVER,changeSelectCursor);
	Application.application.scenarioField.canvasScenario.addEventListener(MouseEvent.MOUSE_OUT,changeNormalCursor);
	//Application.application.scenarioField.canvasScenario.addEventListener(MouseEvent.DOUBLE_CLICK,cancelSelection);
	
	//Creamos listeners para actualizar el dibujo del area cuando se modifiquen los stepers
	this.xFrom.addEventListener(Event.CHANGE,updateDrawArea);
	this.xTo.addEventListener(Event.CHANGE,updateDrawArea);
	this.yFrom.addEventListener(Event.CHANGE,updateDrawArea);
	this.yTo.addEventListener(Event.CHANGE,updateDrawArea);
}

//Manejador del evento de inicio de seleccion de area
private function mouseDownS(event:MouseEvent):void
{	
	// start selection only if we clicked on our List(not outside or it's items) 
	if(event.target.parent != Application.application.scenarioField)
	 	return;
	
	var x_From:int = _displayPropertiesInstance.mouseScenarioXcoord;
	var y_From:int = _displayPropertiesInstance.mouseScenarioYcoord;
	setInitCoordinates(x_From,y_From);
	
	//punto desde el que empezaremos la seleccion		
	selectionRectRightBottom = new Point(_displayPropertiesInstance.mouseScenarioXcoord, 
				_displayPropertiesInstance.mouseScenarioYcoord);
	
	Application.application.scenarioField.selectRectCanvas.width = 0;
	Application.application.scenarioField.selectRectCanvas.height = 0;
	
	Application.application.scenarioField.canvasScenario.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoveS);
}

//Manejador de Actualizacion del area de seleccion
private function mouseMoveS(e:MouseEvent):void
{
	// end-poing of our selection rectangle  
	selectionRectLeftTop = new Point(_displayPropertiesInstance.mouseScenarioXcoord, _displayPropertiesInstance.mouseScenarioYcoord);
	  
	// calculating selection rectangle height and width
	var selectionRectWidth:Number = -selectionRectRightBottom.x + selectionRectLeftTop.x;
	var selectionRectHeight:Number =-selectionRectRightBottom.y + selectionRectLeftTop.y;
	
	if (selectionRectWidth > 0 && selectionRectHeight > 0)
	{
		var x_To:int = _displayPropertiesInstance.mouseScenarioXcoord;
		var y_To:int = _displayPropertiesInstance.mouseScenarioYcoord;
		setEndCoordinates(x_To,y_To);
		
		Application.application.scenarioField.selectRectCanvas.width = selectionRectWidth * scaleFactor;
		Application.application.scenarioField.selectRectCanvas.height = selectionRectHeight * scaleFactor;
		
		Application.application.scenarioField.selectRectCanvas.x = selectionRectRightBottom.x * scaleFactor;
		Application.application.scenarioField.selectRectCanvas.y = selectionRectRightBottom.y * scaleFactor;
		
		Application.application.scenarioField.canvasScenario.addEventListener(MouseEvent.MOUSE_UP,mouseUpS);
	}
}

//Manejador del fin de seleccion de area
private function mouseUpS(e:Event):void
{
	var x_To:int = _displayPropertiesInstance.mouseScenarioXcoord;
	var y_To:int = _displayPropertiesInstance.mouseScenarioYcoord;
	setEndCoordinates(x_To,y_To);
	
	selectionRectRightBottom = null;
	selectionRectLeftTop = null;
	Application.application.scenarioField.canvasScenario.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMoveS);
	Mouse.cursor = MouseCursor.AUTO;
}

// Manejador del Boton OK
private function returnArea():void
{
	if (!checkLimitValues())
	{
		Alert.show("Introduce appropriate limits", DisplayPropertiesSingleton.APPLICATION_TITLE);
		return;
	}
    myArea = new Array(this.xFrom.value, this.xTo.value, this.yFrom.value, this.yTo.value, zoneType);
    
    this.dispatchEvent(new Event(Event.SELECT));
    removeSelectAreaListeners();
    
    Application.application.scenarioField.selectRectCanvas.visible = false;
	Application.application.scenarioField.selectRectCanvas.enabled = false;
    
    PopUpManager.removePopUp(this);
}

public function closePanel_Handler(e:Event):void
{
	closeAreaPanel();
}

// Funcion que cierra el PopUp sin actualizar datos
private function closeAreaPanel():void
{
	myArea=null;
	Application.application.scenarioField.selectRectCanvas.visible = false;
	Application.application.scenarioField.selectRectCanvas.enabled = false;
	removeSelectAreaListeners();
	PopUpManager.removePopUp(this);
}

//Funcion que comprueba los datos introducidos
private function checkLimitValues():Boolean
{	
	if (this.xFrom.value > this.xTo.value || this.yFrom.value > this.yTo.value)
		return false;
	else if (this.xFrom.value > sWidht || this.yFrom.value > sHeight)
		return false;
	return true;
}

//Funcion para actualizar el valor de las coordenadas de inicio del area
private function setInitCoordinates(x_From:Number,y_From:Number):void
{
	this.xFrom.value = (int(x_From*100)/100);
	this.yFrom.value = (int(y_From*100)/100);
}

//Funcion para actualizar el valor de las coordenadas de fin del area
private function setEndCoordinates(x_To:Number,y_To:Number):void
{
	this.xTo.value = (int(x_To*100)/100);
	this.yTo.value = (int(y_To*100)/100);
}

//Funcion que redibuja el area y lo adapta a posibles cambios en el factor de escala
public function redrawSelectArea(myNewArea:Array):void
{
	scaleFactor = this._displayPropertiesInstance.scaleFactor;
	
	if (myNewArea == null)
	{
		Application.application.scenarioField.selectRectCanvas.width = 0;
		Application.application.scenarioField.selectRectCanvas.height = 0;
		return;
	}
	selectionRectRightBottom = new Point(myNewArea[0],myNewArea[2]);
	selectionRectLeftTop = new Point(myNewArea[1],myNewArea[3]);
	var selectionRectWidth:Number = -selectionRectRightBottom.x + selectionRectLeftTop.x;
	var selectionRectHeight:Number =-selectionRectRightBottom.y + selectionRectLeftTop.y;
	
	Application.application.scenarioField.selectRectCanvas.width = selectionRectWidth * scaleFactor;
	Application.application.scenarioField.selectRectCanvas.height = selectionRectHeight * scaleFactor;
	
	Application.application.scenarioField.selectRectCanvas.x = selectionRectRightBottom.x * scaleFactor;
	Application.application.scenarioField.selectRectCanvas.y = selectionRectRightBottom.y * scaleFactor;
}

//Funcion que redibuja el area al modificar los steppers
private function updateDrawArea(event:Event):void
{
	myArea = new Array(this.xFrom.value, this.xTo.value, this.yFrom.value, this.yTo.value, zoneType);
	redrawSelectArea(myArea);
}

//Si hacemos doble click cancelamos la seleccion de area
private function cancelSelection(e:Event):void
{
	resetCoordinates();
}

//Funcion encargada de resetear las coordenadas
private function resetCoordinates():void
{
	Application.application.scenarioField.selectRectCanvas.width = 0;
	Application.application.scenarioField.selectRectCanvas.height = 0;
	
	this.xFrom.value = 0;
	this.xTo.value = this.xTo.maximum = this.xFrom.maximum = sWidht;
	this.yFrom.value = 0;
	this.yTo.value = this.yTo.maximum = this.yFrom.maximum = sHeight;
}

//Funcion que cierra todos los listeners creados por este popup
private function removeSelectAreaListeners():void
{
	Application.application.scenarioField.canvasScenario.removeEventListener(MouseEvent.DOUBLE_CLICK,cancelSelection);
	Application.application.scenarioField.canvasScenario.removeEventListener(MouseEvent.MOUSE_DOWN,mouseDownS);
	Application.application.scenarioField.canvasScenario.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMoveS);
	Application.application.scenarioField.canvasScenario.removeEventListener(MouseEvent.MOUSE_OVER,changeSelectCursor);
	Application.application.scenarioField.canvasScenario.removeEventListener(MouseEvent.MOUSE_OUT,changeNormalCursor);
}

//Cambio de cursores para mejorar la usabilidad
private function changeSelectCursor(e:Event):void
{
	Application.application.scenarioField.selectRectCanvas.enabled = true;
	Application.application.scenarioField.selectRectCanvas.visible = true;
	Mouse.cursor = MouseCursor.BUTTON;
}

private function changeNormalCursor(e:Event):void
{
	Mouse.cursor = MouseCursor.AUTO;
}

////////////////////////////////////////////////////////////////////////
//		FIN controlador Select Area
/////////////////////////////////////////////////////////////////////// 
