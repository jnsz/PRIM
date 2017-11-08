///////////////////////////////////////////////////////
//                        PRIM                       //
///////////////////////////////////////////////////////
// Using leap motion move your hands up and down, forwards and backwards and tilt them site to site to generate ornaments.
// Sometimes a bug will happen and things will change.
// You can also force change by clenching your fists, putting them together and than moving them apart to the sides.
// For more precise controls, you can use keyboard shortcuts.
//
// CONTROLS
// q - line style
// w - curve style
// e - dot style
//
// + - stroke++
// - - stroke--
//
// a - random offset
// s - random style change
// d - random color
// f - B&W color
// g - toggle ghosting
//
// r - reset
// y - screenshot  
// space - freeze // disabled
///////////////////////////////////////////////////////

import processing.pdf.*;
import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;
import de.voidplus.leapmotion.*;

// TINKER WITH THESE
final float minRadius_ = 0;                  // min size of shape 
float maxRadius_;                            // max size of shape
final int maxPoints_ = 15;                   // max points on circle
final float maxRotSpeed_ = 5;                // max rotation speed

// OTHER VARIABLES
color bgColor = color(0, 0, 0);              // bg color
color compColor = color(0, 0, 100);          // comp color 
float strokeWeight = 2;                      // stroke weight

boolean s_ghosting = false;                  // ghosting style
int s_style = 0;                             // style type 
float s_noiseStr = 0;                        // strength of point offset caused by noise
float s_pointOffset = 0;                     // strength of connectiong points offset caused by noise
int s_nDots = 10;                            // number of dots in dot style

LeapMotion leap;                             // leap motion variables
Hand mainHand = null;                        // main hand
Hand offHand = null;                         // off hand

PVector mhPos = new PVector(0, 0, -30);      // mh position
PVector ohPos = new PVector(0, 0, -30);      // oh position

float mhRot = 0;                             // mh rotataion
float ohRot = 0;                             // oh rotation

boolean isMHPinching = false;                // is mh pinching
boolean isOHPinching = false;                // is oh pinching

boolean snapTaken = false;                   // screenshot taken

boolean isMHGrabbing = false;                // is mh grabbing
boolean isOHGrabbing = false;                // is oh grabbing

boolean grabbing = false;                    // are hands grabbing
float grabStartDist = -1;                    // distance between hands


Circle circle1 = new Circle();               // circle 1
Circle circle2 = new Circle();               // circle 2

boolean isFreezed = false;

final String initTime = timestamp();         // initial time for photo timestamps

int time;
int prevStyle;
int bugTime;
					 
// SOUND
Minim minim;
AudioOutput output;
InstRandomGranulator i;					 
					   
void setup() {
  //fullScreen();
  size(1200,900);
  //size(3508, 2480);
  frameRate(24); 
  smooth();

  colorMode(HSB, 360, 100, 100);  
  compColor = complementaryColor(bgColor);
  strokeCap(ROUND);  

  leap = new LeapMotion(this);  
  maxRadius_ = height/3;
  
  // SOUND
  minim = new Minim(this);  
  output = minim.getLineOut();

  i = new InstRandomGranulator(output);
  output.playNote(0,10000,i);
}

void draw() {
  doBug();  
  
  pushMatrix();
  if (s_ghosting) {
    fill(bgColor, 50);
    noStroke();
    rect(-10, -10, width+20, height+20);
  } 
  else background(bgColor);

  fill(compColor);
  stroke(compColor);
  strokeWeight(strokeWeight);
 
  if(!isFreezed) getHands();

  translate(width/2, height/2);                                                                              // CRYSTAL POSITION

  circle1.radiusDest = clamp( map( mhPos.z, -10, 60, minRadius_, maxRadius_ ), minRadius_, maxRadius_);      // circle 1 radius
  circle1.setRotSpeed( map( mhRot, -180, 180, maxRotSpeed_, -maxRotSpeed_ ) );                               // circle 1 rotation
  circle1.nPoints = int( round( clamp( map( mhPos.y, 700, -600, 2, maxPoints_ ), 2, maxPoints_ ) ) );        // circle 1 points
  circle1.update();                                                                                          // circle 1 update

  circle2.radiusDest = clamp( map( ohPos.z, -10, 60, minRadius_, maxRadius_ ), minRadius_, maxRadius_ );     // circle 2 radius
  circle2.setRotSpeed( map( ohRot, -180, 180, maxRotSpeed_, -maxRotSpeed_ ) );                               // circle 2 rotation
  circle2.nPoints = int( round( clamp( map( ohPos.y, 400, -600, 2, maxPoints_ ), 2, maxPoints_ ) ) );        // circle 2 points
  circle2.update();                                                                                          // circle 2 updates

  if ( mainHand != null && offHand != null )grabSwap();

  connectPoints(circle1, circle2);  

  popMatrix();
  //////////////////////////////////////////////////////
  //                     SOUND                        //
  //////////////////////////////////////////////////////  
  
  float f1 = map( circle1.nPoints, 2, maxPoints_, 50, 200 );
  //float a1 = map( circle2.radius, maxRadius_, minRadius_, 0.2, 0.5 );
  
  float speedOfSine = map(degrees(circle1.rotationSpeed), maxRotSpeed_, -maxRotSpeed_,500,2000);
  float a1 = clamp(map(sin(millis()/speedOfSine), -1,1, -0.9,0.9),-0.9,0.9);
  

  
  float f2 = map( circle2.nPoints, 2, maxPoints_, 200, 50 );
  //float a2 = map( circle2.radius, maxRadius_, minRadius_, 0.5, 0.9 );
  
  speedOfSine = map(degrees(circle2.rotationSpeed), maxRotSpeed_, -maxRotSpeed_,500,2000);
  float a2 = clamp(map(cos(millis()/speedOfSine), -1,1, -0.9,0.9),-0.9,0.9);
  
  i.setOsc1( f1, a1 );
  i.setOsc2( f2, a2 );

  //////////////////////////////////////////////////////
  
  //drawDebugWaveform();
  //snap();   //takes a snap if you are pinching
  debug();  //displays the debug dots at the bottom
}

