/*MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNmmmmmNMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM/     /MMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMhy.   hMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMNNNNMMMMMMMMMMMMMMMMMMMMMMNMMMMMMMNNNNNm   -MMMMMMMMMMNNNMMMMM
MMMMMMMMMy////oNh+:..-oNN/////sMMMN+///MMMMo:/oNMMdo:-.-::   yMy////oMdo:./MMMMM
MMMMMMMMM/-`   /`-:`   od--   /MMN+    MMMs   sMN+` `:++-   .NM/-`   +``..dMMMMM
MMMMMMMMMMM-   :mMMh   :MMM.  /MMo ``  MMy  `yMm-  -dMMMs   oMMMM-   .smmmMMMMMM
MMMMMMMMMMd   -NMMMh   +MMM:  /Ms  s`  Md` `yMM/  `mMMMM-  `mMMMd   .mMMMMMMMMMM
MMMMMMMMMM/   hMMMM+   dMMM/  +h` oN   m. `hMMd   /MMMMh   /MMMM:   dMMMMMMMMMMM
MMMMMMMMMm`  .NMMMy   oMMMMo  /` oMN  .: `hMMMs   sMMMd.   dMMMd   :MMMNddNMMMMM
MMMMMMMMMo   :hdh+` `oNMMMMs    +NMm    .dMMMMs   -hho..  `yyNM/   hMMd.``.hMMMM
MMMMMMMMN`    ``  ./dMMMMMMy   +NMMd   .dMMMMMN:    `:hy.```.MN```-MMMh`  `yMMMM
MMMMMMMMs   +dhyhdmMMMMMMMMNdddNMMMNdddmMMMMMMMNdyyhmNMMNmmmmMNmmmNMMMMmhhmMMMMM
MMMMMNdd.   ydMMddddddddddddddddddddddddddddddddddddddddddddddddddddddddddNMMMMM
MMMMMy``    `.Mm``````````````````````````````````````````````````````````mMMMMM
MMMMMmdddddddmMNddddddddddddddddddddddddddddddddddddddddddddddddddddddddddMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMM                                                          MMMMMMMMMMM
MMMMMMMMMMM Firmware for Pwdr three-dimensional powder based printer MMMMMMMMMMM
MMMMMMMMMMM Author: Alex Budding                                     MMMMMMMMMMM
MMMMMMMMMMM E-mail: a.budding@gstudent.utwente.nl                    MMMMMMMMMMM
MMMMMMMMMMM This software has been released under the GPL License    MMMMMMMMMMM 
MMMMMMMMMMM                                                          MMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM*/

import processing.serial.*;

Serial arduinoSerial;

PImage backgroundPrinting, backgroundConverting;
PFont myFont;

PImage source;       // Source image
PImage destination;  // Destination image
PrintWriter output;  // Output lower nozzles file
PrintWriter outputUpper; // Output upper nozzles

String tempSerial;
String inString = "";

int ttM = 432;      // text top margin
int tlM = 437;      // text left margin
int bW = 54;        // button width
int bH = 34;        // buton height
int bM = 101;       // button margin
int b2W = 155;      // button 2 width
int b2M = 10;       // button 2 margin
int mL = 123;       // margin left
int mT = 491;       // margin top
int m2T = 596;      // margin 2 top
int lW = 70;        // label width
int pW = 200;       // preprocessor left margin

String guiState = "converting";
boolean preview = false;

float threshold = 140;
int lowernozzles = 8;
int uppernozzles = 4;
int nozzles = lowernozzles+uppernozzles;


void setup(){
  
  // Load font
  myFont = loadFont("OfficinaSerif.vlw");
  textFont(myFont, 19);
  
  // Load background
  backgroundPrinting = loadImage("Pwdr-GUI-v0.2.png");
  backgroundConverting = loadImage("Pwdr-GUI-v0.2-convertState.png");
  
  // Make dummy image for the preview window
  
  size(800, 650);
  background(255,0,0);
  smooth();

  // Print all serial devices, hard code the number of the Arduino 2560 in the next section
  println(Serial.list());

  // Serial connection to the Arduino Mega 2560
  arduinoSerial = new Serial(this, Serial.list()[5], 9600);
  // Buffer the serial communication until a 'enter' is sent
  arduinoSerial.bufferUntil(10);
}

