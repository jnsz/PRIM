class Circle {  

  float radius = 0;
  float radiusDest = 0;

  // stored in radians
  float rotationSpeed;

  PVector cPos;

  int nPoints;
  ArrayList<CirclePoint> points = new ArrayList<CirclePoint>();
  ArrayList<CirclePoint> pointsToRemove = new ArrayList<CirclePoint>();

  Circle() {

    rotationSpeed = 0;

    cPos = new PVector(300, 300);

    nPoints = 2;
    points.add(new CirclePoint( radius, 0 ));
    points.add(new CirclePoint( radius, 180 ));
  }

  // SET ROTATION SPEED 
  void setRotSpeed(float rs) {
    rotationSpeed = radians(rs);
  }

  // ADD POINT
  void addPoint() { 
    // INSERT POINT AT RANDOM LOC
    //int spawnPoint = Math.round( random(points.size() - 1) );    
    //float spawnAngle = degrees( points.get( spawnPoint ).angle );
    //points.add(spawnPoint, new CirclePoint( radius, spawnAngle ));

    // APPEND POINT AS LAST
    float spawnAngle = degrees( points.get( points.size() - 1 ).angle );
    points.add(new CirclePoint( radius, spawnAngle ));

    distributePoints();
   
  }

  // REMOVE POINT
  void removePoint() {    
    // if(points.size() > 2){  points.remove( points.size() - 1 );  }   

    if (points.size() > 2) {  
      CirclePoint p = points.get( points.size() - 1 );
      
      // points to merge with
      CirclePoint q = points.get( points.size() - 2 );
      p.setDestinationAngle( degrees(q.angle) );

      points.remove(p);
      pointsToRemove.add(p);
    }   

    distributePoints();
  }

  void distributePoints() {
    int n = points.size();
    float angleStep = 360.0/n;
    float firstPointAngle = degrees(points.get(0).destAngle);


    for ( int i = 0; i < n; i++ ) {
      CirclePoint p = points.get(i);
      p.setDestinationAngle( angleStep * i + firstPointAngle );
    }
  }

  // UPDATE POS OF ALL POINTS ON CIRCLE
  void update() { 
    radius += (radiusDest - radius) * 0.1;
    
    if (points.size() < nPoints) {
      addPoint();
    } else if (points.size() > nPoints) {
      removePoint();
    }

    for ( CirclePoint p : points) {
      p.radius = radius;
      p.angle += rotationSpeed;
      p.destAngle += rotationSpeed;

      p.updatePos();
    }

    if ( pointsToRemove.size() >= 0 ) {
      for ( int i = 0; i < pointsToRemove.size(); i++ ) {
        CirclePoint p = pointsToRemove.get(i);
        p.radius = radius;
        
        p.setDestinationAngle( degrees( points.get( points.size() - 1 ).angle) );
        p.updatePos();
        
        float angle = round(p.angle * 10); 
        float destAngle = round(p.destAngle * 10);
        if (angle == destAngle) {
          pointsToRemove.remove( p );
        }
      }
    }
  }

  // DRAW CIRCLE
  void drawCircle(boolean center, boolean circle, boolean points, boolean lines) {
    if (center) {
      strokeWeight(20);
      point(cPos.x, cPos.y);
    }
    if (circle) {
      strokeWeight(5);
      ellipse(cPos.x, cPos.y, radius*2, radius*2);
    }
    if (points || lines) {
      for (CirclePoint p : this.points) {
        p.drawPoint(points, lines);
      }
    }
  }
}