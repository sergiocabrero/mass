// ActionScript file

import Classes.DisplayPropertiesSingleton;
import Classes.DisplayPropertyChangeEventKind;
import Classes.DisplayedManetNodesProperties;
import Classes.ModelPropertyChangeEventKind;
import Classes.ModelPropertyChangeEventType;
import Classes.ModelSingleton;
import Classes.ParamEvent;
import Classes.StringUtils;

import Entities.GoogleInfo;
import Entities.ManetNode;
import Entities.Movement;
import Entities.NodeState;
import Entities.ScenarioProperties;
import Entities.TimestampPositionCheckpoint;

import GraphicElements.*;

import com.google.maps.LatLng;
import com.google.maps.LatLngBounds;
import com.google.maps.MapAction;
import com.google.maps.MapType;
import com.google.maps.interfaces.IMapType;
import com.google.maps.overlays.Marker;
import com.google.maps.services.ClientGeocoder;
import com.google.maps.services.GeocodingEvent;

import de.polygonal.ds.Vector;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.collections.ArrayCollection;
import mx.containers.Canvas;
import mx.controls.Alert;
import mx.controls.Image;
import mx.core.UIComponent;
import mx.events.PropertyChangeEvent;
import mx.events.PropertyChangeEventKind;
import mx.managers.CursorManagerPriority;
	
private var _creationGridFlag:Boolean = false;
//estados, 0:up (inactivo), 1:down, 2:down y move
private var _thereIsGraphicCircleMovementFlag:uint = 0;	
private var _modelInstance:ModelSingleton;
private var _displayPropertiesInstance:DisplayPropertiesSingleton;
private var _fGrid:FluidGrid;
private var nodeColors:Array = [0xe8350b, 0xe8c10b, 0xace80b, 0x0be80b, 0x0be98d, 0x0bc6e8, 0x0b4fe8, 0x4f0be8, 0xac0be8, 0xe80b25];

private var _mouseXcoordinate:int = 0;
private var _mouseYcoordinate:int = 0;

private var latitude:Number = 0;
private	var longitude:Number = 0;
private	var zoomLevel:int = -1;
private var mapType:Object = "";
private var centerMapMode:Object = "";
private var location:String = "";
private var sizeChange:Boolean = false;
private var googleMapLoaded:Boolean = false;
private var rangeBackUp:Vector.<Number>;

private var nwLat:Number;			// Valor de latitud, esquina superior izquierda
private var nwLng:Number;			// Valor de longitud, esquina superior izquierda
private var neLat:Number;			// Valor de latitud, esquina superior derecha
private var neLng:Number;			// Valor de longitud, esquina superior derecha
private var swLat:Number;			// Valor de latitud, esquina inferior izquierda
private var swLng:Number;			// Valor de longitud, esquina inferior izquierda
private var seLat:Number;			// Valor de latitud, esquina inferior derecha
private var seLng:Number;			// Valor de longitud, esquina inferior derecha
private var ctLat:Number;			// Valor de latitud, en el centro
private var ctLng:Number;			// Valor de longitud, en el centro
private var nw:LatLng;				// Esquina superior izquierda, en tipo LatLng
private var ne:LatLng;				// Esquina superior derecha, en tipo LatLng
private var sw:LatLng;				// Esquina inferior derecha, en tipo LatLng
private var se:LatLng;				// Esquina inferior izquierda, en tipo LatLng
private var ct:LatLng;				// Centro, en tipo LatLng
private var nwPoint:Point;			// Punto (coordenadas x,y) de la esquina superior izquierda
private var nePoint:Point;			// Punto (coordenadas x,y) de la esquina superior derecha
private var swPoint:Point;			// Punto (coordenadas x,y) de la esquina inferior izquierda
private var sePoint:Point;			// Punto (coordenadas x,y) de la esquina inferior derecha
private var ctPoint:Point;			// Punto (coordenadas x,y) del centro
private var bounds:LatLngBounds;	// Utilizado para obtener latitudes y longitudes

private var xTranslation:Number = 0; // Desplazamiento acumulado del canvas respecto al vértice sup izq (eje x)
private var yTranslation:Number = 0; // Desplazamiento acumulado del canvas respecto al vértice sup izq (eje y)
private var clickedOnCanvasScenario:Boolean = false; // Para distinguir entre clicks dentro y fuera del canvasScenario
private var distanceBetweenCenters:Point = new Point(0,0); //Distancia entre centro de la ventana (1000x572) y centro del mapa completo
private var nwCorner:LatLng;		// Esquina superior izquierda del CanvasScenario, en tipo LatLng
private var nwCornerLat:Number;		// Valor de latitud, esquina superior izquierda del CanvasScenario
private var nwCornerLng:Number;		// Valor de longitud, esquina superior izquierda del CanvasScenario
private var resetShift:LatLng = null;
private var xTranslationForZoomChange:Number = 0;
private var yTranslationForZoomChange:Number = 0;
private var xTranslationForSaving:Number = 0;
private var yTranslationForSaving:Number = 0;
private var offsetX:Number = 0;
private var offsetY:Number = 0;
private var corner:LatLng;			// LatLng de la esquina superior izquierda del CanvasScenario en el momento de cambiar zoom
private var cornerPoint:Point = new Point(0,0); //Posición (x,y) del LatLng corner en el proceso de cambio de zoom
private var doubleClickMode:String = "Shift";
private var cornerLat:Number;
private var cornerLng:Number;
private var shifted:Boolean = false;	// Es verdadero si el vértice del mapa se ha escogido pinchando sobre el escenario
private var cornerSet:Boolean = false;  // Es verdadero si el vértice del mapa se ha escogido pinchando sobre el escenario


//#########################  HANDLERS DE EVENTOS INTERNOS ############################
private function ScenarioField_creationComplete_handler(event:Event):void
{
	
	this._modelInstance = ModelSingleton.getSingletonInstance();
	this._modelInstance.addEventListener(ModelPropertyChangeEventType.MANETNODE_CHANGE_EVENT, manetNodesTable_changeEvent_handler);
	this._modelInstance.addEventListener(ModelPropertyChangeEventType.MANETNODESTABLE_CHANGE_EVENT, manetNodesTable_changeEvent_handler);
	this._modelInstance.addEventListener(ModelPropertyChangeEventType.SCENARIOPROPERTIES_CHANGE_EVENT, scenarioProperties_changeEvent_handler);
	this._modelInstance.addEventListener(ModelPropertyChangeEventType.MODEL_UNLOCKED_EVENT, modelUnlocked_handler);
	this._modelInstance.addEventListener(ModelPropertyChangeEventType.TRACES_MODEL_UNLOCKED_EVENT, tracesModelUnlocked_handler);
	
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	this._displayPropertiesInstance.addEventListener(PropertyChangeEventKind.UPDATE, displayProperties_changeEvent_handler);
	this._displayPropertiesInstance.addEventListener(DisplayPropertyChangeEventKind.CLEAR_SCENARIO_EVENT, clearScenarioEvent_handler);
	this._displayPropertiesInstance.addEventListener(DisplayPropertyChangeEventKind.USER_REQUEST_DISPLAY_NODE_PROPERTY_CHANGE, userRequestDisplayNodeChange_handler);
	if (this.imgScenarioBackground.source != "" && this.imgScenarioBackground.content != null)
	{
		this._displayPropertiesInstance.backgroundImageHeight = this.imgScenarioBackground.content.height;
		this._displayPropertiesInstance.backgroundImageWidth = this.imgScenarioBackground.content.width;
	}
	this._modelInstance.scenarioPropertiesCallableProxy.height = this.canvasScenario.height;
	this._modelInstance.scenarioPropertiesCallableProxy.width = this.canvasScenario.width;

	this._fGrid = new FluidGrid(this.canvasGrid);

	
	
	this.canvasScenario.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownOnScenario_handler);
	this.canvasScenario.addEventListener(MouseEvent.MOUSE_UP, mouseUpOnScenario_handler);
	this.canvasScenario.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveOnScenario_handler);
	//this.canvasScenario.addEventListener(MouseEvent.MOUSE_OVER, mouseOverOnScenario_handler);
	//this.canvasScenario.addEventListener(MouseEvent.MOUSE_OUT, mouseOutOnScenario_handler);
	
	this.doubleClickEnabled = true; //FR
	this.canvasScenario.doubleClickEnabled = true; //FR
	this.addEventListener(MouseEvent.RIGHT_CLICK,mouseRightClickOnViewport_handler); //FR
	this.canvasScenario.addEventListener(MouseEvent.DOUBLE_CLICK, mouseDoubleClickOnScenario_handler); //FR
	this.addEventListener(MouseEvent.DOUBLE_CLICK,mouseDoubleClickOnViewport_handler); //FR
	this._modelInstance.addEventListener(ModelPropertyChangeEventType.SAVE_FILE_EVENT, saveFile_handler);		//FR
	this._modelInstance.addEventListener(ModelPropertyChangeEventType.MAP_AFTER_SAVING_EVENT, mapAfterSaving_handler);//FR
	this._modelInstance.addEventListener(ModelPropertyChangeEventType.SAVE_KML_OR_GPX_FILE_EVENT, saveKMLorGPXFile_handler);//FR
	this._modelInstance.addEventListener(ModelPropertyChangeEventType.CHECK_CONNECTION_EVENT, checkConnectionEvent_handler);//FR
	this._modelInstance.addEventListener(ModelPropertyChangeEventType.CHECK_CONNECTION_EVENT, checkConnectionEvent_handler);//FR
	this._modelInstance.addEventListener(ModelPropertyChangeEventType.SET_GOOGLE_MOBILITY_VALUE, setGoogleMobilityValue_handler);//FR
}

private function addedToStage_handler(event:Event):void
{
	if (!this._creationGridFlag)
	{
		var uiComponent:UIComponent = new UIComponent();
		this.canvasGrid.addChildAt(uiComponent, 0);
		uiComponent.addChild(this._fGrid);	
		this._creationGridFlag = true;
	}	
}
//######################################################################################










//#########################  HANDLERS DE EVENTOS CUSTOM  ############################
private function clearScenarioEvent_handler(event:Event):void
{
	try{
		//FR
		this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo = null;
		latitude = 0;
		longitude = 0;
		zoomLevel = -1;
		mapType = "";
		centerMapMode = "";
		location = "";
		sizeChange = false;
		googleMapLoaded = false;
		
		if (this.map.isLoaded()){
		
			this.map.setSize(new Point(this.width-4,this.height-4));
			this.map.visible = false;
			this.map.clearOverlays();
			this._modelInstance.scenarioPropertiesCallableProxy.connectedToInternet = true;
			
		}

    	this.xTranslation = 0;
    	this.yTranslation = 0;
    	this.distanceBetweenCenters.x = 0;
    	this.distanceBetweenCenters.y = 0;
    	this.canvasScenario.move(this.xTranslation,this.yTranslation);
    	this.canvasGrid.move(this.xTranslation,this.yTranslation);
    	this.canvasLinks.move(this.xTranslation,this.yTranslation);
    	this.canvasPoppers.move(this.xTranslation,this.yTranslation);
    	this.cornerSet = false;
		//FR
		this.clearField();
		
	}
	catch(err:Error){
		
		Alert.show(err.toString(),"MASS Editor");
		
	}
}

private function displayProperties_changeEvent_handler(event:PropertyChangeEvent):void	
{	
	try
	{
		switch (event.kind)
		{
			case DisplayPropertyChangeEventKind.SCALE_FACTOR_CHANGE_EVENT:
				this._modelInstance = ModelSingleton.getSingletonInstance();
				this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
				
				//Se cambian las dimensiones
				this.canvasScenario.width = this._modelInstance.scenarioPropertiesCallableProxy.width * Number(event.newValue);
				this.imgScenarioBackground.width = this._displayPropertiesInstance.backgroundImageWidth * Number(event.newValue);			
				
				this.canvasScenario.height = this._modelInstance.scenarioPropertiesCallableProxy.height * Number(event.newValue);
				this.imgScenarioBackground.height = this._displayPropertiesInstance.backgroundImageHeight * Number(event.newValue);
				this.imgScenarioBackground.scaleContent = true;		
				
				this.redrawAllManetNodesAndTrajectoriesForScaling(Number(event.oldValue), Number(event.newValue));
				this.redrawAllInstantPositions(Number(event.oldValue), Number(event.newValue));
				this._fGrid.spacingFactor = 20 * Number(event.newValue);
														
				
				var realFactor:Number = Number(event.newValue)/Number(event.oldValue);
				if (realFactor >= 1)
				{
					this.validateNow();
				}

				if (this.horizontalScrollPosition != 0)
				{
					this.horizontalScrollPosition = (this.horizontalScrollPosition * realFactor) + ((this.width/2) * (realFactor-1));
				}
				else
				{
					this.horizontalScrollPosition = 0;
				}
				if (this.verticalScrollPosition != 0)
				{	
					this.verticalScrollPosition = (this.verticalScrollPosition * realFactor) + ((this.height/2) * (realFactor-1));
				}
				else
				{
					this.verticalScrollPosition = 0;
				}	 
										
				break;
				
			case DisplayPropertyChangeEventKind.BACKGROUND_IMAGE_DIMENSIONS_CHANGE_EVENT:
				if (event.property == "backgroundImageWidth")
				{
					//this.imgScenarioBackground.width = Number(event.newValue);
					break;				
				}
				else if (event.property == "backgroundImageHeight")
				{
					//this.imgScenarioBackground.height = Number(event.newValue);			
					break;				
				}
			
			case DisplayPropertyChangeEventKind.BACKGROUND_IMAGE_VISIBLE_CHANGE_EVENT:
				this.imgScenarioBackground.visible = Boolean(event.newValue);
				break;
			
			case DisplayPropertyChangeEventKind.GRID_VISIBLE_CHANGE_EVENT:
				this.canvasGrid.visible = Boolean(event.newValue);				
				break;
				
			case DisplayPropertyChangeEventKind.NEW_GRAPHIC_CHECKPOINT_SELECTED_EVENT:
					
				if (event.newValue != null)
				{
					GraphicCircle(event.newValue).setAsSelected(true);
				}
				if (event.oldValue)
				{
					GraphicCircle(event.oldValue).setAsSelected(false);
				}	
				break;
			
			case DisplayPropertyChangeEventKind.NODE_ICON_PATH_CHANGE:
				if (event.newValue == null)
				{
					this.changeInstantPositionIconAllNodes(null);
				}
				else
				{
					this.changeInstantPositionIconAllNodes(event.newValue.toString());
				}
				break;
			
			case DisplayPropertyChangeEventKind.TIME_POSITION_TO_SHOW_CHANGE_EVENT:
				this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
				
				var tempAlpha:Number = this._displayPropertiesInstance.rangeAlpha;
				var nodesAC:ArrayCollection = this._displayPropertiesInstance.getManetNodesIdAC();
				
				for each (var a:String in nodesAC)
				{	
			
					this.drawInstantPositionNode(a, this._displayPropertiesInstance.scaleFactor, 
						this._displayPropertiesInstance.getManetNodeCanvasTimePosReferenceVisibilityRange(a), tempAlpha);	
						
				}

				break;	
				
			case DisplayPropertyChangeEventKind.RANGE_ALPHA_CHANGE:
				this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
				
				var nodesAC2:ArrayCollection = this._displayPropertiesInstance.getManetNodesIdAC();
				
				for each (var b:String in nodesAC2)
				{	
				
					this.drawInstantPositionNode(b, this._displayPropertiesInstance.scaleFactor, 
						this._displayPropertiesInstance.getManetNodeCanvasTimePosReferenceVisibilityRange(b), Number(event.newValue));	
						
				}				
				break;
			
			case DisplayPropertyChangeEventKind.CHECKPOINT_SIZE_CHANGE:
				this._modelInstance = ModelSingleton.getSingletonInstance();
				this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
				var nodesArray:Array = this._modelInstance.manetNodesTableCallableProxy.getIdManetNodesArray();
				for (var i:int = 0; i<nodesArray.length; i++)
				{
					//this.drawManetNodeAndTrajectoriesFromModel(nodesArray[i], this._displayPropertiesInstance.scaleFactor, Number(event.newValue));
					this.resizeManetNodeCheckpoints(nodesArray[i], Number(event.newValue));
				}
				
				var nodesAC3:ArrayCollection = this._displayPropertiesInstance.getManetNodesIdAC();
				for each (var c:String in nodesAC3)
				{	
					this.drawInstantPositionNode(c, this._displayPropertiesInstance.scaleFactor, 
						this._displayPropertiesInstance.getManetNodeCanvasTimePosReferenceVisibilityRange(c),
						this._displayPropertiesInstance.rangeAlpha);			
				}
				this.drawAsSelectedCheckpoint();
				break;
								
		}
	}
	catch(thrownError:Error)
	{
		trace("ERROR!! " + thrownError.message);
	}		
}

private function userRequestDisplayNodeChange_handler(event:ParamEvent):void
{
	try
	{
		this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
		switch (event.params.propertyName)
		{
			case "node_trajectory_visibility":
				this._displayPropertiesInstance.setManetNodeTrajectoryVisibility(event.params.nodeId, event.params.value);
				this._displayPropertiesInstance.getManetNodeCanvasReference(event.params.nodeId).visible = event.params.value;
				//this._displayPropertiesInstance.getManetNodeCanvasTimePosReference(event.params.nodeId).visible = event.params.value;
				break;
			
			case "node_range_visibility":
				var tempAlpha:Number = this._displayPropertiesInstance.rangeAlpha;
				this._displayPropertiesInstance.setManetNodeCanvasTimePosReferenceVisibilityRange(event.params.nodeId, event.params.value);
				this.drawInstantPositionNode(event.params.nodeId, this._displayPropertiesInstance.scaleFactor, event.params.value, tempAlpha);
				break;
			
			case "node_colour":
				var tempAlpha1:Number = this._displayPropertiesInstance.rangeAlpha;
				this._displayPropertiesInstance.setManetNodeColour(event.params.nodeId, event.params.value);
				this.changeManetNodeColourInScenario(this._displayPropertiesInstance.getManetNodeCanvasReference(event.params.nodeId), event.params.value);
				this.drawInstantPositionNode(event.params.nodeId, this._displayPropertiesInstance.scaleFactor, 
					this._displayPropertiesInstance.getManetNodeCanvasTimePosReferenceVisibilityRange(event.params.nodeId), tempAlpha1);
				break;	
		}
	}
	catch(thrownError:Error)
	{
		
	}	
}

