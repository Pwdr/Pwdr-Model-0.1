PrintWriter output, outputUpper;

int lowernozzles = 8;
int uppernozzles = 4;
int nozzles = lowernozzles+uppernozzles;

void convertModel() { 
  output = createWriter("PrintData/PwdrPrintData"+sliceNumber+".ino"); 
  outputUpper = createWriter("PrintData/PwdrPrintDataUpper"+sliceNumber+".ino"); 

  output.print("int printfilesize[] = {650,40,26000};\r\nPROGMEM prog_uchar printFileLower[][2000] ={{");
  // used to include "+source.width*+", but 2000 is the max size approximately the max size of the array on the Arduino. Hence the array must be declared in the Main source too,
  // it's eassier to declare the max size and give the actual dimensions of the array seperately

  outputUpper.print("PROGMEM prog_uchar printFileUpper[][2000] ={{");
  // Used to include "+source.width+", see previous lines


  // Steps of 12 nozzles in Y direction
  for (int y = 30; y < 510; y=y+nozzles ) {
    if (y!=30) {
      output.print("},{");
      outputUpper.print("},{");
    }
    // Step in X direction  
    for (int x = 120; x < 770; x++) {
      
      // Clear the temp strings
      String[] LowerStr = {""};
      String LowerStr2 = "";
      String[] UpperStr = {""};
      String UpperStr2 = "";

      // For every step in Y direction, sample the 12 nozzles
      for ( int i=0; i<nozzles; i++) {
        // Calculate the location in the pixel array
        int loc = x + (y+i)*800;

        if (brightness(pixels[loc]) < 100) {

          // Write a zero when the pixel is white (or should be white, as the preview is inverted
          if (i<uppernozzles) {
            UpperStr = append(UpperStr, "0");
          } else {
            LowerStr = append(LowerStr, "0");
          }
        } else {
          // Write a one when the pixel is black     
          if (i<uppernozzles) {
            UpperStr = append(UpperStr, "1");
          } else {
            LowerStr = append(LowerStr, "1");
          }
        }
      } 
      
      // Join the individual characters of the string and convert them to a decimal and add commas
      if (x!=120) {
        output.print(", ");
        outputUpper.print(", ");
      }

      LowerStr2 = join(LowerStr, "");
      output.print(unbinary(LowerStr2));
      //      output.print(", ");

      UpperStr2 = join(UpperStr, "");
      outputUpper.print(unbinary(UpperStr2));
      //      outputUpper.print(", ");
    }
  }
  output.print("}};");
  outputUpper.print("}};");
  
  sliceNumber++;
  println(sliceNumber);
}

