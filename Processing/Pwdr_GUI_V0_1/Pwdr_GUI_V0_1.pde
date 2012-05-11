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

PImage b;
PFont myFont;

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

void setup(){
  
  // Load font
  myFont = loadFont("OfficinaSerif.vlw");
  textFont(myFont, 19);
  
  // Load background
  b = loadImage("Pwdr-GUI-v0.1.png");
  size(800, 650);
  background(255,0,0);
  smooth();

  // Print all serial devices, hard code the number of the Arduino 2560 in the next section
  println(Serial.list());

  // Serial connection to the Arduino Mega 2560
  arduinoSerial = new Serial(this, Serial.list()[0], 9600);
  // Buffer the serial communication until a 'enter' is sent
  arduinoSerial.bufferUntil(10);
}

void draw() {
  
  // Set the background image
  background(b);
  
  // Print the serial messages in the GUI
  textAlign(CENTER);
  fill(#E5E5E5);
  text(inString, tlM+1, ttM); 
  text(inString, tlM-1, ttM); 
  fill(#333333);
  text(inString, tlM, ttM); 
 }
  
// Perform actions when the 'buttons' are clicked.  These are just areas on the canvas.
// When the action is sent to the Arduino via serial , the button is colored grey for a
// split moment, and in the serial monitor, the action is displayed.  
void mouseClicked(){
       
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
      stroke(196,200,211); 
      fill(196,200,211); 
      rect(mL+3*b2W+3*b2M,m2T,b2W,bH);
      println("abort print");      
      

    } else {
      return;
    }
    
}

void serialEvent(Serial p) { 
  // read the string from serial
  inString = p.readString(); 
}
