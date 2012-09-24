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
 MMMMMMMMMMM Software for Pwdr three-dimensional powder based printer MMMMMMMMMMM
 MMMMMMMMMMM Author: Alex Budding                                     MMMMMMMMMMM
 MMMMMMMMMMM E-mail: pwdr@wetterhorn.nl                               MMMMMMMMMMM
 MMMMMMMMMMM                                                          MMMMMMMMMMM
 MMMMMMMMMMM This software released under the GNU/GPL license         MMMMMMMMMMM 
 MMMMMMMMMMM                                                          MMMMMMMMMMM
 MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
 MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM*/

/////////////////////////////////////////////////////////////////////////////////
// The void spray_ink is adapted from DIY Inkjet Printer Firmware written by 
// Nicholas C Lewis (2011), see thingiverse.com/thing:8542
/////////////////////////////////////////////////////////////////////////////////

// Inlcude libraries for stepper motor [http://www.open.com.au/mikem/arduino/AccelStepper]
#include <AccelStepper.h>
#include <SD.h> 

// How many times a single spot is printed
const int saturation = 15;

// Bytes for the nozzle control
byte lower = B00000000;
byte upper = B0000;

// Define the size of the file that stores the print information,
// stored as follows: 
// width, height/#nozzles, number of elements per row (height/nozzles*width)
// This information is stored in the seperate file called printdata.ino
extern int printfilesize[];
extern prog_uchar printFileLower[][2000];
extern prog_uchar printFileUpper[][2000];

File dataFile;
#define BUFFER_SIZE 512;
int chipSelect = 4;

// Initilize stepper driver, 11 Direction and 12 Step
AccelStepper stepperX(1, 53, 52);  
AccelStepper stepperZ2(1, 47, 46);
AccelStepper stepperY(1, 49, 48);
AccelStepper stepperZ1(1, 51, 50);
// Watch out, this one is wired different!
AccelStepper stepperR(1, 44, 45);

// Stepper speed and accelaration
float stepperMaxSpeed = 20000.0;
float stepper_R_MaxSpeed = 22000.0;
float stepperMaxAccelaration = 1000000.0;

// Size of steps for stepper motors
const int stepX = 21;    // 0.09433962264 mm  per step (5*9.6mm*PI/1600)
const int stepY = 500;      // 0.09433962264 mm  per step (5*9.6mm*PI/1600)
const int stepZ = 120;      // 0.1mm per full stap (10*0.01)

// Size of steps when jogging
const int jogStepY = 1000;
const int jogStepX = 500;
const int jogStepZ = 250;

// Size of machine in steps. Type long because number of steps > int (2^15)
const long build_piston_width = 11000/stepX;    //2000/stepX;         // total width: 14800
const long build_piston_length = 28000/stepY;   // total length 76000
const long distance_roller_nozzle = 20000;      
const long piston_depth = printfilesize[3];     // The depth of the part is defined by the preprocessor
const long build_piston_end_stop = 76000;          // Absolute end of the machine

// Variable for positioning
long jogvar = 0;
long jogvar2 = 0;

void setup(){  

  // Initialize Onboard LED and extra button
  pinMode(5, INPUT); 
  pinMode(13, OUTPUT);

  // Initilize the ink pins (22 to 33) and stepper pins (44-53)
  for (int i=22; i<=53; i++) {
    pinMode(i, OUTPUT);
  } 

  // Reset the ports for the printer nozzles
  PORTA = B00000000;
  PORTC = B00000000;

  if (!SD.begin(chipSelect)) {
    Serial.println("initialization SD failed!");
    return;
  }
  Serial.println("initialization SD done.");

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
  stepperR.setSpeed(-stepper_R_MaxSpeed);   

  // Return the carriage to 0,-14000 position, first set the Y to -14000
  stepperY.setCurrentPosition(-distance_roller_nozzle);
  homeXY();

  Serial.println("Printer ready");
  Serial.println("-- SAFE TO CONNECT POWER --");     
}

