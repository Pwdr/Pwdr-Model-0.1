void loadPreferences(){
  File f = new File(sketchPath("config.txt"));
  if (!f.exists()) {
    println("File does not exist");
  } else {
    String[] configFile = loadStrings("config.txt");
    configFile = split(configFile[0], ',');
    println(configFile);
    
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
  String[] configFile = new String[6];
  
  configFile[0] = str(maxSlices);
  configFile[1] = str(PreScale);
  configFile[2] =str(showBox);
  configFile[3] =str(printXcoordinate);
  configFile[4] =str(printYcoordinate);
  configFile[5] =str(printWidth);
  configFile[6] =str(printHeight);
  join(configFile, ","); 
  println(configFile);
  saveStrings("config.txt",configFile);
}
