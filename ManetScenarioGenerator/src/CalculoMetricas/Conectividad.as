package CalculoMetricas
{
	import Entities.*;
	import mx.controls.Alert;
	import mx.utils.ObjectProxy;

	public class Conectividad extends ObjectProxy
    {
    
        [Bindable] public var nc_enlace:Number;
        [Bindable] public var pnc_enlace:Number;
        [Bindable] public var d_enlace:Number;
        [Bindable] public var dm_enlace:Number;
       

        public var aux:Auxiliares;

        public function Conectividad()
        {
            aux=new Auxiliares();
        }

        /**
         * NUMERO DE CAMBIOS DE ENLACE
         * =========================================
         * a: coordenada x del nodo i en el tiempo t
         * b: coordenada y del nodo i en el tiempo t
         * c: coordenada x del nodo j en el tiempo t
         * d: coordenada y del nodo j en el tiempo t
         * e: rango del nodo i
         * f: rango del nodo j
        **/
    
        public function NCEnlace(a:int, b:int, c:int, d:int, e:int, f:int):Number{
									
			 nc_enlace=aux.CompruebaEnlace(a,b,c,d,e,f);
			
			 return nc_enlace;
        }
        
         /**
         * PROMEDIO NUMERO DE CAMBIOS DE ENLACE
         * =========================================
         * a1: coordenada x del nodo i en el tiempo t
         * b1: coordenada y del nodo i en el tiempo t
         * c1: coordenada x del nodo j en el tiempo t
         * d1: coordenada y del nodo j en el tiempo t
         * e1: rango del nodo i
         * f1: rango del nodo j
        **/
        
        public function PNCEnlace(a,b,c,d,e,f):Number {
        	
			pnc_enlace=aux.CompruebaEnlace(a,b,c,d,e,f);

			return pnc_enlace ;
        }

         /**
         * DURACION DE ENLACE
         * =========================================
         * a: coordenada x del nodo i en el tiempo t
         * b: coordenada y del nodo i en el tiempo t
         * c: coordenada x del nodo j en el tiempo t
         * d: coordenada y del nodo j en el tiempo t
         * e: rango del nodo i
         * f: rango del nodo j
        **/
    
        public function DEnlace(a,b,c,d,e,f):Number{

   			d_enlace=aux.CompruebaEnlace(a,b,c,d,e,f);

			return d_enlace;
		
        }

         /**
         * DURACIÓN MEDIA DE ENLACE
         * =========================================
         * a: coordenada x del nodo i en el tiempo t
         * b: coordenada y del nodo i en el tiempo t
         * c: coordenada x del nodo j en el tiempo t
         * d: coordenada y del nodo j en el tiempo t
         * e: rango del nodo i
         * f: rango del nodo j
        **/
        public function DMEnlace(a,b,c,d,e,f):Number {
        	
			dm_enlace=aux.CompruebaEnlace(a,b,c,d,e,f);

			return dm_enlace;
        }

    }
}