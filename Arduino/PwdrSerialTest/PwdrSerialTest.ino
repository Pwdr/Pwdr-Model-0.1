int i = 0;

void setup(){
	
	pinMode(13,OUTPUT);
	Serial.begin(9600);
	
}

void loop(){
	
	if(Serial.available()){
		char serialbutton = Serial.read();
	
		Serial.print(serialbutton);		
			
	
	} else {
		
	   digitalWrite(13,LOW);
	   delay(25);
	   digitalWrite(13,HIGH);
	   delay(25);



	}	

	
}