void printFile(){
  // Switch on the LED while printing
  analogWrite(13, 255);
  digitalWrite(21, HIGH);

  // Safety measure, return carriage to 0,0 position
  homeXY();
  Serial.println("Print started");
 
  // Read config file for print size
  dataFile.close();    
  dataFile = SD.open("PWDR/PWDRCONF.TXT");
  
  if (!dataFile) {
    Serial.println("Error while opening printer config, stop and repair.");
    while(1);
    digitalWrite(21, LOW);
  } else {
    Serial.println("Reading file printer config");
  }
 
  int index = 0;
  int index2 = 0;
  char buffer[5];
 
  while (dataFile.available()) {
    int temp = dataFile.read();
    // Convert the CSV file in individual int's
    if (temp != ','){
      buffer[index++] = temp;
    } else {
     pwdrconfig[index2] = atoi(buffer);
     memset(buffer, 0, sizeof(buffer));
     index = 0;
     index2++;
    }
  }

  int zTemp = 0;

  for (int z=3;z<2*pwdrconfig[2]+1;z++){
    
    if (z%2) {
      zTemp = (z/2);      
    } else if ((z%2) == 0){
      zTemp = (z/2)-1;
    }
   
    // Use layer numer in file name   
    char filename[] = "PWDR/PWDR0000.DAT";
    // Add leading zeros
    filename[12] += char(zTemp%10);   
    if (zTemp >= 10){
      filename[11] += char((zTemp/10)%10);
    } if (zTemp >= 100){
      filename[10] += char((zTemp/100)%10);
    } if (zTemp >= 1000){
      filename[9] += char((zTemp/1000)%10);
    }
    
    // Increase saturation for first 4 layers
    if (zTemp < 4){
      saturation = 1.5 * pwdrconfig[3];
    } else {
      saturation = pwdrconfig[3];
    }
    
    // Always start with closing a file, inside the Z-loop
    dataFile.close();    
    dataFile = SD.open(filename);
    
    if (!dataFile) {
      Serial.print("Error while opening "); Serial.println(filename);
    } else {
      Serial.print("Reading file  "); Serial.println(filename);
    }

    for (long y=1; y<=pwdrconfig[1]; y++){  
      for (long x=1; x<=pwdrconfig[0]; x++){
         
         // If the button on the protoshield is pushed, the printing process is aborted.
        if (analogRead(54) == 0){
          abortPrint();
        } else {

          // Move steps in X direction, reverse direction from left to right
          // when the Y position is even. Meanwhile, read the SD file for printdata
          if(y % 2){
            stepperX.runToNewPosition(stepperX.currentPosition()-stepX);
            // All but first stap of right-left Y, move 2 bytes to the left
            lower  =  dataFile.read();
            upper =  dataFile.read();
          } else if ((y % 2) == 0) { // Prevent mis-step
            // Normal left-right Y
            lower  =  dataFile.read();
            upper =  dataFile.read();
            stepperX.runToNewPosition(stepperX.currentPosition()+stepX);
          }               
          // Fire the nozzles, as many times as prescribed
          if (lower != 0 && upper !=0){
            for (int i=0; i<saturation; i++){
              spray_ink(lower,upper);
            }
          } else {
            delayMicroseconds(500);
          }
        }
      } 
      // When finished all X, step in Y-direction
      stepperY.runToNewPosition(stepperY.currentPosition()-stepY);
    }
    // Print every layer twice
    if(z % 2){
      homeXY();
    } else { 
      
      // Message to serial to indicate layer is done and the show overall progress
      Serial.print("Layer "); Serial.print(zTemp); Serial.print(" of "); Serial.print(pwdrconfig[2])-1; Serial.println(" printed");
      
      // When the complete layer is printed, a new layer of powder is deposited
      newLayer();
      stepperX.runToNewPosition(stepperX.currentPosition()-stepX);
    }
  }
}   
