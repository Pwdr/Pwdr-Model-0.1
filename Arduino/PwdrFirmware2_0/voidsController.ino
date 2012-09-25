// Deposit new powder layer
void newLayer(){
  // In case the X is not at zero
  stepperX.runToNewPosition(0);
  // Lower the powder bin to prevent powder from scooping
  jogZ1(2*jogStepZ);
  //Jog Y to the end of the powder bin
  stepperY.runToNewPosition(-build_piston_end_stop);
  // And move the powder bin back again
  jogZ1(-2*jogStepZ);
  // Move both pistons simultaniously
  jogZ(stepZ);
   // Spread the powder over the piston, roller rotate with constant spee   
  stepperY.moveTo(0);
  // Let the roller rotate untill 
  while (stepperY.currentPosition() != 0){
    stepperR.runSpeed();
    stepperY.run();
  }
  // Return carriage to starting position
  homeXY();
}

// Reset the positions of the steppers. This acts as a margin
// for the printer, making it possible to fill the pistons with
// powder and stopping the 
void resetStepperPositions(){
  stepperX.setCurrentPosition(0);
  stepperY.setCurrentPosition(-distance_roller_nozzle);
  stepperZ1.setCurrentPosition(0);
  stepperZ2.setCurrentPosition(0);
  Serial.println("Stepper counters reset");  
}

void homeXY(){
  // Return the XY-carriage to 0,0
  stepperX.moveTo(0); 
  stepperY.moveTo(-distance_roller_nozzle); 

  while (stepperY.currentPosition() != -distance_roller_nozzle || stepperX.currentPosition() != 0) {
    stepperX.run();
    stepperY.run();
  }
  Serial.println("Carriage homing");
}

void spray_ink( byte lower_nozzles, byte upper_nozzles) {
  //lower_nozzles = 1-8  - PORTA
  for(int i = 0; i <= 7; i++){
    byte mask = 1<<i;
    if(lower_nozzles & mask){
      PORTA |= mask; delayMicroseconds(5);
      PORTA &= ~mask; delayMicroseconds(1);
    }
  } 
  //upper_nozzles = 9-12 - PORTC using pins 4,5,6,7 so 4-7 not 0-3
  for(int i = 4; i <= 7; i++){
    byte mask = 1<<i;
    if(upper_nozzles<<3 & mask){
      PORTC |= mask; delayMicroseconds(5);
      PORTC &= ~mask; delayMicroseconds(1);
    }
  }
  //wait to be sure we don't try to fire nozzles to fast and burn them out
  delayMicroseconds(500); 
}

void abortPrint() {
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
