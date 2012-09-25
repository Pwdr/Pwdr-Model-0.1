void printFile(){
  // Switch on the LED while printing
  analogWrite(13, 255);

  // Safety measure, return carriage to 0,0 position
  homeXY();
  Serial.println("Print started"); 

  for (long z=1;z<2*printfilesize[3];z++){

    // Use layer numer in file name
     String Temp = "printdata/PwdrPrintData"+z;
    Temp = Temp +".dat";
    char __Temp[sizeof(Temp)];
    Temp.toCharArray(__Temp, sizeof(__Temp));
    
    // Always start with closing a file, inside the Z-loop
    dataFile.close();
    dataFile = SD.open(__Temp);
    
    if (!dataFile) {
      Serial.print("Error while opening "); Serial.println(__Temp);
    }

    for (long y=1; y<=printfilesize[1]; y++){  
      for (long x=1; x<=printfilesize[0]; x++){
         
         // If the button on the protoshield is pushed, the printing process is aborted.
        if (analogRead(54) == 0){
          abortPrint();
        } else {
       
          // Move steps in X direction, reverse direction from left to right
          // when the Y position is even. Meanwhile, read the SD file for printdata
          if(y % 2 && x == printfilesize[0]){
            stepperX.runToNewPosition(stepperX.currentPosition()-stepX);
            // First step of right-left Y
            dataFile.seek(dataFile.position()+2*printfilesize[2]-2);  
            lower  =  dataFile.read();
            upper =  dataFile.read();
          } else if(y % 2 && dataFile.position()>0){
            stepperX.runToNewPosition(stepperX.currentPosition()-stepX);
            // All but first stap of right-left Y, move 2 bytes to the left
            dataFile.seek(dataFile.position()-2);
            lower  =  dataFile.read();
            upper =  dataFile.read();
          } else {
            // Normal left-right Y
            lower  =  dataFile.read();
            upper =  dataFile.read();
            stepperX.runToNewPosition(stepperX.currentPosition()+stepX);
          }               
          // Fire the nozzles, as many times as prescribed
          for (int i=0; i<saturation; i++){
            spray_ink(lower,upper);
          }
        }
      }
      // When finished X, step in Y-direction
      stepperY.runToNewPosition(stepperY.currentPosition()-stepY);
    }
    
    // Print every layer twice
    if(z % 2){
      homeXY();
    } else { 
      // Message to serial to indicate layer is done and the show overall progress
      Serial.print("Layer "); Serial.print(z); Serial.print(" of "); Serial.print(piston_depth)-1; Serial.println(" printed");

      // When the complete layer is printed, a new layer of powder is deposited
      newLayer();
    }
  }
}   
