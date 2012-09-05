void mouseClicked() {  
  // Pick the color on the mask
  color clickColor = backgroundImageMask.pixels[mouseX+mouseY*800];
  // Convert the color datatype (r,g,b) to a int, only red is used, 255 possible buttons
  int R_MASK = 255<<16;
  clickColorInt = (clickColor & R_MASK)>>16;
 
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
    case 15:
      serialSend("x");
      break;
    case 16:
      serialSend("X");
      break;
    case 17:
      serialSend("y");
      break;
    case 18:
      serialSend("Y");
      break;      
    case 19:
      serialSend("z");
      break;
    case 20:
      serialSend("Z");
      break;
    case 21:
      // piston 1 down
      serialSend("q");
      break;
    case 22:
      // piston 1 up
      serialSend("1");
      break;
    case 23:
      // piston 2 down
      serialSend("w");
      break;
    case 24:
      // piston 2 up
      serialSend("2");
      break;
    case 25:
      // reset positions
      serialSend("r");
      break;
    case 26:
      // Initial position
      serialSend("s");
      break;
    case 27:
      // New layer
      serialSend("n");
      break;
    case 28:
      // Start printing
      serialSend("p");
      break;
    case 29:
      // Abort printing
      serialSend("q");
      break;
  }
}