void connectPoints(Circle c1, Circle c2) {
  ArrayList<CirclePoint> p1 = new ArrayList(); 
  p1.addAll(c1.points);
  p1.addAll(c1.pointsToRemove);
  ArrayList<CirclePoint> p2 = new ArrayList();
  p2.addAll(c2.points);
  p2.addAll(c2.pointsToRemove);

  noFill();

  switch(s_style) {
  case 0:
    for ( CirclePoint outerP : p1 ) {
      for ( CirclePoint innerP : p2 ) {   
        line( outerP.pos.x, outerP.pos.y, innerP.pos.x, innerP.pos.y );
      }
    }
    break;

  case 1:
    int p1size = p1.size();
    int p2size = p2.size();

    for ( int i = 0; i < p1size; i++ ) {    
      for ( int j = 0; j < p2size; j++ ) {  
        beginShape();
        curveVertex( p2.get( abs((j - 1) % p2size) ).pos.x, p2.get( abs((j - 1) % p2size) ).pos.y);  
        curveVertex( p1.get(i).pos.x, p1.get(i).pos.y );
        curveVertex( p2.get( j ).pos.x, p2.get( j ).pos.y);
        curveVertex( p2.get( (j + 1) % p2size ).pos.x, p2.get( (j + 1) % p2size ).pos.y);      
        endShape();
      }
    }
    break;

  case 2:
    for ( CirclePoint outerP : p1 ) {
      for ( CirclePoint innerP : p2 ) { 
        for ( int i = 0; i <= s_nDots; i++ ) {
          float x = lerp(outerP.pos.x, innerP.pos.x, float(i)/s_nDots );
          x += map( noise(frameCount * i), 0, 1, -s_pointOffset, s_pointOffset);
          float y = lerp(outerP.pos.y, innerP.pos.y, float(i)/s_nDots );
          y += map( noise(0, frameCount * i), 0, 1, -s_pointOffset, s_pointOffset);
          point(x, y);
        }
      }
    }
    break;
  }
}

void getHands() {
  switch(leap.getHands().size()) {

  case 0:
    mainHand = null;
    offHand = null;
    break;

  case 1:
    mainHand = leap.getHands().get(0);
    offHand = null;    
    break;

  default:
    mainHand = leap.getHands().get(0);
    offHand = leap.getHands().get(1);
    break;
  }

  if (mainHand != null) {


    mhPos = mainHand.getPosition();
    mhRot = mainHand.getRoll();


    if ( mainHand.getGrabStrength() > 0.99 ) isMHGrabbing = true;
    else isMHGrabbing = false;

    if ( mainHand.getPinchStrength() > 0.99 ) isMHPinching = true;
    else isMHPinching = false;
  }

  if (offHand != null) {
    ohPos = offHand.getPosition();
    ohRot = offHand.getRoll();

    if ( offHand.getGrabStrength() > 0.99 ) isOHGrabbing = true;
    else isOHGrabbing = false;

    if ( offHand.getPinchStrength() > 0.99 ) isOHPinching = true;
    else isOHPinching = false;
  }
}