private function scenarioProperties_changeEvent_handler(event:PropertyChangeEvent):void
{
	try
	{
		this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
		this._modelInstance = ModelSingleton.getSingletonInstance();//FR
		
		switch (event.kind)
		{
			case ModelPropertyChangeEventKind.SET_SCENARIO_INIT_TIME:
				break;
			case ModelPropertyChangeEventKind.SET_SCENARIO_WIDTH:
				this.canvasScenario.width = ScenarioProperties(event.newValue).width * this._displayPropertiesInstance.scaleFactor;
				this.imgScenarioBackground.scaleContent = true;
				//FR Si está activado el googlemaps ir a SET GOOGLEMAP
				if (this.map.visible){					
					
					var maptype:IMapType = this.map.getCurrentMapType();
					var zoom:Number = this.map.getZoom();
					var area:Point;
					var nuevoCentro:Point;
					var info:GoogleInfo;
					var nuevoCentroLatLng:LatLng;
					var centralLat:Number;
					var centralLng:Number;
						
					if ((this.xTranslation != 0) || (this.yTranslation !=0)){
						
						if ((this.width-4 >= this.canvasScenario.width+this.xTranslation)&&
							(this.height-4 >= this.canvasScenario.height+this.yTranslation))
							area = new Point(this.width-4,this.height-4);
						else if ((this.width-4 >= this.canvasScenario.width+this.xTranslation)&&
							(this.height-4 < this.canvasScenario.height+this.yTranslation))
							area = new Point(this.width-4,this.canvasScenario.height+this.yTranslation);
						else if ((this.width-4 < this.canvasScenario.width+this.xTranslation)&&
							(this.height-4 >= this.canvasScenario.height+this.yTranslation))
							area = new Point(this.canvasScenario.width+this.xTranslation,this.height-4);
						else if ((this.width-4 < this.canvasScenario.width+this.xTranslation)&&
							(this.height-4 < this.canvasScenario.height+this.yTranslation))
							area = new Point(this.canvasScenario.width+this.xTranslation,this.canvasScenario.height+this.yTranslation);
						
						nuevoCentro = new Point(area.x/2,area.y/2);
						nuevoCentroLatLng = this.map.fromViewportToLatLng(nuevoCentro);
						map.setSize(area);
						
						centralLat = nuevoCentroLatLng.lat();
						centralLng = nuevoCentroLatLng.lng();
					
					}
					else {
						
						this.sizeChange = true;
					
						if ((this.width-4 >= this.canvasScenario.width)&&(this.height-4 >= this.canvasScenario.height))
							area = new Point(this.width-4,this.height-4);
						else if ((this.width-4 >= this.canvasScenario.width)&&(this.height-4 < this.canvasScenario.height))
							area = new Point(this.width-4,this.canvasScenario.height);
						else if ((this.width-4 < this.canvasScenario.width)&&(this.height-4 >= this.canvasScenario.height))
							area = new Point(this.canvasScenario.width,this.height-4);
						else if ((this.width-4 < this.canvasScenario.width)&&(this.height-4 < this.canvasScenario.height))
							area = new Point(this.canvasScenario.width,this.canvasScenario.height); 
						
						nuevoCentro = new Point(area.x/2,area.y/2);
						nuevoCentroLatLng = this.map.fromViewportToLatLng(nuevoCentro);
						
						map.setSize(area);
						
						centralLat = nuevoCentroLatLng.lat();
						centralLng = nuevoCentroLatLng.lng();						
						
					}
					
					if (maptype == MapType.NORMAL_MAP_TYPE)
					info = new GoogleInfo("Normal","Coordinates",zoom,centralLat,centralLng,"",true,doubleClickMode);
					else if (maptype == MapType.SATELLITE_MAP_TYPE)
					info = new GoogleInfo("Satellite","Coordinates",zoom,centralLat,centralLng,"",true,doubleClickMode);
					else if (maptype == MapType.HYBRID_MAP_TYPE)
					info = new GoogleInfo("Hybrid","Coordinates",zoom,centralLat,centralLng,"",true,doubleClickMode);
					else
					info = new GoogleInfo("Physical","Coordinates",zoom,centralLat,centralLng,"",true,doubleClickMode);
					
					distanceBetweenCenters.x = (area.x - (this.width-4))/2;
		    		distanceBetweenCenters.y = (area.y - (this.height-4))/2; 
        			this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo = info;
					
				}//FR 		
				break;
			case ModelPropertyChangeEventKind.SET_SCENARIO_HEIGHT:
				this.canvasScenario.height = ScenarioProperties(event.newValue).height * this._displayPropertiesInstance.scaleFactor;
				this.imgScenarioBackground.scaleContent = true;
				break;
			case ModelPropertyChangeEventKind.SET_SCENARIO_DEPTH:
				break;
			case ModelPropertyChangeEventKind.SET_SCENARIO_BACKGROUND_IMAGE_PATH:
				if (ScenarioProperties(event.newValue).backgroundImagePath != null)
				{
					this.imgScenarioBackground.removeEventListener(flash.events.Event.COMPLETE, completeImageLoad_handler);
					this.imgScenarioBackground.addEventListener(flash.events.Event.COMPLETE, completeImageLoad_handler);
					this.imgScenarioBackground.load(ScenarioProperties(event.newValue).backgroundImagePath);
				}
				else
				{
					this.imgScenarioBackground.unloadAndStop();
				}	
				break;
				//FR
			case ModelPropertyChangeEventKind.SET_GOOGLEMAP:
			
				if(ScenarioProperties(event.newValue).googleData != null){
					if(ScenarioProperties(event.newValue).connectedToInternet){		
							if(ScenarioProperties(event.newValue).googleData._visible == true){	
							
							this._modelInstance.scenarioPropertiesCallableProxy.backgroundImagePath = null;
							//this._modelInstance.scenarioPropertiesCallableProxy.backgroundImagePath = "";
							
							if((ScenarioProperties(event.newValue).googleData._location != "")||
							(ScenarioProperties(event.newValue).googleData._centerMapMode=="Coordinates")){
							
								zoomLevel = ScenarioProperties(event.newValue).googleData._zoomLevel;
								mapType = ScenarioProperties(event.newValue).googleData._mapType;
								centerMapMode = ScenarioProperties(event.newValue).googleData._centerMapMode;
								location = ScenarioProperties(event.newValue).googleData._location;
								doubleClickMode = ScenarioProperties(event.newValue).googleData._doubleClickMode;
								
								var updatedLatitude:Number = ScenarioProperties(event.newValue).googleData._latitude;
								var updatedLongitude:Number = ScenarioProperties(event.newValue).googleData._longitude;
								 
								if( (this._modelInstance.manetNodesTableCallableProxy.getManetNodeTableSize() != 0 ) && 
									(this.map.getZoom() != zoomLevel) && (ctLat >= -90) && (ctLat <= 90) &&
									(Math.abs(latitude-updatedLatitude) < 0.000001) &&
									(Math.abs(longitude-updatedLongitude) < 0.000001) ) {
										
										latitude = updatedLatitude;
										longitude = updatedLongitude;
										googleZoomChange(zoomLevel);
										break;
								
								}
								else{
									
									latitude = redondear(updatedLatitude,6);
									longitude = redondear(updatedLongitude,6);
									
								}
								
								
								if (this.sizeChange){
									this.map.setCenter(new LatLng(latitude,longitude),zoomLevel,this.map.getCurrentMapType());
								}
								else{
									if (centerMapMode=="Coordinates"){
										if (mapType=="Normal"){
											this.map.setCenter(new LatLng(latitude,longitude),zoomLevel,MapType.NORMAL_MAP_TYPE);
										}
										else if (mapType=="Satellite"){
											this.map.setCenter(new LatLng(latitude,longitude),zoomLevel,MapType.SATELLITE_MAP_TYPE);
										}
										else if (mapType=="Hybrid"){
											this.map.setCenter(new LatLng(latitude,longitude),zoomLevel,MapType.HYBRID_MAP_TYPE);
										} 
										else if (mapType=="Physical"){
											this.map.setCenter(new LatLng(latitude,longitude),zoomLevel,MapType.PHYSICAL_MAP_TYPE);
										}
										
										ct = map.getCenter();
										ctLat = ct.lat();
										ctLng = ct.lng();
										ctPoint = map.fromLatLngToViewport(ct);
											    		
										bounds = map.getLatLngBounds();
											        		
										nw = bounds.getNorthWest();
										nwLat = nw.lat();
										nwLng = nw.lng();
										nwPoint = map.fromLatLngToViewport(nw);
											        		
										ne = bounds.getNorthEast();
										neLat = ne.lat();
										neLng = ne.lng();
										nePoint = map.fromLatLngToViewport(ne);
											        		
										sw = bounds.getSouthWest();
										swLat = sw.lat();
										swLng = sw.lng();
										swPoint = map.fromLatLngToViewport(sw);
											        		
										se = bounds.getSouthEast();
										seLat = se.lat();
										seLng = se.lng();
										sePoint = map.fromLatLngToViewport(se);
									}
									
									else if (centerMapMode=="Location"){
										
										var geocoder:ClientGeocoder = new ClientGeocoder();
										
										geocoder.addEventListener(GeocodingEvent.GEOCODING_SUCCESS,
										function(event:GeocodingEvent):void {
					          				var placemarks:Array = event.response.placemarks;
					          				if (placemarks.length > 0) {
					          					if (mapType=="Normal"){
													map.setCenter(placemarks[0].point,zoomLevel,MapType.NORMAL_MAP_TYPE);
												}
												else if (mapType=="Satellite"){
													map.setCenter(placemarks[0].point,zoomLevel,MapType.SATELLITE_MAP_TYPE);
												}
												else if (mapType=="Hybrid"){
													map.setCenter(placemarks[0].point,zoomLevel,MapType.HYBRID_MAP_TYPE);
												} 
												else if (mapType=="Physical"){
													map.setCenter(placemarks[0].point,zoomLevel,MapType.PHYSICAL_MAP_TYPE);
												}
												
												ct = map.getCenter();
												ctLat = ct.lat();
												ctLng = ct.lng();
												ctPoint = map.fromLatLngToViewport(ct);
													    		
												bounds = map.getLatLngBounds();
													        		
												nw = bounds.getNorthWest();
												nwLat = nw.lat();
												nwLng = nw.lng();
												nwPoint = map.fromLatLngToViewport(nw);
													        		
												ne = bounds.getNorthEast();
												neLat = ne.lat();
												neLng = ne.lng();
												nePoint = map.fromLatLngToViewport(ne);
													        		
												sw = bounds.getSouthWest();
												swLat = sw.lat();
												swLng = sw.lng();
												swPoint = map.fromLatLngToViewport(sw);
													        		
												se = bounds.getSouthEast();
												seLat = se.lat();
												seLng = se.lng();
												sePoint = map.fromLatLngToViewport(se);
					
							          		}
										});
										
										geocoder.addEventListener(GeocodingEvent.GEOCODING_FAILURE,
					          			function(event:GeocodingEvent):void {
					          				
								            Alert.show("Location unknown", DisplayPropertiesSingleton.APPLICATION_TITLE);
	
					          			});
					          			
					          			geocoder.geocode(location);
					          			
					          					
					          		}
									
									this.map.visible = ScenarioProperties(event.newValue).googleData._visible;
									this.map.disableDragging();
									this.map.setDoubleClickMode(MapAction.ACTION_NOTHING);
								} //else sizeChange
								nwCorner = this.map.fromViewportToLatLng(new Point(this.xTranslation,this.yTranslation));
								nwCornerLat = nwCorner.lat();
								nwCornerLng = nwCorner.lng();
								this.sizeChange = false;
							}// if nueva info de Google
						
						}// if visible
						else
							this.map.visible = false;
					}// if connectedToInternet
					else
						Alert.show("Unable to connect with Google Maps","MASS Editor");
				}// if data!=null
				break;
				
			case ModelPropertyChangeEventKind.SET_SCENARIO_EASTERN_POSITION:
				break;
			case ModelPropertyChangeEventKind.SET_SCENARIO_SOUTHERN_POSITION:
				break;
		}
		
		function completeImageLoad_handler(event:Event):void
		{
			_displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
			_displayPropertiesInstance.backgroundImageHeight = imgScenarioBackground.content.height;
			_displayPropertiesInstance.backgroundImageWidth = imgScenarioBackground.content.width;
		}
	}
	catch(thrownError:Error)
	{
		Alert.show("Error at ScenarioField.as: " + Error);
	}	
		
}

private function manetNode_changeEvent_handler(event:PropertyChangeEvent):void
{
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();

}

private function manetNodesTable_changeEvent_handler(event:PropertyChangeEvent):void
{
	try
	{
		this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
		
		if (event.kind == ModelPropertyChangeEventKind.CLEAR_MANET_NODES_TABLE)
		{
			this.canvasScenario.removeAllChildren();
			this._displayPropertiesInstance.clearDisplayedAllManetNodesProperties();
			return;
		}
		
		if (event.kind == ModelPropertyChangeEventKind.REMOVED_MANET_NODE)
		{
			//Borrar el contenido de los canvas correspondientes
			if(this._displayPropertiesInstance.getManetNodeCanvasReference(ManetNode(event.oldValue).id))
			{
				this._displayPropertiesInstance.getManetNodeCanvasReference(ManetNode(event.oldValue).id).removeAllChildren();
			}
			if(this._displayPropertiesInstance.getManetNodeCanvasTimePosReference(ManetNode(event.oldValue).id))
			{
				this._displayPropertiesInstance.getManetNodeCanvasTimePosReference(ManetNode(event.oldValue).id).removeAllChildren();
			}	
				
			//Borrar las propiedades de visualizacion del nodo
			this._displayPropertiesInstance.clearDisplayedManetNodeProperties(ManetNode(event.oldValue).id);
			return;
		}
		
		if (event.kind == ModelPropertyChangeEventKind.ADDED_MANET_NODE)
		{
			//Se añaden las propiedades de visualizacion del nodo al singleton
			var nodeCanvas:Canvas = new Canvas();
			this.canvasScenario.addChild(nodeCanvas);
			this._displayPropertiesInstance.setManetNodeCanvasReference(ManetNode(event.newValue).id, nodeCanvas);	
		}
		
		if (event.kind == ModelPropertyChangeEventKind.SET_MANET_NODE_RANGE)
		{
			this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
			var tempAlpha:Number = this._displayPropertiesInstance.rangeAlpha;
			this.drawInstantPositionNode(ManetNode(event.newValue).id, this._displayPropertiesInstance.scaleFactor, 
				this._displayPropertiesInstance.getManetNodeCanvasTimePosReferenceVisibilityRange(ManetNode(event.newValue).id), tempAlpha);
			return;
		}
		
		if (event.kind == ModelPropertyChangeEventKind.SET_MANET_NODE_ID)
		{
			this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
			//var tempAlpha2:Number = this._displayPropertiesInstance.rangeAlpha;
			this.changeManetNodeIdInScenario(this._displayPropertiesInstance.getManetNodeCanvasReference(ManetNode(event.oldValue).id), ManetNode(event.newValue).id);
			//this.drawInstantPositionNode(ManetNode(event.newValue).id, this._displayPropertiesInstance.scaleFactor, 
				//this._displayPropertiesInstance.getManetNodeCanvasTimePosReferenceVisibilityRange(ManetNode(event.newValue).id), tempAlpha2);
			return;				
		}
		
		//Si conocemos sobre que nodo se efectuo la actualizacion, dibujamos solo ese nodo
		if (event.oldValue != null)
		{
			this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
			var tempAlpha1:Number = this._displayPropertiesInstance.rangeAlpha;
			this.drawManetNodeAndTrajectoriesFromModel( ManetNode(event.oldValue).id , this._displayPropertiesInstance.scaleFactor,
				this._displayPropertiesInstance.checkpointSize);
				
			this.drawInstantPositionNode(ManetNode(event.oldValue).id, this._displayPropertiesInstance.scaleFactor, 
				this._displayPropertiesInstance.getManetNodeCanvasTimePosReferenceVisibilityRange(ManetNode(event.oldValue).id), tempAlpha1);
				
		}
		else if (event.newValue != null)
		{
			this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
			var tempAlpha2:Number = this._displayPropertiesInstance.rangeAlpha;
			this.drawManetNodeAndTrajectoriesFromModel(ManetNode(event.newValue).id, this._displayPropertiesInstance.scaleFactor,
				this._displayPropertiesInstance.checkpointSize);
			
			if(event.oldValue != null)//FR	
				this.drawInstantPositionNode(ManetNode(event.newValue).id, this._displayPropertiesInstance.scaleFactor, 
					this._displayPropertiesInstance.getManetNodeCanvasTimePosReferenceVisibilityRange(ManetNode(event.oldValue).id), tempAlpha2);
		}
		//dibujamos todos los nodos
		else
		{
			this.drawAllManetNodesAndTrajectoriesFromModel(this._displayPropertiesInstance.scaleFactor, this._displayPropertiesInstance.checkpointSize);
		}
		
		this.drawAsSelectedCheckpoint();
	}
	catch(thrownError:Error)
	{
		trace("Error refreshing the scenario field!!! " + thrownError.message);
	}		
}

