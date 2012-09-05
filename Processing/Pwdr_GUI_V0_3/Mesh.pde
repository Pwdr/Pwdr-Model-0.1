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

  
  void Scale(float Factor)
  {
    for(int i = Triangles.size()-1;i>=0;i--)
    {
      Triangle tri = (Triangle) Triangles.get(i);
      tri.Scale(Factor);
    }
    CalculateBoundingBox();
  }

  void Translate(float tx, float ty, float tz)
  {
    for(int i = Triangles.size()-1;i>=0;i--)
    {
      Triangle tri = (Triangle) Triangles.get(i);
      tri.Translate(tx,ty,tz);
    }
    CalculateBoundingBox();
  }

  void CalculateBoundingBox()
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
float bin_to_float(byte b0, byte b1, byte b2, byte b3)
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
float CleanFloat(float Value)
{
  Value = Value * 1000;
  Value = round(Value);
  return Value / 1000;
}
