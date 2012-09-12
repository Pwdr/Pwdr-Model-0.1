import processing.core.*; 
import processing.xml.*; 

import processing.serial.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class Pwdr_GUI_V0_3 extends PApplet {

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
MMMMMMMMMMM Software for Pwdr three-dimensional powder based printer MMMMMMMMMMM
MMMMMMMMMMM Author: Alex Budding                                     MMMMMMMMMMM
MMMMMMMMMMM E-mail: pwdr@wetterhorn.nl                               MMMMMMMMMMM
MMMMMMMMMMM                                                          MMMMMMMMMMM
MMMMMMMMMMM This software released under the GNU/GPL license         MMMMMMMMMMM 
MMMMMMMMMMM                                                          MMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM*/



PImage backgroundImage, backgroundImageMask;
PFont myFont;

// !Redundant!

int clickColorInt;
int sliceNumber = 1;

String GUIstate = "converting";


public void setup(){
  size(800,600);
  // The low framerate reduce CPU load, can't be used during convertion
  frameRate(10);
  // Load the background images
  backgroundImage = loadImage("Converting.png");
  // Load the mask for click detection. 
  backgroundImageMask = loadImage("ConvertingMask.png");
  // Load font
  myFont = loadFont("OfficinaSerif.vlw");
  textFont(myFont, 19);
}

public void draw(){
  background(backgroundImage);
  
  if(GUIstate == "connection"){
    // Store and count avalaible serial ports
    comList = arduinoSerial.list();
    String comlist = join(comList, ",");
    String COMlist = comList[0];
    int size2 = COMlist.length();
    int size1 = comlist.length() / size2; 
    
    for(int i=0; i< size1; i++){
      stroke(0);
      fill(0xff666666);
      text(i+1+" : "+comList[i], 173, 145+i*27);
      noFill();
      strokeWeight(2);
      stroke(0xff666666);
      rect(136, 128+27*i, 20, 20);
      if (serialSet) {
        fill(0xff666666);
        rect(136, 128+27*(selectPort-1), 20, 20);
      }
    }
    
    fill(0xff666666);
    text(serialString, 136, 500);
    
  } else if((GUIstate == "converting...") && (FileName != null) && (sliceNumber <= maxSlices)) {
    // Slice the STL file
    // Increase framerate for the slicing of the STL file
    frameRate(60);
    
     //Generate a Slice
    Line2D Intersection;
    Slice = new ArrayList();
    
    for(int i = STLFile.Triangles.size()-1;i>=0;i--){
      Triangle tri = (Triangle) STLFile.Triangles.get(i);
      Intersection = tri.GetZIntersect(MeshHeight*sliceNumber/maxSlices);
      if(Intersection!=null)Slice.add(Intersection);
    }
  
    //Draw the profile
    stroke(0);
    strokeWeight(1);
  
    for(int i = Slice.size()-1;i>=0;i--){
      Line2D lin = (Line2D) Slice.get(i);
      line(208+lin.x1,30+lin.y1,208+lin.x2,30+lin.y2);
    }    
    loadPixels();
    floodFill(new Vec2D(121,31), 0xff000000, 0xffFFFFFF);
    updatePixels();
    // Debug output
    //saveFrame("slices/slice-####.png");
    loadPixels();
    convertModel();
    
    if (sliceNumber == maxSlices){
        GUIstate = "converting";
        frameRate(10);
    }
  } else if(GUIstate == "printing"){
    textAlign(CENTER);
    fill(0xff666666);
    text(serialString, 450, 395);
    textAlign(LEFT);
  }
}
public void floodFill(Vec2D p, int col, int bg) {
  int xx,yy,idx,idxUp,idxDown;
  int h1=height-1;
  boolean scanUp,scanDown;

  // use the default java stack:
  // http://java.sun.com/j2se/1.4.2/docs/api/java/util/Stack.html
  Stack stack=new Stack();

  // the Stack class is throwing an exception
  // when we're trying to pop() too often...
  // so we need to wrap code inside a try - catch block
  try {
    while(true) {
      xx = p.x;
      yy = p.y;
      // compute current index in pixel buffer array
      idx=yy*width+xx;
      idxUp=idx-width;
      idxDown=idx+width;
      scanUp = scanDown = false;
      // find left boundary in current scanline...
      // checking neighbouring pixel rows
      while(xx >= 0 && pixels[idx] == bg) {
        pixels[idx] = col;
        if (yy>0) {
          if (pixels[idxUp--]==bg && !scanUp) {
            stack.push(new Vec2D(xx, yy-1));
            scanUp = true;
          }
          else if (scanUp) scanUp=false;
        }
        if (yy < h1) {
          if (pixels[idxDown--]==bg && !scanDown) {
            stack.push(new Vec2D(xx, yy+1));
            scanDown = true;
          }
          else if (scanDown) scanDown=false;
        }
        xx--;
        idx--;
      }
      // ...now continue scanning/filling to the right
      xx = p.x;
      yy = p.y;
      idx = yy*width+xx;
      idxUp=idx-width;
      idxDown=idx+width;
      scanUp = scanDown = false;
      while(++xx < width && pixels[++idx] == bg) {
        pixels[idx] = col;
        if (yy>0) {
          if (pixels[++idxUp]==bg && !scanUp) {
            stack.push(new Vec2D(xx, yy-1));
            scanUp = true;
          }
          else if (scanUp) scanUp=false;
        }
        if (yy<h1) {
          if (pixels[++idxDown]==bg && !scanDown) {
            stack.push(new Vec2D(xx, yy+1));
            scanDown = true;
          }
          else if (scanDown) scanDown=false;
        }
      }
      p=(Vec2D)stack.pop();
    }
  }
  // catch exceptions...
  // stack is empty when we're finished filling, so just ignore
  catch(EmptyStackException e) {
  }
  // catch other exceptions
  // e.g. OutOfMemoryException, though shouldn't be caused by filler
  catch(Exception e) {
  }
}

class Vec2D {
  public int x,y;

  Vec2D(int x,int y) {
    this.x=x;
    this.y=y;
  }
}
// Line Class
// Once we have the slices as 2D lines,
// we never look back.
class Line2D {
  
  float x1,y1,x2,y2;
  
  final float epsilon = 1e-6f;
  
  Line2D(float nx1, float ny1, float nx2, float ny2) {
    x1=nx1;
    x2=nx2;
    y1=ny1;
    y2=ny2;
  }
  
  
  public void Scale(float Factor)
  {
    x1=x1*Factor;
    x2=x2*Factor;
    y1=y1*Factor;
    y2=y2*Factor;
  }


  public void Flip()
  {
    float xn, yn;
    xn = x1;
    yn = y1;
    x1 = x2;
    y1 = y2;
    x2 = xn;
    y2 = yn;
  }

  
  public void Rotate(float Angle)
  {
    float xn,yn;
    xn = x1*cos(Angle) - y1*sin(Angle);
    yn = x1*sin(Angle) + y1*cos(Angle);
    x1 = xn;
    y1 = yn;
    xn = x2*cos(Angle) - y2*sin(Angle);
    yn = x2*sin(Angle) + y2*cos(Angle);
    x2 = xn;
    y2 = yn;
  }

  
  public float Length()
  {
    return mag(y2-y1, x2-x1);
  }


  public float RadianAngle()
  {
    return atan2(y2-y1, x2-x1);
  }
  
}

public void loadModel(){
  // Code for a 'open file' system window  
  // Opens file chooser
  FileName = selectInput();  
  if (FileName == null) {
    // If a file was not selected
    println("No file was selected...");
  } else {
    FileName = "file://"+FileName;
    // If a file was selected, print path to file
    println(FileName);
  }
}
// Mesh Class

class Mesh {
  ArrayList Triangles;
  float bx1,by1,bz1,bx2,by2,bz2; //bounding box

  float Sink;

  //Mesh Loading routine
  Mesh(String FileName)
  {
    byte b[] = loadBytes(FileName);
    Triangles = new ArrayList();
    Sink=0;
    float[] Tri = new float[9];
    //Skip the header
    int offs = 84;
    //Read each triangle out
    while(offs<b.length){
      offs = offs + 12; //skip the normals entirely!
      for(int i = 0; i<9; i++)
      {
        Tri[i]=bin_to_float(b[offs],b[offs+1],b[offs+2],b[offs+3]);
        offs=offs+4;
      }
      offs=offs+2;//Skip the attribute bytes
      Triangles.add(new Triangle(Tri[0],Tri[1],Tri[2],Tri[3],Tri[4],Tri[5],Tri[6],Tri[7],Tri[8]));
    } 
    CalculateBoundingBox();
  }

  
  public void Scale(float Factor)
  {
    for(int i = Triangles.size()-1;i>=0;i--)
    {
      Triangle tri = (Triangle) Triangles.get(i);
      tri.Scale(Factor);
    }
    CalculateBoundingBox();
  }

  public void Translate(float tx, float ty, float tz)
  {
    for(int i = Triangles.size()-1;i>=0;i--)
    {
      Triangle tri = (Triangle) Triangles.get(i);
      tri.Translate(tx,ty,tz);
    }
    CalculateBoundingBox();
  }

  public void CalculateBoundingBox()
  {
      bx1 = 10000;
      bx2 = -10000;
      by1 = 10000;
      by2 = -10000;
      bz1 = 10000;
      bz2 = -10000;
      for(int i = Triangles.size()-1;i>=0;i--)
    {

      Triangle tri = (Triangle) Triangles.get(i);
      if(tri.x1<bx1)bx1=tri.x1;
      if(tri.x2<bx1)bx1=tri.x2;
      if(tri.x3<bx1)bx1=tri.x3;
      if(tri.x1>bx2)bx2=tri.x1;
      if(tri.x2>bx2)bx2=tri.x2;
      if(tri.x3>bx2)bx2=tri.x3;
      if(tri.y1<by1)by1=tri.y1;
      if(tri.y2<by1)by1=tri.y2;
      if(tri.y3<by1)by1=tri.y3;
      if(tri.y1>by2)by2=tri.y1;
      if(tri.y2>by2)by2=tri.y2;
      if(tri.y3>by2)by2=tri.y3;
      if(tri.z1<bz1)bz1=tri.z1;
      if(tri.z2<bz1)bz1=tri.z2;
      if(tri.z3<bz1)bz1=tri.z3;
      if(tri.z1>bz2)bz2=tri.z1;
      if(tri.z2>bz2)bz2=tri.z2;
      if(tri.z3>bz2)bz2=tri.z3;
    }    
  }
}

//Convert the binary format of STL to floats.
public float bin_to_float(byte b0, byte b1, byte b2, byte b3)
{
  int exponent, sign;
  float significand;
  float finalvalue=0;
  
  exponent = (b3 & 0x7F)*2 | (b2 & 0x80)>>7;
  sign = (b3&0x80)>>7;
  exponent = exponent-127;
  significand = 1 + (b2&0x7F)*pow(2,-7) + b1*pow(2,-15) + b0*pow(2,-23);  //throwing away precision for now...

  if(sign!=0)significand=-significand;
  finalvalue = significand*pow(2,exponent);

  return finalvalue;
}

//Display floats cleanly!
public float CleanFloat(float Value)
{
  Value = Value * 1000;
  Value = round(Value);
  return Value / 1000;
}
String[] comList;
int selectPort;
boolean serialSet = false;
Serial arduinoSerial;

String serialString = "Choose the correct Arduino COM port...";

public void startSerial(){
  arduinoSerial = new Serial(this, Serial.list()[selectPort], 9600);
  arduinoSerial.bufferUntil(10);
  serialSet = true;
  serialString = "Serial port #"+selectPort+" connected";
}

public void serialEvent(Serial p) { 
  // read the string from serial
  serialString = p.readString(); 
}

public void serialSend(String serialTemp){
  
  println(serialTemp);
  
  if (serialSet){
    arduinoSerial.write(serialTemp);
  } else { 
    serialString = "Arduino not connected";
  }
}

//Measured in millimeters
float LayerThickness = 0.4f;
float Sink = 2;
int maxSlices = 500;

//Dimensionless
float PreScale = 1.4f;
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

public void SimpleSlice(){
 
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
// Slice Class
//
class Slice {
  
  ArrayList Lines;

  //Right now this is all in the constructor.
  //It might make more sense to split these
  //out but that's a pretty minor difference
  //at the moment.
  Slice(Mesh InMesh, float ZLevel) {
    
    ArrayList UnsortedLines;
    Line2D Intersection;
    UnsortedLines = new ArrayList();
    for(int i = InMesh.Triangles.size()-1;i>=0;i--)
    {
      Triangle tri = (Triangle) InMesh.Triangles.get(i);
      Intersection = tri.GetZIntersect(ZLevel);
      if(Intersection!=null)UnsortedLines.add(Intersection);
    }
    
    
    if(UnsortedLines==null)return;
        
    //Slice Sort: arrange the line segments so that
    //each segment leads to the nearest available
    //segment. This is accomplished by using two
    //arraylists of lines, and at each step moving
    //the nearest available line segment from the
    //unsorted pile to the next slot in the sorted pile.
    Lines = new ArrayList();
    Lines.add(UnsortedLines.get(0));
    int FinalSize = UnsortedLines.size();
    UnsortedLines.remove(0);

    //ratchets for distance
    //dist_flipped exists to catch flipped lines
    float dist, dist_flipped;
    float mindist = 10000;

    int iNextLine;

    float epsilon = 1e-6f;
    
    while(UnsortedLines.size()>0)
    {
      Line2D CLine = (Line2D) Lines.get(Lines.size()-1);//Get last
      iNextLine = (Lines.size()-1);
      mindist = 10000;
      boolean doflip = false;
      for(int i = UnsortedLines.size()-1;i>=0;i--)
      {
        Line2D LineCandidate = (Line2D) UnsortedLines.get(i);
        dist         = mag(LineCandidate.x1-CLine.x2, LineCandidate.y1-CLine.y2);
        dist_flipped = mag(LineCandidate.x2-CLine.x2, LineCandidate.y2-CLine.y2); // flipped
          
	if(dist<epsilon)
	{
	  // We found exact match.  Break out early.
	  doflip = false;
	  iNextLine = i;
          mindist = 0;
	  break;
	}

	if(dist_flipped<epsilon)
	{
	  // We found exact flipped match.  Break out early.
	  doflip = true;
	  iNextLine = i;
          mindist = 0;
	  break;
	}

        if(dist<mindist)
        {
	  // remember closest nonexact matches to end
	  doflip = false;
          iNextLine=i;
          mindist = dist;
        }

        if(dist_flipped<mindist)
        {
	  // remember closest flipped nonexact matches to end
	  doflip = true;
          iNextLine=i;
          mindist = dist_flipped;
        }
      }

      Line2D LineToMove = (Line2D) UnsortedLines.get(iNextLine);
      if(doflip) {
        LineToMove.Flip();
      }
      Lines.add(LineToMove);
      UnsortedLines.remove(iNextLine);
    }
  }
  
} 
// Triangle Class

class Triangle {
  
  float x1,x2,x3,y1,y2,y3,z1,z2,z3,xn,yn,zn;
  
  Triangle(float tX1, float tY1, float tZ1,float tX2, float tY2, float tZ2,float tX3, float tY3, float tZ3) {
    x1 = tX1;
    y1 = tY1;
    z1 = tZ1;
    x2 = tX2;
    y2 = tY2;
    z2 = tZ2;
    x3 = tX3;
    y3 = tY3;
    z3 = tZ3;
    
    
    //Sorting the Triangle according to
    //height makes slicing them easier.
    Resort();
    
    
  }
  
  public void Scale(float Factor)
  {
    x1 = Factor*x1;
    y1 = Factor*y1;
    z1 = Factor*z1;
    x2 = Factor*x2;
    y2 = Factor*y2;
    z2 = Factor*z2;
    x3 = Factor*x3;
    y3 = Factor*y3;
    z3 = Factor*z3;
  }
  
  
  public void Translate(float tX, float tY, float tZ)
  {
    x1=x1+tX;
    x2=x2+tX;
    x3=x3+tX;
    y1=y1+tY;
    y2=y2+tY;
    y3=y3+tY;
    z1=z1+tZ;
    z2=z2+tZ;
    z3=z3+tZ;
  }
  
  //Rotations-- feed these in radians!
  //A great application is rotating your
  //mesh to a desired orientation.
  // 90 degrees = PI/2.
  public void RotateZ(float Angle)
  {
    float xn,yn;
    xn = x1*cos(Angle) - y1*sin(Angle);
    yn = x1*sin(Angle) + y1*cos(Angle);
    x1 = xn;
    y1 = yn;
    xn = x2*cos(Angle) - y2*sin(Angle);
    yn = x2*sin(Angle) + y2*cos(Angle);
    x2 = xn;
    y2 = yn;
    xn = x3*cos(Angle) - y3*sin(Angle);
    yn = x3*sin(Angle) + y3*cos(Angle);
    x3 = xn;
    y3 = yn;
    Resort();
  }
  public void RotateY(float Angle)
  {
    float xn,zn;
    xn = x1*cos(Angle) - z1*sin(Angle);
    zn = x1*sin(Angle) + z1*cos(Angle);
    x1 = xn;
    z1 = zn;
    xn = x2*cos(Angle) - z2*sin(Angle);
    zn = x2*sin(Angle) + z2*cos(Angle);
    x2 = xn;
    z2 = zn;
    xn = x3*cos(Angle) - z3*sin(Angle);
    zn = x3*sin(Angle) + z3*cos(Angle);
    x3 = xn;
    z3 = zn;
    Resort();
  }  
  public void RotateX(float Angle)
  {
    float yn,zn;
    yn = y1*cos(Angle) - z1*sin(Angle);
    zn = y1*sin(Angle) + z1*cos(Angle);
    y1 = yn;
    z1 = zn;
    yn = y2*cos(Angle) - z2*sin(Angle);
    zn = y2*sin(Angle) + z2*cos(Angle);
    y2 = yn;
    z2 = zn;
    yn = y3*cos(Angle) - z3*sin(Angle);
    zn = y3*sin(Angle) + z3*cos(Angle);
    y3 = yn;
    z3 = zn;
    Resort();
  } 
  
  
  //The conditionals here are for working
  //out what kind of intersections the triangle
  //makes with the plane, if any.  Returns
  //null if the triangle does not intersect.
  public Line2D GetZIntersect(float ZLevel)
  {
    Line2D Intersect;
    float xa,xb,ya,yb;
    if(z1<ZLevel)
    {
      if(z2>ZLevel)
      {
        xa = x1 + (x2-x1)*(ZLevel-z1)/(z2-z1);
        ya = y1 + (y2-y1)*(ZLevel-z1)/(z2-z1);
        if(z3>ZLevel)
        {
          xb = x1 + (x3-x1)*(ZLevel-z1)/(z3-z1);
          yb = y1 + (y3-y1)*(ZLevel-z1)/(z3-z1);
        }
        else
        {
          xb = x2 + (x3-x2)*(ZLevel-z2)/(z3-z2);
          yb = y2 + (y3-y2)*(ZLevel-z2)/(z3-z2);          
        }
        Intersect = new Line2D(xa,ya,xb,yb);
        return Intersect;
      }
      else
      {
        if(z3>ZLevel)
        {
          xa = x1 + (x3-x1)*(ZLevel-z1)/(z3-z1);
          ya = y1 + (y3-y1)*(ZLevel-z1)/(z3-z1);
          xb = x2 + (x3-x2)*(ZLevel-z2)/(z3-z2);
          yb = y2 + (y3-y2)*(ZLevel-z2)/(z3-z2);
        
          Intersect = new Line2D(xa,ya,xb,yb);
          return Intersect;
        }
        else
        {
          return null;
        }
      }
    }
    else
    {
      return null;
    }
  }
  
  //In the old days, a triangle's normal was defined
  //by right-hand-rule from the order vertices were
  //defined.  If this were the case with STL this would
  //scramble the normals horribly.
  //Of course, we never USE the normals...
  public void Resort()
  {
        if(z3<z1)
    {
      xn=x1;
      yn=y1;
      zn=z1;
      x1=x3;
      y1=y3;
      z1=z3;
      x3=xn;
      y3=yn;
      z3=zn;
    }
    if(z2<z1)
    {
      xn=x1;
      yn=y1;
      zn=z1;
      x1=x2;
      y1=y2;
      z1=z2;
      x2=xn;
      y2=yn;
      z2=zn;
    }
    if(z3<z2)
    {
      xn=x3;
      yn=y3;
      zn=z3;
      x3=x2;
      y3=y2;
      z3=z2;
      x2=xn;
      y2=yn;
      z2=zn;
    }
  }
  
  
}  
PrintWriter output, outputUpper;

int lowernozzles = 8;
int uppernozzles = 4;
int nozzles = lowernozzles+uppernozzles;

public void convertModel() { 
  output = createWriter("PrintData/PwdrPrintData"+sliceNumber+".ino"); 
  outputUpper = createWriter("PrintData/PwdrPrintDataUpper"+sliceNumber+".ino"); 

  output.print("int printfilesize[] = {650,40,26000};\r\nPROGMEM prog_uchar printFileLower[][2000] ={{");
  // used to include "+source.width*+", but 2000 is the max size approximately the max size of the array on the Arduino. Hence the array must be declared in the Main source too,
  // it's eassier to declare the max size and give the actual dimensions of the array seperately

  outputUpper.print("PROGMEM prog_uchar printFileUpper[][2000] ={{");
  // Used to include "+source.width+", see previous lines


  // Steps of 12 nozzles in Y direction
  for (int y = 30; y < 510; y=y+nozzles ) {
    if (y!=30) {
      output.print("},{");
      outputUpper.print("},{");
    }
    // Step in X direction  
    for (int x = 120; x < 770; x++) {
      
      // Clear the temp strings
      String[] LowerStr = {""};
      String LowerStr2 = "";
      String[] UpperStr = {""};
      String UpperStr2 = "";

      // For every step in Y direction, sample the 12 nozzles
      for ( int i=0; i<nozzles; i++) {
        // Calculate the location in the pixel array
        int loc = x + (y+i)*800;

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
      
      // Join the individual characters of the string and convert them to a decimal and add commas
      if (x!=120) {
        output.print(", ");
        outputUpper.print(", ");
      }

      LowerStr2 = join(LowerStr, "");
      output.print(unbinary(LowerStr2));
      //      output.print(", ");

      UpperStr2 = join(UpperStr, "");
      outputUpper.print(unbinary(UpperStr2));
      //      outputUpper.print(", ");
    }
  }
  output.print("}};");
  outputUpper.print("}};");
  
  sliceNumber++;
  println(sliceNumber);
}

  int R_MASK = 255<<16;

public void mouseClicked() {  
  // Pick the color on the mask
  int clickColor = backgroundImageMask.pixels[mouseX+mouseY*800];
  // Convert the color datatype (r,g,b) to a int, only red is used, 255 possible buttons
  clickColorInt = (clickColor & R_MASK)>>16;
  
  println(clickColorInt);
 
  switch(clickColorInt) {
    case 1:
      GUIstate = "converting";
      backgroundImage = loadImage("Converting.png");
      backgroundImageMask = loadImage("ConvertingMask.png");
      break;
    case 2:
      GUIstate = "connection";
      backgroundImage = loadImage("Connecting.png");
      backgroundImageMask = loadImage("ConnectingMask.png");
      break;
    case 3:
      GUIstate = "printing";
      backgroundImage = loadImage("Printing.png");
      backgroundImageMask = loadImage("PrintingMask.png");
      break;
    case 4:
      GUIstate = "settings";
      backgroundImage = loadImage("Settings.png");
      break;
    // "Converting"
    case 5:
      loadModel();
      // Opening a new file, thus reset counter
      sliceNumber = 1;
      SimpleSlice();
      break;
    // Convert model
    case 6:
      GUIstate = "converting...";
      break;
    // Save files
    case 7:
      saveFile();
      break;
    // "Connecting"
    case 8:
      println("connecting");
      selectPort = 7;
      startSerial();
      // Serial 7
      break;
    case 9:
      // Serial 1
      selectPort = 1;
      startSerial();
      break;
    case 10:
      // Serial 2
      selectPort = 2;
      startSerial();
      break;
    case 11:
      selectPort = 3;
      startSerial();
      // Serial 3
      break;
    case 12:
      selectPort = 4;
      startSerial();
      // Serial 4
      break;
    case 13:
      selectPort = 5;
      startSerial();
      // Serial 5
      break;
    case 14:
      selectPort = 6;
      startSerial();
      // Serial 6
      break;
    case 21:
      serialSend("x");
      break;
    case 22:
      serialSend("X");
      break;
    case 23:
      serialSend("y");
      break;
    case 24:
      serialSend("Y");
      break;      
    case 25:
      serialSend("z");
      break;
    case 32:
      serialSend("Z");
      break;
    case 33:
      // piston 1 down
      serialSend("q");
      break;
    case 34:
      // piston 1 up
      serialSend("1");
      break;
    case 35:
      // piston 2 down
      serialSend("w");
      break;
    case 36:
      // piston 2 up
      serialSend("2");
      break;
    case 37:
      // reset positions
      serialSend("r");
      break;
    case 38:
      // Initial position
      serialSend("s");
      break;
    case 39:
      // New layer
      serialSend("n");
      break;
    case 40:
      // Start printing
      serialSend("p");
      break;
    case 41:
      // Abort printing
      serialSend("q");
      break;
  }
}
public void saveFile(){

}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "Pwdr_GUI_V0_3" });
  }
}
