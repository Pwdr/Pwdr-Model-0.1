//Measured in millimeters
float LayerThickness = 0.4;
float Sink = 2;
int maxSlices = 20;

//Dimensionless
float PreScale = 1.4;
//String FileName = "file:///Users/alex/Downloads/teapot.stl";
String FileName;

//Display Properties
float BuildPlatformWidth = 100;
float BuildPlatformHeight = 100;
float DisplayScale = 5;

//End of "easy" modifications you can make...
//Naturally I encourage everyone to learn and
//alter the code that follows!
int t=0;
float tfloat=0;
float[] Tri = new float[9];
ArrayList Slice;
Mesh STLFile;
float MeshHeight;

void SimpleSlice(){
 
  Slice = new ArrayList();
  print("Loading STL...\n");
  //Load the .stl
  //Later we should totally make this runtime...
  STLFile = new Mesh(FileName);


  //Scale and locate the mesh
  STLFile.Scale(PreScale);
  //Put the mesh in the middle of the platform:
  STLFile.Translate(-STLFile.bx1,-STLFile.by1,-STLFile.bz1);
  STLFile.Translate(-STLFile.bx2/2,-STLFile.by2/2,0);
  STLFile.Translate(0,0,-LayerThickness);  
  STLFile.Translate(0,0,-Sink);


  print("File Loaded, Slicing:\n");
  print("X: " + CleanFloat(STLFile.bx1) + " - " + CleanFloat(STLFile.bx2) + "   ");
  print("Y: " + CleanFloat(STLFile.by1) + " - " + CleanFloat(STLFile.by2) + "   ");
  print("Z: " + CleanFloat(STLFile.bz1) + " - " + CleanFloat(STLFile.bz2) + "   \n");
  
 
  //Match viewport scale to 1cm per gridline
  STLFile.Scale(DisplayScale);
  STLFile.Translate(BuildPlatformWidth*DisplayScale/2,BuildPlatformHeight*DisplayScale/2,-STLFile.bz1);
  MeshHeight=STLFile.bz2-STLFile.bz1;

  print("Number of slices: " + (maxSlices-1) + "\n");
  
}