//FR
private function tracesModelUnlocked_handler(event:Event):void{
	
	this._modelInstance = ModelSingleton.getSingletonInstance();
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	
	if ((this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._visible)&&
		(this._modelInstance.scenarioPropertiesCallableProxy.connectedToInternet)){
		
		this.canvasScenario.width = this.width-4;
		this.canvasScenario.height = this.height-4;
		
		var latNw:Number = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._latitude;
		var lngNw:Number = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._longitude;
		var maptype:Object = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._mapType;
		var dcMode:String = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._doubleClickMode;
		
		var lines:Array = this._modelInstance.scenarioPropertiesCallableProxy.tracesData;
		
		lines = sortLines(lines);
		
		if (lines != null){
			
			var highestLatitude:Number = -90;
			var highestLongitude:Number = -180;
			var lowestLatitude:Number = 90;
			var lowestLongitude:Number = 180;
			var lowestTimestamp:Date;
			var highestTimestamp:Date;
			
			var line:String;
			var lineInfo:Array;
			var nodeName:String;
			var nodeLongitude:Number;
			var nodeLatitude:Number;
			var nodeTimestamp:Date;
			var nodeRange:Number;
			var nodeRangeLatAndLng:Point;
			
			var highestLatLine:Number = -1;
			var lowestLngLine:Number = -1;
			var highestLngLine:Number = -1;
			var lowestLatLine:Number = -1;
			
			for (var i:Number = 0; i < lines.length; i++){
				
				line = new String (lines[i]);
				lineInfo = line.split("\t");
				//var nodeName:String = lineInfo[0];
				nodeLongitude = lineInfo[1];
				nodeLatitude = lineInfo[2];
				nodeTimestamp = new Date(parseInt(lineInfo[3]));
				nodeRange = 1.5*lineInfo[4];
				nodeRangeLatAndLng = this.calculateMargin(nodeRange,latNw,lngNw);
				
				if (i == 0){
					
					highestTimestamp = nodeTimestamp;
					lowestTimestamp = nodeTimestamp;
					
				}
				else{
					
					if (nodeTimestamp.time > highestTimestamp.time)
						highestTimestamp = nodeTimestamp;
					if (nodeTimestamp.time < lowestTimestamp.time)
						lowestTimestamp = nodeTimestamp;
					
				}
				
				if (nodeLongitude + nodeRangeLatAndLng.y > highestLongitude){
					highestLongitude = nodeLongitude + nodeRangeLatAndLng.y;
					highestLngLine = i;
				}
				if (nodeLongitude - nodeRangeLatAndLng.y < lowestLongitude){
					lowestLongitude = nodeLongitude - nodeRangeLatAndLng.y;
					lowestLngLine = i;
				}
				if (nodeLatitude + nodeRangeLatAndLng.x > highestLatitude){
					highestLatitude = nodeLatitude + nodeRangeLatAndLng.x;
					highestLatLine = i;
				}
				if (nodeLatitude - nodeRangeLatAndLng.x < lowestLatitude){
					lowestLatitude = nodeLatitude - nodeRangeLatAndLng.x;
					lowestLatLine = i;
				}
	
			}
					
			var latSw:Number =lowestLatitude;
			var lngSw:Number =lowestLongitude;
			var latNe:Number =highestLatitude;
			var lngNe:Number =highestLongitude;
			latNw = highestLatitude;
			lngNw =	lowestLongitude;	
			var latLngNw:LatLng = new LatLng(latNw,lngNw);
			var latLngSw:LatLng = new LatLng(latSw,lngSw);
			var latLngNe:LatLng = new LatLng(latNe,lngNe);
			var limits:LatLngBounds = new LatLngBounds(latLngSw,latLngNe);
			var area:Point = new Point(this.canvasScenario.width,this.canvasScenario.height);
			this.map.setCenter(latLngNw,this.map.getBoundsZoomLevel(limits),MapType.HYBRID_MAP_TYPE);
			
			var centroFinalLatLng:LatLng = this.map.fromViewportToLatLng(area);
			var zoomLevel:Number = this.map.getZoom();
			var centralLat:Number = centroFinalLatLng.lat();
			var centralLng:Number = centroFinalLatLng.lng();
			
			var info:GoogleInfo = new GoogleInfo(maptype,"Coordinates",
			zoomLevel,centralLat,centralLng,"",true,dcMode); 
	        this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo = info;
	        googleMapLoaded = true;
	        
	        var previousNodeName:String = new String("");
			var previousTimestamp:Date;
			nodeRange = 50;
						
			for (i = 0; i < lines.length; i++){
				
				line = new String (lines[i]);
				lineInfo = line.split("\t");
				nodeName = lineInfo[0];
				nodeLongitude = lineInfo[1];
				nodeLatitude = lineInfo[2];
				var positionLatLng:LatLng = new LatLng(nodeLatitude,nodeLongitude);
				var positionNode:Point = this.map.fromLatLngToViewport(positionLatLng);
				var xCoord:Number = redondear(positionNode.x,0);
				var yCoord:Number = redondear(positionNode.y,0);
				nodeTimestamp = new Date(parseInt(lineInfo[3]));
				
				if (lineInfo.length == 5)
					nodeRange = lineInfo[4];
				
				var nextLine:String;
				var nextLineInfo:Array;
				var nextLineName:String;
				//var nextLineLongitude:Number;
				//var nextLineLatitude:Number;
				var nextLineTimestamp:Date;
				
				if (i < lines.length - 1){
					nextLine = new String (lines[i+1]);
					nextLineInfo = nextLine.split("\t");
					nextLineName = nextLineInfo[0];
					//nextLineLongitude = nexLineInfo[1];
					//nexLineLatitude = nextLineInfo[2];
					nextLineTimestamp = new Date(parseInt(nextLineInfo[3]));
				}
				
				if (nodeName != previousNodeName){//SwitchOn
						
						var newManetNode:ManetNode = new ManetNode("", nodeRange, "", 0, "circular", nodeName);
						
						if (this._modelInstance.manetNodesTableCallableProxy.getManetNode(nodeName) != null)
						{
							Alert.show("Error parsing the txt scenario: node id repeated", DisplayPropertiesSingleton.APPLICATION_TITLE);
							break;						
						}
						
						this._modelInstance.manetNodesTableCallableProxy.addManetNode(newManetNode, false);
						
						//var prevLongCoord:int = nodeLongitude;
						//var prevLatCoord:int = nodeLatitude;
						var prevxCoord:Number = xCoord;
						var prevyCoord:Number = yCoord;
						var prevZcoord:int = 0;
						
						var initialPoint:Point = new Point(prevxCoord,prevyCoord);
						initialPoint = recalculatePointToDistance(initialPoint);
						previousTimestamp = nodeTimestamp;
						this._modelInstance.manetNodesTableCallableProxy.setManetNodeState(nodeName, nodeTimestamp, true, 
								initialPoint.x, initialPoint.y, 0);
						
						//Si el nodo no tiene movimientos se añade un movimiento nulo para que el nodo sea representado con un checkpoint en el escenario
						if ((nodeName != nextLineName)||(i == lines.length-1)){
							
							this._modelInstance.manetNodesTableCallableProxy.setManetNodeMovement(nodeName, nodeTimestamp, nodeTimestamp, prevxCoord, prevyCoord, prevxCoord,
								prevyCoord, 0, 0, true);
														
						}								
					
				}
				else if ((nextLineName != nodeName) || (i == lines.length -1)){//SwitchOff
						
						this._modelInstance.manetNodesTableCallableProxy.setManetNodeMovement(nodeName, previousTimestamp, nodeTimestamp, prevxCoord, prevyCoord, xCoord,
								yCoord, 0, 0, true); //Esta instrucción fue añadida después
						this._modelInstance.manetNodesTableCallableProxy.setManetNodeState(nodeName, nodeTimestamp, false);		
					
				}
				else{//MoveTo
				
						this._modelInstance.manetNodesTableCallableProxy.setManetNodeMovement(nodeName, previousTimestamp, nodeTimestamp, prevxCoord, prevyCoord, xCoord,
								yCoord,0,0, true);
						//prevLongCoord = nodeLongitude;
						//prevLatCoord = nodeLatitude;
						prevxCoord = xCoord;
						prevyCoord = yCoord;
						previousTimestamp = nodeTimestamp;
				}	
				previousNodeName = nodeName;
				
			}
			
			var nodesArray:Array = this._modelInstance.manetNodesTableCallableProxy.getIdManetNodesArray();
			
			for (var j:Number = 0; j<nodesArray.length; j++){

				var newRange:Number = recalculateRange(this._modelInstance.manetNodesTableCallableProxy.getManetNodeRange(nodesArray[j]));
				
				if (!this._modelInstance.manetNodesTableCallableProxy.setManetNodeRange(nodesArray[j],newRange))
					Alert.show("Error while updating node range", DisplayPropertiesSingleton.APPLICATION_TITLE);
				
			this.drawManetNodeAndTrajectoriesFromModel(nodesArray[j], this._displayPropertiesInstance.scaleFactor, this._displayPropertiesInstance.checkpointSize);

			}
		
			var nodesAC3:ArrayCollection = this._displayPropertiesInstance.getManetNodesIdAC();
			for each (var c:String in nodesAC3){
				
				this.drawInstantPositionNode(c, this._displayPropertiesInstance.scaleFactor, 
				this._displayPropertiesInstance.getManetNodeCanvasTimePosReferenceVisibilityRange(c),
				this._displayPropertiesInstance.rangeAlpha);			
			}
			
			this.drawAsSelectedCheckpoint();

			this._modelInstance.scenarioPropertiesCallableProxy.width = this.map.fromLatLngToViewport(latLngNe).x;
			this._modelInstance.scenarioPropertiesCallableProxy.height = this.map.fromLatLngToViewport(latLngSw).y;

		}
			
		this._modelInstance.scenarioPropertiesCallableProxy.tracesData = null;
			
	}
	else
		Alert.show("Unable to connect with Google Maps","MASS Editor");
		
	
}
//FR

private function modelUnlocked_handler(event:Event):void
{
	this._modelInstance = ModelSingleton.getSingletonInstance();
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();	
	
	if (!this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._visible){ //FR
		//Propiedades escenario
		this.canvasScenario.width = this._modelInstance.scenarioPropertiesCallableProxy.width * this._displayPropertiesInstance.scaleFactor;
		this.canvasScenario.height = this._modelInstance.scenarioPropertiesCallableProxy.height * this._displayPropertiesInstance.scaleFactor;
		this.imgScenarioBackground.scaleContent = true;
		
		if (this._modelInstance.scenarioPropertiesCallableProxy.backgroundImagePath != null)
		{
			this.imgScenarioBackground.removeEventListener(flash.events.Event.COMPLETE, completeImageLoad_handler);
			this.imgScenarioBackground.addEventListener(flash.events.Event.COMPLETE, completeImageLoad_handler);
			this.imgScenarioBackground.load(this._modelInstance.scenarioPropertiesCallableProxy.backgroundImagePath);
			
			function completeImageLoad_handler(event:Event):void
			{
				_displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
				_displayPropertiesInstance.backgroundImageHeight = imgScenarioBackground.content.height;
				_displayPropertiesInstance.backgroundImageWidth = imgScenarioBackground.content.width;
			}			
		}
		else
		{
			this.imgScenarioBackground.unloadAndStop();
		}
		
	}//FR
	//FR
	else{
		
		if(this._modelInstance.scenarioPropertiesCallableProxy.connectedToInternet){
			this.canvasScenario.width = this.width-4;
			this.canvasScenario.height = this.height-4;
			
			var eastern:Number = this._modelInstance.scenarioPropertiesCallableProxy.eastern;
			var southern:Number = this._modelInstance.scenarioPropertiesCallableProxy.southern;
			var latNw:Number = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._latitude;
			var lngNw:Number = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._longitude;
			var maptype:Object = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._mapType;
			var dcMode:String = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._doubleClickMode;
			
			var R:Number = 6370000; //radio de la Tierra, en metros
			
			var bearing:Number = 180; //rumbo = 180º
			var latSw:Number = (Math.asin(Math.sin(latNw*Math.PI/180)*Math.cos(southern/R) +
									Math.cos(latNw*Math.PI/180)*Math.sin(southern/R)*Math.cos(bearing*Math.PI/180)))*180/Math.PI;
			var lngSw:Number = lngNw + (Math.atan2(Math.sin(bearing*Math.PI/180)*Math.sin(southern/R)*Math.cos(latNw*Math.PI/180),
									Math.cos(southern/R)-Math.sin(latNw*Math.PI/180)*Math.sin(latSw*Math.PI/180)))*180/Math.PI;
			bearing = 90; //rumbo = 90º
			var latNe:Number = (Math.asin(Math.sin(latNw*Math.PI/180)*Math.cos(eastern/R) +
									Math.cos(latNw*Math.PI/180)*Math.sin(eastern/R)*Math.cos(bearing*Math.PI/180)))*180/Math.PI;
			var lngNe:Number = lngNw + (Math.atan2(Math.sin(bearing*Math.PI/180)*Math.sin(eastern/R)*Math.cos(latNw*Math.PI/180),
									Math.cos(eastern/R)-Math.sin(latNw*Math.PI/180)*Math.sin(latNe*Math.PI/180)))*180/Math.PI;
			
			var latLngNw:LatLng = new LatLng(latNw,lngNw);
			var latLngSw:LatLng = new LatLng(latSw,lngSw);
			var latLngNe:LatLng = new LatLng(latNe,lngNe);
			var limits:LatLngBounds = new LatLngBounds(latLngSw,latLngNe);
			
			var area:Point = new Point(this.canvasScenario.width,this.canvasScenario.height);
			this.map.setCenter(latLngNw,this.map.getBoundsZoomLevel(limits),MapType.HYBRID_MAP_TYPE);
			var centroFinalLatLng:LatLng = this.map.fromViewportToLatLng(area);
			var zoomLevel:Number = this.map.getZoom();
			var centralLat:Number = centroFinalLatLng.lat();
			var centralLng:Number = centroFinalLatLng.lng();
			
			var info:GoogleInfo = new GoogleInfo(maptype,"Coordinates",
			zoomLevel,centralLat,centralLng,"",true,dcMode); 
	        this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo = info;
	        googleMapLoaded = true;
	 	}
	 	else
	 		Alert.show("Unable to connect with Google Maps","MASS Editor");
			
	}
	//FR
	
	if ((this._modelInstance.scenarioPropertiesCallableProxy.connectedToInternet)||
		(!this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._visible)){
	//Nodos
		var nodesArray:Array = this._modelInstance.manetNodesTableCallableProxy.getIdManetNodesArray();
		
		for (var i:int = 0; i<nodesArray.length; i++){
			
			//FR
			if(googleMapLoaded){
			
				recalculateNodeTrajectory(nodesArray[i]);
				var newRange:Number = recalculateRange(this._modelInstance.manetNodesTableCallableProxy.getManetNodeRange(nodesArray[i]));
				
				if (!this._modelInstance.manetNodesTableCallableProxy.setManetNodeRange(nodesArray[i],newRange)){
				
					Alert.show("Error while updating node range", DisplayPropertiesSingleton.APPLICATION_TITLE);
				
				}
			}
			//FR
			
			this.drawManetNodeAndTrajectoriesFromModel(nodesArray[i], this._displayPropertiesInstance.scaleFactor, this._displayPropertiesInstance.checkpointSize);
			
		}//for
		
		var nodesAC3:ArrayCollection = this._displayPropertiesInstance.getManetNodesIdAC();
		for each (var c:String in nodesAC3)
		{	
			this.drawInstantPositionNode(c, this._displayPropertiesInstance.scaleFactor, 
				this._displayPropertiesInstance.getManetNodeCanvasTimePosReferenceVisibilityRange(c),
				this._displayPropertiesInstance.rangeAlpha);			
		}
		this.drawAsSelectedCheckpoint();
		
		if(googleMapLoaded){ 
		
			var limit:Point = new Point(this.width-4,this.height-4);
			
			limit = this.recalculatePoint(new Point(this._modelInstance.scenarioPropertiesCallableProxy.eastern,
				this._modelInstance.scenarioPropertiesCallableProxy.southern));
			
			this._modelInstance.scenarioPropertiesCallableProxy.width = limit.x;
			this._modelInstance.scenarioPropertiesCallableProxy.height = limit.y;
		
			googleMapLoaded = false;
		}//FR
	
	}//Connected
		
}

//#################################################################################












//######################  METODOS ###############################
public function clearField():void
{

	
}


private function changeInstantPositionIconAllNodes(newIconPath:String):void
{
	try
	{
		this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
		//this._modelInstance = ModelSingleton.getSingletonInstance();
		var nodesAC:ArrayCollection = this._displayPropertiesInstance.getManetNodesIdAC();
		
		for each (var a:String in nodesAC)
		{	
			for each (var i:Object in 
				this._displayPropertiesInstance.getManetNodeCanvasTimePosReference(a).getChildren())	
			{
				if (i as GraphicAreaCircleIcon)
				{
					GraphicAreaCircleIcon(i).iconPath = newIconPath;
				}				
			}
		}
	}
	catch(thrownError:Error)
	{
		trace("thrownError!!! " + thrownError.message);
	}	
}


private function drawInstantPositionNode(nodeId:String, scaleFactor:Number, drawRange:Boolean, rangeAlpha:Number):void
{	
	try
	{
		this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
		this._modelInstance = ModelSingleton.getSingletonInstance();
		
		
		var timePosCanvasRef:Canvas = this._displayPropertiesInstance.getManetNodeCanvasTimePosReference(nodeId);
		
		var theCircle:GraphicAreaCircleIcon;
		
		var instantTimeNode:Date = this._displayPropertiesInstance.timePositionToShow;
		var nodeColour:uint = this._displayPropertiesInstance.getManetNodeColour(nodeId);
		var nodeRange:Number = this._modelInstance.manetNodesTableCallableProxy.getManetNodeRange(nodeId);
				
		var aNewCircleNeeded:Boolean = false;
		
		if(timePosCanvasRef)
		{
			if (timePosCanvasRef.getChildren() != null && timePosCanvasRef.getChildren().length > 0  && timePosCanvasRef.getChildAt(0) != null)
			{

				theCircle = GraphicAreaCircleIcon(timePosCanvasRef.getChildAt(0));
			}	
			
	
			if (theCircle != null && 
				timePosCanvasRef.getChildren() != null && timePosCanvasRef.getChildren().length > 0  && timePosCanvasRef.getChildAt(0) != null &&
				theCircle.colourFill == nodeColour && 
				theCircle.colourStroke == nodeColour &&
				theCircle.drawRange == drawRange &&
				theCircle.radius == nodeRange * scaleFactor &&
				theCircle.rangeAlpha == rangeAlpha)
			{
				theCircle.instantTime = new Date(instantTimeNode.time);
			}
			else
			{	
				//Limpiar el canvas correspondiente
				timePosCanvasRef.removeAllChildren();
				var iconPath:String = this._displayPropertiesInstance.nodeIconPath;
				theCircle = new GraphicAreaCircleIcon(nodeRange* scaleFactor, nodeColour, nodeColour, drawRange, instantTimeNode, nodeId, rangeAlpha, iconPath);
				aNewCircleNeeded = true;
			}	
		}	
		
		
		var instantCheckpoint:TimestampPositionCheckpoint = this._modelInstance.manetNodesTableCallableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(nodeId, instantTimeNode);
			
		if (instantCheckpoint == null || instantTimeNode == null)
		{
			return;
		}
	
		theCircle.x = instantCheckpoint.xCoordinate * scaleFactor;
		theCircle.y = instantCheckpoint.yCoordinate * scaleFactor;
			
		if (aNewCircleNeeded)
		{
			timePosCanvasRef.addChild(theCircle);
		}	
		
		//Trampa para evitar que exceda del escenario
		this.noClippingCanvas(timePosCanvasRef);
	}
	catch(thrownError:Error)
	{
		trace("thrownError at drawInstantPositionNode!!!  " + thrownError.message);
	}			
}

//Trampa para evitar que el contenido exceda de un canvas
private function noClippingCanvas(canvasRef:Canvas):void
{
	var noClip:Image = new Image();
	noClip.width = 0;
	noClip.height = 0;
	noClip.alpha = 0;
	canvasRef.addChild(noClip);
	noClip.x = -1;
	noClip.y = -1; 	
}

private function redrawAllInstantPositions(oldScaleFactor:Number, newScaleFactor:Number):void
{
	try
	{
		this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
		
		var nodesAC:ArrayCollection = this._displayPropertiesInstance.getManetNodesIdAC();
		var tempAlpha:Number = this._displayPropertiesInstance.rangeAlpha;
		
		for each (var a:String in nodesAC)
		{
			this.drawInstantPositionNode(a, newScaleFactor, this._displayPropertiesInstance.getManetNodeCanvasTimePosReferenceVisibilityRange(a), tempAlpha);	
		}
	}
	catch(thrownError:Error)
	{
		
	}		
}


private function redrawAllManetNodesAndTrajectoriesForScaling(oldScaleFactor:Number, newScaleFactor:Number):void
{
	try
	{
		this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
		
		var nodesAC:ArrayCollection = this._displayPropertiesInstance.getManetNodesIdAC();
		
		for each (var a:String in nodesAC)
		{	
			for each (var i:Object in 
				this._displayPropertiesInstance.getManetNodeCanvasReference(a).getChildren())	
			{
				if (i as GraphicCircle)
				{
					GraphicCircle(i).x = GraphicCircle(i).x * (newScaleFactor/oldScaleFactor);
					GraphicCircle(i).y = GraphicCircle(i).y * (newScaleFactor/oldScaleFactor);
					if (GraphicCircle(i).previousTrajectory)
					{
						GraphicCircle(i).previousTrajectory.update();
					}
					if (GraphicCircle(i).nextTrajectory)
					{
						GraphicCircle(i).nextTrajectory.update();
					}			
				}				
			}
		}
	}
	catch(thrownError:Error)
	{
		
	}
}

private function changeManetNodeColourInScenario(nodeCanvasRef:Canvas, newColour:uint):void
{
	try
	{
		for each (var i:Object in nodeCanvasRef.getChildren())
		{
			if (i as GraphicCircle)
			{
				GraphicCircle(i).fillColour = newColour;
				if (GraphicCircle(i).isSelected())
				{
					GraphicCircle(i).setAsSelected(true);
				}
				
			}	
		}
	}
	catch(thrownError:Error)
	{
		
	}		
}

private function changeManetNodeIdInScenario(nodeCanvasRef:Canvas, newNodeId:String):void
{
	try
	{
		for each (var i:Object in nodeCanvasRef.getChildren())
		{
			if (i as GraphicCircle)
			{
				GraphicCircle(i).manetNodeParentId = newNodeId;
				if (GraphicCircle(i).isSelected())
				{
					GraphicCircle(i).setAsSelected(true);
				}
				
			}	
		}
	}
	catch(thrownError:Error)
	{
		
	}		
}