void snap() {
  if (( isMHPinching || isOHPinching) && !snapTaken ) {
    saveFrame("snaps\\session_" + initTime + "\\snap_" + initTime + "_#####.png");
    snapTaken = true;

    strokeWeight(20);
    
    rect(0, 0, width, height);
    strokeWeight(strokeWeight);
  } else if ( ( !isMHPinching && !isOHPinching ) && snapTaken ) {
    snapTaken = false;
  }
}

void debug() {  
  strokeWeight(10);
  fill(bgColor);

  if (mainHand != null) {    
    point( (width / 2) - 10, height - 10);
  }
  if (offHand !=null) {
    point((width / 2) + 10, height - 10);
  }
  
  strokeWeight(2);
  
  if(isFreezed){
    line((width / 2) - 18, height - 10,(width / 2) + 18, height - 10);
  }
  
  strokeWeight(strokeWeight);
}

void grabSwap() {
  float handDist = mhPos.dist(ohPos);

  // is user grabbing?
  if (isMHGrabbing && isOHGrabbing) {
    if (!grabbing) {
      grabbing = true;
      grabStartDist = handDist;
    }
  } else {
    grabbing = false;
  }


  if (handDist > grabStartDist + 300 && grabStartDist != -1) {
    grabStartDist = -1;

    // do pull code
    changeStyle();
  }
}

void changeStyle() {
  bgColor = color(random(360), 100, 100);
  compColor = color( (hue(bgColor) + 180) % 360, 100, 100);
  
  
  if (random(0, 1) > .5) {
    s_ghosting = !s_ghosting;
  }
  
  if (random(0, 1) > .5) {
    s_style = round(random(0, 2));
    if (s_style == 2) {
      s_nDots= round( random(6, 50) );
    }
  }
  if (random(0, 1) > .5) {
    strokeWeight = random(1, 5);
  }
  
  
  if (random(0, 1) > .5) {
    if (s_noiseStr == 0) s_noiseStr = 300;  
    else s_noiseStr = 0;
  }
  
  changeWave();
}

void keyPressed() {  
  if (key == 'q'|| key == 'Q') {
    s_style = 0; 
    changeWave();
  }
  if (key == 'w'|| key == 'W') {
    s_style = 1;
    changeWave();
  }
  if (key == 'e'|| key == 'E') {
    s_style = 2;
    s_nDots = round( random(6, 50));
    changeWave();
  }

  if (key == '+') strokeWeight++;
  if (key == '-') if (strokeWeight > 1) strokeWeight--;

  if (key == 'a' || key == 'A') {
    if (s_noiseStr == 0) s_noiseStr = 300;  
    else s_noiseStr = 0;
  }
  if (key == 'g' || key == 'G') s_ghosting = !s_ghosting;
  if (key == 'f' || key == 'F') {
    bgColor = color(0, 0, 0);
    compColor = color(0, 0, 100);
  };
  if (key == 'd' || key == 'D') {
    bgColor = color(random(360), 100, 100);
    compColor = color( (hue(bgColor) + 180) % 360, 100, 100);
  };

  if (key == 'r' || key == 'R') {    
    s_ghosting = false;
    s_style = 0;
    s_noiseStr = 0;
    s_pointOffset = 0;
    strokeWeight = 2;
    s_nDots = 10;
    bgColor = color(0, 0, 0);
    compColor = color(0, 0, 100);
    i.setWave(Waves.TRIANGLE);    
  }

  if (key == 's' || key == 'S') changeStyle();

  if (key == 'y' || key == 'Y') saveFrame("screenshots\\session_" + initTime + "\\screenshot_" + initTime + "_#####.png");
  
  //if (key == ' ') isFreezed = !isFreezed;  
}

void changeWave(){
    switch(s_style){
    case 0: 
      i.setWave(Waves.TRIANGLE); 
      break;
    case 1:
      i.setWave(Waves.SINE);
      break;
    case 2:
      i.setWave(Waves.TRIANGLE);
      break;
    default:
      i.setWave(Waves.TRIANGLE); 
      break;
  } 
}

void doBug(){
  if(s_pointOffset == 20 && millis() - time > bugTime) {
    s_style = prevStyle;
    s_pointOffset = 0;
    changeWave();
    bugTime = int(random (1000,10000));
    time = millis();
    
    if(random(0,1) > 0.9){
      changeStyle();
    }
  }
  else if(s_pointOffset == 0 && millis() - time > bugTime){
    if (random(0, 1) > .7) {
      prevStyle = s_style;
      s_style = 2;
      s_pointOffset = 20;
      i.setWave(Waves.SQUARE);
      bugTime = int(random (1,1000));
      time = millis();
    }
  }
}

void drawDebugWaveform(){
  for(int i = 0; i < output.bufferSize() - 1; i++)
  {
    line( i, 50  - output.left.get(i)*50,  i+1, 50  - output.left.get(i+1)*50 );
  } 
}
 