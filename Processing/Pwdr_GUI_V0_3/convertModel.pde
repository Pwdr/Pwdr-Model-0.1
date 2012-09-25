// Convert the graphical output of the sliced STL into a printable binary format. 
// The bytes are read by the Arduino firmware

PrintWriter output, outputUpper;

int lowernozzles = 8;
int uppernozzles = 4;
int nozzles = lowernozzles+uppernozzles;

int printXcoordinate = 120;
int printYcoordinate = 30;
int printWidth = 650;
int printHeight = 480;

int layer_size = printWidth * printHeight/nozzles * 2;

void convertModel() {
//  output = createWriter("PrintData/PwdrPrintData"+sliceNumber+".ino"); 
//  outputUpper = createWriter("PrintData/PwdrPrintDataUpper"+sliceNumber+".ino"); 

//  output.print("int printfilesize[] = {650,40,26000};\r\nPROGMEM prog_uchar printFileLower[][2000] ={{");
  // used to include "+source.width*+", but 2000 is the max size approximately the max size of the array on the Arduino. Hence the array must be declared in the Main source too,
  // it's eassier to declare the max size and give the actual dimensions of the array seperately

//  outputUpper.print("PROGMEM prog_uchar printFileUpper[][2000] ={{");
  // Used to include "+source.width+", see previous lines


  int index=0;
  byte[] print_data = new byte[layer_size];


  // Steps of 12 nozzles in Y direction
  for (int y = printYcoordinate; y < printHeight; y=y+nozzles ) {
        
//    if (y!=30) {
//      output.print("},{");
//      outputUpper.print("},{");
//    }
    // Step in X direction  
    for (int x = printXcoordinate; x < printWidth; x++) {
      
      // Clear the temp strings
      String[] LowerStr = {""};
      String LowerStr2 = "";
      String[] UpperStr = {""};
      String UpperStr2 = "";

      // For every step in Y direction, sample the 12 nozzles
      for ( int i=0; i<nozzles; i++) {
        // Calculate the location in the pixel array, use total window width!
        int loc = x + (y+i)*width;

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
//      if (x!=120) {
//        output.print(", ");
//        outputUpper.print(", ");
//      }

      LowerStr2 = join(LowerStr, "");
//      output.print(unbinary(LowerStr2));
      print_data[index] = byte(unbinary(LowerStr2));
      index++;
      //      output.print(", ");

      UpperStr2 = join(UpperStr, "");
//      outputUpper.print(unbinary(UpperStr2));
      print_data[index] = byte(unbinary(LowerStr2));
      index++;
      //      outputUpper.print(", ");
    }
  }
//  output.print("}};");
//  outputUpper.print("}};");

  saveBytes("PrintData/PwdrPrintData"+sliceNumber+".dat", print_data);
 
  sliceNumber++;
  println(sliceNumber);
}
