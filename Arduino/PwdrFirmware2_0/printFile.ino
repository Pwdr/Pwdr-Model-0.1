void printFile(){
  // Switch on the LED while printing
  analogWrite(13, 255);

  // Safety measure, return carriage to 0,0 position
  homeXY();
  Serial.println("Print started");
 
  // Read config file for print size
  dataFile.close();    
  dataFile = SD.open("PWDR/PWDRCONF.TXT");
  
  if (!dataFile) {
    Serial.println("Error while opening printer config");
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
  
  saturation = pwdrconfig[3];
  Serial.println(saturation);

  for (int z=1;z<2*pwdrconfig[2];z++){

    // Use layer numer in file name   
    char filename[] = "PWDR/PWDR0000.DAT";
    // Add leading zeros
    filename[12] += char(z%10);   
    if (z >= 10){
      filename[11] += char((z/10)%10);
    } if (z >= 100){
      filename[10] += char((z/100)%10);
    } if (z >= 1000){
      filename[9] += char((z/1000)%10);
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
          if(y % 2 && x == pwdrconfig[0]){
            stepperX.runToNewPosition(stepperX.currentPosition()-stepX);
            // First step of right-left Y
            dataFile.seek(dataFile.position()+2*pwdrconfig[0]-2);  
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
