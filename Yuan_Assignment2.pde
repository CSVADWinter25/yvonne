int interval = 200; 
int lastGeneratedTime = 0;

ArrayList<float[]> patterns = new ArrayList<float[]>(); 

//[1,2,3,4,5]
//[[1.0,2.34 , 3,4,5], [1,2,3,4,5]

ArrayList<Boolean> fadeInFlags = new ArrayList<Boolean>(); 



void setup() {
  size(800, 800);     // canvas
  // background(255);   // set to white
  noStroke();        // no borders
}

void draw() {
  background(0); // set to black


  // Add a new pattern to the pattern array  
  if ((millis() - lastGeneratedTime) > interval) {
    
    patterns.add(new float[] {
      random(width - 50), // startX
      random(height - 50), // startY
      random(5, 20), // diameter
      random(40, 80), // squareLength
      random(100, 255), // r
      random(100, 255), // g
      random(100, 255), // b
      0 // a (initial alpha starts at 0 for fade-in)  
    });
    
    
    fadeInFlags.add(true); // Set fade-in flag for the new pattern
    
    // Dequeue the last one
    if (patterns.size() > 80) {
      patterns.remove(0);
      fadeInFlags.remove(0);
    }
    lastGeneratedTime = millis(); // Reset the timer
  }



  // Draw all stored patterns and update alpha
  for (int i = patterns.size() - 1; i >= 0; i--) {
    
    float[] p = patterns.get(i);
    boolean fadeIn = fadeInFlags.get(i);

    // Update alpha for fade-in or fade-out
    if (fadeIn) {
      p[7] += 5; // Increase alpha for fade-in
      if (p[7] >= 255) {
        p[7] = 255;
        fadeInFlags.set(i, false); // Switch to fade-out
      }
    } else {
      p[7] -= 0.3; // Decrease alpha for fade-out
            p[2] += 0.1; // remove me!

      if (p[7] <= 0) {
        patterns.remove(i); // Remove the pattern when alpha reaches 0
        fadeInFlags.remove(i);
        continue;
      }
    }

    // Draw the pattern with the current alpha
    circleInSquare(p[0], p[1], p[2], p[3], (int)p[4], (int)p[5], (int)p[6], (int)p[7]);
  }
}

// Function for one pattern
void circleInSquare(float startX, float startY, float diameter, float squareLength, int r, int g, int b, int a) {
  fill(r, g, b, a); // Apply color with current alpha
  for (float x = startX; x < startX + squareLength; x += diameter) {
    for (float y = startY; y < startY + squareLength; y += diameter) {
      ellipse(x, y, diameter, diameter); // Draw circles
    }
  }
}
