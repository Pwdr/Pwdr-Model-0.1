String[] comList;
int selectPort;
boolean serialSet = false;
Serial myPort;

String serialString = "Choose the correct Arduino COM port...";

void startSerial(){
  myPort = new Serial(this, comList[selectPort], 9600);
  serialSet = true;
  serialString = "Serial port #"+selectPort+" connected";
}

void serialEvent(Serial p) { 
  // read the string from serial
  serialString = p.readString(); 
}

void serialSend(String serialTemp){
  if (serialSet){
    myPort.write(serialTemp);
  } else { 
    serialString = "Arduino not connected";
  }
}

