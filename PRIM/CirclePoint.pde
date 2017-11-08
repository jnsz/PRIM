class CirclePoint{
  
  float radius;
  
  float radiusNoise;
  float time = random(0,1000);
  
  color pointColor;
  
  // stored in radians
  float angle;  
  float destAngle;
  
  PVector pos;
  PVector cPos;
  
  CirclePoint(float r, float a){
    radius = r;
    
    angle = radians(a);
    destAngle = angle;
    
    pos = new PVector(radius * sin(angle), radius * cos(angle));
    cPos = new PVector(0,0);
  }
  
  
  void setDestinationAngle(float a){
    destAngle = radians(a);
    
    if ( Math.abs( destAngle - angle ) > Math.PI )
      {
        if ( destAngle > angle ) angle += Math.PI * 2;
        else destAngle += Math.PI * 2;
      }    
  }
  
   
  void updatePos(){
    angle += (destAngle - angle) * 0.7;
    
    radiusNoise = noise(time);
    
    float newRadius = radius + map(radiusNoise, 0, 1, -s_noiseStr, s_noiseStr);
    
    pos.x = newRadius * sin(angle);
    pos.y = newRadius * cos(angle);
    
    
    time += 0.01;
  }
  
  ////////////////////////////////////////////
  void drawPoint(boolean point, boolean line){
    
    strokeWeight(15);
    if(point) point(pos.x, pos.y);
    
    strokeWeight(3);
    if(line) line(pos.x, pos.y, cPos.x, cPos.y); 
    
  }
}