 // ActionScript file

	//IMPORTS

	import CalculoMetricas.Conectividad;
	import CalculoMetricas.ConstantKeys;
	import CalculoMetricas.Movilidad;
	
	import Classes.ModelSingleton;
	
	import Entities.*;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.MenuEvent;

	//DECLARACIÓN DE VARIABLES
	
	private var movilidad:Movilidad= new Movilidad(); 
	private var conectividad:Conectividad= new Conectividad();
	private var ventanaPopUp:Popup; 
	private var evt:MenuEvent;
	private var metricaSeleccionada:String;
	
	//LISTA NODOS PARA CÁLCULO	
	private var lista:ArrayCollection=new ArrayCollection();

	//VARIABLES TEMPORALES
	private var tempini:Date;
	private var tempfin:Date;
	private var tempaux:Date;
	private var milini:Number;
	private var milfin:Number;
	private var milaux:Number; 
	
	//COORDENADAS X e Y DE DIFERENTES NODOS
	private var coorX_1:int;
	private var coorX_2:int;
	private var coorX_3:int;
	private var coorY_1:int;
	private var coorY_2:int;
	private var coorY_3:int;
	private var coorX_4:int;
	private var coorY_4:int;
	
	//RESULTADOS
	private var resultado:Number=0;
	private var res:int=0;
	
	//ACUMULADORES
	private var num_itera:int=0;
 
 	//ITERADORES
	private var iterador1:int=0;
	private var iterador2:int=0;
	private var iterador3:int=0;
	private var iterador4:int=0;
	private var iterador5:int=0;
 
 	//RANGOS
	private  var rango_1:int;
	private  var rango_2:int;
	private  var rango_3:int;
   
    //FUNCIÓN: recupera los nodos seleccionados en el popup para realizar los cálculos
	public function setData(listaNodos:ArrayCollection):void{ 
		lista=listaNodos;
		PopUpManager.removePopUp(ventanaPopUp);
		ModelSingleton.getSingletonInstance().lockDispatchModelEvents(true); //FR
		ModelSingleton.getSingletonInstance().lockDispatchSaveEvent(false);//FR 
		calculaMetricas(lista);
		ModelSingleton.getSingletonInstance().lockDispatchMapAfterSavingEvent(false);//FR
	}

	//FUNCIÓN: controlador del popup menu button. Selecciona el cálculo a realizar
	public function calculaMetricas(lista:ArrayCollection):void{
		
		switch(metricaSeleccionada){
			
			case ConstantKeys.GRADO_DEPENDENCIA_ESPACIAL:{ dependenciaEspacial(lista); break;}
			case ConstantKeys.GRADO_MEDIO_DEPENDENCIA_ESPACIAL:{ mediaEspacial(lista); break;}
			case ConstantKeys.GRADO_DEPENDENCIA_TEMPORAL:{ dependenciaTemporal(lista); break;}
			case ConstantKeys.GRADO_MEDIO_DEPENDENCIA_TEMPORAL:{ mediaTemporal(lista);break;}
			case ConstantKeys.VELOCIDAD_RELATIVA:{ velocidadRelativa(lista); break;}
			case ConstantKeys.VELOCIDAD_RELATIVA_MEDIA:{ mediaVelocidad(lista); break;}
			case ConstantKeys.CAMBIOS_ENLACE:{cambiosEnlace(lista); break;}
			case ConstantKeys.PROMEDIO_CAMBIOS_ENLACE:{promedioCambios(lista); break;}
			case ConstantKeys.DURACION_ENLACE:{duracionEnlace(lista);break;}
			case ConstantKeys.PROMEDIO_DURACION_ENLACE:{mediaDuracion(lista);break;}
		}   
	}
	
	//FUNCION: cálculo de la dependencia espacial
	public function dependenciaEspacial(lista:ArrayCollection):void{
		
		try
		{	
			//resultados parciales
			var dep_espacial:Number;      
			
			//inicialización de parámetros
			num_itera=0;      
			resultado=0;
			 	         
			for(milaux=milini;milaux<milfin;milaux=milaux+1000){
			 	
				tempaux.setTime(milaux);
				
				//Coordenadas de los nodos para un instante de tiempo concreto
				coorX_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[0],tempaux).xCoordinate;
				coorY_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[0],tempaux).yCoordinate;
				coorX_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[1],tempaux).xCoordinate;
				coorY_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[1],tempaux).yCoordinate;
				
				resultado+=movilidad.Despatial(coorX_1,coorY_1,coorX_2,coorY_2);
				
				num_itera++;
			}
			
			//Recuperamos el timestamp inicial de los nodos del escenario.
			tempini.setTime(milini);
			
			ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[0],tempini).xCoordinate;
			ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[0],tempini).yCoordinate;
			ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[1],tempini).xCoordinate;
			ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[1],tempini).yCoordinate;
			
			//resultado
			dep_espacial=resultado/num_itera;
			
			Alert.show("Degree of spatial dependence: "+dep_espacial);
		}
		
		catch(err:Error)
		{
				Alert.show("ERROR: Invalid number of selected nodes.")
		}	
	}
	
	//FUNCION: cálculo del grado medio de dependencia espacial
	public function mediaEspacial(lista:ArrayCollection):void{
		
		try
		{	
			//Comprueba que pasemos más de 2 nodos
			if(lista.length>2){
				
				//Declaración de variables auxiliares
				var sum_depEspacial:Number=0;
				var mediaEspacial:Number=0;
				
				//Inicialización de parámetros
				num_itera=0;
				                     	 
				for(milaux=milini;milaux<milfin;milaux=milaux+1000){
				 	
					tempaux.setTime(milaux);
				
					for(iterador1=0; iterador1<lista.length; iterador1++ ){
					   	
					   	//Coordenadas del nodo para un instante de tiempo concreto	
						coorX_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[iterador1],tempaux).xCoordinate;
						coorY_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[iterador1],tempaux).yCoordinate;
						    
						for(iterador2=0; iterador2<lista.length; iterador2++){
							
							if(iterador1!=iterador2){
								    
								//Coordenadas del nodo para un instante de tiempo concreto
								coorX_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[iterador2],tempaux).xCoordinate;
								coorY_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[iterador2],tempaux).yCoordinate;
								  
								//Calculamos la dependencia temporal del nodo en todo el escenario
								sum_depEspacial+=movilidad.Despatial(coorX_1, coorY_1, coorX_2, coorY_2);
								
								num_itera++;
							
							}					
						}		
					}
				 }
		
				//Recuperamos el timestamp inicial de los nodos del escenario	
				tempini.setTime(milini);
				
				for (iterador3=0; iterador3<lista.length; iterador3++){					
					ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[iterador3],tempini).xCoordinate;
					ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[iterador3],tempini).yCoordinate;
				}	 
			
				//Resultado
				mediaEspacial=sum_depEspacial/num_itera;
				
				Alert.show("Average degree of spatial dependence: "+mediaEspacial);	 	
			}
			else Alert.show("ERROR: Invalid number of selected nodes.");	
			
		}
		
		catch(err:Error)
		{
						
		}	
	 		
	}
	
	//FUNCION: Grado de dependencia temporal
	public	 function dependenciaTemporal(lista:ArrayCollection):void{
		
		try
		{	
			//Variables auxiliares	
			var dep_temporal:Number;
			
			//Inicializaciones
			num_itera=0;
			resultado=0;
			
			//Coordenadas del nodo para un instante de tiempo concreto  
			coorX_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeFirstState(lista[0]).xCoordinate;
			coorY_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeFirstState(lista[0]).yCoordinate;
			
				for(milaux=milini;milaux<milfin;milaux=milaux+1000){
				 
					tempaux.setTime(milaux);
					
					//Coordenadas del nodo para un instante de tiempo concreto   
					coorX_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[0],tempaux).xCoordinate;
					coorY_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[0],tempaux).yCoordinate;
					
					resultado+= movilidad.Dtemporal(coorX_1,coorY_1,coorX_2,coorY_2);
				  
				num_itera++;
				}
			
			//Recuperamos el timestamp inicial de los nodos del escenario.			
			tempini.setTime(milini);
			
			ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[0],tempini).xCoordinate;
			ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[0],tempini).yCoordinate;
	
			//Resultado			
			dep_temporal=resultado/num_itera;
			
			Alert.show("Degree of temporal dependence: " + dep_temporal);
		}
		
		catch(err:Error)
		{
			Alert.show("ERROR: Invalid number of selected nodes.")
		}	
	}
	
	//FUNCION: Calcula grado medio de dependencia temporal
	public	 function mediaTemporal(lista:ArrayCollection):void{
		
		try
		{	
			//comprobamos que haya más de 2 nodos
			if (lista.length>2){
				
				//Variables auxiliares
				var sum_depTemporal:Number=0;
				var mediaTemporal:Number=0;
				
				//Inicialización
				num_itera=0;
				  
					for(iterador1=0; iterador1<lista.length; iterador1++ ){
								 	  
						for(milaux=milini;milaux<milfin;milaux=milaux+1000){
						 
							tempaux.setTime(milaux);
							    
							//Coordenadas del nodo para un instante de tiempo concreto
							coorX_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeFirstState(lista[iterador1]).xCoordinate;
							coorY_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeFirstState(lista[iterador1]).yCoordinate;
							coorX_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[iterador1],tempaux).xCoordinate;
							coorY_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[iterador1],tempaux).yCoordinate;
							  
							//Calculamos la dependencia temporal del nodo en todo el escenario
							sum_depTemporal+= movilidad.Dtemporal(coorX_1,coorY_1,coorX_2,coorY_2);
							    	
							num_itera++;	
						}		  		       	            	            		        
					}
			
					//Recuperamos el timestamp inicial de los nodos del escenario.
							
					for (iterador2=0; iterador2<lista.length; iterador2++){
					
					tempini.setTime(milini);
							
					ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[iterador2],tempini);
					}
					   
				//Resultado			
				mediaTemporal=sum_depTemporal/num_itera;
				   
				Alert.show ("Average degree of spatial dependence: "+mediaTemporal);
			}
			else Alert.show ("ERROR: Invalid number of selected nodes.");
		}
		catch(err:Error)
		{
			
		}	
	   
	}
	
	//FUNCION: Cálculo de la velocidad relativa
	public	 function velocidadRelativa(lista:ArrayCollection):void{
		
		try
		{	
			// Parámetros auxiliares
			var velocidadRelativa:Number=0;
			var segundos:int;
			var minutos:int;
			var horas:int;
			var aux1:int;
			var aux2:int;
			var tiempofinal:int;
			
			//Inicialización		
			num_itera=0;
			
			//Coordenadas de los nodos para un instante de tiempo concreto
			coorX_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeFirstTimestampPositionCheckpoint(lista[0]).xCoordinate;
			coorY_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeFirstTimestampPositionCheckpoint(lista[0]).yCoordinate;
			coorX_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeLastTimestampPositionCheckpoint(lista[0]).xCoordinate;
			coorY_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeLastTimestampPositionCheckpoint(lista[0]).yCoordinate;
			coorX_3=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeFirstTimestampPositionCheckpoint(lista[1]).xCoordinate;
			coorY_3=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeFirstTimestampPositionCheckpoint(lista[1]).yCoordinate;
			coorX_4=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeLastTimestampPositionCheckpoint(lista[1]).xCoordinate;
			coorY_4=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeLastTimestampPositionCheckpoint(lista[1]).yCoordinate;
			
			//Obtenemos el tiempo
			segundos=tempfin.seconds;
			minutos=tempfin.minutes;
			horas=tempfin.hours;
			  
			aux1=horas*60*60;
			aux2=minutos*60;
			  
			tiempofinal= (aux1+aux2+segundos);
			
			//Recuperamos el timestamp inicial de los nodos del escenario.
			tempini.setTime(milini);
			
			ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[0],tempini).xCoordinate;
			ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[0],tempini).yCoordinate;
			ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[1],tempini).xCoordinate;
			ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[1],tempini).yCoordinate;
			
			//Resultado
			velocidadRelativa = movilidad.VRelativa(coorX_1,coorY_1,coorX_2,coorY_2,coorX_3,coorY_3,coorX_4,coorY_4,tiempofinal);
			
			Alert.show ("Relative speed: "+velocidadRelativa);
	 	} 
	    
	    catch(err:Error)
		{
			Alert.show("ERROR: Invalid number of selected nodes.")
		}	   	
	}
 
	public	 function mediaVelocidad(lista:ArrayCollection):void{
		
		try
		{
			if (lista.length>2){
			
				//Declaración de parámetros auxiliares
				var sumVelocidad:Number=0;
				var velocidadRelativaMedia:Number=0;
				var segs:int;
				var mins:int;
				var hors:int;
				var auxiliar1:int;
				var auxiliar2:int;
				var tfinal:int;
				
				//Inicialización
				num_itera=0;
				
				//Obtenemos el tiempo 
				segs=tempfin.seconds;
				mins=tempfin.minutes;
				hors=tempfin.hours;
				auxiliar1=hors*60*60;
				auxiliar2=mins*60;
				tfinal= (auxiliar1+auxiliar2+segs);           
					 
					for(iterador1=0; iterador1<lista.length; iterador1++ ){
					   
					   //Coordenadas de los nodos para un instante de tiempo concreto
						coorX_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeFirstTimestampPositionCheckpoint(lista[iterador1]).xCoordinate;
						coorY_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeFirstTimestampPositionCheckpoint(lista[iterador1]).yCoordinate;
						coorX_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeLastTimestampPositionCheckpoint(lista[iterador1]).xCoordinate;
						coorY_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeLastTimestampPositionCheckpoint(lista[iterador1]).yCoordinate;
						
						for(iterador2=0; iterador2 <lista.length; iterador2++ ){
						 
						 	//Coordenadas de los nodos para un instante de tiempo concreto			 	
							coorX_3=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeFirstTimestampPositionCheckpoint(lista[iterador2]).xCoordinate;
							coorY_3=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeFirstTimestampPositionCheckpoint(lista[iterador2]).yCoordinate;
							coorX_4=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeLastTimestampPositionCheckpoint(lista[iterador2]).xCoordinate;
							coorY_4=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeLastTimestampPositionCheckpoint(lista[iterador2]).yCoordinate;
							
							sumVelocidad +=  movilidad.VRelativa(coorX_1,coorY_1, coorX_2, coorY_2, coorX_3, coorY_3, coorX_4, coorY_4,tfinal);
							  
							num_itera++;	
						}   	            		        
					}
			
				//Recuperamos el timestamp inicial de los nodos del escenario.		
				tempini.setTime(milini);
							
				for (iterador3=0; iterador3<lista.length; iterador3++){
										
					ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[iterador3],tempini).xCoordinate;
					ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[iterador3],tempini).yCoordinate;
				}	
				
				//Resultado								       	
				velocidadRelativaMedia=sumVelocidad/num_itera;
				       	
				Alert.show ("Average relative speed: "+velocidadRelativaMedia);
			}
			
			else Alert.show ("ERROR: Invalid number of selected nodes.");
		
		}
				
		catch(err:Error)
		{
			
		}	
		       		    			
	}
	
	//FUNCION: Numero de cambios de enlace
	public	function cambiosEnlace(lista:ArrayCollection):void{
		
		try
		{
			//Variables auxiliares
			var numEnlaces:int=0;
			var vector:Array=new Array();
			var iter:int=0;
			var fin:int=0;
			
			//Inicialización
			num_itera=0;
			res=0;
			  
			for(milaux=milini;milaux<milfin;milaux=milaux+1000){
			 
				tempaux.setTime(milaux);
				
				//Coordenadas de los nodos para un instante de tiempo concreto
				coorX_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[0],tempaux).xCoordinate;
				coorY_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[0],tempaux).yCoordinate;
				coorX_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[1],tempaux).xCoordinate;
				coorY_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[1],tempaux).yCoordinate;
				rango_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNode(lista[0]).range;
				rango_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNode(lista[1]).range;			    
						
				res=conectividad.NCEnlace(coorX_1,coorY_1,coorX_2,coorY_2,rango_1,rango_2);
				
				vector[fin]=res;
				  
				fin++;
			}
			
			//Recuperamos el timestamp inicial de los nodos del escenario.
			tempini.setTime(milini);
			
			ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[0],tempini).xCoordinate;
			ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[0],tempini).yCoordinate;
			ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[1],tempini).xCoordinate;
			ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[1],tempini).yCoordinate;
			
			for(iterador1=0; iterador1<fin; iterador1++){
				
				//Resultado
				if((vector[iterador1]==0)&&(vector[iterador1+1]==1)) numEnlaces++; 	     	    
			}
			    
			Alert.show("Number of link changes: "+numEnlaces);
		}
		catch(err:Error)
		{
			Alert.show("ERROR: Invalid number of selected nodes.");
		}	               
	       	                     	          
	}                
	
	//FUNCION: calcula la media de cambios de enlace
	public	function promedioCambios(lista:ArrayCollection):void{
	
		try
		{
			//Comprueba que el número de nodos sea superior a 2	
			if (lista.length>2){
		 
		 		//Declaración de variables auxiliares
				var pc_Enlace:Number=0;
				var sumaEnlace:int=0;
				var vectorAux:Array=new Array();
				var ultimo:int=0;
			
				//Inicialización 	
				num_itera=0;
				res=0;
				
				for(milaux=milini;milaux<milfin;milaux=milaux+1000){
					
					tempaux.setTime(milaux);
					
					for(iterador1=0; iterador1<lista.length; iterador1++ ){
						   		
					coorX_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[iterador1],tempaux).xCoordinate;
					coorY_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[iterador1],tempaux).yCoordinate;
					rango_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNode(lista[iterador1]).range;
							 	  
						for(iterador2=iterador1+1; iterador2<lista.length; iterador2++){
						
								//Coordenadas del nodo para un instante de tiempo concreto
								coorX_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[iterador2],tempaux).xCoordinate;
								coorY_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[iterador2],tempaux).yCoordinate;
								rango_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNode(lista[iterador2]).range;			    
								
								//Calculamos la dependencia temporal del nodo en todo el escenario
								res= conectividad.PNCEnlace(coorX_1, coorY_1, coorX_2, coorY_2, rango_1, rango_2);
								vectorAux[ultimo]=res;
								ultimo++;
							}
							
						num_itera++;	
						}
						
					}
				
				//Recuperamos el timestamp inicial de los nodos del escenario.	
				tempini.setTime(milini);
				
				for (iterador3=0; iterador3<lista.length; iterador3++){
											
						ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[iterador3],tempini).xCoordinate;
						ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[iterador3],tempini).yCoordinate;
		
				}	
			      
				for(iterador4=0; iterador4<ultimo; iterador4++){
				 
					if((vectorAux[iterador4]==0)&&(vectorAux[iterador4+1]==1)) sumaEnlace++; 	
				     
				}
				   
				//Resultado
				pc_Enlace=sumaEnlace/num_itera;
				    
				Alert.show("Average number of link changes: "+pc_Enlace);
			}
			else Alert.show ("ERROR: Invalid number of selected nodes.");     
		}
		catch(err:Error)
		{
			
		}	               	
	}
	
	public	function duracionEnlace(lista:ArrayCollection):void{
		
		try
		{   
			//Declaración de variables auxiliares        
			var n_enlaces:int=0;        
			var duracion_max:int=0;                     
			var v_aux:Array=new Array();
			var v_aux2:Array=new Array();
			var end:int=0;
			
			//Inicialización de parámetros
			num_itera=0;
			resultado=0;
			                          
			for(milaux=milini;milaux<milfin;milaux=milaux+1000){
			 
				tempaux.setTime(milaux);
				
				//Coordenadas de los nodos para un instante de tiempo concreto
				coorX_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[0],tempaux).xCoordinate;
				coorY_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[0],tempaux).yCoordinate;
				coorX_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[1],tempaux).xCoordinate;
				coorY_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[1],tempaux).yCoordinate;
				rango_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNode(lista[0]).range;
				rango_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNode(lista[1]).range;		    
								
				resultado=conectividad.NCEnlace(coorX_1,coorY_1,coorX_2,coorY_2,rango_1,rango_2);
				v_aux[end]=resultado;       
				num_itera++;
				end++;
			}
			
			//Recuperamos el timestamp inicial de los nodos del escenario.
			tempini.setTime(milini);
										
			ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[0],tempini).xCoordinate;
			ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[0],tempini).yCoordinate;
			ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[1],tempini).xCoordinate;
			ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[1],tempini).yCoordinate;	
						     	  	        
			for(iterador1=0; iterador1<v_aux.length; iterador1++){
				
				if(v_aux[iterador1]==0)	v_aux2[iterador1]=v_aux[iterador1];    							
				
				if (v_aux[iterador1+1]==1)v_aux2[iterador1+1]=v_aux2[iterador1]+1;
				
			}
							           	    
			for(iterador2=0;iterador2<v_aux2.length;iterador2++){
				
				if (v_aux2[iterador2] > duracion_max) duracion_max = v_aux2[iterador2];
				
			}
			
			//Resultado
			Alert.show("Link duration: "+duracion_max);
		}
			
		catch(err:Error)
		{
			 Alert.show ("ERROR: Invalid number of selected nodes."); 
		}	   
	}
	
	//FUNCION: cálculo de la duración media de enlace
	public	function mediaDuracion(lista:ArrayCollection):void{
		
		try
		{	
			//Comprueba que el número de nodos sea superior a 2
			if (lista.length>2){
				
				//Declaración de variables auxiliares
				var dm_Enlace:Number=0;
				var max_duracion:int=0;
				var vector_aux1:Array=new Array();
				var vector_aux2:Array=new Array();
				var recorre:int=0;
				
				//Inicialización de parámetros	
				num_itera=0;        
				res=0;
				
				for(milaux=milini;milaux<milfin;milaux=milaux+1000){
						 
					tempaux.setTime(milaux);
					
					for(iterador1=0; iterador1<lista.length; iterador1++ ){
					   	
					   	//Coordenadas del nodo para un instante de tiempo concreto
						coorX_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[iterador1],tempaux).xCoordinate;
						coorY_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[iterador1],tempaux).yCoordinate;
						rango_1=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNode(lista[iterador1]).range;
									 	  
						for(iterador2=iterador1+1; iterador2<lista.length; iterador2++){
						 
							//Coordenadas del nodo para un instante de tiempo concreto
							coorX_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[iterador2],tempaux).xCoordinate;
							coorY_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[iterador2],tempaux).yCoordinate;
							rango_2=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNode(lista[iterador2]).range;			    
							
							//Calculamos la dependencia temporal del nodo en todo el escenario
							res= conectividad.DMEnlace(coorX_1, coorY_1, coorX_2, coorY_2, rango_1, rango_2);
							vector_aux1[recorre]=res;				    								    	
							recorre++;
								    					    
							}
						}		
					num_itera++;   		
				}
				
				//Recuperamos el timestamp inicial de los nodos del escenario.
				tempini.setTime(milini);
				
				for (iterador3=0; iterador3<lista.length; iterador3++){
											
						ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[iterador3],tempini).xCoordinate;
						ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getManetNodeEstimatedTimestampPositionCheckpoint(lista[iterador3],tempini).yCoordinate;
				}	
			   
				for(iterador4=0; iterador4<vector_aux1.length; iterador4++){
							
					if(vector_aux1[iterador4]==0) vector_aux2[iterador4]=vector_aux1[iterador4];   			
											
					else if (vector_aux1[iterador4]==1){
					
						vector_aux2[iterador4]=vector_aux1[iterador4];
								
						if (vector_aux1[iterador4 + 1]==1) vector_aux2[iterador4 + 1]= vector_aux2[iterador4]+1;
					}   	
				}
				    			           	    
				for(iterador5=0;iterador5<vector_aux2.length;iterador5++){
				
					if (vector_aux2[iterador5] > max_duracion) max_duracion = vector_aux2[iterador5];
				      
				}
			
				dm_Enlace=max_duracion/num_itera;
				
				//Resultado
				Alert.show("Average link duration: "+dm_Enlace);    
			}
			else Alert.show("ERROR: Invalid number of selected nodes.");
		}
		catch(err:Error)
		{
			
		}   
	}
	
	//FUNCIÓN: inicializa las variables temporales y lanza la ventana auxiliar de cálculo.
	public function itemClickHandler(evt:MenuEvent):void {
		try
		{	
		  	metricaSeleccionada=evt.label; 
			                               
			tempini=ModelSingleton.getSingletonInstance().scenarioPropertiesCallableProxy.initTime;
			tempaux=ModelSingleton.getSingletonInstance().scenarioPropertiesCallableProxy.initTime;
			tempfin=ModelSingleton.getSingletonInstance().scenarioPropertiesCallableProxy.endTime; 
			  
			milini=tempini.getTime().valueOf();
			milfin=tempfin.getTime().valueOf();
			milaux=tempini.getTime().valueOf();
			 
			ventanaPopUp = new Popup(); 
			ventanaPopUp.targetParent = this as PopupToMetrics;
			PopUpManager.addPopUp(ventanaPopUp,this, true); 
			//PopUpManager.centerPopUp(ventanaPopUp); FR 
			ventanaPopUp.title="CALCULATE METRICS";
			ventanaPopUp.setStyle("borderAlpha",0.9);
			//ventanaPopUp.screen.x=120; FR
			
		}
		catch(err:Error)
		{
				Alert.show("ERROR: The current scenario does not have nodes for calculation.")
		}
	}