private function drawAsSelectedCheckpoint():void
{
	try
	{
		this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
		
		if (this._displayPropertiesInstance.graphicCheckpointSelected == null ||
		this._displayPropertiesInstance.getManetNodeCanvasReference(this._displayPropertiesInstance.graphicCheckpointSelected.manetNodeParentId) == null)
		{
			return;
		}
		for each (var i:Object in 
			this._displayPropertiesInstance.getManetNodeCanvasReference(this._displayPropertiesInstance.graphicCheckpointSelected.manetNodeParentId).getChildren())
		{
			if (i as GraphicCircle)
			{
				if (GraphicCircle(i).manetNodeParentId == this._displayPropertiesInstance.graphicCheckpointSelected.manetNodeParentId)
				{				
					if (( (this._displayPropertiesInstance.graphicCheckpointSelected.initTime != null && GraphicCircle(i).initTime != null) &&
						GraphicCircle(i).initTime.time == this._displayPropertiesInstance.graphicCheckpointSelected.initTime.time) ||
						( (this._displayPropertiesInstance.graphicCheckpointSelected.endTime != null && GraphicCircle(i).endTime != null) &&
						GraphicCircle(i).endTime.time == this._displayPropertiesInstance.graphicCheckpointSelected.endTime.time))
						{
							this._displayPropertiesInstance.graphicCheckpointSelected = GraphicCircle(i);
						}				
						
				}
			}
		}
	}
	catch(thrownError:Error)
	{
		trace("thrownError at drawAsSelectedCheckpoint!!!  " + thrownError.message);
		return;
	}		
}


private function resizeManetNodeCheckpoints(nodeId:String, checkpointRadius:Number):void
{
	try
	{
		this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
		var cnvNode:Canvas = this._displayPropertiesInstance.getManetNodeCanvasReference(nodeId);
		
		var checkpointScaleFactor:Number = checkpointRadius/2.5;
		
		for each (var i:Object in cnvNode.getChildren())
		{
			if (i as GraphicCircle)
			{
				GraphicCircle(i).scaleX = checkpointScaleFactor;
				GraphicCircle(i).scaleY = checkpointScaleFactor;
				//if (GraphicCircle(i).isSelected())
				//{
					//GraphicCircle(i).setAsSelected(true);
				//}
				
			}	
		}		
		
		
	}
	catch(thrownError:Error)
	{
		
	}		
}

private function drawManetNodeAndTrajectoriesFromModel(nodeId:String, scaleFactor:Number, checkpointRadius:Number):void
{	
	try
	{
		this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
		
		//Limpiar los canvas correspondiente
		if(this._displayPropertiesInstance.getManetNodeCanvasReference(nodeId))
		{
			this._displayPropertiesInstance.getManetNodeCanvasReference(nodeId).removeAllChildren();
		}
		
		if(this._displayPropertiesInstance.getManetNodeCanvasTimePosReference(nodeId))
		{
			this._displayPropertiesInstance.getManetNodeCanvasTimePosReference(nodeId).removeAllChildren();
		}	
		
		//Copiamos las propiedades de manera temporal
		var tempDisplayManetNodesProperties:DisplayedManetNodesProperties = this._displayPropertiesInstance.getDisplayedManetNodesProperties();
		//Borramos las propiedades de ese nodo del singleton
		this._displayPropertiesInstance.clearDisplayedManetNodeProperties(nodeId);
		
	
	
		//Cogemos del objeto temporal las propiedades que hay guardadas para los nodos visualizados, para los que no hay propiedades se dan unas por defecto
		var nodeColour:uint;
		if (tempDisplayManetNodesProperties.getManetNodeColour(nodeId) != 0x000000)
		{
			nodeColour = tempDisplayManetNodesProperties.getManetNodeColour(nodeId);
		}
		else
		{
			nodeColour = StringUtils.convertStringToHex(nodeId.toString());
		}
		var nodeCanvas:Canvas = new Canvas();
		var nodeTimeposCanvas:Canvas = new Canvas();
		var nodeVisibility:Boolean = tempDisplayManetNodesProperties.getManetNodeTrajectoryVisibility(nodeId);
		var rangeVisibility:Boolean = tempDisplayManetNodesProperties.getManetNodeCanvasTimePosReferenceVisibilityRange(nodeId);
		
		nodeCanvas.visible = nodeVisibility;
								
		var circleTempPrevious:GraphicCircle;
		var tempMovement:Movement = this._modelInstance.manetNodesTableCallableProxy.getManetNodeFirstMovement(nodeId);
			
		while (tempMovement != null)
		{
			//si el movimiento solo representa un checkpoint
			if (tempMovement.fromTimestampPositionCheckpoint.pointTime == null && this._modelInstance.manetNodesTableCallableProxy.getManetNodeMovementsSize(nodeId) == 1)
			{
					var circleInit0:GraphicCircle = new GraphicCircle(checkpointRadius, nodeColour, 0x000000);	
					circleInit0.manetNodeParentId = nodeId;
					circleInit0.canvasToPopUp = this.canvasPoppers;
					circleInit0.x = tempMovement.toTimestampPositionCheckpoint.xCoordinate * scaleFactor;
					circleInit0.y = tempMovement.toTimestampPositionCheckpoint.yCoordinate * scaleFactor; 
					nodeCanvas.addChild(circleInit0);
					circleInit0.addEventListener(MouseEvent.MOUSE_MOVE, graphicCircleMouseMove_handler, false, 0, true);
					circleInit0.addEventListener(MouseEvent.MOUSE_UP, graphicCircleMouseUp_handler, false, 0, true);
					circleInit0.addEventListener(MouseEvent.MOUSE_DOWN, graphicCircleMouseDown_handler, false, 0, true);
					circleInit0.endTime = tempMovement.toTimestampPositionCheckpoint.pointTime;
					circleInit0.initTime = tempMovement.toTimestampPositionCheckpoint.pointTime;
					break;			
					 								
			}
			else if(tempMovement.toTimestampPositionCheckpoint.pointTime == null && this._modelInstance.manetNodesTableCallableProxy.getManetNodeMovementsSize(nodeId) == 1)
			{
					var circleInit1:GraphicCircle = new GraphicCircle(checkpointRadius, nodeColour, 0x000000);	
					circleInit1.manetNodeParentId = nodeId;
					circleInit1.canvasToPopUp = this.canvasPoppers;
					circleInit1.x = tempMovement.fromTimestampPositionCheckpoint.xCoordinate * scaleFactor;
					circleInit1.y = tempMovement.fromTimestampPositionCheckpoint.yCoordinate * scaleFactor; 
					nodeCanvas.addChild(circleInit1);
					circleInit1.addEventListener(MouseEvent.MOUSE_MOVE, graphicCircleMouseMove_handler, false, 0, true);
					circleInit1.addEventListener(MouseEvent.MOUSE_UP, graphicCircleMouseUp_handler, false, 0, true);
					circleInit1.addEventListener(MouseEvent.MOUSE_DOWN, graphicCircleMouseDown_handler, false, 0, true);
					circleInit1.endTime = tempMovement.fromTimestampPositionCheckpoint.pointTime;
					circleInit1.initTime = tempMovement.fromTimestampPositionCheckpoint.pointTime;			
					break;			
			}
			else if( (tempMovement.fromTimestampPositionCheckpoint.pointTime.time == tempMovement.toTimestampPositionCheckpoint.pointTime.time) &&
				(tempMovement.fromTimestampPositionCheckpoint.xCoordinate == tempMovement.toTimestampPositionCheckpoint.xCoordinate) &&
				(tempMovement.fromTimestampPositionCheckpoint.yCoordinate == tempMovement.toTimestampPositionCheckpoint.yCoordinate) )		
			{
					var circleInit2:GraphicCircle = new GraphicCircle(checkpointRadius, nodeColour, 0x000000);	
					circleInit2.manetNodeParentId = nodeId;
					circleInit2.canvasToPopUp = this.canvasPoppers;
					circleInit2.x = tempMovement.toTimestampPositionCheckpoint.xCoordinate * scaleFactor;
					circleInit2.y = tempMovement.toTimestampPositionCheckpoint.yCoordinate * scaleFactor; 
					nodeCanvas.addChild(circleInit2);
					circleInit2.addEventListener(MouseEvent.MOUSE_MOVE, graphicCircleMouseMove_handler, false, 0, true);
					circleInit2.addEventListener(MouseEvent.MOUSE_UP, graphicCircleMouseUp_handler, false, 0, true);
					circleInit2.addEventListener(MouseEvent.MOUSE_DOWN, graphicCircleMouseDown_handler, false, 0, true);
					circleInit2.endTime = tempMovement.toTimestampPositionCheckpoint.pointTime;
					circleInit2.initTime = tempMovement.toTimestampPositionCheckpoint.pointTime;
					break;						
			}
						
			//si es el primer movimiento
			if (this._modelInstance.manetNodesTableCallableProxy.isManetNodeFirstStretchMovement(nodeId, tempMovement.id))
			{			
				//Añadimos los checkpoints inicial y final y la trayectoria
				var circleInit:GraphicCircle = new GraphicCircle(checkpointRadius, nodeColour, 0x000000);
				var circleEnd:GraphicCircle = new GraphicCircle(checkpointRadius, nodeColour, 0x000000);
				var trajInit:GraphicTrajectory;	
					
				circleInit.manetNodeParentId = nodeId;
				circleInit.canvasToPopUp = this.canvasPoppers;
				
				circleInit.x = tempMovement.fromTimestampPositionCheckpoint.xCoordinate * scaleFactor;
				circleInit.y = tempMovement.fromTimestampPositionCheckpoint.yCoordinate * scaleFactor; 
				       
				nodeCanvas.addChild(circleInit);
				circleInit.addEventListener(MouseEvent.MOUSE_MOVE, graphicCircleMouseMove_handler, false, 0, true);
				circleInit.addEventListener(MouseEvent.MOUSE_UP, graphicCircleMouseUp_handler, false, 0, true);
				circleInit.addEventListener(MouseEvent.MOUSE_DOWN, graphicCircleMouseDown_handler, false, 0, true);
				    
				circleEnd.manetNodeParentId = nodeId;
				circleEnd.canvasToPopUp = this.canvasPoppers;
				
				circleEnd.x = tempMovement.toTimestampPositionCheckpoint.xCoordinate * scaleFactor;
				circleEnd.y = tempMovement.toTimestampPositionCheckpoint.yCoordinate * scaleFactor;
				           
				nodeCanvas.addChild(circleEnd);			    
				circleEnd.addEventListener(MouseEvent.MOUSE_MOVE, graphicCircleMouseMove_handler, false, 0, true);
				circleEnd.addEventListener(MouseEvent.MOUSE_UP, graphicCircleMouseUp_handler, false, 0, true);
				circleEnd.addEventListener(MouseEvent.MOUSE_DOWN, graphicCircleMouseDown_handler, false, 0, true);

				trajInit = new GraphicTrajectory(0x555555, new Array(circleInit,circleEnd));
				nodeCanvas.addChildAt(trajInit,0);
				    
				circleInit.endTime = tempMovement.fromTimestampPositionCheckpoint.pointTime;
				circleInit.nextTrajectory = trajInit;
				    
				circleEnd.initTime = tempMovement.toTimestampPositionCheckpoint.pointTime;
				circleEnd.previousTrajectory = trajInit;
				    
				circleTempPrevious = circleEnd;	
				    			
			}
			//si no es el primer movimiento
			else
			{
				//Añadimos solo el checkpoint final	
				var circleNext:GraphicCircle = new GraphicCircle(checkpointRadius, nodeColour, 0x000000);
					
				circleNext.manetNodeParentId = nodeId;	
				circleNext.canvasToPopUp = this.canvasPoppers;
				
				circleNext.x = tempMovement.toTimestampPositionCheckpoint.xCoordinate * scaleFactor;
				circleNext.y = tempMovement.toTimestampPositionCheckpoint.yCoordinate * scaleFactor;    														
				
				nodeCanvas.addChild(circleNext);
				circleNext.addEventListener(MouseEvent.MOUSE_MOVE, graphicCircleMouseMove_handler, false, 0, true);
				circleNext.addEventListener(MouseEvent.MOUSE_UP, graphicCircleMouseUp_handler, false, 0, true);
				circleNext.addEventListener(MouseEvent.MOUSE_DOWN, graphicCircleMouseDown_handler, false, 0, true);
					
				var trajNext:GraphicTrajectory;
					
				trajNext = new GraphicTrajectory(0x555555, new Array(circleTempPrevious,circleNext));
				nodeCanvas.addChildAt(trajNext,0);
					
				circleTempPrevious.endTime = tempMovement.fromTimestampPositionCheckpoint.pointTime;
				circleTempPrevious.nextTrajectory = trajNext;
				circleNext.initTime = tempMovement.toTimestampPositionCheckpoint.pointTime;
				circleNext.previousTrajectory = trajNext;
				circleTempPrevious = circleNext;
				          					
			}
			if (this._modelInstance.manetNodesTableCallableProxy.isManetNodeLastMovement(nodeId, tempMovement.id))
			{
				break;
			}			
			else
			{
				//pasamos al siguiente movimiento
				tempMovement = this._modelInstance.manetNodesTableCallableProxy.getManetNodeNextMovement(nodeId, tempMovement.id);
			}	
			
		}//end while
		
		//Se añade el canvas (capa) donde se dibujaron los checkpoints del nodo al canvasScenario
		this.canvasScenario.addChild(nodeCanvas);
		this.canvasScenario.addChildAt(nodeTimeposCanvas, 0);
				
		//Se añaden las propiedades de visualizacion del nodo al singleton
		this._displayPropertiesInstance.addDisplayedManetNodePropertiesItem(nodeId, nodeColour, nodeVisibility, rangeVisibility, nodeCanvas, nodeTimeposCanvas);
			
	}
	catch(thrownError:Error)
	{
		
	}
}


private function drawAllManetNodesAndTrajectoriesFromModel(scaleFactor:Number, checkpointRadius:Number):void
{
	try
	{
		//Limpiar el escenario
		this.canvasScenario.removeAllChildren();
		
		this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
		this._modelInstance = ModelSingleton.getSingletonInstance();
		
		//Copiamos las propiedades de manera temporal
		var tempDisplayManetNodesProperties:DisplayedManetNodesProperties = this._displayPropertiesInstance.getDisplayedManetNodesProperties();
		//Borramos las propiedades del singleton
		this._displayPropertiesInstance.clearDisplayedAllManetNodesProperties();
	
		
		//Recorrer los nodos uno por uno
		var arrayIdNodes:Array = this._modelInstance.manetNodesTableCallableProxy.getIdManetNodesArray(); 
		for (var i:int = 0; i < arrayIdNodes.length; i++) 
		{
			
			//Cogemos del objeto temporal las propiedades que hay guardadas para los nodos visualizados, para los que no hay propiedades se dan unas por defecto
			var nodeColour:uint;
			if (tempDisplayManetNodesProperties.getManetNodeColour(arrayIdNodes[i]) != 0x000000)
			{
				nodeColour = tempDisplayManetNodesProperties.getManetNodeColour(arrayIdNodes[i]);
			}
			else
			{
				//nodeColour = this.nodeColors[i%10];
				nodeColour = this.nodeColors[StringUtils.convertStringToInt(arrayIdNodes[i].toString())];
			}
			var nodeCanvas:Canvas = new Canvas();
			var nodeTimeposCanvas:Canvas = new Canvas();
			var nodeVisibility:Boolean = tempDisplayManetNodesProperties.getManetNodeTrajectoryVisibility(arrayIdNodes[i]);
			var rangeVisibility:Boolean = tempDisplayManetNodesProperties.getManetNodeCanvasTimePosReferenceVisibilityRange(arrayIdNodes[i]);
			
			nodeCanvas.visible = nodeVisibility;
			//nodeTimeposCanvas.visible = nodeVisibility;			
					
			
			var circleTempPrevious:GraphicCircle;
			var tempMovement:Movement = this._modelInstance.manetNodesTableCallableProxy.getManetNodeFirstMovement(arrayIdNodes[i]);
			while (tempMovement != null)
			{
				
				//si el movimiento solo representa un checkpoint
				if (tempMovement.fromTimestampPositionCheckpoint.pointTime == null && this._modelInstance.manetNodesTableCallableProxy.getManetNodeMovementsSize(arrayIdNodes[i]) == 1)
				{
						var circleInit0:GraphicCircle = new GraphicCircle(checkpointRadius, nodeColour, 0x000000);	
						circleInit0.manetNodeParentId = arrayIdNodes[i];
						circleInit0.canvasToPopUp = this.canvasPoppers;
						circleInit0.x = tempMovement.toTimestampPositionCheckpoint.xCoordinate * scaleFactor;
						circleInit0.y = tempMovement.toTimestampPositionCheckpoint.yCoordinate * scaleFactor; 
						nodeCanvas.addChild(circleInit0);
						circleInit0.addEventListener(MouseEvent.MOUSE_MOVE, graphicCircleMouseMove_handler, false, 0, true);
						circleInit0.addEventListener(MouseEvent.MOUSE_UP, graphicCircleMouseUp_handler, false, 0, true);
						circleInit0.addEventListener(MouseEvent.MOUSE_DOWN, graphicCircleMouseDown_handler, false, 0, true);
						circleInit0.endTime = tempMovement.toTimestampPositionCheckpoint.pointTime;
						circleInit0.initTime = tempMovement.toTimestampPositionCheckpoint.pointTime;
						break;			
						 								
				}
				else if(tempMovement.toTimestampPositionCheckpoint.pointTime == null && this._modelInstance.manetNodesTableCallableProxy.getManetNodeMovementsSize(arrayIdNodes[i]) == 1)
				{
						var circleInit1:GraphicCircle = new GraphicCircle(checkpointRadius, nodeColour, 0x000000);	
						circleInit1.manetNodeParentId = arrayIdNodes[i];
						circleInit1.canvasToPopUp = this.canvasPoppers;
						circleInit1.x = tempMovement.fromTimestampPositionCheckpoint.xCoordinate * scaleFactor;
						circleInit1.y = tempMovement.fromTimestampPositionCheckpoint.yCoordinate * scaleFactor; 
						nodeCanvas.addChild(circleInit1);
						circleInit1.addEventListener(MouseEvent.MOUSE_MOVE, graphicCircleMouseMove_handler, false, 0, true);
						circleInit1.addEventListener(MouseEvent.MOUSE_UP, graphicCircleMouseUp_handler, false, 0, true);
						circleInit1.addEventListener(MouseEvent.MOUSE_DOWN, graphicCircleMouseDown_handler, false, 0, true);
						circleInit1.endTime = tempMovement.fromTimestampPositionCheckpoint.pointTime;
						circleInit1.initTime = tempMovement.fromTimestampPositionCheckpoint.pointTime;			
						break;			
				}				
				
				//si es el primer movimiento
				if (this._modelInstance.manetNodesTableCallableProxy.isManetNodeFirstMovement(arrayIdNodes[i], tempMovement.id))
				{				
					//Añadimos los checkpoints inicial y final y la trayectoria
					var circleInit:GraphicCircle = new GraphicCircle(checkpointRadius, nodeColour, 0x000000);
					var circleEnd:GraphicCircle = new GraphicCircle(checkpointRadius, nodeColour, 0x000000);
					var trajInit:GraphicTrajectory;	
					
					circleInit.manetNodeParentId = arrayIdNodes[i];
					circleInit.canvasToPopUp = this.canvasPoppers;
				    circleInit.x = tempMovement.fromTimestampPositionCheckpoint.xCoordinate * scaleFactor;
				    circleInit.y = tempMovement.fromTimestampPositionCheckpoint.yCoordinate * scaleFactor;           
				    nodeCanvas.addChild(circleInit);
				    circleInit.addEventListener(MouseEvent.MOUSE_MOVE, graphicCircleMouseMove_handler, false, 0, true);
				    circleInit.addEventListener(MouseEvent.MOUSE_UP, graphicCircleMouseUp_handler, false, 0, true);
				    circleInit.addEventListener(MouseEvent.MOUSE_DOWN, graphicCircleMouseDown_handler, false, 0, true);
				    
				    circleEnd.manetNodeParentId = arrayIdNodes[i];
				    circleEnd.canvasToPopUp = this.canvasPoppers;
				    circleEnd.x = tempMovement.toTimestampPositionCheckpoint.xCoordinate * scaleFactor;
				    circleEnd.y = tempMovement.toTimestampPositionCheckpoint.yCoordinate * scaleFactor;           
				    nodeCanvas.addChild(circleEnd);			    
				    circleEnd.addEventListener(MouseEvent.MOUSE_MOVE, graphicCircleMouseMove_handler, false, 0, true);
					circleEnd.addEventListener(MouseEvent.MOUSE_UP, graphicCircleMouseUp_handler, false, 0, true);
					circleEnd.addEventListener(MouseEvent.MOUSE_DOWN, graphicCircleMouseDown_handler, false, 0, true);
	
				    trajInit = new GraphicTrajectory(0x555555, new Array(circleInit,circleEnd));
				    nodeCanvas.addChildAt(trajInit,0);
				    
				    circleInit.endTime = tempMovement.fromTimestampPositionCheckpoint.pointTime;
				    circleInit.nextTrajectory = trajInit;
				    
				    circleEnd.initTime = tempMovement.toTimestampPositionCheckpoint.pointTime
				    circleEnd.previousTrajectory = trajInit;
				    
				    circleTempPrevious = circleEnd;	
				    			
				}
				//si no es el primer movimiento
				else
				{
					//Añadimos solo el checkpoint final	
					var circleNext:GraphicCircle = new GraphicCircle(checkpointRadius, nodeColour, 0x000000);
					
					circleNext.manetNodeParentId = arrayIdNodes[i];	
					circleNext.canvasToPopUp = this.canvasPoppers;
				    circleNext.x = tempMovement.toTimestampPositionCheckpoint.xCoordinate * scaleFactor;
				    circleNext.y = tempMovement.toTimestampPositionCheckpoint.yCoordinate * scaleFactor;  
				    									
					nodeCanvas.addChild(circleNext);
					circleNext.addEventListener(MouseEvent.MOUSE_MOVE, graphicCircleMouseMove_handler, false, 0, true);
					circleNext.addEventListener(MouseEvent.MOUSE_UP, graphicCircleMouseUp_handler, false, 0, true);
					circleNext.addEventListener(MouseEvent.MOUSE_DOWN, graphicCircleMouseDown_handler, false, 0, true);
					
					var trajNext:GraphicTrajectory;
					
					trajNext = new GraphicTrajectory(0x555555, new Array(circleTempPrevious,circleNext));
					nodeCanvas.addChildAt(trajNext,0);
					
					circleTempPrevious.endTime = tempMovement.fromTimestampPositionCheckpoint.pointTime;
					circleTempPrevious.nextTrajectory = trajNext;
					circleNext.initTime = tempMovement.toTimestampPositionCheckpoint.pointTime;
					circleNext.previousTrajectory = trajNext;
					circleTempPrevious = circleNext;
				          					
				}
				
				if (this._modelInstance.manetNodesTableCallableProxy.isManetNodeLastMovement(arrayIdNodes[i], tempMovement.id))
				{
				
					break;
				}			
				else
				{
					//pasamos al siguiente movimiento
					tempMovement = this._modelInstance.manetNodesTableCallableProxy.getManetNodeNextMovement(arrayIdNodes[i], tempMovement.id);
				}	
			}
			//Se añade el canvas (capa) donde se dibujaron los checkpoints del nodo al canvasScenario
			this.canvasScenario.addChild(nodeCanvas);
			this.canvasScenario.addChildAt(nodeTimeposCanvas, 0);
			
			//Se añaden las propiedades de visualizacion del nodo al singleton
			this._displayPropertiesInstance.addDisplayedManetNodePropertiesItem(arrayIdNodes[i], nodeColour, nodeVisibility, rangeVisibility, nodeCanvas, nodeTimeposCanvas);		
		}//end for
	}
	catch(thrownError:Error)
	{
		
	}	
		
}


