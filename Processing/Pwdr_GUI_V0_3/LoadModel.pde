void loadModel(){
  // Code for a 'open file' system window  
  selectInput("Select a STL file to process:", "fileSelected");
}  

void fileSelected(File selection) {
  // callback function for selectInput, handling of the selected filename
  if (selection == null) {
    println("No file selected...");
  } else {
    println("User selected " + selection.getAbsolutePath());
    Filename = selection.getAbsolutePath();
  }
}

