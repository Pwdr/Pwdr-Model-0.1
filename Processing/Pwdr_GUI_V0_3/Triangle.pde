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
  
  void Scale(float Factor)
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
  
  
  void Translate(float tX, float tY, float tZ)
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
  void RotateZ(float Angle)
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
  void RotateY(float Angle)
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
  void RotateX(float Angle)
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
  Line2D GetZIntersect(float ZLevel)
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
  void Resort()
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
