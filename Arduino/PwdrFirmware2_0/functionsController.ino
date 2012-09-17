
void make_new_powder_layer(){
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
  // Return carriage to (0,-14000)
  stepperY.runToNewPosition(-distance_roller_nozzle);
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
