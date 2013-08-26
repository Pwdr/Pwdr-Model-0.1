void loadModel(){
  // Code for a 'open file' system window  
   FileName = selectInput();  
  
  if (FileName == null) {
    // If a file was not selected
    println("No file was selected...");
  } else {
    // If a file was selected, print path to file
     println(FileName);
    // FileName = "file://"+FileName; //Old bug under Windows
     FileName = FileName;
  }
}