/*
private function drawCurrentLinksBetweenNodes(scaleFactor:Number, instantTime:Date):void
{
        try
        {
                this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
                this._modelInstance = ModelSingleton.getSingletonInstance();
               
                //Recorrer los nodos uno por uno
                var arrayIdNodes:Array = this._modelInstance.manetNodesTableCallableProxy.getIdManetNodesArray();
                for (var i:int = 0; i < arrayIdNodes.length; i++)
                {
                        //Posicion y rango del nodo en cuestion
                        var instantCheckpointA:TimestampPositionCheckpoint =
                                this._modelInstance.manetNodesTableCallableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(arrayIdNodes[i], instantTime);
                        var rangeA:int = this._modelInstance.manetNodesTableCallableProxy.getManetNodeRange(arrayIdNodes[i]);
                       
                        //Recorrer el resto de los nodos para ver con cual puede estar conectado el nodo i                             
                        for(var j:int = i ; j < arrayIdNodes.length; j++)
                        {
                                var instantCheckpointB:TimestampPositionCheckpoint =
                                        this._modelInstance.manetNodesTableCallableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(arrayIdNodes[j], instantTime);
                                var rangeB:int = this._modelInstance.manetNodesTableCallableProxy.getManetNodeRange(arrayIdNodes[j]);
                                       
                                //Calculamos la distancia entre las posiciones
                                var distance:Number = Math.abs(Math.sqrt(Math.pow((instantCheckpointB.xCoordinate - instantCheckpointA.xCoordinate) , 2) +
                                         Math.pow((instantCheckpointB.yCoordinate - instantCheckpointA.yCoordinate) , 2) ));   
                               
                                trace("distancia: " + distance);
                                trace("rangoA: " + rangeA);
                                trace("rangoB: " + rangeB);
                               
                                //Aplicamos el criterio para establecer el link
                                //Si debería existir el enlace
                                if (rangeA >= distance || rangeB >= distance)
                                {
                                        //Si está establecido el link, hay que actualizarlo
                                        
                                        //HAY QUE BUSCAR SI EXISTE EL LINK QUE UNA LOS DOS NODOS
                                        //Recorremos todos los links
                                        var existsLinkBetweenNodes:Boolean = false;
										for each (var i:Object in this.canvasLinks.getChildren())
										{
											if (i as GraphicTrajectory)
											{
												//Recorrer el array de dependencias y buscar si estan los circulos correspondientes a los nodos i y j
												for(var j:int = 0; j < GraphicTrajectory(i).getDependencies().length, j++)
												{
													
												}
												GraphicTrajectory(i) = checkpointScaleFactor;
												GraphicTrajectory(i).scaleY = checkpointScaleFactor;
												
											}	
										}
										//Si existe una dependencia entre los nodos		                                        
                                        if(existsLinkBetweenNodes)
                                        {
                                        	//se actualiza la dependencia
                                                trace("QUE NO");
                                        }
                                        //Si no está establecido, se crea la dependencia y se establecen los escuchadores
                                        else
                                        {
                                                trace("QUE SI, i:" + i + " , j:" + j);
                                                //Se traen los canvasPos y los circulos de posicion
                                                var canvasA:Canvas = this._displayPropertiesInstance.getManetNodeCanvasTimePosReference(arrayIdNodes[i]);
                                                var canvasB:Canvas = this._displayPropertiesInstance.getManetNodeCanvasTimePosReference(arrayIdNodes[j]);
                                                var circlePosA:GraphicAreaCircleIcon;
                                                var circlePosB:GraphicAreaCircleIcon;
                                               
                                                if (canvasA.getChildren() != null && canvasA.getChildren().length > 0  && canvasA.getChildAt(0) != null)
                                                {
                                                        circlePosA = GraphicAreaCircleIcon(canvasA.getChildAt(0));
                                                }
                                                                                               
                                                if (canvasB.getChildren() != null && canvasB.getChildren().length > 0  && canvasB.getChildAt(0) != null)
                                                {
                                                        circlePosB = GraphicAreaCircleIcon(canvasB.getChildAt(0));
                                                }
                                               
                                                if (circlePosA != null && circlePosB != null)
                                                {
                                                        trace("voy a dibujar");
                                                        var trajAB:GraphicTrajectory = new GraphicTrajectory(0x555555, new Array(circlePosA, circlePosB));
                                                        //this._displayPropertiesInstance.linksTrajectoriesCanvas.addChildAt(trajAB,0);
                                                        this.canvasLinks.addChild(trajAB);
                                               
                                                        circlePosA.pushAssociatedLink(trajAB);
                                                        circlePosB.pushAssociatedLink(trajAB);
                                                        circlePosA.addEventListener(MoveEvent.MOVE, graphicAreaCircleIconMove_handler);
                                                        circlePosB.addEventListener(MoveEvent.MOVE, graphicAreaCircleIconMove_handler);

                                                }                                              
                                               
                                        }
                                }
                                //Si no deberia existir el enlace
                                else
                                {
                                	//Si esta establecido el link hay que borrarlo
                                	if(false)
                                	{
                                		
                                	}
                                	//Si no esta establacido el link no hacemos nada
                                	else
                                	{
                                		
                                	}
                                	
                                }              
                               
                        }
                }                              
        }
        catch(err:Error)
        {
               
        }
}
*/

//####################  HANDLERS DE EVENTOS SOBRE COMPONENTES GRAFICOS PROPIOS  ##########################

private function graphicCircleMouseMove_handler(evt:MouseEvent):void 
{
	this._modelInstance = ModelSingleton.getSingletonInstance();
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	
	
	//Se comprueba si esta dentro de los limites del escenario	
	if ((this._modelInstance.scenarioPropertiesCallableProxy.width * this._displayPropertiesInstance.scaleFactor < GraphicCircle(evt.currentTarget).x) ||
		(GraphicCircle(evt.currentTarget).x < 0) ||
		(this._modelInstance.scenarioPropertiesCallableProxy.height * this._displayPropertiesInstance.scaleFactor < GraphicCircle(evt.currentTarget).y) ||
		(GraphicCircle(evt.currentTarget).y < 0))
	{
		 		
		GraphicCircle(evt.currentTarget).forceMouseUp_handler();
		this.drawManetNodeAndTrajectoriesFromModel(GraphicCircle(evt.currentTarget).manetNodeParentId, this._displayPropertiesInstance.scaleFactor,
			this._displayPropertiesInstance.checkpointSize);
			
		this.drawInstantPositionNode(GraphicCircle(evt.currentTarget).manetNodeParentId, this._displayPropertiesInstance.scaleFactor,
			this._displayPropertiesInstance.getManetNodeCanvasTimePosReferenceVisibilityRange(GraphicCircle(evt.currentTarget).manetNodeParentId),
			this._displayPropertiesInstance.rangeAlpha); 
			
		return;
			
	}

	if (GraphicCircle(evt.currentTarget).previousTrajectory)
	{
		GraphicCircle(evt.currentTarget).previousTrajectory.update();
	}
	if (GraphicCircle(evt.currentTarget).nextTrajectory)
	{	
		GraphicCircle(evt.currentTarget).nextTrajectory.update();
	}
	//si no tiene trayectorias asociadas es un checkpoint unico
	if (!GraphicCircle(evt.currentTarget).previousTrajectory && !GraphicCircle(evt.currentTarget).nextTrajectory)
	{
		
	}
	
		
	if(this._thereIsGraphicCircleMovementFlag == 1)
	{
		this._thereIsGraphicCircleMovementFlag = 2;
	}
	
}


private function graphicCircleMouseDown_handler(evt:MouseEvent):void
{
	this._thereIsGraphicCircleMovementFlag = 1;
}


private function graphicCircleMouseUp_handler(evt:MouseEvent):void
{
	this._modelInstance = ModelSingleton.getSingletonInstance();
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	var update:Boolean = false;
	
	
	if(this._thereIsGraphicCircleMovementFlag == 2)
	{	
				
		//Se comprueba si esta dentro de los limites del escenario	
		if ((this._modelInstance.scenarioPropertiesCallableProxy.width * this._displayPropertiesInstance.scaleFactor < GraphicCircle(evt.currentTarget).x) ||
			(GraphicCircle(evt.currentTarget).x < 0) ||
			(this._modelInstance.scenarioPropertiesCallableProxy.height * this._displayPropertiesInstance.scaleFactor < GraphicCircle(evt.currentTarget).y) ||
			(GraphicCircle(evt.currentTarget).y < 0))
		{	
			GraphicCircle(evt.currentTarget).forceMouseUp_handler();
			this.drawManetNodeAndTrajectoriesFromModel(GraphicCircle(evt.currentTarget).manetNodeParentId, this._displayPropertiesInstance.scaleFactor,
				this._displayPropertiesInstance.checkpointSize);
				
			//this.redrawAllInstantPositions(this._displayPropertiesInstance.scaleFactor, this._displayPropertiesInstance.scaleFactor);
			this.drawInstantPositionNode(GraphicCircle(evt.currentTarget).manetNodeParentId, this._displayPropertiesInstance.scaleFactor,
				this._displayPropertiesInstance.getManetNodeCanvasTimePosReferenceVisibilityRange(GraphicCircle(evt.currentTarget).manetNodeParentId),
				this._displayPropertiesInstance.rangeAlpha);			
			
			return;			
		}	

		
		//FR
		var nodeId:String;
		var initTime:Date;
		var endTime:Date;
		var xPosition:int;
		var yPosition:int;
		var firstState:NodeState;
		var firstMovement:Movement;

		nodeId = GraphicCircle(evt.currentTarget).manetNodeParentId;
		initTime = GraphicCircle(evt.currentTarget).initTime;
		endTime = GraphicCircle(evt.currentTarget).endTime;
		xPosition = GraphicCircle(evt.currentTarget).x/this._displayPropertiesInstance.scaleFactor;
		yPosition = GraphicCircle(evt.currentTarget).y/this._displayPropertiesInstance.scaleFactor;
		firstState = this._modelInstance.manetNodesTableCallableProxy.getManetNodeFirstState(nodeId);
		firstMovement = this._modelInstance.manetNodesTableCallableProxy.getManetNodeFirstMovement(nodeId);
		 
		if (endTime!=null)
			if(firstMovement.fromTimestampPositionCheckpoint.pointTime.time == endTime.time)
				this._modelInstance.manetNodesTableCallableProxy.updateManetNodeState(nodeId,firstState.switchedOn,
					firstState.timestamp,xPosition,yPosition);
		 
		 update = this._modelInstance.manetNodesTableCallableProxy.updateManetNodeTimestampPositionCheckpoint(nodeId,
			initTime,endTime,initTime,endTime,xPosition,yPosition,false);
		 /*update = this._modelInstance.manetNodesTableCallableProxy.updateManetNodeTimestampPositionCheckpoint(GraphicCircle(evt.currentTarget).manetNodeParentId,
			GraphicCircle(evt.currentTarget).initTime, 
			GraphicCircle(evt.currentTarget).endTime, 
			GraphicCircle(evt.currentTarget).initTime, 
			GraphicCircle(evt.currentTarget).endTime,			
			GraphicCircle(evt.currentTarget).x/this._displayPropertiesInstance.scaleFactor,
			GraphicCircle(evt.currentTarget).y/this._displayPropertiesInstance.scaleFactor,
			false);*/ 
		//FR
									
	}
	this._thereIsGraphicCircleMovementFlag = 0;
}


private function mouseDownOnScenario_handler(event:MouseEvent):void
{
	this._mouseXcoordinate = event.localX;
	this._mouseYcoordinate = event.localY;
}


private function mouseUpOnScenario_handler(event:MouseEvent):void
{
	this._mouseXcoordinate = 0;
	this._mouseYcoordinate = 0;
}

private function mouseMoveOnScenario_handler(event:MouseEvent):void
{
	if (event.buttonDown && (event.localX != this._mouseXcoordinate || event.localY != this._mouseYcoordinate) &&
		!DisplayPropertiesSingleton.getSingletonInstance().isDraggingCheckpoint)
	{		
		this.horizontalScrollPosition = this.horizontalScrollPosition - (event.localX - this._mouseXcoordinate);
		this.verticalScrollPosition = this.verticalScrollPosition - (event.localY - this._mouseYcoordinate);
		this._mouseXcoordinate = event.localX;
		this._mouseYcoordinate = event.localY;		
	}

	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();	
	this._displayPropertiesInstance.mouseScenarioXcoord = this.canvasScenario.mouseX / this._displayPropertiesInstance.scaleFactor;
	this._displayPropertiesInstance.mouseScenarioYcoord = this.canvasScenario.mouseY / this._displayPropertiesInstance.scaleFactor;		
}

private function mouseOverOnScenario_handler(event:MouseEvent):void
{
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
	this.cursorManager.setCursor(this._displayPropertiesInstance.customCursorHandDrag, CursorManagerPriority.HIGH, -5, -2);
}




private function mouseOutOnScenario_handler(event:MouseEvent):void
{
	this.cursorManager.removeAllCursors();
	
}
//########################################################################################################################
//FR
/**
 * Función para desplazar el mapa y el CanvasScenario con los nodos y checkpoints incluidos cuando se hace
 * doble click en la ventana gráfica, pero fuera del propio rectángulo rojo (CanvasScenario).
 * Se ha añadido también la opción de que el doble click sirva para fijar el punto sobre el que se hace como
 * vértice superior izquierdo del rectángulo rojo
 * */