void loop(){

  if (Serial.available()){
    char serialbutton = Serial.read();

    if (serialbutton == 'p'){        
 
      // Switch on the LED
      analogWrite(13, 255);

      // Safety measure, return carriage to 0,0 position
      homeXY();

      Serial.println("Print started"); 

      for (long z=1;z<2*piston_depth;z++){

        
// Use layer numer in file name
 String Temp = "printdata/PrintDataSlice"+z;
Temp = Temp +".txt";
char __Temp[sizeof(Temp)];
Temp.toCharArray(__Temp, sizeof(__Temp));

dataFile.close();
dataFile = SD.open(__Temp);

if (dataFile) {
    
} 
else {
  Serial.print("Error while opening file");
  Serial.println(__Temp);
}


        for (long y=1; y<=printfilesize[1]; y++){    //build_piston_length; y++){

          for (long x=1; x<=printfilesize[0]; x++){  //build_piston_width

            // Move steps in X direction, reverse direction from left to right
            // when the Y position is even.
            if(y % 2){
              stepperX.runToNewPosition(stepperX.currentPosition()-stepX);
            } 
            else {
              stepperX.runToNewPosition(stepperX.currentPosition()+stepX);
            }

            // If the button on the protoshield is pushed, the printing process is aborted.
            if (analogRead(54) == 0){
              // Reset the ports for the printer nozzles, prevent destroying the nozzles
              PORTA = B00000000;
              PORTC = B00000000;      
              Serial.println("Printing aborted");
              delay(1000);
              Serial.println("Please disconnect power and reset Arduino");
              // Hence breaking all the loops would demand for a couple of extra statements, it's
              // eassier and less resource demanding to put the Arduino controller in a infinite loop
              while(1) { 
              }

            } 
            else {

              for (int i=0; i<saturation; i++){   
                // Fire the nozzles, as many times as prescribed
                // Read the print files stored in the flash memory
                
while (dataFile.position()<dataFile.size()-1) {
  byte lower = dataFile.read();
  byte upper = dataFile.read();
}

                if(y % 2){
                  lower  =  pgm_read_byte_near(&printFileLower[y-1][x-1]);
                  upper =  pgm_read_byte_near(&printFileUpper[y-1][x-1]);
                } 
                else {
                  lower  =  pgm_read_byte_near(&printFileLower[y-1][printfilesize[0]-(x-1)]);
                  upper =  pgm_read_byte_near(&printFileUpper[y-1][printfilesize[0]-(x-1)]); 
                }               
                spray_ink(lower,upper);
              }
            }
          }

          stepperY.runToNewPosition(stepperY.currentPosition()-stepY);

        }

        if(z % 2){
          homeXY();
        } 
        else { 
          // Message to serial to indicate layer is done and the show overall progress
          Serial.print("Layer "); 
          Serial.print(z); 
          Serial.print(" of "); 
          Serial.print(piston_depth)-1; 
          Serial.println(" printed");

          // When the complete layer is printed, a new layer of powder is deposited
          make_new_powder_layer();
        }
      }   

      // Handle all other incoming communication

      // Backward x-axis
    } 
    else if(serialbutton == 'x'){
      jogX(-jogStepX);
      //          Serial.println("Jog -X done");
      Serial.println(stepperX.currentPosition());
      // Forward x-axis
    } 
    else if(serialbutton == 'X'){
      jogX(jogStepX);
      //          Serial.println("Jog X+ done");
      Serial.println(stepperX.currentPosition());
      // Backward y-axis
    } 
    else if(serialbutton == 'y'){
      jogY(-jogStepY);
      Serial.println(stepperY.currentPosition());
      //      Serial.println("Jog -Y done");
      // Forward y-axis
    } 
    else if(serialbutton == 'Y'){
      jogY(jogStepY);
      Serial.println(stepperY.currentPosition());
      //      Serial.println("Jog Y+ done");
      // Backward z-axis
    } 
    else if(serialbutton == 'z'){
      jogZ(-jogStepZ);
      Serial.println("Jog -Z done");
      // Forward z-axis
    } 
    else if(serialbutton == 'Z'){
      jogZ(jogStepY);
      Serial.println("Jog Z+ done");
      // Home the carriage
    }  
    else if(serialbutton == '1'){
      jogZ1(-jogStepZ);
      Serial.println("Jog Z1+ done");
    } 
    else if(serialbutton == 'q'){
      jogZ1(jogStepZ);
      Serial.println("Jog Z1- done");
    } 
    else if(serialbutton == '2'){
      jogZ2(-jogStepZ);
      Serial.println("Jog Z2+ done");
    } 
    else if(serialbutton == 'w'){
      jogZ2(jogStepZ);
      Serial.println("Jog Z2+ done");
    } 
    else if(serialbutton == 'h'){
      homeXY();
      // Reset the stepper counters
    } 
    else if(serialbutton == 'r'){
      resetStepperPositions();
      Serial.println("Stepper counters reset");
      // Make a new powder layer
    } 
    else if(serialbutton == 'n'){
      make_new_powder_layer();
      Serial.println("New powder layer deposited");
    } 
    else if(serialbutton == 's'){
      jogY(-distance_roller_nozzle);
      jogX(-6000);
      resetStepperPositions();
      Serial.println("Nozzle at start position");
    } 
    else if(serialbutton == 'R'){
      stepperR.runToNewPosition(stepperR.currentPosition()+5000);
      Serial.println("Roller");
    }
    else if(serialbutton == 'E'){
      stepperY.runToNewPosition(-build_piston_end_stop+stepY);
      Serial.println("Carriage near end of piston");
    }  
    else {
      Serial.println("Unknown command"); 
    }
  }  

  // Blink the LED to show the Arduino is idle
  digitalWrite(13,HIGH);
  delay(18);
  digitalWrite(13,LOW);
  delay(18);
}


