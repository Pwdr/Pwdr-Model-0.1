void loadModel(){
  // Code for a 'open file' system window  
<<<<<<< HEAD
  selectInput("Select a STL file to process:", "fileSelected");
}  

void fileSelected(File selection) {
  // callback function for selectInput, handling of the selected filename
  if (selection == null) {
    println("No file selected...");
  } else {
    println("User selected " + selection.getAbsolutePath());
    Filename = selection.getAbsolutePath();
=======
  // Opens file chooser
  FileName = selectInput();  
  if (FileName == null) {
    // If a file was not selected
    println("No file was selected...");
  } else {
    FileName = "file://"+FileName;
    // If a file was selected, print path to file
    println(FileName);
>>>>>>> parent of 743ad5f... updated the selectInput() behavior, using the callback
  }
}