void draw() {
  if(guiState == "printing"){
    // Set the background image
    background(backgroundPrinting);
    
    // Print the serial messages in the GUI
    textAlign(CENTER);
    fill(#E5E5E5);
    text(inString, tlM+1, ttM); 
    text(inString, tlM-1, ttM); 
    fill(#333333);
    text(inString, tlM, ttM); 

  } else if(guiState == "converting"){
     background(backgroundConverting);

     if(preview == true){
       image(destination, 220, 91);
     }
   }
}

  
// Perform actions when the 'buttons' are clicked.  These are just areas on the canvas.
// When the action is sent to the Arduino via serial , the button is colored grey for a
// split moment, and in the serial monitor, the action is displayed.  
void mouseClicked(){

  if(guiState == "printing"){
      
      // Jogging X 
      if(mouseX >= mL && mouseX <= mL+bW  && mouseY>= mT && mouseY<= mT+bH){
        arduinoSerial.write('x');
        stroke(196,200,211); 
        fill(196,200,211); 
        rect(mL,mT,bW,bH);
        println("button x");
      } else if(mouseX >= mL+lW+bW && mouseX <= mL+lW+2*bW && mouseY>= mT && mouseY<= mT+bH){
        arduinoSerial.write('X');
        stroke(196,200,211); 
        fill(196,200,211); 
        rect(mL+lW+bW,mT,bW,bH);
        println("button X");
      
      // Joging Y
      } else if(mouseX >= mL+lW+bW+bM && mouseX <= mL+lW+2*bW+bM && mouseY>= mT && mouseY<= mT+bH){
        arduinoSerial.write('y');
        stroke(196,200,211); 
        fill(196,200,211); 
        rect(mL+lW+2*bW+bM,mT,bW,bH);
        println("button y");
      } else if(mouseX >= mL+2*lW+2*bW+bM && mouseX <= mL+2*lW+3*bW+bM && mouseY>= mT && mouseY<= mT+bH){
        arduinoSerial.write('Y');
        stroke(196,200,211); 
        fill(196,200,211); 
        rect(mL+2*lW+2*bW+bM,mT,bW,bH);
        println("button Y");
      
      // Jogging Z
      } else if(mouseX >= mL+2*lW+2*bW+2*bM && mouseX <= mL+2*lW+3*bW+2*bM && mouseY>= mT && mouseY<= mT+bH){
         arduinoSerial.write('z');
         stroke(196,200,211); 
         fill(196,200,211); 
         rect(mL+2*lW+2*bW+2*bM,mT,bW,bH);
         println("button z");
      } else if(mouseX >= mL+3*lW+3*bW+2*bM  && mouseX <= mL+3*lW+4*bW+2*bM && mouseY>= mT && mouseY<= mT+bH){
         arduinoSerial.write('Z');
         stroke(196,200,211); 
         fill(196,200,211); 
         rect(mL+3*lW+3*bW+2*bM,mT,bW,bH);
         println("button Z");
  
      // Reset stepper position
      } else if(mouseX >= mL  && mouseX <= mL+b2W && mouseY>= m2T && mouseY<= m2T+bH){
        arduinoSerial.write('r');
        stroke(196,200,211); 
        fill(196,200,211); 
        rect(mL,m2T,b2W,bH);
        println("reset position");  
  
      // Make a new layer
      } else if(mouseX >= mL+b2W+b2M  && mouseX <= mL+2*b2W+b2M && mouseY>= m2T && mouseY<= m2T+bH){
        arduinoSerial.write('n');
        stroke(196,200,211); 
        fill(196,200,211); 
        rect(mL+b2W+b2M,m2T,b2W,bH);
        println("make new powder layer");  
  
      // Print file
      } else if(mouseX >= mL+2*b2W+2*b2M  && mouseX <= mL+3*b2W+2*b2M && mouseY>= m2T && mouseY<= m2T+bH){
        arduinoSerial.write('p');
        stroke(196,200,211); 
        fill(196,200,211); 
        rect(mL+2*b2W+2*b2M,m2T,b2W,bH);
        println("print file");  
  
      // Abort printing
      } else if(mouseX >= mL+3*b2W+3*b2M  && mouseX <= mL+4*b2W+3*b2M && mouseY>= m2T && mouseY<= m2T+bH){
        arduinoSerial.write('q');
        guiState = "converting";
        stroke(196,200,211); 
        fill(196,200,211); 
        rect(mL+3*b2W+3*b2M,m2T,b2W,bH);
        println("abort print");      
 
      } else {
        return;
      }
    } else if (guiState == "converting"){

      // Load model...     
      if(mouseX >= mL  && mouseX <= mL+b2W && mouseY>= m2T && mouseY<= m2T+bH){
        loadModel();
        stroke(196,200,211); 
        fill(196,200,211); 
        rect(mL,m2T,b2W,bH);
        println("Load model...");  
      // Convert model
       } else if(mouseX >= mL+b2W+b2M  && mouseX <= mL+2*b2W+b2M && mouseY>= m2T && mouseY<= m2T+bH){
        convertModel();
        stroke(196,200,211); 
        fill(196,200,211); 
        rect(mL+b2W+b2M,m2T,b2W,bH);
        println("Convert model"); 
     // Send print file
      } else if(mouseX >= mL+2*b2W+2*b2M  && mouseX <= mL+3*b2W+2*b2M && mouseY>= m2T && mouseY<= m2T+bH){
        sendPrintFile();
        stroke(196,200,211); 
        fill(196,200,211); 
        rect(mL+2*b2W+2*b2M,m2T,b2W,bH);
        println("Send print file");  
     // Switch to printing interface
     } else if(mouseX >= mL+3*b2W+3*b2M  && mouseX <= mL+4*b2W+3*b2M && mouseY>= m2T && mouseY<= m2T+bH){
        guiState = "printing";
        stroke(196,200,211); 
        fill(196,200,211); 
        rect(mL+3*b2W+3*b2M,m2T,b2W,bH);
        println("Switch interface");   
     }   
   }
}

void serialEvent(Serial p) { 
  // read the string from serial
  inString = p.readString(); 
}

void loadModel(){
  // Code for a 'open file' system window  
  // Opens file chooser
  String loadPath = selectInput();  
  if (loadPath == null) {
    // If a file was not selected
    println("No file was selected...");
  } else {
    // If a file was selected, print path to file
    println(loadPath);
  }
  
  source = loadImage(loadPath);  
  // The destination image is created as a blank image the same size as the source.
  destination = createImage(source.width, source.height, RGB);
  // Make a external file inside the PwdrFirmware folder
  output = createWriter("../../Arduino/PwdrFirmware/PwdrPrintData.ino"); 
  outputUpper = createWriter("../../Arduino/PwdrFirmware/PwdrPrintDataUpper.ino"); 
  
  source.loadPixels();
  destination.loadPixels();

  for (int x = 0; x < source.width; x++) {
    for (int y = 0; y < source.height; y++ ) {
      int loc = x + y*source.width;
      // Test the brightness against the threshold
      if (brightness(source.pixels[loc]) > threshold) {
        destination.pixels[loc]  = color(255);  // White
      }  
      else {
        destination.pixels[loc]  = color(0);    // Black
      }
    }
  }

  // We changed the pixels in destination
  destination.updatePixels();

   if(source.height<source.width){
     destination.resize(398, 0);
   } else {
     destination.resize(0,398);
   }         

  preview = true;
}

void convertModel(){
  // There is a check whether the file is a multiple of 12 high, but not a fix when this isn't the case.
 if (source.height%12 != 0){
    println("Height of the image isn't a multiple of 12, please adjust size");
  } else {
    
    output.print("int printfilesize[] = {"+source.width+","+source.height/nozzles+","+source.height/nozzles*source.width+"1};\r\nPROGMEM prog_uchar printFileLower[][2000] ={{");
    // used to include "+source.width*+", but 2000 is the max size approximately the max size of the array on the Arduino. Hence the array must be declared in the Main source too,
    // it's eassier to declare the max size and give the actual dimensions of the array seperately
    
    outputUpper.print("PROGMEM prog_uchar printFileUpper[][2000] ={{");
    // Used to include "+source.width+", see previous lines
  
  
    // Steps of 12 nozzles in Y direction
    for (int y = 0; y < source.height; y=y+nozzles ) {
      if(y!=0){
        output.print("},{");
        outputUpper.print("},{");
      }
      // Step in X direction  
      for (int x = 0; x < source.width; x++) {
  
        String[] LowerStr = {""};
        String LowerStr2 = "";
        String[] UpperStr = {""};
        String UpperStr2 = "";
  
        // For every step in Y direction, sample the 12 nozzles
        for ( int i=0; i<nozzles; i++) {
          // Calculate the location in the pixel array
          int loc = x + (y+i)*source.width;
  
          if (loc < source.width*source.height) {
            if (brightness(source.pixels[loc]) > threshold) {
  
              // Write a zero when the pixel is white
              if(i<uppernozzles){
                UpperStr = append(UpperStr, "0");
              } else {
                LowerStr = append(LowerStr, "0");
                }
              } else {
              // Write a one when the pixel is black     
              if(i<uppernozzles){
                UpperStr = append(UpperStr, "1");
              } else {
                LowerStr = append(LowerStr, "1");
              }
            }
          }
        } 
        // Join the individual characters of the string and convert them to a decimal and add commas
        if(x!=0){
          output.print(", ");
          outputUpper.print(", ");
        }
        
        LowerStr2 = join(LowerStr,"");
        output.print(unbinary(LowerStr2));
  //      output.print(", ");
  
        UpperStr2 = join(UpperStr,"");
        outputUpper.print(unbinary(UpperStr2));
  //      outputUpper.print(", ");
  
      }
    }
  output.print("}};");
  outputUpper.print("}};");
    }
}

void sendPrintFile(){
  outputUpper.flush(); // Writes the remaining data to the file
  outputUpper.close(); // Finishes the file
  
  output.flush(); 
  output.close(); 
  
  open("/Applications/Arduino.app");

//  open("../../Arduino/PwdrFirmware/PwdrFirmware.ino");

}
