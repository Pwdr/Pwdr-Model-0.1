void loadPreferences(){
  File f = new File(sketchPath("config.txt"));
  if (!f.exists()) {
    println("File does not exist");
  } else {
    String[] configFile = loadStrings("config.txt");
    configFile = split(configFile[0], ',');
    
    maxSlices = int(configFile[0]);
    PreScale = float(configFile[1]);

    showBox = boolean(configFile[2]);
    printXcoordinate = int(configFile[3]);
    printYcoordinate = int(configFile[4]);
    printWidth = int(configFile[5]);
    printHeight = int(configFile[6]);
  }
}

void savePreferences(){  
  output = createWriter("config.txt"); 
  
  output.println(maxSlices + "," + PreScale + "," + showBox + "," + printXcoordinate + "," + printYcoordinate  + "," + printWidth + "," + printHeight);
  
  output.flush();
  output.close();
}
