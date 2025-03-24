class FlockBird {
  PVector position, velocity, acceleration;
  float maxSpeed = 1.5;
  float maxForce = 0.05;

  FlockBird(float x, float y) {
    position = new PVector(x, y);
    velocity = PVector.random2D().mult(1.5);
    acceleration = new PVector();
  }

  void applyForce(PVector force) {
    acceleration.add(force);
  }

  void flock(ArrayList<FlockBird> flock) {
    applyForce(align(flock));
    applyForce(cohere(flock));
    applyForce(separate(flock));
  }

  PVector align(ArrayList<FlockBird> flock) {
    float perceptionRadius = 100;
    PVector avgVelocity = new PVector();
    int count = 0;

    for (FlockBird other : flock) {
      float d = PVector.dist(position, other.position);
      if (other != this && d < perceptionRadius) {
        avgVelocity.add(other.velocity);
        count++;
      }
    }

    if (count > 0) {
      avgVelocity.div(count);
      avgVelocity.setMag(maxSpeed);
      return PVector.sub(avgVelocity, velocity).limit(maxForce);
    }
    return new PVector();
  }

  PVector cohere(ArrayList<FlockBird> flock) {
    float perceptionRadius = 100;
    PVector center = new PVector();
    int count = 0;

    for (FlockBird other : flock) {
      float d = PVector.dist(position, other.position);
      if (other != this && d < perceptionRadius) {
        center.add(other.position);
        count++;
      }
    }

    if (count > 0) {
      center.div(count);
      return seek(center);
    }
    return new PVector();
  }

  PVector separate(ArrayList<FlockBird> flock) {
    float perceptionRadius = 50;
    PVector repulsion = new PVector();
    int count = 0;

    for (FlockBird other : flock) {
      float d = PVector.dist(position, other.position);
      if (other != this && d < perceptionRadius) {
        PVector diff = PVector.sub(position, other.position);
        diff.div(d);
        repulsion.add(diff);
        count++;
      }
    }

    if (count > 0) {
      repulsion.div(count);
      repulsion.setMag(maxSpeed);
      return PVector.sub(repulsion, velocity).limit(maxForce);
    }
    return new PVector();
  }

  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);
    desired.setMag(maxSpeed);
    return PVector.sub(desired, velocity).limit(maxForce);
  }

  void update() {
    velocity.add(acceleration);
    velocity.limit(maxSpeed);
    position.add(velocity);
    acceleration.mult(0);

    if (position.x > width) position.x = 0;
    if (position.x < 0) position.x = width;
    if (position.y > height) position.y = 0;
    if (position.y < 0) position.y = height;
  }

  void display() {
    // **Calculate distance from center**
    float distToCenter = dist(position.x, position.y, width / 2, height / 2);
    float maxDist = dist(0, 0, width / 2, height / 2);

    // **Map size based on distance (closer to center = bigger, further away = smaller)**
    float birdSize = map(distToCenter, 0, maxDist, 30, 10);  // Center: 30, Edge: 10

    shape(flyingBirdIcon, position.x - birdSize / 2, position.y - birdSize / 2, birdSize, birdSize);
  }
}

ArrayList<FlockBird> flock = new ArrayList<>();

void updateAndDrawFlock() {
  for (FlockBird fb : flock) {
    fb.flock(flock);
    fb.update();
    fb.display();
  }
}