private function mouseDoubleClickOnViewport_handler(event:MouseEvent):void{
	
	try{
		
		if (this.map.visible){
		
			if (!this.clickedOnCanvasScenario){
				
				this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
				this._modelInstance = ModelSingleton.getSingletonInstance();
				
				var oldCenterLat:Number = ctLat;
				var oldCenterLng:Number = ctLng;
				var oldCenterLatLng:LatLng = ct;
				var oldCenterCoord:Point = this.map.fromLatLngToViewport(ct);
				var markerLatLng:LatLng = this.map.fromViewportToLatLng(new Point((this.width-4)/2,(this.height-4)/2));
				var xClicked:Number = event.localX-this.xTranslation;
				var yClicked:Number = event.localY-this.yTranslation;
				
				var zoom:Number = this.map.getZoom();
				var maptype:Object = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._mapType;
				var dcMode:String = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._doubleClickMode;
				
				var newCenterCoord:Point;
				var newCenterLatLng:LatLng;
				var newCenterLat:Number;
				var newCenterLng:Number;
				var info:GoogleInfo;
				var marcador:Marker;
				
				if (this.doubleClickMode == "Shift"){
					
					newCenterCoord = new Point(xClicked+this.xTranslation,yClicked+this.yTranslation);
					newCenterLatLng = this.map.fromViewportToLatLng(newCenterCoord);
					newCenterLat = newCenterLatLng.lat();
					newCenterLng = newCenterLatLng.lng();
					info = new GoogleInfo(maptype,"Coordinates",zoom,newCenterLat,newCenterLng,"",true,dcMode);
				
			    	this.xTranslation = (this.width-4)/2-xClicked;
			    	this.yTranslation = (this.height-4)/2-yClicked;
			    	this.canvasScenario.move(this.xTranslation,this.yTranslation);
			    	this.canvasGrid.move(this.xTranslation,this.yTranslation);
			    	this.canvasLinks.move(this.xTranslation,this.yTranslation);
			    	this.canvasPoppers.move(this.xTranslation,this.yTranslation);
	
			    	this.map.setSize(new Point(this.width-4,this.height-4));
			    	this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo = info;

			    	var area:Point;
					var nuevoCentro:Point;
					if ((this.width-4 >= this.canvasScenario.width+this.xTranslation)&&
						(this.height-4 >= this.canvasScenario.height+this.yTranslation))
						area = new Point(this.width-4,this.height-4);
					else if ((this.width-4 >= this.canvasScenario.width+this.xTranslation)&&
						(this.height-4 < this.canvasScenario.height+this.yTranslation))
						area = new Point(this.width-4,this.canvasScenario.height+this.yTranslation);
					else if ((this.width-4 < this.canvasScenario.width+this.xTranslation)&&
						(this.height-4 >= this.canvasScenario.height+this.yTranslation))
						area = new Point(this.canvasScenario.width+this.xTranslation,this.height-4);
					else if ((this.width-4 < this.canvasScenario.width+this.xTranslation)&&
						(this.height-4 < this.canvasScenario.height+this.yTranslation))
						area = new Point(this.canvasScenario.width+this.xTranslation,this.canvasScenario.height+this.yTranslation);
					
					nuevoCentro = new Point(area.x/2+distanceBetweenCenters.x,area.y/2+distanceBetweenCenters.y);
			    	var nuevoCentroLatLng:LatLng = this.map.fromViewportToLatLng(nuevoCentro);
					var centralLat:Number = nuevoCentroLatLng.lat();
					var centralLng:Number = nuevoCentroLatLng.lng();
						
					this.map.setSize(area);				
					
					info = new GoogleInfo(maptype,"Coordinates",
						zoom,centralLat,centralLng,"",true,dcMode);		
			    	this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo = info;
	
			    	distanceBetweenCenters.x = (area.x - (this.width-4))/2;
			    	distanceBetweenCenters.y = (area.y - (this.height-4))/2;
			    	
		  		}//doubleClickMode==Shift
		  		else{
		  				
		  			newCenterCoord = new Point(this.map.getSize().x/2 + xClicked,
		  				this.map.getSize().y/2 + yClicked);
					newCenterLatLng = this.map.fromViewportToLatLng(newCenterCoord);
					newCenterLat = newCenterLatLng.lat();
					newCenterLng = newCenterLatLng.lng();
					
					info = new GoogleInfo(maptype,"Coordinates",zoom,newCenterLat,newCenterLng,"",true,dcMode);
					this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo = info;
					
					if ((this.xTranslation!=0)||(this.yTranslation!=0)){
						
						shifted = true;
						undoShift();
						shifted = false;
						
					}
		  			
		  		}//doubleClickMode==Set corner
		  		
		  		marcador = new Marker(markerLatLng);
			    this.map.addOverlay(marcador);
			
			}//clickedOnCanvasScenario
			this.clickedOnCanvasScenario = false;
			
		}//visible
		
	}//try
	catch(thrownError:Error){
		
		trace("ERROR at mouseDoubleClickOnViewport_handler!! " + thrownError.message);
	
	}	
	
}

/**
 * Función para desplazar el mapa y el CanvasScenario con los nodos y checkpoints incluidos cuando se hace
 * doble click en la ventana gráfica, pero dentro del propio rectángulo rojo (CanvasScenario).
 * Se ha añadido también la opción de que el doble click sirva para fijar el punto sobre el que se hace como
 * vértice superior izquierdo del rectángulo rojo
 * */
private function mouseDoubleClickOnScenario_handler(event:MouseEvent):void{
	
	try{
		
		if (this.map.visible){
			
			this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
			this._modelInstance = ModelSingleton.getSingletonInstance();
			
			var oldCenterLat:Number = ctLat;
			var oldCenterLng:Number = ctLng;
			var oldCenterLatLng:LatLng = ct;
			var oldCenterCoord:Point = this.map.fromLatLngToViewport(ct);
			var markerLatLng:LatLng = this.map.fromViewportToLatLng(new Point((this.width-4)/2,(this.height-4)/2));
			var xClicked:Number = this._displayPropertiesInstance.mouseScenarioXcoord;
			var yClicked:Number = this._displayPropertiesInstance.mouseScenarioYcoord;
	
			var zoom:Number = this.map.getZoom();
			var maptype:Object = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._mapType;
			var dcMode:String = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._doubleClickMode;
						
			var newCenterCoord:Point;
			var newCenterLatLng:LatLng;
			var newCenterLat:Number;
			var newCenterLng:Number;
			var info:GoogleInfo;
			var marcador:Marker;
			
			if (this.doubleClickMode == "Shift"){
				
				newCenterCoord = new Point(xClicked+this.xTranslation,yClicked+this.yTranslation);
				newCenterLatLng = this.map.fromViewportToLatLng(newCenterCoord);
				newCenterLat = newCenterLatLng.lat();
				newCenterLng = newCenterLatLng.lng();
				info = new GoogleInfo(maptype,"Coordinates",zoom,newCenterLat,newCenterLng,"",true,dcMode);
			
		    	this.xTranslation = (this.width-4)/2-xClicked;
			    this.yTranslation = (this.height-4)/2-yClicked;
		    	this.canvasScenario.move(this.xTranslation,this.yTranslation);
		    	this.canvasGrid.move(this.xTranslation,this.yTranslation);
		    	this.canvasLinks.move(this.xTranslation,this.yTranslation);
		    	this.canvasPoppers.move(this.xTranslation,this.yTranslation);
		    		    	
		    	this.map.setSize(new Point(this.width-4,this.height-4));
		    	this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo = info;

		    	var area:Point;
				var nuevoCentro:Point;
				if ((this.width-4 >= this.canvasScenario.width+this.xTranslation)&&
					(this.height-4 >= this.canvasScenario.height+this.yTranslation))
					area = new Point(this.width-4,this.height-4);
				else if ((this.width-4 >= this.canvasScenario.width+this.xTranslation)&&
					(this.height-4 < this.canvasScenario.height+this.yTranslation))
					area = new Point(this.width-4,this.canvasScenario.height+this.yTranslation);
				else if ((this.width-4 < this.canvasScenario.width+this.xTranslation)&&
					(this.height-4 >= this.canvasScenario.height+this.yTranslation))
					area = new Point(this.canvasScenario.width+this.xTranslation,this.height-4);
				else if ((this.width-4 < this.canvasScenario.width+this.xTranslation)&&
					(this.height-4 < this.canvasScenario.height+this.yTranslation))
					area = new Point(this.canvasScenario.width+this.xTranslation,this.canvasScenario.height+this.yTranslation);
				
				nuevoCentro = new Point(area.x/2+distanceBetweenCenters.x,area.y/2+distanceBetweenCenters.y);
		    	var nuevoCentroLatLng:LatLng = this.map.fromViewportToLatLng(nuevoCentro);
				var centralLat:Number = nuevoCentroLatLng.lat();
				var centralLng:Number = nuevoCentroLatLng.lng();	
				
				this.map.setSize(area);
				
				info = new GoogleInfo(maptype,"Coordinates",
					zoom,centralLat,centralLng,"",true,dcMode);	
		    	this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo = info;
		    		
		    	distanceBetweenCenters.x = (area.x - (this.width-4))/2;
			    distanceBetweenCenters.y = (area.y - (this.height-4))/2;
			
			}//doubleClickMode==shift
			else{
				
				newCenterCoord = new Point(this.map.getSize().x/2 + xClicked,this.map.getSize().y/2 + yClicked);
				newCenterLatLng = this.map.fromViewportToLatLng(newCenterCoord);
				newCenterLat = newCenterLatLng.lat();
				newCenterLng = newCenterLatLng.lng();
					
				info = new GoogleInfo(maptype,"Coordinates",zoom,newCenterLat,newCenterLng,"",true,dcMode);
				this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo = info;
				
				if ((this.xTranslation!=0)||(this.yTranslation!=0)){
						
						shifted = true;
						undoShift();
						shifted = false;
						
				}
					
			}//doubleClickMode==Set corner
			
			marcador = new Marker(markerLatLng);
			this.map.addOverlay(marcador);
	    	this.clickedOnCanvasScenario = true;	    	
	    	
		}//visible
		
	}//try
	catch(thrownError:Error){
		
		trace("ERROR at mouseDoubleClickOnScenario_handler!! " + thrownError.message);
	
	}
	
}

/**
 * Función para borrar todos los marcadores añadidos sobre el mapa cuando se hace clic derecho sobre el escenario
 * */
private function mouseRightClickOnViewport_handler(event:MouseEvent):void{
	
	try{
		
		if (this.map.visible)
			this.map.clearOverlays();
			
	}
	catch(thrownError:Error){
		
		trace("ERROR at mouseRightClickOnViewport_handler!! " + thrownError.message);
		
	}
	
}

/**
 * Función para recalcular la trayectoria de un nodo cuando se utiliza GoogleMaps.
 * Recibe un string con el nombre del nodo. Llamando a otras funciones, se van recalculando las posiciones
 * de los checkpoints y se actualiza la manetNodesTable. 
 * */
private function recalculateNodeTrajectory (nodeId:String):void{
	
	try{
		
		this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
		this._modelInstance = ModelSingleton.getSingletonInstance();
		var tempMovement:Movement = this._modelInstance.manetNodesTableCallableProxy.getManetNodeFirstMovement(nodeId);

		var oldPoint:Point;
		var newPoint:Point;		

		do{
			oldPoint = new Point(tempMovement.fromTimestampPositionCheckpoint.xCoordinate,
					tempMovement.fromTimestampPositionCheckpoint.yCoordinate);
			newPoint = recalculatePoint (oldPoint);
			
			
			this._modelInstance.manetNodesTableCallableProxy.updateManetNodeTimestampPositionCheckpoint(nodeId,
				tempMovement.toTimestampPositionCheckpoint.pointTime,
				tempMovement.fromTimestampPositionCheckpoint.pointTime,
				tempMovement.toTimestampPositionCheckpoint.pointTime,
				tempMovement.fromTimestampPositionCheckpoint.pointTime,
				newPoint.x,newPoint.y,
				true);
			
			if (this._modelInstance.manetNodesTableCallableProxy.isManetNodeLastMovement(nodeId,tempMovement.id)){
			
				oldPoint = new Point(tempMovement.toTimestampPositionCheckpoint.xCoordinate,
					tempMovement.toTimestampPositionCheckpoint.yCoordinate);
				newPoint = recalculatePoint (oldPoint);
				
				this._modelInstance.manetNodesTableCallableProxy.updateManetNodeTimestampPositionCheckpoint(nodeId,
					tempMovement.toTimestampPositionCheckpoint.pointTime,
					tempMovement.toTimestampPositionCheckpoint.pointTime,
					tempMovement.toTimestampPositionCheckpoint.pointTime,
					tempMovement.toTimestampPositionCheckpoint.pointTime,
					newPoint.x,newPoint.y,
					true);	
			
			}
			
			tempMovement = this._modelInstance.manetNodesTableCallableProxy.getManetNodeNextMovement(nodeId,tempMovement.id);
			
		}while (tempMovement!=null);
		
	}
	catch(thrownError:Error){
		
		trace("ERROR at recalculateNodeTrajectory!! " + thrownError.message);
	
	}

}

/**
 * Función que recibe unas coordenadas (x,y) que respresentan la distancia en metros respecto al vértice superior
 * izquierdo. Conocida la latitud y longitud de dicho vértice, calcula la latitud y longitud del punto y devuelve otras
 * coordenadas (x',y'), que ahora indican la posición sobre la ventana gráfica que debe tener ese punto teniendo en
 * cuenta que el par (latitud,longitud) del vértice superior izquierdo está en la posición (0.0).
 * */
private function recalculatePoint (old:Point):Point
{
	var recalculated:Point;
	
	var R:Number = 6370000; //radio de la Tierra, en metros
	
	var bearing:Number = 180; //rumbo = 180º
	
	var latS:Number = (Math.asin(Math.sin(nwLat*Math.PI/180)*Math.cos(old.y/R) +
							Math.cos(nwLat*Math.PI/180)*Math.sin(old.y/R)*Math.cos(bearing*Math.PI/180)))*180/Math.PI;
	var lngS:Number = nwLng + (Math.atan2(Math.sin(bearing*Math.PI/180)*Math.sin(old.y/R)*Math.cos(nwLat*Math.PI/180),
							Math.cos(old.y/R)-Math.sin(nwLat*Math.PI/180)*Math.sin(latS*Math.PI/180)))*180/Math.PI;
	
	bearing = 90; //rumbo = 90º
	var latFinal:Number = (Math.asin(Math.sin(latS*Math.PI/180)*Math.cos(old.x/R) +
							Math.cos(latS*Math.PI/180)*Math.sin(old.x/R)*Math.cos(bearing*Math.PI/180)))*180/Math.PI;
	var lngFinal:Number = lngS + (Math.atan2(Math.sin(bearing*Math.PI/180)*Math.sin(old.x/R)*Math.cos(latS*Math.PI/180),
							Math.cos(old.x/R)-Math.sin(latS*Math.PI/180)*Math.sin(latFinal*Math.PI/180)))*180/Math.PI;
							
	var latlngFinal:LatLng = new LatLng(latFinal,lngFinal);
	recalculated = this.map.fromLatLngToViewport(latlngFinal);
	recalculated.x = redondear(recalculated.x,0);
	recalculated.y = redondear(recalculated.y,0);
	return recalculated;
}

/**
 * Función que recibe el rango de un nodo, en metros. Calcula en función del mapa de Google cargado el valor
 * que debe tener el rango, en píxels, de manera que representado sobre ese mapa, se observe el mismo radio en metros.
 * */
private function recalculateRange (old:Number):Number
{
	var recalculated:Point;
	
	var R:Number = 6370000; //radio de la Tierra, en metros
	
	var bearing:Number = 180; //rumbo = 180º
	
	var latS:Number = (Math.asin(Math.sin(nwLat*Math.PI/180)*Math.cos(old/R) +
							Math.cos(nwLat*Math.PI/180)*Math.sin(old/R)*Math.cos(bearing*Math.PI/180)))*180/Math.PI;
	var lngS:Number = nwLng + (Math.atan2(Math.sin(bearing*Math.PI/180)*Math.sin(old/R)*Math.cos(nwLat*Math.PI/180),
							Math.cos(old/R)-Math.sin(nwLat*Math.PI/180)*Math.sin(latS*Math.PI/180)))*180/Math.PI;
	
	var latlngS:LatLng = new LatLng(latS,lngS);
	recalculated = this.map.fromLatLngToViewport(latlngS);
	recalculated.y = redondear(recalculated.y,0);
	return recalculated.y;
}

/**
 * Función que recibe el rango, una latitud y una longitud, multiplica el rango por un coeficiente y calcula la distancia
 * en valores de latitud y longitud de dicho rango multiplicado respecto de los parámetros recibidos. Se utiliza para
 * poder dejar un margen en los bordes del escenario y que los rangos puedan dibujarse al completo y dejando un pequeño
 * espacio añadido 
**/
private function calculateMargin (range:Number,lat:Number,lng:Number):Point{
	
	var R:Number = 6370000; //radio de la Tierra, en metros
	
	var bearing:Number = 180; //rumbo = 180º
	
	var latS:Number = (Math.asin(Math.sin(lat*Math.PI/180)*Math.cos(range/R) +
							Math.cos(lat*Math.PI/180)*Math.sin(range/R)*Math.cos(bearing*Math.PI/180)))*180/Math.PI;
	var lngS:Number = lng + (Math.atan2(Math.sin(bearing*Math.PI/180)*Math.sin(range/R)*Math.cos(lat*Math.PI/180),
							Math.cos(range/R)-Math.sin(lat*Math.PI/180)*Math.sin(latS*Math.PI/180)))*180/Math.PI;
							
	bearing = 90; //rumbo = 90º
	var latFinal:Number = (Math.asin(Math.sin(latS*Math.PI/180)*Math.cos(range/R) +
							Math.cos(latS*Math.PI/180)*Math.sin(range/R)*Math.cos(bearing*Math.PI/180)))*180/Math.PI;
	var lngFinal:Number = lngS + (Math.atan2(Math.sin(bearing*Math.PI/180)*Math.sin(range/R)*Math.cos(latS*Math.PI/180),
							Math.cos(range/R)-Math.sin(latS*Math.PI/180)*Math.sin(latFinal*Math.PI/180)))*180/Math.PI;
	
	var margin:Point = new Point(Math.abs(latFinal-lat),Math.abs(lngFinal-lng));
	return margin;
	
}

/**
 * Función que recibe el nuevo valor de zoom del Mapa de Google que se desea aplicar y, en base a él, recalcula las
 * posiciones de todos los nodos, checkpoints, tamaño de la ventana gráfica y del ScenarioCanvas, además del nuevo
 * centro del mapa ya que aunque se cambie el zoom, el vértice superior izquierdo ha de conservar su latitud y longitud
 * inicial.
 * */
