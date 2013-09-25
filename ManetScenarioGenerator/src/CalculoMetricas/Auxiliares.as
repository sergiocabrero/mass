package CalculoMetricas
{
 	import mx.controls.Alert;
 	
    public class Auxiliares{
	
	    [Bindable] public var aceleracion:Number;
	    [Bindable] public var angulo:Number;
	    [Bindable] public var distancia:int;
	    [Bindable] public var maximo:Number;
	    [Bindable] public var minimo:Number;
	    [Bindable] public var modulo:Number;
	    [Bindable] public var res:Number;
	    [Bindable] public var dr:Number;
	    [Bindable] public var num_azar:Number;
	    [Bindable] public var vr:Number;
	    [Bindable] public var espacio:Number;
	    [Bindable] public var velocidad:Number;
	    [Bindable] public var compruebaEnlace:Number;
	
	
	    public function Auxiliares()
	        {
	        }
	        
	    /**FUNCION CALCULA ACELERACION
	     *========================================
	     *a: coordenada x del nodo i en el tiempo1
	     *b: coordenada y del nodo i en el tiempo1
	     *c: tiempo1
	     *d: coordenada x del nodo i en el tiempo2
	     *e: coordenada y del nodo i en el tiempo2
	     *f: tiempo2
	     * */
	    
	    public function CalculaAceleracion (a:int , b:int, c:int, d:int, e:int ):Number {
	
			var tiempo:int;
			var espacio:int;
			var velocidad:int;
	
			tiempo=d-c;
			espacio=CalculaDistancia(a,b,d,e);
	
			velocidad=espacio/tiempo;
			aceleracion=velocidad/tiempo;
	
			return aceleracion;
	
	    	}
	
	    /**FUNCION CALCULA DISTANCIA
	     *=========================
	     *a: coordenada x inicial
	     *b: coordenada y inicial
	     *c: coordenada x final
	     *d: coordenada y final
	     * */
	    
	    public function CalculaDistancia(a:int, b:int, c:int, d:int):Number {
	    
			var aux1:Number;
			var aux2:Number;
			
			aux1=c-a;
			aux2=d-b;
			
			espacio=CalculaModulo(aux1, aux2);
			
			return espacio;
	        
	        }
	
	    /**FUNCION CALCULA ANGULO
	     *======================
	     *a: coordenada x
	     *b: coordenada y
	     * */
	    
	    public function CalculaAngulo (a:Number, b:int ):Number {
	
			var auxiliar:Number;
			var modulo:Number;
			
			modulo=CalculaModulo(a,b);
			
			angulo= Math.acos(a/modulo)* 180/Math.PI;
			
			return angulo;
	
	   		}
	    
	    /**CALCULA VELOCIDAD
	    ===================================
	     *a: coordenada x del nodo i en el t1
	     *b: coordenada y del nodo i en el t1
	     *c: t1
	     *d: coordenada x del nodo j en el t2
	     *e: coordenada y del nodo j en el t2
	     *f: t2
	     * */
	    
	    public function CalculaVelocidad(a:Number, b:int, c:int, d:int, e:int ):Number {
	
			var distancia:Number;
			
			distancia=CalculaDistancia(a,b,c,d);
			
			velocidad=distancia/e;
			
			return velocidad;
	
	        }
	
	    /**FUNCION CALCULA MAXIMO
	     *======================
	     *a: numero 1
	     *b: numero 2
	     * */
	
	    public function CalculaMaximo (a:Number, b:Number ):Number {
	
			maximo=Math.max(a,b);
	
			return maximo;
	
	    	}
	
	    /**FUNCION CALCULA MINIMO
	     *======================
	     *a: numero 1
	     *b: numero 2
	     * */
	    
	    public function CalculaMinimo (a:Number, b:Number ):Number {
	
			minimo=Math.min(a,b);
	
	        return minimo;
	
		    }
	
	    /**FUNCION CALCULA MODULO
	     *======================
	     *a: numero 1
	     *b: numero 2^
	     */
	
	    public function CalculaModulo (a:int , b:int ):Number{
	
	        var auxiliar:Number;
	
	        auxiliar=Math.pow(a, 2)+Math.pow(b, 2);
	
	        modulo=CalculaRaiz(auxiliar);
	
	        return modulo;
		
		    }
	
	    /**FUNCION CALCULA RAIZ
	     *======================
	     *a: numero
	     * */
	    
	    public function CalculaRaiz(a:int):Number {
	
	        res= Math.sqrt(a);
	
	        return res;
	
		    }
	
	    /**FUNCION DIRECCION RELATIVA
	     *==========================
	     *a: coordenada x inicial
	     *b: coordenada y inicial
	     *c: coordenada x final
	     *d: coordenada y final
	     * */
	    
	    public function DireccionRelativa(a:int, b:int, c:int, d:int ):Number {
	
			var numerador:Number;
			var denominador:Number;
			var auxiliar1:Number;
			var auxiliar2:Number;
			
			numerador= ((a*c)+(b*d));
			
			auxiliar1=CalculaModulo(a,b);
			auxiliar2=CalculaModulo(c,d);
			
			denominador=auxiliar1*auxiliar2;
			
			dr=numerador/denominador;
			
			return dr;
	
	        }
	
	    //FUNCION CALCULA NUMERO ALEATORIO
	
	    public function RandomNumber():Number {
	
			num_azar=Math.random();
			
			return num_azar;
	
	       }
	
	    /**FUNCION CALCULA VELOCIDAD RATIO
	     *===============================
	     *a: coordenada x inicial
	     *b: coordenada y inicial
	     *c: coordenada x final
	     *d: coordenada y final
	     * */
	
	    public function VelocidadRatio(a:int, b:int, c:int, d:int ):Number {
	
			var modulo1:Number;
			var modulo2:Number;
			var minimo:Number;
			var maximo:Number;
			
			modulo1=CalculaModulo(a,b);
			modulo2=CalculaModulo(c,d);
			
			minimo=CalculaMinimo(modulo1,modulo2);
			maximo=CalculaMaximo(modulo1,modulo2);
			
			vr=minimo/maximo;
			
			return vr;
	        }
	        
	    /**FUNCION COMPRUEBA ENLACE
	     * a: coordenada x del nodo i en el tiempo t
	     * b: coordenada y del nodo i en el tiempo t
	     * c: coordenada x del nodo j en el tiempo t
	     * d: coordenada y del nodo j en el tiempo t
	     * e: rango del nodo i
	     * f: rango del nodo j
	     * */
	
		public function CompruebaEnlace (a:int, b:int, c:int, d:int, e:int, f:int):Number{
	   	
			var distancia:int=0;
			var compruebaEnlace:int=0;
	
			//Calculamos la distancia entre los nodos
			distancia=CalculaDistancia(a,b,c,d);
				
			//Comprobamos que la distancia sea menor que el rango 1 y rango 2 para que
			//exista bidireccionalidad
					
			if ((distancia < e) && (distancia < f))compruebaEnlace=1;
			
			else if ((distancia > e) && (distancia < f)) compruebaEnlace=0;
						
			else if ((distancia < e) && (distancia > f)) compruebaEnlace=0;
					
			else compruebaEnlace=0;
						
			return compruebaEnlace;
		
	    }
	}
}



