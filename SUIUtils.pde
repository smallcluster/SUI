public float clamp(float val, float min, float max){
  return val < min ? min : val > max ? max : val;
}

public int clamp(int val, int min, int max){
  return val < min ? min : (val > max ? max : val);
}

class Transform {
  PVector location;
  PVector rotation;
  PVector scale;
  
  public Transform(){
    location = new PVector(0, 0, 0);
    rotation = new PVector(0, 0, 0);
    scale = new PVector(1, 1, 1);
  }
}

class Rectangle{
  
  float x, y, w, h;
  Rectangle(){
    x = 0;
    y = 0;
    w = 0;
    h = 0;
  }
  boolean pointInside(PVector p){
    return (p.x >= x && p.x <= x+w && p.y >= y && p.y <= y+h);
  }
  boolean pointInside(float x, float y){
    return (x >= this.x && x <= this.x+w && y >= this.y && y <= this.y+h);
  }
}
