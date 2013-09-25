/** Clase encargada de generar los diferentes valores aleatorios
 * requeridos para cada uno de los modelos de mobilidad
 **/

package MobilityModels
{
	public class RandomValues
	{
		public var value:Number;
		
		public function RandomValues(){}
		
		//calculo de una posicion aleatoria
		public function createRandomPosition(minPosition:int, maxPosition:int):int
		{
			return value = Math.floor(Math.random()*(maxPosition-minPosition+1))+minPosition;
		}
		
		//calculo de un color aleatorio
		public function generateRandomColor():int
		{
			return value = Math.round( Math.random()*0xFFFFFF );
		}
		
		//Calculo de direcion entre dos angulos
		public function calculateRandomDirection(minDirection:Number=0, maxDirection:Number=2):Number
		{
			return value = Math.PI*(Math.random()*(maxDirection-minDirection)+minDirection);
		}
		
		//Calculo de velocidad entre dos valores
		public function calculateRandomSpeed(minSpeed:int, maxSpeed:int):int
		{
			return value = Math.floor(Math.random()*(maxSpeed-minSpeed+1))+minSpeed;
		}
		
		//seguira de frente con una probilidad del 0.5 y girara
		//a izqda o dcha con prob de 0.25 cada una
		public function calculateRandomCrossing():Number
		{
			var dir:int = createRandomPosition(0,3);
			var direction:Number;
			switch (dir)
			{
				case 0: direction = Math.PI/2; break;
				case 1: direction = 3*Math.PI/2; break;
				default : direction = 0;
			}
			return direction;
		}
		
		//calcula un tiempo aleatorio entre un tmin y tmax
		static public function calculateRandomTime(minTime:Date,maxTime:Date):Date
		{
			var newRandomDate:Date = new Date();
			newRandomDate.time = (Math.random()*(maxTime.time-minTime.time+1))+minTime.time;	
			return newRandomDate;	
		}
	}	
}
