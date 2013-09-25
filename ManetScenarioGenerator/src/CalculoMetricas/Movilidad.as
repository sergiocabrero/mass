package CalculoMetricas
{
    import Entities.*;
    import mx.controls.Alert;
    import mx.utils.ObjectProxy;

    public class Movilidad extends ObjectProxy
    {
        [Bindable] public var g_despatial:Number;
        [Bindable] public var gm_despatial:Number;
        [Bindable] public var g_dtemporal:Number;
        [Bindable] public var gm_dtemporal:Number;
        [Bindable] public var v_relativa:Number;
        [Bindable] public var vm_relativa:Number;

        public var aux:Auxiliares;

        public function Movilidad()
        {
            aux=new Auxiliares();
        }

        /**
         *     GRADO DE DEPENDENCIA ESPACIAL
         * =========================================
         * a: coordenada x del nodo i en el tiempo t
         * b: coordenada y del nodo i en el tiempo t
         * c: coordenada x del nodo j en el tiempo t
         * d: coordenada y del nodo j en el tiempo t
        **/
        public function Despatial(a:int, b:int, c:int, d:int ):Number{

	        g_despatial=aux.DireccionRelativa(a,b,c,d)*aux.VelocidadRatio(a,b,c,d);

    	    return g_despatial;

        }

        public function GMDespatial(a:int, b:int, c:int, d:int ):Number{

        gm_despatial=aux.DireccionRelativa(a,b,c,d)*aux.VelocidadRatio(a,b,c,d);

        return g_despatial;

        }

        /**
         * GRADO DE DEPENDENCIA TEMPORAL
         * ==========================================
         * a: coordenada x del nodo i en el tiempo t1
         * b: coordenada x del nodo i en el tiempo t2
         * c: coordenada y del nodo i en el tiempo t1
         * d: coordenada y del nodo i en el tiempo t2
         **/

         public function Dtemporal(a:int, b:int, c:int, d:int ):Number
        {

            g_dtemporal=aux.DireccionRelativa(a,b,c,d)*aux.VelocidadRatio(a,b,c,d);

            return g_dtemporal;

        }

        public function GMDtemporal(a:int, b:int, c:int, d:int ):Number{

            gm_dtemporal=aux.DireccionRelativa(a,b,c,d)*aux.VelocidadRatio(a,b,c,d);

            return gm_dtemporal;

        }
        
        /**
         * VELOCIDAD RELATIVA
         * ==================================
         * a:coordenada xinicial del nodo i
         * b:coordenada yinicial del nodo i
         * c:coordenada xfinal del nodo i
         * d:coordenada yfinal del nodo i
         * e:coordenada xinicial del nodo j
         * f:coordenada yinicial del nodo j
         * g:coordenada xfinal del nodo j
         * h:coordenada yfinal del nodo j
         * i: tiempo

         **/

         public function VRelativa (a:int, b:int, c:int, d:int, e:int, f:int, g:int, h:int, i:int):Number {
			var aux1:Number;
			var aux2:Number;
			
			aux1=aux.CalculaVelocidad (a,b,c,d,i);
			aux2=aux.CalculaVelocidad (e,f,g,h,i);
			  		
			v_relativa= Math.abs(aux1-aux2);
			
			return v_relativa;
        }

        /**
         * VELOCIDAD RELATIVA MEDIA
         * ========================
         **/

        public function VMRelativa (a:int, b:int, c:int, d:int, e:int, f:int, g:int, h:int, i:int):Number {
        
         	var aux1:Number;
         	var aux2:Number;

	        aux1=aux.CalculaVelocidad (a,b,c,d,i);
         	aux2=aux.CalculaVelocidad (e,f,g,h,i);

        	vm_relativa= Math.abs(aux1-aux2);

			return vm_relativa;
        }
    }
}