private function googleZoomChange (newZoom:Number):void{

	try{
		
		this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
		this._modelInstance = ModelSingleton.getSingletonInstance();
		
		var shiftedScenario:Boolean = false;
		
		if ( (this.xTranslation != 0) || (this.yTranslation != 0) || (cornerSet == true)){
			
			this.xTranslationForZoomChange = this.xTranslation;
			this.yTranslationForZoomChange = this.yTranslation;
			undoShiftBeforeChangingZoom();
			shiftedScenario = true;
			cornerPoint = this.map.fromLatLngToViewport(corner);
			
		}					
		
		var nodesArray:Array = this._modelInstance.manetNodesTableCallableProxy.getIdManetNodesArray();
		
		var latitudes:Vector.<Number>;
		latitudes = new Vector.<Number>();
		var longitudes:Vector.<Number>;
		longitudes = new Vector.<Number>();
		var numberOfPositions:Vector.<Number>;
		numberOfPositions = new Vector.<Number>();
		var level:Number = this.map.getZoom();
		var centro:LatLng = this.map.getCenter();
		var centroA:Number = centro.lat();
		var centroO:Number = centro.lng();
		
		var South:Point = new Point(0,this.canvasScenario.height+cornerPoint.y);
		var East:Point = new Point(this.canvasScenario.width+cornerPoint.x,0);
		var bottom:LatLng = this.map.fromViewportToLatLng(South);
		var right:LatLng = this.map.fromViewportToLatLng(East);
		
		var rangeLimitLat:Vector.<Number>;
		rangeLimitLat = new Vector.<Number>;
		var rangeLimitLng:Vector.<Number>;
		rangeLimitLng = new Vector.<Number>;
		
		for (var i:int = 0; i<nodesArray.length; i++){
		
			var tempMovement:Movement = this._modelInstance.manetNodesTableCallableProxy.getManetNodeFirstMovement(nodesArray[i]);
			var myPoint:Point;
			var latAndLng:LatLng;
			numberOfPositions.push(1);
			
			do{	
				if(shiftedScenario)
					myPoint = new Point(tempMovement.fromTimestampPositionCheckpoint.xCoordinate+cornerPoint.x,
						tempMovement.fromTimestampPositionCheckpoint.yCoordinate+cornerPoint.y);
				else					
					myPoint = new Point(tempMovement.fromTimestampPositionCheckpoint.xCoordinate,
						tempMovement.fromTimestampPositionCheckpoint.yCoordinate);
				
				latAndLng = this.map.fromViewportToLatLng(myPoint);
				latitudes.push(latAndLng.lat());
				longitudes.push(latAndLng.lng());
						
				if (this._modelInstance.manetNodesTableCallableProxy.isManetNodeLastMovement(nodesArray[i],tempMovement.id)){
				
					if(shiftedScenario)
						myPoint = new Point(tempMovement.toTimestampPositionCheckpoint.xCoordinate+cornerPoint.x,
							tempMovement.toTimestampPositionCheckpoint.yCoordinate+cornerPoint.y);
					else					
						myPoint = new Point(tempMovement.toTimestampPositionCheckpoint.xCoordinate,
							tempMovement.toTimestampPositionCheckpoint.yCoordinate);
					
					latAndLng = this.map.fromViewportToLatLng(myPoint);
					latitudes.push(latAndLng.lat());
					longitudes.push(latAndLng.lng());

				}
				
				tempMovement = this._modelInstance.manetNodesTableCallableProxy.getManetNodeNextMovement(nodesArray[i],tempMovement.id);
				numberOfPositions[i]++;
				
			}while (tempMovement!=null);
			
			rangeLimitLat.push(recalculateRangeLatAfterGoogleZoomChange(
				this._modelInstance.manetNodesTableCallableProxy.getManetNodeRange(nodesArray[i])));
			rangeLimitLng.push(recalculateRangeLngAfterGoogleZoomChange(
				this._modelInstance.manetNodesTableCallableProxy.getManetNodeRange(nodesArray[i])));

		}
				
		var zoom:Number = this.map.getZoom();
		var maptype:Object = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._mapType;
		var dcMode:String = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._doubleClickMode;
		
		var area:Point;
		if ((this.width-4 >= this.canvasScenario.width)&&(this.height-4 >= this.canvasScenario.height))
			area = new Point(this.width-4,this.height-4);
		else if ((this.width-4 >= this.canvasScenario.width)&&(this.height-4 < this.canvasScenario.height))
			area = new Point(this.width-4,this.canvasScenario.height);
		else if ((this.width-4 < this.canvasScenario.width)&&(this.height-4 >= this.canvasScenario.height))
			area = new Point(this.canvasScenario.width,this.height-4);
		else if ((this.width-4 < this.canvasScenario.width)&&(this.height-4 < this.canvasScenario.height))
			area = new Point(this.canvasScenario.width,this.canvasScenario.height);
		
		if (shiftedScenario)
			this.map.setCenter(corner,newZoom,MapType.NORMAL_MAP_TYPE);
		else
			this.map.setCenter(nw,newZoom,MapType.NORMAL_MAP_TYPE);	
		
		var centroFinalLatLng:LatLng;			
		var center:Point;
		
		if (shiftedScenario)
			if ( (area.x+this.xTranslationForZoomChange > 2*(this.width-4)) || (area.y+this.yTranslationForZoomChange > 2*(this.height-4) ) )
				center = new Point( area.x + (area.x+this.xTranslationForZoomChange - 2*(this.width-4))/2 ,
						area.y + (area.y+this.yTranslationForZoomChange - 2*(this.height-4))/2 );
			else			
				center = new Point(area.x+this.distanceBetweenCenters.x,area.y+this.distanceBetweenCenters.y);
		else
			center = new Point(area.x,area.y);		
		
		centroFinalLatLng = this.map.fromViewportToLatLng(center);
		var centralLat:Number = centroFinalLatLng.lat();
		var centralLng:Number = centroFinalLatLng.lng();
		var info:GoogleInfo = new GoogleInfo(maptype,"Coordinates",
		newZoom,centralLat,centralLng,"",true,dcMode); 
    	this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo = info;
					
		var xPosition:Vector.<Number>;
		xPosition = new Vector.<Number>();
		var yPosition:Vector.<Number>;
		yPosition = new Vector.<Number>();
		
		for (var j:int = 0; j<latitudes.length; j++){
			
			var latitudeAndLongitude:LatLng = new LatLng(latitudes[j],longitudes[j]);
			var updated:Point = this.map.fromLatLngToViewport(latitudeAndLongitude);
			
			if (shiftedScenario){

				cornerPoint = this.map.fromLatLngToViewport(corner);
				xPosition.push(updated.x-cornerPoint.x);
				yPosition.push(updated.y-cornerPoint.y);
				
			}
			else{
				xPosition.push(updated.x);
				yPosition.push(updated.y);
			}
			
		}
		
			
		var root:Number = 0;
		
		for (var n:int = 0; n<nodesArray.length; n++){
			
			var tmpMovement:Movement = this._modelInstance.manetNodesTableCallableProxy.getManetNodeFirstMovement(nodesArray[n]);
			
			var index:Number = numberOfPositions[n];
			
			if (n!=0)
				root = root + numberOfPositions[n-1];
			
			do{
				var x:Number;
				var y:Number;
				
				x = xPosition[root + numberOfPositions[n]-index];
				y = yPosition[root + numberOfPositions[n]-index];	
				
				this._modelInstance.manetNodesTableCallableProxy.updateManetNodeTimestampPositionCheckpoint(nodesArray[n],
					tmpMovement.toTimestampPositionCheckpoint.pointTime,
					tmpMovement.fromTimestampPositionCheckpoint.pointTime,
					tmpMovement.toTimestampPositionCheckpoint.pointTime,
					tmpMovement.fromTimestampPositionCheckpoint.pointTime,
					x,y,true);
						
				if (this._modelInstance.manetNodesTableCallableProxy.isManetNodeLastMovement(nodesArray[n],tmpMovement.id)){
					
					index--;
					
					x = xPosition[root+numberOfPositions[n]-index];
					y = yPosition[root+numberOfPositions[n]-index];
					
					this._modelInstance.manetNodesTableCallableProxy.updateManetNodeTimestampPositionCheckpoint(nodesArray[n],
						tmpMovement.toTimestampPositionCheckpoint.pointTime,
						tmpMovement.toTimestampPositionCheckpoint.pointTime,
						tmpMovement.toTimestampPositionCheckpoint.pointTime,
						tmpMovement.toTimestampPositionCheckpoint.pointTime,
						x,y,true);
				
				}
				
				tmpMovement = this._modelInstance.manetNodesTableCallableProxy.getManetNodeNextMovement(nodesArray[n],tmpMovement.id);
				index--;
				
			}while (tmpMovement!=null); 
		
		}
		
		for (var k:int = 0; k<nodesArray.length; k++){
			
			var calculatingRange:Point = this.map.fromLatLngToViewport(new LatLng(rangeLimitLat[k],rangeLimitLng[k]));
			var newRange:Number;
			
			if (shiftedScenario)
					newRange = redondear(calculatingRange.y-this.map.fromLatLngToViewport(corner).y,0);
			else
				newRange = redondear(calculatingRange.y,0);
			
			if (!this._modelInstance.manetNodesTableCallableProxy.setManetNodeRange(nodesArray[k],newRange)){
			
				Alert.show("Error while updating node range", DisplayPropertiesSingleton.APPLICATION_TITLE);
			
			}
			
			this.drawManetNodeAndTrajectoriesFromModel(nodesArray[k], this._displayPropertiesInstance.scaleFactor, this._displayPropertiesInstance.checkpointSize);
			
		}
		
		var nodesAC3:ArrayCollection = this._displayPropertiesInstance.getManetNodesIdAC();
		
		for each (var c:String in nodesAC3){
				
			this.drawInstantPositionNode(c, this._displayPropertiesInstance.scaleFactor, 
			this._displayPropertiesInstance.getManetNodeCanvasTimePosReferenceVisibilityRange(c),
			this._displayPropertiesInstance.rangeAlpha);			
		
		}
		this.drawAsSelectedCheckpoint();
		
		var newBottomLimit:Number = this.map.fromLatLngToViewport(bottom).y-cornerPoint.y;
		var newRightLimit:Number = this.map.fromLatLngToViewport(right).x-cornerPoint.x;
			
		this._modelInstance.scenarioPropertiesCallableProxy.height = newBottomLimit;
		this._modelInstance.scenarioPropertiesCallableProxy.width = newRightLimit;
		
			
		if (shiftedScenario){
			
			redoShiftAfterChangingZoom ();
			shiftedScenario = false;
				
			}
	
	}	
	catch(thrownError:Error){
		
		Alert.show("Error at googleZoomChange function: " + thrownError.message, DisplayPropertiesSingleton.APPLICATION_TITLE);
		trace("ERROR!! " + thrownError.message);
	
	}

}

/**
 * Función útil para recalcular el nuevo valor en píxels del rango de un nodo cuando se varía el zoom de Google aplicado
 * (Latitud)
 * */
private function recalculateRangeLatAfterGoogleZoomChange (oldPosition:Number):Number
{
	var oldRange:Point;
	var rangeLimit:LatLng;
	
	if ((this.xTranslationForZoomChange!=0)||(this.yTranslationForZoomChange!=0))
		oldRange = new Point(cornerPoint.x,cornerPoint.y+oldPosition)
	else
		oldRange = new Point(0,oldPosition);
	
	rangeLimit = this.map.fromViewportToLatLng(oldRange);
	return rangeLimit.lat();
	
}

/**
 * Función útil para recalcular el nuevo valor en píxels del rango de un nodo cuando se varía el zoom de Google aplicado
 * (Longitud)
 * */
private function recalculateRangeLngAfterGoogleZoomChange (oldPosition:Number):Number
{
	var oldRange:Point;
	var rangeLimit:LatLng;
	
	if ((this.xTranslationForZoomChange!=0)||(this.yTranslationForZoomChange!=0))
		oldRange = new Point(cornerPoint.x,cornerPoint.y+oldPosition)
	else
		oldRange = new Point(0,oldPosition);
	
	rangeLimit = this.map.fromViewportToLatLng(oldRange);
	return rangeLimit.lng();
	
}

/**
 * Se llama a esta función cada vez que se quiere grabar un escenario que utiliza GoogleMaps. Lo que hace es recalcular
 * todos los datos de nodos, checkpoints, para pasar los pares (x',y') que indican la posición en píxels sobre la ventana
 * gráfica de los mismos, a pares (x,y) que indiquen la distancia en metros respecto a la (latitud,longitud) del vértice
 * superior izquierdo. Estos nuevos datos serán los que se graben en el fichero xml.
 * También se utiliza cuando se va a realizar un cálculo de métricas, para adaptar las posiciones a metros en lugar de a
 * píxeles.
 * */
private function saveFile_handler(event:Event):void
{
	this._modelInstance = ModelSingleton.getSingletonInstance();
	this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
		
	if(this.map.visible){
		
		if ( (this.xTranslation != 0) || (this.yTranslation != 0) || (cornerSet == true))
			undoShift ();

		var nodesArray:Array = this._modelInstance.manetNodesTableCallableProxy.getIdManetNodesArray();
		rangeBackUp = new Vector.<Number>();
		
		for (var i:int = 0; i<nodesArray.length; i++){
			
			toDistanceTrajectory(nodesArray[i]);
			
			rangeBackUp.push(this._modelInstance.manetNodesTableCallableProxy.getManetNodeRange(nodesArray[i]));
			var newRange:Number = toDistanceRange(rangeBackUp[i]);
			
			if (!this._modelInstance.manetNodesTableCallableProxy.setManetNodeRange(nodesArray[i],newRange)){
			
				Alert.show("Error while updating node range", DisplayPropertiesSingleton.APPLICATION_TITLE);
			
			}

		}
		
		var maptype:Object = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._mapType;
		var dcMode:String = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._doubleClickMode;
		var zoomLevel:int = this.map.getZoom();
		var info:GoogleInfo = new GoogleInfo(maptype,"Coordinates",
		zoomLevel,this.nwLat,this.nwLng,"",true,dcMode); 
        this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo = info;
	
	}
}

/**
 * Se llama a esta función cada vez que se quiere grabar un escenario que utiliza GoogleMaps, con formato KML. Se rellena
 * la variable string "Traces Data" con toda la info de los nodos y se lee luego en KMLScenarioParser.as
 * */
private function saveKMLorGPXFile_handler(event:Event):void
{
	try{
		
		this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
		this._modelInstance = ModelSingleton.getSingletonInstance();
		var nodesArray:Array = this._modelInstance.manetNodesTableCallableProxy.getIdManetNodesArray();
		var file:String = "";
		
		for (var i:Number = 0; i < nodesArray.length; i++){
			
			var tempMovement:Movement = this._modelInstance.manetNodesTableCallableProxy.getManetNodeFirstMovement(nodesArray[i]);
			var position:Point;
			var LatAndLng:LatLng;		
			var marca:Number;
			var line:String = "";
			var range:Number = this._modelInstance.manetNodesTableCallableProxy.getManetNodeRange(nodesArray[i]);
			range = this.toDistanceRange(range);
			
			do{
				position = new Point(tempMovement.fromTimestampPositionCheckpoint.xCoordinate,
						tempMovement.fromTimestampPositionCheckpoint.yCoordinate);
				
				LatAndLng = this.map.fromViewportToLatLng(position);
				marca = tempMovement.fromTimestampPositionCheckpoint.pointTime.time;
				
				line = nodesArray[i] + "\t" + redondear(LatAndLng.lng(),6).toString() + "\t" +
					redondear(LatAndLng.lat(),6).toString() + "\t" + marca.toString() + "\t" + range.toString() + "\r\n";
				
				file = file.concat(line);
				
				if (this._modelInstance.manetNodesTableCallableProxy.isManetNodeLastMovement(nodesArray[i],tempMovement.id)){
				
					position = new Point(tempMovement.toTimestampPositionCheckpoint.xCoordinate,
						tempMovement.toTimestampPositionCheckpoint.yCoordinate);
					LatAndLng = this.map.fromViewportToLatLng(position);
					marca = tempMovement.toTimestampPositionCheckpoint.pointTime.time;
					
					line = nodesArray[i] + "\t" + redondear(LatAndLng.lng(),6).toString() + "\t" + 
						redondear(LatAndLng.lat(),6).toString() + "\t" + marca + "\t" + range.toString();
					
					if ( i != nodesArray.length-1)
						line = line.concat("\r\n")
					
					file = file.concat(line);
					
				}
				
				tempMovement = this._modelInstance.manetNodesTableCallableProxy.getManetNodeNextMovement(nodesArray[i],tempMovement.id);
				
			}while (tempMovement!=null);
			
		}//for
		
		var lines:Array = file.split("\r\n");
		this._modelInstance.scenarioPropertiesCallableProxy.tracesData = lines;
		
	}
	catch(thrownError:Error){
		
		trace("ERROR at saveKMLFile_handler!! " + thrownError.message);
	
	}
	
}

/**
 * Función que recibe el rango de un nodo, en píxels (está habilitado Google Maps), y lo pasa a metros.
 * Se llama a esta función cuando se va a grabar el escenario.
 * */
private function toDistanceRange (cartesianRange:Number):Number
{
	var cartesian:Point = new Point(0,cartesianRange);
	var rangeLimit:LatLng = this.map.fromViewportToLatLng(cartesian);
	
	var R:Number = 6370000; // m
	
	var lat:Number = rangeLimit.lat(); //grados
	var lng:Number = rangeLimit.lng(); //grados
	
	var dLat:Number = (lat-nwLat)*Math.PI/180; //radianes
	var dLon:Number = (lng-nwLng)*Math.PI/180; //radianes
	
	var a:Number = Math.sin(dLat/2) * Math.sin(dLat/2) +
	        Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(nwLat*Math.PI/180) * Math.cos(lat*Math.PI/180); 
	var c:Number = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
	var d:Number = R * c;
	d = redondear (d,0);
	
	return d;
	
}

/**
 * Función que recibe el nombre de un nodo. Recalcula las posiciones de todos sus movimientos,
 * inicialmente en píxels (está habilitado Google Maps), y las pasa a metros.
 * Se llama a esta función cuando se va a grabar el escenario.
 * */
private function toDistanceTrajectory (nodeId:String):void{
	
	try{
		
		this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
		this._modelInstance = ModelSingleton.getSingletonInstance();
		var tempMovement:Movement = this._modelInstance.manetNodesTableCallableProxy.getManetNodeFirstMovement(nodeId);
		
		var theNodeState:NodeState = this._modelInstance.manetNodesTableCallableProxy.getManetNodeFirstState(nodeId);
		var nodeStateUpdated:Boolean = false;
		
		var oldPoint:Point;
		var newPoint:Point;

		do{
			
			oldPoint = new Point(tempMovement.fromTimestampPositionCheckpoint.xCoordinate,
					tempMovement.fromTimestampPositionCheckpoint.yCoordinate);
			newPoint = recalculatePointToDistance (oldPoint);
			
			
			this._modelInstance.manetNodesTableCallableProxy.updateManetNodeTimestampPositionCheckpoint(nodeId,
				tempMovement.toTimestampPositionCheckpoint.pointTime,
				tempMovement.fromTimestampPositionCheckpoint.pointTime,
				tempMovement.toTimestampPositionCheckpoint.pointTime,
				tempMovement.fromTimestampPositionCheckpoint.pointTime,
				newPoint.x,newPoint.y,true);
				
			if((!nodeStateUpdated)&&(theNodeState!=null)){
				
				this._modelInstance.manetNodesTableCallableProxy.updateManetNodeState(nodeId,theNodeState.switchedOn,
					theNodeState.timestamp,newPoint.x,newPoint.y);
				nodeStateUpdated = true;
				
			}
			
			var updatedMovement:Movement = this._modelInstance.manetNodesTableCallableProxy.getManetNodeMovement(nodeId,tempMovement.id);
								
			if (this._modelInstance.manetNodesTableCallableProxy.isManetNodeLastMovement(nodeId,tempMovement.id)){
			
				oldPoint = new Point(tempMovement.toTimestampPositionCheckpoint.xCoordinate,
					tempMovement.toTimestampPositionCheckpoint.yCoordinate);
				newPoint = recalculatePointToDistance (oldPoint);
				
				this._modelInstance.manetNodesTableCallableProxy.updateManetNodeTimestampPositionCheckpoint(nodeId,
					tempMovement.toTimestampPositionCheckpoint.pointTime,
					tempMovement.toTimestampPositionCheckpoint.pointTime,
					tempMovement.toTimestampPositionCheckpoint.pointTime,
					tempMovement.toTimestampPositionCheckpoint.pointTime,
					newPoint.x,newPoint.y,true);	
			
			}
			
			tempMovement = this._modelInstance.manetNodesTableCallableProxy.getManetNodeNextMovement(nodeId,tempMovement.id);
			
		}while (tempMovement!=null);
		
	}
	catch(thrownError:Error){
		
		trace("ERROR at toDistanceTrajectory!! " + thrownError.message);
	
	}

}

/**
 * Función que recibe un par (x',y') que representa en píxels la posición sobre el escenario de un checkpoint
 * (está habilitado Google Maps), y la pasa a metros. Se llama a esta función cuando se va a grabar el escenario.
 * */
