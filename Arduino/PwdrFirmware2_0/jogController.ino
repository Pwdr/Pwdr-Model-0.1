// Jog in X direction
void jogX(long jogDirStep){
  // Define direction, larger than 1 means clockwise
  if(jogDirStep>0){
    jogvar = stepperX.currentPosition()+abs(jogDirStep);
  } else {
    jogvar = stepperX.currentPosition()-abs(jogDirStep);
  }
  // Check wether it's allowed to take a step
  if ((jogvar >= 0) || (jogvar <= build_piston_width)){
    stepperX.runToNewPosition(jogvar); 
  } else { 
    Serial.println("jog X impossible");
  }
}

// Jog in Y direction
void jogY(long jogDirStep){
  if(jogDirStep>0){
    jogvar = stepperY.currentPosition()+abs(jogDirStep);
  } else {
    jogvar = stepperY.currentPosition()-abs(jogDirStep);
  }
  if ((jogvar >= 0) || (jogvar <= build_piston_length)){
    stepperY.runToNewPosition(jogvar); 
  } else { 
    Serial.println("jog Y impossible");
  }
}

// Jog of Z1 piston
void jogZ1(long jogDirStep){
  if(jogDirStep>0){
    jogvar = stepperZ1.currentPosition()+abs(jogDirStep);
  } else {
    jogvar = stepperZ1.currentPosition()-abs(jogDirStep);
  }
  if ((jogvar >= 0) || (jogvar <= piston_depth)){
    stepperZ1.runToNewPosition(jogvar); 
  } else { 
    Serial.println("jog Z1 impossible");
  }
}

// Jog of Z2 piston
void jogZ2(long jogDirStep){
  if(jogDirStep>0){
    jogvar = stepperZ2.currentPosition()+abs(jogDirStep);
  } else {
    jogvar = stepperZ2.currentPosition()-abs(jogDirStep);
  }
  if ((jogvar >= 0) || (jogvar <= piston_depth)){
    stepperZ2.runToNewPosition(jogvar); 
  } else { 
    Serial.println("jog Z2 impossible");
  }
}

// Combined jog in Z direction for both pistons
void jogZ(long jogDirStep){
  if(jogDirStep>0){
    jogvar = stepperZ1.currentPosition()-abs(1.5*jogDirStep);
    jogvar2 = stepperZ2.currentPosition()+abs(jogDirStep);
  } else {
    jogvar = stepperZ1.currentPosition()+abs(1.5*jogDirStep);
    jogvar2 = stepperZ2.currentPosition()-abs(jogDirStep);
  }
  if ((jogvar >= 0) || (jogvar <= piston_depth)){
    stepperZ1.moveTo(jogvar); 
    stepperZ2.moveTo(jogvar2); 
  } else { 
    Serial.println("jog Z2 impossible");
  }
  while (stepperZ1.currentPosition() != jogvar || stepperZ2.currentPosition() != jogvar2){
    stepperZ1.run();
    stepperZ2.run(); 
  }
}
