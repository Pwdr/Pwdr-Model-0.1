String[] comList;
int selectPort;
boolean serialSet = false;
Serial arduinoSerial;

String serialString = "Choose the correct Arduino COM port...";

void startSerial(){
  arduinoSerial = new Serial(this, Serial.list()[selectPort], 9600);
  arduinoSerial.bufferUntil(10);
  serialSet = true;
  serialString = "Serial port #"+selectPort+" connected";
}

void serialEvent(Serial p) { 
  // read the string from serial
  serialString = p.readString(); 
}

void serialSend(String serialTemp){
  
  println(serialTemp);
  
  if (serialSet){
    arduinoSerial.write(serialTemp);
  } else { 
    serialString = "Arduino not connected";
  }
}