private function recalculatePointToDistance (old:Point):Point
{
	var recalculated:Point= new Point(0,0);
	
	var oldLatLng:LatLng = this.map.fromViewportToLatLng(old);
	var oldLat:Number = oldLatLng.lat();
	var oldLng:Number = oldLatLng.lng();
	
	var R:Number = 6370000; //radio de la Tierra, en metros
	
	var westPoint:Point = new Point(0,old.y);
	var westPointLatLng:LatLng = this.map.fromViewportToLatLng(westPoint);
	var westPointLat:Number = westPointLatLng.lat();
	var westPointLng:Number = westPointLatLng.lng();
	var northPoint:Point = new Point(old.x,0);
	var northPointLatLng:LatLng = this.map.fromViewportToLatLng(northPoint);
	var northPointLat:Number = northPointLatLng.lat();
	var northPointLng:Number = northPointLatLng.lng();
	
	var dWLat:Number = (oldLat - westPointLat)*Math.PI/180; //en radianes
	var dWLng:Number = (oldLng - westPointLng)*Math.PI/180; //en radianes
	
	var f:Number = Math.sin(dWLat/2) * Math.sin(dWLat/2)+
		Math.sin(dWLng/2) * Math.sin(dWLng/2) * Math.cos(westPointLat*Math.PI/180) * Math.cos(oldLat*Math.PI/180);
	var g:Number = 2 * Math.atan2(Math.sqrt(f), Math.sqrt(1-f));
	recalculated.x = redondear (R * g,0);
	
	var dNLat:Number = (oldLat - northPointLat)*Math.PI/180; //en radianes
	var dNLng:Number = (oldLng - northPointLng)*Math.PI/180; //en radianes
	
	var h:Number = Math.sin(dNLat/2) * Math.sin(dNLat/2)+
		Math.sin(dNLng/2) * Math.sin(dNLng/2) * Math.cos(northPointLat*Math.PI/180) * Math.cos(oldLat*Math.PI/180);
	var i:Number = 2 * Math.atan2(Math.sqrt(h), Math.sqrt(1-h));
	recalculated.y = redondear (R * i,0);

	return recalculated;
}

/**
 * Método para redondear un número n con la cantidad de decimales que se desee. 
 * */
private function redondear(n:Number, decimales:Number):Number {
	
   var k:Number = Math.pow(10, decimales);
   return Math.round(n*k)/k;
   
}

/**
 * Se llama a esta función cuando se ha grabado un escenario. El objetivo es recalcular nuevamente toda la tabla
 * de nodos para seguir con el escenario representado igual que estaba antes de pulsar "save scenario". Se vuelven
 * a pasar todos los datos de metros a píxels.
 * También se utiliza después de realizar un cálculo de métricas, para adaptar las posiciones a píxeles en lugar de a
 * metross.
 * */
private function mapAfterSaving_handler(event:Event):void
{
	try{
		if (this.map.visible){
			this._modelInstance = ModelSingleton.getSingletonInstance();
			this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
			
			var maptype:Object = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._mapType;
			var dcMode:String = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._doubleClickMode;
			var zoomLevel:int = this.map.getZoom();
			var info:GoogleInfo = new GoogleInfo(maptype,"Coordinates",
				zoomLevel,this.seLat,this.seLng,"",true,dcMode); 
		    this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo = info;
		    
		    var nodesArray:Array = this._modelInstance.manetNodesTableCallableProxy.getIdManetNodesArray();
		    
		    for (var i:int = 0; i<rangeBackUp.length; i++){
		    	
		    	recalculateNodeTrajectory(nodesArray[i]);
				
				if (!this._modelInstance.manetNodesTableCallableProxy.setManetNodeRange(nodesArray[i],rangeBackUp[i])){
				
					Alert.show("Error while updating node range after saving", DisplayPropertiesSingleton.APPLICATION_TITLE);
				
				}
			
			this.drawManetNodeAndTrajectoriesFromModel(nodesArray[i], this._displayPropertiesInstance.scaleFactor, this._displayPropertiesInstance.checkpointSize);
			
			}
			
			var nodesAC3:ArrayCollection = this._displayPropertiesInstance.getManetNodesIdAC();
			for each (var c:String in nodesAC3)
			{	
				this.drawInstantPositionNode(c, this._displayPropertiesInstance.scaleFactor, 
					this._displayPropertiesInstance.getManetNodeCanvasTimePosReferenceVisibilityRange(c),
					this._displayPropertiesInstance.rangeAlpha);			
			}
			this.drawAsSelectedCheckpoint();
			
			redoShift();
		}//if visible
    
	}
	catch(thrownError:Error){
		
		trace("ERROR at mapAfterSaving_handler!! " + thrownError.message);
	
	}		

}

/**
 * Función para ordenar el array con los datos de entrada (cuando el formato es Traces), en función del nombre
 * de cada nodo y de las marcas de tiempo.
 * */
private function sortLines (lines:Array):Array{
	
	var arrayOrdenacion:Array = new Array(lines.length);
	var line:String;
	var lineInfo:Array;
	
	for (var i:int = 0; i < lines.length; i++){
		
		line = new String (lines[i]);
		lineInfo = line.split("\t");
		arrayOrdenacion[i] = new Array(5);
		arrayOrdenacion[i][0] = lineInfo[0];
		arrayOrdenacion[i][1] = lineInfo[3];
		arrayOrdenacion[i][2] = lineInfo[1];
		arrayOrdenacion[i][3] = lineInfo[2];
		if (lineInfo.length == 5)
			arrayOrdenacion[i][4] = lineInfo[4];
		else
			arrayOrdenacion[i][4] = 50;

	}
	
	arrayOrdenacion.sort();
	var lineaFinal:String;
	
	for (var j:int = 0; j < lines.length; j++){
		
		lineaFinal = new String(arrayOrdenacion[j][0]);
		lineaFinal = lineaFinal.concat("\t",arrayOrdenacion[j][2],"\t",arrayOrdenacion[j][3],"\t",arrayOrdenacion[j][1],
			"\t",arrayOrdenacion[j][4]);
		lines[j] = lineaFinal;
		
	}
	
	return lines;
	
}

private function undoShift ():void{
	
	try{
			
			this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
			this._modelInstance = ModelSingleton.getSingletonInstance();
			cornerSet = false;
			
			if(!shifted){					
				
				this.xTranslationForSaving = this.xTranslation;
				this.yTranslationForSaving = this.yTranslation;
			
			}			
			
			this.corner = this.map.fromViewportToLatLng(new Point(this.xTranslation,this.yTranslation));
			var deltaArea:Point = new Point(this.map.getSize().x,this.map.getSize().y);
			
			if(!shifted){
				
				resetShift = this.map.fromViewportToLatLng(new Point((this.width-4)/2,(this.height-4)/2));				
				
			}
			
			var xClicked:Number = (this.width - 4)/2;
			var yClicked:Number = (this.height - 4)/2;
			
			this.xTranslation = (this.width-4)/2-xClicked;
		    this.yTranslation = (this.height-4)/2-yClicked;
	    	this.canvasScenario.move(this.xTranslation,this.yTranslation);
	    	this.canvasGrid.move(this.xTranslation,this.yTranslation);
	    	this.canvasLinks.move(this.xTranslation,this.yTranslation);
	    	this.canvasPoppers.move(this.xTranslation,this.yTranslation);
	   
	    	var area:Point;
			if ((this.width-4 >= this.canvasScenario.width+this.xTranslation)&&
				(this.height-4 >= this.canvasScenario.height+this.yTranslation))
				area = new Point(this.width-4,this.height-4);
			else if ((this.width-4 >= this.canvasScenario.width+this.xTranslation)&&
				(this.height-4 < this.canvasScenario.height+this.yTranslation))
				area = new Point(this.width-4,this.canvasScenario.height+this.yTranslation);
			else if ((this.width-4 < this.canvasScenario.width+this.xTranslation)&&
				(this.height-4 >= this.canvasScenario.height+this.yTranslation))
				area = new Point(this.canvasScenario.width+this.xTranslation,this.height-4);
			else if ((this.width-4 < this.canvasScenario.width+this.xTranslation)&&
				(this.height-4 < this.canvasScenario.height+this.yTranslation))
				area = new Point(this.canvasScenario.width+this.xTranslation,this.canvasScenario.height+this.yTranslation);
				
			deltaArea.x = deltaArea.x - area.x;
			deltaArea.y = deltaArea.y - area.y;
			var zoom:Number = this.map.getZoom();
			var maptype:Object = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._mapType;
			var dcMode:String = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._doubleClickMode;
			
			map.setSize(area);
			this.map.setCenter(corner);
			
			cornerLat = corner.lat();
			cornerLng = corner.lng();

			var nuevoCentro:Point;
			if (!shifted)
				 nuevoCentro = new Point(area.x+deltaArea.x,area.y+deltaArea.y);
			else{				
				cornerSet = true;
				nuevoCentro = new Point(area.x+deltaArea.x/2,area.y+deltaArea.y/2);
			}
			
    		var nuevoCentroLatLng:LatLng = this.map.fromViewportToLatLng(nuevoCentro);
			var centralLat:Number = nuevoCentroLatLng.lat();
			var centralLng:Number = nuevoCentroLatLng.lng();
			var info:GoogleInfo = new GoogleInfo(maptype,"Coordinates",
				zoom,centralLat,centralLng,"",true,dcMode);	
	    	this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo = info;	
		
	}
	catch(thrownError:Error){
		
		trace("ERROR at undoShift!! " + thrownError.message);
	
	}

}


private function redoShift ():void{

	try{
			if (resetShift != null){
			
				this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
				this._modelInstance = ModelSingleton.getSingletonInstance();
								
				var xClicked:Number = (this.width-4)/2-this.xTranslationForSaving;
				var yClicked:Number = (this.height-4)/2-this.yTranslationForSaving;
				
		    	this.xTranslation = (this.width-4)/2-xClicked;
		    	this.yTranslation = (this.height-4)/2-yClicked;
		    	this.canvasScenario.move(this.xTranslation,this.yTranslation);
		    	this.canvasGrid.move(this.xTranslation,this.yTranslation);
		    	this.canvasLinks.move(this.xTranslation,this.yTranslation);
		    	this.canvasPoppers.move(this.xTranslation,this.yTranslation);
		    		    	
		    	var area:Point;
				if ((this.width-4 >= this.canvasScenario.width+this.xTranslation)&&
					(this.height-4 >= this.canvasScenario.height+this.yTranslation))
					area = new Point(this.width-4,this.height-4);
				else if ((this.width-4 >= this.canvasScenario.width+this.xTranslation)&&
					(this.height-4 < this.canvasScenario.height+this.yTranslation))
					area = new Point(this.width-4,this.canvasScenario.height+this.yTranslation);
				else if ((this.width-4 < this.canvasScenario.width+this.xTranslation)&&
					(this.height-4 >= this.canvasScenario.height+this.yTranslation))
					area = new Point(this.canvasScenario.width+this.xTranslation,this.height-4);
				else if ((this.width-4 < this.canvasScenario.width+this.xTranslation)&&
					(this.height-4 < this.canvasScenario.height+this.yTranslation))
					area = new Point(this.canvasScenario.width+this.xTranslation,this.canvasScenario.height+this.yTranslation);
				
				var zoom:Number = this.map.getZoom();
				var maptype:Object = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._mapType;	
				var dcMode:String = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._doubleClickMode;
				
				this.map.setSize(area);
				this.map.setCenter(corner);
		    	
		    	this.offsetX = this.map.fromLatLngToViewport(corner).x-this.xTranslation;
		    	this.offsetY = this.map.fromLatLngToViewport(corner).y-this.yTranslation;
		    	var nuevoCentro:Point = new Point(area.x/2+this.offsetX,area.y/2+this.offsetY);
		    	var nuevoCentroLatLng:LatLng = this.map.fromViewportToLatLng(nuevoCentro);	
		    	var centralLat:Number = nuevoCentroLatLng.lat();
				var centralLng:Number = nuevoCentroLatLng.lng();
		    	var info:GoogleInfo = new GoogleInfo(maptype,"Coordinates",
					zoom,centralLat,centralLng,"",true,dcMode);	
		    	this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo = info;
		    	
		    	distanceBetweenCenters.x = (area.x - (this.width-4))/2;
			    distanceBetweenCenters.y = (area.y - (this.height-4))/2;
			    
			    this.xTranslationForSaving = 0;
			    this.yTranslationForSaving = 0;
			    resetShift = null;
			    
				}
						    	    		
	}
	catch(thrownError:Error){
		
		trace("ERROR at redoShift!! " + thrownError.message);
	
	}

}

private function undoShiftBeforeChangingZoom ():void{
	
	try{
			
			this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
			this._modelInstance = ModelSingleton.getSingletonInstance();
			cornerSet = false;
						
			this.corner = this.map.fromViewportToLatLng(new Point(this.xTranslation,this.yTranslation));
			var deltaArea:Point = new Point(this.map.getSize().x,this.map.getSize().y);
			
			resetShift = this.map.fromViewportToLatLng(new Point((this.width-4)/2,(this.height-4)/2));
			
			var xClicked:Number = (this.width - 4)/2;
			var yClicked:Number = (this.height - 4)/2;
			
			this.xTranslation = (this.width-4)/2-xClicked;
		    this.yTranslation = (this.height-4)/2-yClicked;
	    	this.canvasScenario.move(this.xTranslation,this.yTranslation);
	    	this.canvasGrid.move(this.xTranslation,this.yTranslation);
	    	this.canvasLinks.move(this.xTranslation,this.yTranslation);
	    	this.canvasPoppers.move(this.xTranslation,this.yTranslation);
	    	
	    	var area:Point;
			if ((this.width-4 >= this.canvasScenario.width+this.xTranslation)&&
				(this.height-4 >= this.canvasScenario.height+this.yTranslation))
				area = new Point(this.width-4,this.height-4);
			else if ((this.width-4 >= this.canvasScenario.width+this.xTranslation)&&
				(this.height-4 < this.canvasScenario.height+this.yTranslation))
				area = new Point(this.width-4,this.canvasScenario.height+this.yTranslation);
			else if ((this.width-4 < this.canvasScenario.width+this.xTranslation)&&
				(this.height-4 >= this.canvasScenario.height+this.yTranslation))
				area = new Point(this.canvasScenario.width+this.xTranslation,this.height-4);
			else if ((this.width-4 < this.canvasScenario.width+this.xTranslation)&&
				(this.height-4 < this.canvasScenario.height+this.yTranslation))
				area = new Point(this.canvasScenario.width+this.xTranslation,this.canvasScenario.height+this.yTranslation);
				
			deltaArea.x = deltaArea.x - area.x;
			deltaArea.y = deltaArea.y - area.y;
			var zoom:Number = this.map.getZoom();
			var maptype:Object = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._mapType;
			var dcMode:String = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._doubleClickMode;
			
			map.setSize(area);
			this.map.setCenter(corner);
			var nuevoCentro:Point = new Point(area.x+deltaArea.x/2,area.y+deltaArea.y/2);
    		var nuevoCentroLatLng:LatLng = this.map.fromViewportToLatLng(nuevoCentro);
			var centralLat:Number = nuevoCentroLatLng.lat();
			var centralLng:Number = nuevoCentroLatLng.lng();
			var info:GoogleInfo = new GoogleInfo(maptype,"Coordinates",
				zoom,centralLat,centralLng,"",true,dcMode);	
		
	    	this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo = info;
			
	    	this.offsetX = this.distanceBetweenCenters.x;
	    	this.offsetY = this.distanceBetweenCenters.y; 	
		
	}
	catch(thrownError:Error){
		
		trace("ERROR at undoShiftBeforeChangingZoom!! " + thrownError.message);
	
	}
	
}


private function redoShiftAfterChangingZoom ():void{

	try{
			if (resetShift != null){
					
						this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
						this._modelInstance = ModelSingleton.getSingletonInstance();
						
						var xClicked:Number = (this.width-4)/2 - this.xTranslationForZoomChange;
						var yClicked:Number = (this.height-4)/2 - this.yTranslationForZoomChange;
						
				    	this.xTranslation = (this.width-4)/2-xClicked;
				    	this.yTranslation = (this.height-4)/2-yClicked;
				    	this.canvasScenario.move(this.xTranslation,this.yTranslation);
				    	this.canvasGrid.move(this.xTranslation,this.yTranslation);
				    	this.canvasLinks.move(this.xTranslation,this.yTranslation);
				    	this.canvasPoppers.move(this.xTranslation,this.yTranslation);
				    		    	
				    	var area:Point;
						if ((this.width-4 >= this.canvasScenario.width+this.xTranslation)&&
							(this.height-4 >= this.canvasScenario.height+this.yTranslation))
							area = new Point(this.width-4,this.height-4);
						else if ((this.width-4 >= this.canvasScenario.width+this.xTranslation)&&
							(this.height-4 < this.canvasScenario.height+this.yTranslation))
							area = new Point(this.width-4,this.canvasScenario.height+this.yTranslation);
						else if ((this.width-4 < this.canvasScenario.width+this.xTranslation)&&
							(this.height-4 >= this.canvasScenario.height+this.yTranslation))
							area = new Point(this.canvasScenario.width+this.xTranslation,this.height-4);
						else if ((this.width-4 < this.canvasScenario.width+this.xTranslation)&&
							(this.height-4 < this.canvasScenario.height+this.yTranslation))
							area = new Point(this.canvasScenario.width+this.xTranslation,this.canvasScenario.height+this.yTranslation);
						
						var zoom:Number = this.map.getZoom();
						var maptype:Object = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._mapType;	
						var dcMode:String = this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo._doubleClickMode;
						
						this.map.setSize(area);
						this.map.setCenter(corner);
				    	
				    	this.offsetX = this.map.fromLatLngToViewport(corner).x-this.xTranslation;
				    	this.offsetY = this.map.fromLatLngToViewport(corner).y-this.yTranslation;
				    	var nuevoCentro:Point = new Point(area.x/2+this.offsetX,area.y/2+this.offsetY);
				    	var nuevoCentroLatLng:LatLng = this.map.fromViewportToLatLng(nuevoCentro);	
				    	var centralLat:Number = nuevoCentroLatLng.lat();
						var centralLng:Number = nuevoCentroLatLng.lng();
				    	var info:GoogleInfo = new GoogleInfo(maptype,"Coordinates",
							zoom,centralLat,centralLng,"",true,dcMode);	
				    	this._modelInstance.scenarioPropertiesCallableProxy.googleMapsInfo = info;
				    	
				    	distanceBetweenCenters.x = (area.x - (this.width-4))/2;
					    distanceBetweenCenters.y = (area.y - (this.height-4))/2;
					    
					    this.xTranslationForZoomChange = 0;
					    this.yTranslationForZoomChange = 0;
					    resetShift = null;
					    
			}//resetShift		    	    	
		
		}//try
		catch(thrownError:Error){
			
			trace("ERROR at redoShift!! " + thrownError.message);
		
		}
}

private function checkConnectionEvent_handler(event:Event):void	{
	
	try{
		
		this._modelInstance = ModelSingleton.getSingletonInstance();
		
		if (this.map.isLoaded())
			this._modelInstance.scenarioPropertiesCallableProxy.connectedToInternet = true;
		
	}
	catch(thrownError:Error){
		
			trace("ERROR at checkConnectionEvent_handler!! " + thrownError.message);
		
	}
	
}

private function setGoogleMobilityValue_handler(event:Event):void{
	
	try{
		
		this._modelInstance = ModelSingleton.getSingletonInstance();
		var valorEnMetros:Number = this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue;
		var valorEnPixels:Number = this.recalculateRange(valorEnMetros);
		this._modelInstance.scenarioPropertiesCallableProxy.googleMobilityValue = valorEnPixels;
		
	}
	catch(thrownError:Error){
		
			trace("ERROR at setGoogleMobilityValue_handler!! " + thrownError.message);
		
	}
	
}	