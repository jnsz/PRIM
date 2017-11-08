import java.util.Calendar;

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

float clamp(float value, float min, float max){
  if(value < min) return min;
  if(value > max) return max;
  return value;  
}

int randomDirection(){
  float rand = random(-1,1);
  if(rand < 0) { return -1; }
  return 1;
}

color complementaryColor(color c){
  color output;  
  float hue = hue(c) + 180;
  if(hue > 360) hue %= 360;
  float sat = saturation(c);
  float bri = brightness(c) + 100;
  if(bri > 100) bri %=100; 
  output = color(hue, sat, bri);
  return output;
}