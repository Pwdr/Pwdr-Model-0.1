  int R_MASK = 255<<16;

void mouseClicked() {  
  // Pick the color on the mask
  color clickColor = backgroundImageMask.pixels[mouseX+mouseY*800];
  // Convert the color datatype (r,g,b) to a int, only red is used, 255 possible buttons
  clickColorInt = (clickColor & R_MASK)>>16;
  
  println(clickColorInt);
 
  switch(clickColorInt) {
    case 1:
      GUIstate = "converting";
      backgroundImage = loadImage("Converting.png");
      backgroundImageMask = loadImage("ConvertingMask.png");
      break;
    case 2:
      GUIstate = "connection";
      backgroundImage = loadImage("Connecting.png");
      backgroundImageMask = loadImage("ConnectingMask.png");
      break;
    case 3:
      GUIstate = "printing";
      backgroundImage = loadImage("Printing.png");
      backgroundImageMask = loadImage("PrintingMask.png");
      break;
    case 4:
      GUIstate = "settings";
      backgroundImage = loadImage("Settings.png");
      break;
    // "Converting"
    case 5:
      loadModel();
      // Opening a new file, thus reset counter
      sliceNumber = 1;
      SimpleSlice();
      break;
    // Convert model
    case 6:
      GUIstate = "converting...";
      break;
    // Save files
    case 7:
      saveFile();
      break;
    // "Connecting"
    case 8:
      println("connecting");
      selectPort = 7;
      startSerial();
      // Serial 7
      break;
    case 9:
      // Serial 1
      selectPort = 1;
      startSerial();
      break;
    case 10:
      // Serial 2
      selectPort = 2;
      startSerial();
      break;
    case 11:
      selectPort = 3;
      startSerial();
      // Serial 3
      break;
    case 12:
      selectPort = 4;
      startSerial();
      // Serial 4
      break;
    case 13:
      selectPort = 5;
      startSerial();
      // Serial 5
      break;
    case 14:
      selectPort = 6;
      startSerial();
      // Serial 6
      break;
    case 21:
      serialSend("x");
      break;
    case 22:
      serialSend("X");
      break;
    case 23:
      serialSend("y");
      break;
    case 24:
      serialSend("Y");
      break;      
    case 25:
      serialSend("z");
      break;
    case 32:
      serialSend("Z");
      break;
    case 33:
      // piston 1 down
      serialSend("q");
      break;
    case 34:
      // piston 1 up
      serialSend("1");
      break;
    case 35:
      // piston 2 down
      serialSend("w");
      break;
    case 36:
      // piston 2 up
      serialSend("2");
      break;
    case 37:
      // reset positions
      serialSend("r");
      break;
    case 38:
      // Initial position
      serialSend("s");
      break;
    case 39:
      // New layer
      serialSend("n");
      break;
    case 40:
      // Start printing
      serialSend("p");
      break;
    case 41:
      // Abort printing
      serialSend("q");
      break;
  }
}
