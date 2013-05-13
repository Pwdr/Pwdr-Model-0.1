// Convert the graphical output of the sliced STL into a printable binary format. 
// The bytes are read by the Arduino firmware

PrintWriter output, outputUpper;

int loc;
int LTR = 0;
int lowernozzles = 8;
int uppernozzles = 4;
int nozzles = lowernozzles+uppernozzles;

int printXcoordinate = 120+280;  // Left margin 120
int printYcoordinate = 30+190;  // Top margin 30
int printWidth = 120;        // Total image width 650
int printHeight = 120;      // Total image height 480

int layer_size = printWidth * printHeight/nozzles * 2;

void convertModel() {

  // Create config file for the printer, trailing comma for convenience  
  output = createWriter("PWDR/PWDRCONF.TXT"); 
  output.print(printWidth+","+printHeight/nozzles+","+maxSlices+","+inkSaturation+",");
  output.flush();
  output.close();

  int index = 0;
  byte[] print_data = new byte[layer_size * 2];

  // Steps of 12 nozzles in Y direction
  for (int y = printYcoordinate; y < printYcoordinate+printHeight; y=y+nozzles ) {
    // Set a variable to know wheter we're moving LTR of RTL
    LTR++;  
    // Step in X direction  
    for (int x = 0; x < printWidth; x++) {
      
      // Clear the temp strings
      String[] LowerStr = {""};
      String LowerStr2 = "";
      String[] UpperStr = {""};
      String UpperStr2 = "";

      // For every step in Y direction, sample the 12 nozzles
      for ( int i=0; i<nozzles; i++) {
        // Calculate the location in the pixel array, use total window width!
        // Use the LTR to determine the direction
        
        if (LTR % 2 == 1){
          loc = printXcoordinate + printWidth - x + (y+i) * width;
        } else {
          loc = printXcoordinate + x + (y+i) * width;
        }

        if (brightness(pixels[loc]) < 100) {

          // Write a zero when the pixel is white (or should be white, as the preview is inverted)
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
