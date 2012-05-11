/*MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNmmmmmNMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM/     /MMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMhy.   hMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMNNNNMMMMMMMMMMMMMMMMMMMMMMNMMMMMMMNNNNNm   -MMMMMMMMMMNNNMMMMM
MMMMMMMMMy////oNh+:..-oNN/////sMMMN+///MMMMo:/oNMMdo:-.-::   yMy////oMdo:./MMMMM
MMMMMMMMM/-`   /`-:`   od--   /MMN+    MMMs   sMN+` `:++-   .NM/-`   +``..dMMMMM
MMMMMMMMMMM-   :mMMh   :MMM.  /MMo ``  MMy  `yMm-  -dMMMs   oMMMM-   .smmmMMMMMM
MMMMMMMMMMd   -NMMMh   +MMM:  /Ms  s`  Md` `yMM/  `mMMMM-  `mMMMd   .mMMMMMMMMMM
MMMMMMMMMM/   hMMMM+   dMMM/  +h` oN   m. `hMMd   /MMMMh   /MMMM:   dMMMMMMMMMMM
MMMMMMMMMm`  .NMMMy   oMMMMo  /` oMN  .: `hMMMs   sMMMd.   dMMMd   :MMMNddNMMMMM
MMMMMMMMMo   :hdh+` `oNMMMMs    +NMm    .dMMMMs   -hho..  `yyNM/   hMMd.``.hMMMM
MMMMMMMMN`    ``  ./dMMMMMMy   +NMMd   .dMMMMMN:    `:hy.```.MN```-MMMh`  `yMMMM
MMMMMMMMs   +dhyhdmMMMMMMMMNdddNMMMNdddmMMMMMMMNdyyhmNMMNmmmmMNmmmNMMMMmhhmMMMMM
MMMMMNdd.   ydMMddddddddddddddddddddddddddddddddddddddddddddddddddddddddddNMMMMM
MMMMMy``    `.Mm``````````````````````````````````````````````````````````mMMMMM
MMMMMmdddddddmMNddddddddddddddddddddddddddddddddddddddddddddddddddddddddddMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMM                                                          MMMMMMMMMMM
MMMMMMMMMMM Firmware for Pwdr three-dimensional powder based printer MMMMMMMMMMM
MMMMMMMMMMM Author: Alex Budding                                     MMMMMMMMMMM
MMMMMMMMMMM E-mail: a.budding@gstudent.utwente.nl                    MMMMMMMMMMM
MMMMMMMMMMM This software has been released under the GPL License    MMMMMMMMMMM 
MMMMMMMMMMM                                                          MMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM*/

/////////////////////////////////////////////////////////////////////////////////
//
// Preprocessor for creating PwdrPrintData.ino files from images files
// in GIF, JPG, TGA or PNG format. 
//
/////////////////////////////////////////////////////////////////////////////////

PImage source;       // Source image
PImage destination;  // Destination image
PrintWriter output;  // Output text file
PrintWriter outputUpper;

float threshold = 140;
int lowernozzles = 8;
int uppernozzles = 4;
int nozzles = lowernozzles+uppernozzles;

void setup() {
  // Code for a 'open file' system window  
  // Opens file chooser
  String loadPath = selectInput();  
  if (loadPath == null) {
    // If a file was not selected
    println("No file was selected...");
  } else {
    // If a file was selected, print path to file
    println(loadPath);
  }
  
  source = loadImage(loadPath);  
  size(source.width, source.height);
  // The destination image is created as a blank image the same size as the source.
  destination = createImage(source.width, source.height, RGB);
  // Make a external file inside the PwdrFirmware folder
  output = createWriter("../../Arduino/PwdrFirmware/PwdrPrintData.ino"); 
  outputUpper = createWriter("../../Arduino/PwdrFirmware/PwdrPrintDataUpper.ino"); 
}

void draw() {  
  // We are going to look at both image's pixels
  source.loadPixels();
  destination.loadPixels();

  for (int x = 0; x < source.width; x++) {
    for (int y = 0; y < source.height; y++ ) {
      int loc = x + y*source.width;
      // Test the brightness against the threshold
      if (brightness(source.pixels[loc]) > threshold) {
        destination.pixels[loc]  = color(255);  // White
      }  
      else {
        destination.pixels[loc]  = color(0);    // Black
      }
    }
  }

  // We changed the pixels in destination
  destination.updatePixels();
  // Display the destination
  image(destination, 0, 0);
}

// When any key is pressed, the file is converted to a ASCII print file
void keyPressed() {
  output.print("int printfilesize[] = {"+source.width+","+source.height/nozzles+","+source.height/nozzles*source.width+"};\r\nPROGMEM prog_uchar printFileLower[]["+source.height/nozzles*source.width+"] ={{");
  
  outputUpper.print("PROGMEM prog_uchar printFileUpper[]["+source.height/nozzles*source.width+"] ={{");

  // Steps of 12 nozzles in Y direction
  for (int y = 0; y < source.height; y=y+nozzles ) {
    if(y!=0){
      output.print("},{");
      outputUpper.print("},{");
    }
    // Step in X direction  
    for (int x = 0; x < source.width; x++) {

      String[] LowerStr = {""};
      String LowerStr2 = "";
      String[] UpperStr = {""};
      String UpperStr2 = "";

      // For every step in Y direction, sample the 12 nozzles
      for ( int i=0; i<nozzles; i++) {
        // Calculate the location in the pixel array
        int loc = x + (y+i)*source.width;

        if (loc < source.width*source.height) {
          if (brightness(source.pixels[loc]) > threshold) {

            // Write a zero when the pixel is white
            if(i<uppernozzles){
              UpperStr = append(UpperStr, "0");
            } else {
              LowerStr = append(LowerStr, "0");
              }
            } else {
            // Write a one when the pixel is black     
            if(i<uppernozzles){
              UpperStr = append(UpperStr, "1");
            } else {
              LowerStr = append(LowerStr, "1");
            }
          }
        }
      } 
      
      // Join the individual characters of the string and convert them to a decimal and add commas
      if(x!=0){
        output.print(", ");
        outputUpper.print(", ");
      }
      
      LowerStr2 = join(LowerStr,"");
      output.print(unbinary(LowerStr2));

      UpperStr2 = join(UpperStr,"");
      outputUpper.print(unbinary(UpperStr2));

    }

  }
  output.print("}};");
  outputUpper.print("}};");
  
  outputUpper.flush();
  outputUpper.close();
  
  output.flush(); // Writes the remaining data to the file
  output.close(); // Finishes the file
  exit();         // Stops the program
}


