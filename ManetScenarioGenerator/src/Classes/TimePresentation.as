package Classes
{
	import mx.formatters.DateFormatter;
	
	
	public class TimePresentation
	{
		
		[Bindable]public var p_time:Number;
		[Bindable]public var s_time:String;
		
		public function TimePresentation()
		{
		}

		
		static public function transformTimeToDigits(seconds:Number):String
		{
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "JJ:NN:SS";
			var theDate:Date = new Date(0,0,0,0,0,seconds,0); 
			return dateFormatter.format(theDate);
		
		}

		static public function transformTimeToDigits2(mseconds:Number):String
		{
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "JJ:NN:SS";
			
			var theDate:Date;
			if (mseconds == 0)
			{
				theDate = new Date(0,0,0,0,0,0, mseconds);
			} 
			else
			{
				theDate = new Date(mseconds);
			}
			return dateFormatter.format(theDate);
								
		}

		
		static public function fillTimeDigits(n_hours:int, n_minutes:int, n_seconds:int):String
		{
			var s_minutes:String = "00";
			var s_seconds:String = "00";
			
			if (n_minutes<10)
			{
				s_minutes = "0" + n_minutes.toString();
			}
			else
			{
				s_minutes = n_minutes.toString();
			}
			if (n_seconds<10)
			{
				s_seconds = "0" + n_seconds.toString();
			}
			else
			{
				s_seconds = n_seconds.toString();
			}
			return n_hours.toString() + ":" + s_minutes + ":" + s_seconds;			
		}
	}
}