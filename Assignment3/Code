import controlP5.*;

CatHead myCatHead;
ControlP5 cp5;

// Parameters controlled by UI
float earSize = 0.12;
float eyeSize = 0.05;
float headStretch = 1.2;
float lightingColor = 100;
float mouthExpression = 0.5;

// Rotation control
float rotationY = 0;  // Current rotation
float targetRotationY = 0; // Target rotation (smooth transition)

// Mouse dragging variables
float lastMouseX = 0;

void setup() {
  size(800, 800, P3D);
  noStroke();
  
  // Initialize ControlP5 sliders
  cp5 = new ControlP5(this);
  
  cp5.addSlider("earSize")
     .setPosition(20, 20)
     .setSize(150, 20)
     .setRange(0.06, 0.20)
     .setValue(0.15)
     .setBroadcast(false)
     .addListener(e -> earSize = e.getController().getValue());

  cp5.addSlider("eyeSize")
     .setPosition(20, 50)
     .setSize(150, 20)
     .setRange(0.03, 0.075)
     .setValue(0.05)
     .setBroadcast(false)
     .addListener(e -> eyeSize = e.getController().getValue());

  cp5.addSlider("headStretch")
     .setPosition(20, 80)
     .setSize(150, 20)
     .setRange(1.05, 1.9)
     .setValue(1.2)
     .setBroadcast(false)
     .addListener(e -> headStretch = e.getController().getValue());

  cp5.addSlider("lightingColor")
     .setPosition(20, 110)
     .setSize(150, 20)
     .setRange(1, 255)
     .setValue(100)
     .setBroadcast(false)
     .addListener(e -> lightingColor = e.getController().getValue());

  cp5.addSlider("mouthExpression") // 🎭 New slider for mouth expressions
     .setPosition(20, 140)
     .setSize(150, 20)
     .setRange(-0.65, 0.65) // -1 = Sad, 0 = Neutral, 1 = Happy
     .setValue(0.26)
     .setBroadcast(false)
     .addListener(e -> mouthExpression = e.getController().getValue());

  // Create CatHead (values will be updated dynamically)
  myCatHead = new CatHead(0, 0, 0, 300);
}

void draw() {
  background(200, 230, 255);
  lights();
  ambientLight(lightingColor / 1.5 , lightingColor, 50 *sin(lightingColor));
  noStroke();

  // 🔹 Smooth rotation transition using lerp()
  rotationY = lerp(rotationY, targetRotationY, 0.1);
  
  // 🔹 Apply rotation to the cat head
  pushMatrix();
  translate(width/2, height/2);
  rotateY(rotationY);

  myCatHead.display(earSize, eyeSize, headStretch, mouthExpression);  // ✅ Uses dynamic values

  popMatrix(); // Ends transformation, so UI remains fixed
}

// 🖱️ Rotate by Dragging the Mouse
void mousePressed() {
  lastMouseX = mouseX;  // Store starting mouse position when clicked
}

void mouseDragged() {
  float dragSpeed = 0.005;  // Adjust sensitivity (higher = more sensitive)
  float deltaX = mouseX - lastMouseX;  // Difference in X movement
  targetRotationY += deltaX * dragSpeed;  // Update target rotation based on drag
  lastMouseX = mouseX;  // Update last position
}

// 🐱 CatHead Class (Now with a Smiling Mouth!)
class CatHead {
  float x, y, z;
  float size;
  PShape head;

  CatHead(float x, float y, float z, float size) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.size = size;
    createHead();
  }

  void createHead() {
    head = createShape(SPHERE, size/2);
  }

  void display(float earSize, float eyeSize, float headStretch, float mouthExpression) {
    pushMatrix();
    translate(x, y, z);

    //Draw Head (Now Filled with White)
    pushMatrix();
    pushStyle();
    fill(255);
    noStroke();
    scale(headStretch, 1.0, 1.0);
    shape(head);
    popStyle();
    popMatrix();

    drawCone(-size * 0.25, (-size * 0.5)-50, 0, size * earSize, size * earSize * 4, color(255));
    drawCone(size * 0.25, -size * 0.5 - 50, 0, size * earSize, size * earSize * 4, color(255));

    // ⚫ Draw Eyes (Now controlled dynamically)
    drawSphere(-size * 0.2, -size * 0.1, size * 0.45, size * eyeSize, color(0));
    drawSphere(size * 0.2, -size * 0.1, size * 0.45, size * eyeSize, color(0));

    // 🔴 Draw Nose
    drawSphere(0, size * 0.1, size * 0.5, size/15, color(255, 100, 100));

    // 😀 Draw Mouth (Sad → Neutral → Happy)
    drawMouth(0, size * 0.25, size * 0.5, size * 0.3, mouthExpression);

    popMatrix();
  }

  // 🟠 Function to draw a cone (for ears)
  void drawCone(float x, float y, float z, float radius, float height, int c) {
    pushMatrix();
    translate(x, y, z);
    rotateX(radians(20));
    PShape cone = createShape();
    cone.beginShape(TRIANGLE_FAN);
    cone.fill(c);

    cone.vertex(0, -height/2, 0);
    int detail = 20;
    for (int i = 0; i <= detail; i++) {
      float angle = TWO_PI * i / detail;
      float vx = cos(angle) * radius;
      float vz = sin(angle) * radius;
      cone.vertex(vx, height/2, vz);
    }

    cone.endShape();
    shape(cone);
    popMatrix();
  }

  // ⚫ Function to draw a sphere (for eyes and nose)
  void drawSphere(float x, float y, float z, float r, int c) {
    pushMatrix();
    translate(x, y, z);
    pushStyle();
    fill(c);
    noStroke();
    PShape sphere = createShape(SPHERE, r);
    shape(sphere);
    popStyle();
    popMatrix();
  }

  // 😀 Function to draw a Smiling Mouth
  void drawMouth(float x, float y, float z, float w, float expression) {
    pushMatrix();
    translate(x, y, z);
    rotateX(radians(10));  // Slight tilt to match face

    stroke(0);
    strokeWeight(3);
    noFill();

    float curveHeight = w * expression * 0.5;  // -1 = Sad, 1 = Happy

    beginShape();
    vertex(-w/2, 0);
    bezierVertex(-w/4, curveHeight, w/4, curveHeight, w/2, 0); // Creates dynamic smile or frown
    endShape();

    popMatrix();
  }
}
