// ActionScript file
 import CalculoMetricas.Conectividad;
 
import Classes.ModelSingleton;
 
import Entities.*;
 
import mx.controls.Alert;
import mx.events.MenuEvent;

  public function itemClickHandler(evt:MenuEvent):void {
  	
  	var conectividad:Conectividad;
     conectividad = new Conectividad();
            
     var tiempoini:Date;
     var tiempofin:Date;
     var tiempoaux:Date;
     var msegni:Number;
     var msegfin:Number;
     var msegaux:Number; 
                         
     tiempoini=ModelSingleton.getSingletonInstance().scenarioPropertiesCallableProxy.initTime;
     tiempoaux=ModelSingleton.getSingletonInstance().scenarioPropertiesCallableProxy.initTime;
     tiempofin=ModelSingleton.getSingletonInstance().scenarioPropertiesCallableProxy.endTime; 
          
     msegini=tiempoini.getTime().valueOf();
	 msegfin=tiempofin.getTime().valueOf();
	 msegaux=tiempoini.getTime().valueOf();
	 
	 		function cambiosEnlace():void{
			 
			  var iniX_1:int;
	          var iniY_1:int;
	          var iniX_2:int;
	          var iniY_2:int;
	          var rango1:int;
	          var rango2:int;
                          
              var comprobador:int;            
              var numEnlaces:Number=0; //despatial
              var vector:Array=new Array();
            
              var iter:int=0;
              var fin:int=0;
              			 	  
	  		 rango1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNode("1").range;
			 rango2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNode("4").range;	
			 	
				 for(milaux=milini;milaux<milfin;milaux=milaux+1000){
				 	
					milaux=tempaux.setTime(milaux);
				    
				   	iniX_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint("1",tempaux).xCoordinate;
					iniY_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint("1",tempaux).yCoordinate;
					iniX_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint("4",tempaux).xCoordinate;
					iniY_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint("4",tempaux).yCoordinate;
					
					comprobador=conectividad.NCEnlace(iniX_1,iniY_1,iniX_2,iniY_2,rango1,rango2);	
			 	  
			 	  	vector[fin]=comprobador;
          		
           			fin++;
				
				 }
				 
				 
				   for(iter=0; iter<vector.length; iter++){
           	    
		           	    if((vector[iter]==0)&&(vector[iter+1]==1)) numEnlaces++; 	
		           	         	    
		           	   	else numEnlaces=numEnlaces+0;
	           	   	
	           	   	}
	           	    
				Alert.show("Numero de cambios de enlace: "+vector);
	  		 
	  		 
	  		 
		}
		 switch(evt.label){
			
			case"NUMERO DE CAMBIOS DEL ENLACE":{cambiosEnlace(); break;}
	  		case"PROMEDIO DE NUMERO DE CAMBIOS DEL ENLACE":{promedioCambios(); break;}
	  		case"DURACION DEL ENLACE":{duracionEnlace();break;}
	  		case"DURACION MEDIA DEL ENLACE":{mediaDuracion();break;}
		 }
  }