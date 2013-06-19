void loadModel(){
  // Code for a 'open file' system window  
  // Opens file chooser
  FileName = selectInput();  
  
  selectInput("Select a STL file to process:", "fileSelected");
  
  
  void fileSelected(File selection) {
    if (selection == null) {
      println("No file selected...");
    } else {
      println("User selected " + selection.getAbsolutePath());
      Filename = selection.getAbsolutePath();
    }
  }
}
