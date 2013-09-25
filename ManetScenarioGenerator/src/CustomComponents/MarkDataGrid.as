package CustomComponents
{
	import flash.display.Sprite;
	import mx.collections.ArrayCollection;
	import mx.controls.DataGrid;
	
	public class MarkDataGrid extends DataGrid
	{
		/**
		 * sobreescribimos el método drawRowBackground para que muestre en un color distinto
		 * los elementos con el atributo oculo a falso
		 * */
		override protected function drawRowBackground(s:Sprite,rowIndex:int,y:Number,height:Number,color:uint,dataIndex:int):void  
        {  
			//Creamos un arrayCollection dp que le pasaremos el contenido del dataProvider del Grid en cuestión [el mismo.]	        
        	var dp:ArrayCollection = dataProvider as ArrayCollection;
        	//Una variable objet para almacenar temporalmente el contenido de la fila
			var item:Object;
            /*Aqui le añado el contenido de la fila actual a item SI el dataIndex
            [indice de la fila actual] es menor que el largo del arrayCollection dp 
            que es la copia del dataProvider. 
            (el # de filas de un datagrid no es = al numero de elementos del dataProvider!)*/              
			if( dataIndex < dp.length ) item = dp.getItemAt(dataIndex);
         	
         	if( item != null && item.access == true)
         	{
         		color = 0x94c02a;
         	}
         	else if (item != null && item.access == false)
         	{         	
         		color = 0xF9D273;
         	}
       	
         	/*Aquí invocamos al metodo drawRowBackground de la superclase... 
         	(dataGrid)... dentro de los parámetros que se le pasa..*/
         	super.drawRowBackground(s,rowIndex,y,height,color,dataIndex);  
         } 
 	 }
}

