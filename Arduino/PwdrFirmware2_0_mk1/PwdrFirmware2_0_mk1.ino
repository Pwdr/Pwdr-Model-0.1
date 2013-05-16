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
 MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
 MMMMMMMMMMM                                                          MMMMMMMMMMM
 MMMMMMMMMMM Software for Pwdr three-dimensional powder based printer MMMMMMMMMMM
 MMMMMMMMMMM Author: Alex Budding                                     MMMMMMMMMMM
 MMMMMMMMMMM E-mail: pwdr@wetterhorn.nl                               MMMMMMMMMMM
 MMMMMMMMMMM                                                          MMMMMMMMMMM
 MMMMMMMMMMM This software released under the GNU/GPL license         MMMMMMMMMMM 
 MMMMMMMMMMM                                                          MMMMMMMMMMM
 MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
 MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM*/

/////////////////////////////////////////////////////////////////////////////////
// The void spray_ink() is adapted from DIY Inkjet Printer Firmware written by //
// Nicholas C Lewis (2011), see thingiverse.com/thing:8542                     //
/////////////////////////////////////////////////////////////////////////////////

// Inlcude libraries for stepper motor [http://www.open.com.au/mikem/arduino/AccelStepper]
#include <AccelStepper.h>
#include <SD.h> 

// How many times a single spot is printed
int saturation = 1;

// Declare: print width, length (rows of 12 nozzles), height and saturation
int pwdrconfig[] = {480,40,40,15};

// Bytes for the nozzle control
byte lower = B00000000;
byte upper = B0000;

// SD card information
File dataFile;
int chipSelect = 53;

// Initilize stepper driver, 11 Direction and 12 Step
AccelStepper stepperR(1, 37, 36);
AccelStepper stepperX(1, 39, 38);
AccelStepper stepperY(1, 41, 40);
AccelStepper stepperZ2(1, 43, 42);
AccelStepper stepperZ1(1, 45, 44);


// Stepper speed and accelaration
float stepperMaxSpeed = 20000.0;
float stepper_R_MaxSpeed = 22000.0;
float stepperMaxAccelaration = 1000000.0;

// Size of steps for stepper motors
const int stepX = 21;       // 0.09433962264 mm  per step (5*9.6mm*PI/1600)
const int stepY = 500;      // 0.09433962264 mm  per step (5*9.6mm*PI/1600)
const int stepZ = 120;      // 0.1mm per full stap (10*0.01)

// Size of steps when jogging
const int jogStepY = 1000;
const int jogStepX = 500;
const int jogStepZ = 250;

// Size of machine in steps. Type long because number of steps > int (2^15)
const long build_piston_width = 11000/stepX;       //2000/stepX  total width: 14800
const long build_piston_length = 28000/stepY;      // total length 76000
const long distance_roller_nozzle = 30000;      
const long piston_depth = pwdrconfig[3];        // The depth of the part is defined by the preprocessor
const long build_piston_end_stop = 76000;          // Absolute end of the machine

// Variable for positioning
long jogvar = 0;
long jogvar2 = 0;

void setup(){  

  // Push button
  pinMode(0, INPUT); 
  // LED
  pinMode(13, OUTPUT);
  // Pull up transistor
  pinMode(21, OUTPUT);
  // SPI
  pinMode(53, OUTPUT);

  // Initilize the ink pins (22 to 33) and stepper pins (36-45)
  for (int i=22; i<=45; i++) {
    pinMode(i, OUTPUT);
  } 

  // Start serial communication, baud rate 9600
  Serial.begin(9600);

  // Initialise stepper motors
  stepperX.setMaxSpeed(stepperMaxSpeed);
  stepperX.setAcceleration(stepperMaxAccelaration);
  stepperY.setMaxSpeed(stepperMaxSpeed);
  stepperY.setAcceleration(stepperMaxAccelaration);
  stepperZ1.setMaxSpeed(stepperMaxSpeed);
  stepperZ1.setAcceleration(stepperMaxAccelaration);
  stepperZ2.setMaxSpeed(stepperMaxSpeed);
  stepperZ2.setAcceleration(stepperMaxAccelaration);
  stepperR.setMaxSpeed(stepperMaxSpeed);
  stepperR.setAcceleration(stepper_R_MaxSpeed);
  // Set the speeed for compactin the powder (- for right direction)
  stepperR.setSpeed(stepper_R_MaxSpeed); 

  // Return the carriage to 0,-14000 position, first set the Y to -14000
  stepperY.setCurrentPosition(distance_roller_nozzle);
  homeXY();
  
  if (!SD.begin(chipSelect)) {
    Serial.println("initialization SD failed!");
    delay(2000);
    return;
  }
  Serial.println("initialization SD done.");
  
  Serial.println("Printer ready");
  Serial.println("-- SAFE TO CONNECT POWER --"); 
}

void loop(){

  if (Serial.available()){
    char serialbutton = Serial.read();
    if (serialbutton == 'p'){        
      printFile();
    } else if(serialbutton == 'x'){
      jogX(-jogStepX);
      Serial.print("Position X: "); Serial.println(stepperX.currentPosition());
      // Forward x-axis
    } else if(serialbutton == 'X'){
      jogX(jogStepX);
      Serial.print("Position X: "); Serial.println(stepperX.currentPosition());
      // Backward y-axis
    } else if(serialbutton == 'y'){
      jogY(-jogStepY);
      Serial.print("Position Y: "); Serial.println(stepperY.currentPosition());
      // Forward y-axis
    } else if(serialbutton == 'Y'){
      jogY(jogStepY);
      Serial.print("Position Y: "); Serial.println(stepperY.currentPosition());
      // Backward z-axis
    } else if(serialbutton == 'z'){
      jogZ(-jogStepZ);
      Serial.println("Jog down done");
      // Forward z-axis
    } else if(serialbutton == 'Z'){
      jogZ(jogStepY);
      Serial.println("Jog bins up done");
      // Home the carriage
    } else if(serialbutton == '1'){
      jogZ1(-jogStepZ);
      Serial.print("Position Z1: "); Serial.println(stepperZ1.currentPosition());
    } else if(serialbutton == 'q'){
      jogZ1(jogStepZ);
      Serial.print("Position Z1: "); Serial.println(stepperZ1.currentPosition());
    } else if(serialbutton == '2'){
      jogZ2(-jogStepZ);
      Serial.print("Position Z2: "); Serial.println(stepperZ2.currentPosition());
    } else if(serialbutton == 'w'){
      jogZ2(jogStepZ);
      Serial.print("Position Z2: "); Serial.println(stepperZ2.currentPosition());
    } else if(serialbutton == 'h'){
      homeXY();
    } else if(serialbutton == 'r'){
      resetStepperPositions();
      Serial.println("Stepper counters reset");
      // Make a new powder layer
    } else if(serialbutton == 'n'){
      newLayer();
      Serial.println("New powder layer deposited");
    } else if(serialbutton == 's'){
      jogY(-distance_roller_nozzle);
      jogX(-4000);
      resetStepperPositions();
      Serial.println("Nozzle at start position");
    } else if(serialbutton == 'R'){
      stepperR.runToNewPosition(stepperR.currentPosition()+5000);
      Serial.println("Roller");
    } else if(serialbutton == 'E'){
      stepperY.runToNewPosition(-build_piston_end_stop+stepY);
      Serial.println("Carriage near end of piston");
    } else {
      Serial.println("Unknown command"); 
    }
  }  

  // Blink the LED to show the Arduino is idle
  digitalWrite(13,HIGH);
  delay(300);
  digitalWrite(13,LOW);
  delay(300);
}


