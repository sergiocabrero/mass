package Classes
{
  	public class StringUtils
 	 {
   		 public static function generateRandomString(newLength:uint = 1, userAlphabet:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"):String
   		 {
	      	var alphabet:Array = userAlphabet.split("");
	      	var alphabetLength:int = alphabet.length;
	      	var randomLetters:String = "";
	      	for (var i:uint = 0; i < newLength; i++)
	      	{
				randomLetters += alphabet[int(Math.floor(Math.random() * alphabetLength))];
	      	}
     		return randomLetters;
   		 }
   		 
   		 //Devuelve un entero entre 0 y 9 calculado a partir de un string
   		 public static function convertStringToInt(theString:String):int
   		 {
   		 	if (theString == "")
   		 	{
   		 		return 0;
   		 	}
   		 	var sum:Number = 0;
   		 	for (var i:int=0; i<theString.length; i++)
   		 	{
   		 		sum = sum + theString.charCodeAt(i);
   		 	}
   		 	if (sum < 10)
   		 	{
   		 		return int(Math.floor(sum));
   		 	}
   		 	else
   		 	{
   		 		return int(Math.floor(sum%10));
   		 	}
   		 }

   		 //Devuelve un entero entre 0 y 9 calculado a partir de un string
   		 public static function convertStringToHex(theString:String):uint
   		 {
   		 	
   			var digitsArray:Array = [ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' ];
 		 	var partHex1:String = "00";
 		 	var partHex2:String = "00";
 		 	var partHex3:String = "00";
   		 	var sum1:Number = 0;
   		 	var sum2:Number = 0;
   		 	var sum3:Number = 0;
   		 	
   		 	if (theString == "")
   		 	{
   		 		
   		 	}
   		 	
   		 	for (var i:int=0; i<theString.length; i++)
   		 	{
   		 		sum1 = sum1 + 33*theString.charCodeAt(i);
   		 	}
		    if( sum1 > 255 ){
		    	sum1 = sum1%256;
		    }

   		 	for (var j:int=0; j<theString.length; j++)
   		 	{
   		 		sum2 = sum2 + Math.floor(17*Math.sqrt(theString.charCodeAt(j)));
   		 	}
		    if( sum2 > 255 ){
		    	sum2 = sum2%256;
		    }	
		    
   		 	for (var h:int=0; h<theString.length; h++)
   		 	{
   		 		sum3 = sum3 + Math.ceil(2*Math.pow(theString.charCodeAt(h), 2));
   		 	}
		    if( sum3 > 255 ){
		    	sum3 = sum3%256;
		    }		    	    
		    
		    //Ahora ya tenemos en sum un entero entre 0 y 255
		    
		    var l1:int = sum1 / 16;
		    var r1:int = sum1 % 16;
		    
		    var l2:int = sum2 / 16;
		    var r2:int = sum2 % 16;
		    
		    var l3:int = sum3 / 16;
		    var r3:int = sum3 % 16;		    		    
		    
		    partHex1 = digitsArray[l1] + digitsArray[r1];
		    partHex2 = digitsArray[l2] + digitsArray[r2];
		    partHex3 = digitsArray[l3] + digitsArray[r3];
		     
		    var totalHexString:String = "0x" + partHex1 + partHex2 + partHex3;
		    var totalHex:uint = uint(totalHexString);

		    return totalHex;
    
    
   		 }   		 
 	 }
}