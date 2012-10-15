// Convert the graphical output of the sliced STL into a printable binary format. 
// The bytes are read by the Arduino firmware

PrintWriter output, outputUpper;

int lowernozzles = 8;
int uppernozzles = 4;
int nozzles = lowernozzles+uppernozzles;

int printXcoordinate = 120+224;  // Left margin 120
int printYcoordinate = 30+168;  // Top margin 30
int printWidth = 212;        // Total image width 650
int printHeight = 168;      // Total image height 480

int layer_size = printWidth * printHeight/nozzles * 2;

void convertModel() {

  // Create config file for the printer, trailing comma for convenience  
  output = createWriter("PWDR/PWDRCONF.TXT"); 
  output.print(printWidth+","+printHeight/nozzles+","+maxSlices+","+inkSaturation+",");
  output.flush();
  output.close();

  int index = 0;
  byte[] print_data = new byte[layer_size];

  // Steps of 12 nozzles in Y direction
  for (int y = printYcoordinate; y < printYcoordinate+printHeight; y=y+nozzles ) {
        
    // Step in X direction  
    for (int x = printXcoordinate; x < printXcoordinate+printWidth; x++) {
      
      // Clear the temp strings
      String[] LowerStr = {""};
      String LowerStr2 = "";
      String[] UpperStr = {""};
      String UpperStr2 = "";

      // For every step in Y direction, sample the 12 nozzles
      for ( int i=0; i<nozzles; i++) {
        // Calculate the location in the pixel array, use total window width!
        int loc = x + (y+i) * width;

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
      
      LowerStr2 = join(LowerStr, "");
      print_data[index] = byte(unbinary(LowerStr2));
      index++;
      //      output.print(", ");

      UpperStr2 = join(UpperStr, "");
      print_data[index] = byte(unbinary(UpperStr2));
      index++;
    }
  }

  if (sliceNumber >= 1 && sliceNumber < 10){
    saveBytes("PWDR/PWDR000"+sliceNumber+".DAT", print_data);
  } else if (sliceNumber >= 10 && sliceNumber < 100){
    saveBytes("PWDR/PWDR00"+sliceNumber+".DAT", print_data);
  } else if (sliceNumber >= 100 && sliceNumber < 1000){
    saveBytes("PWDR/PWDR0"+sliceNumber+".DAT", print_data);
  } else if (sliceNumber >= 1000) {
    saveBytes("PWDR/PWDR"+sliceNumber+".DAT", print_data);
  }
 
  sliceNumber++;
  println(sliceNumber);
}
