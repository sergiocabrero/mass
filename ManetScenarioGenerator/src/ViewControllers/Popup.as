// ActionScript file
    
    import Classes.ModelSingleton;
    
    import mx.controls.List;
    import mx.collections.ArrayCollection;
    import mx.managers.PopUpManager;
    import mx.controls.Alert; 
	import mx.core.UIComponent; 
	
	import CalculoMetricas.PopupToMetrics;
	 
    [Bindable] public var listaInicial:ArrayCollection = new ArrayCollection();  //Lista de nodos del escenario
    [Bindable] public var listaFinal:ArrayCollection = new ArrayCollection();  //Lista de nodos para cálculo
     	
    public var targetParent:PopupToMetrics; 
	
	//Calcular
	public function finPopUp():void{ 
		
	    targetParent.setData(this.listaFinal); 
	} 
	
	//Cancelar
	public function onClose():void {
         
         if(this.isPopUp) {
         
         	PopUpManager.removePopUp(this);                    
         }  
 	}
      
    public function getListaInicial():ArrayCollection{
    	
    	return listaInicial;
    }
    
    public function getListaFinal():ArrayCollection{
    	
    	return listaFinal;
    }
    
    //Lanza pop-up
    public function doInit():void {
    	
    	PopUpManager.centerPopUp(this);
    }
  	
    private function initApp():void{
       
    	var aux:Array;
        
        var i:int;
        
		listaInicial = new ArrayCollection();    	
    	listaFinal = new ArrayCollection();
    	
     	aux=ModelSingleton.getSingletonInstance().manetNodesTableReadableProxy.getIdManetNodesArray();
    
    	for(i=0;i<aux.length;i++){
	
		 	listaInicial.addItem(aux[i]);	
		}
    }
      