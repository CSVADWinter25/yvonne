import oscP5.*;
import netP5.*;
import controlP5.*;
import java.awt.Robot;
import java.awt.AWTException;
import java.util.ArrayList;

int cols = 25;
int rows = 25;
float cellSize;
String inputText = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!?@#$%^&*";
float[][] noiseValues;
ControlP5 cp5;
float timeFactor = 0;
int lastUpdateTime = 0;
int updateInterval = 8;
ArrayList<PVector> trail = new ArrayList<>();
int trailLength = 10;
float transitionFactor = 0.5;

OscP5 oscP5;
NetAddress maxAddress;
Robot robot;

// Spotlight properties
float spotlightX, spotlightY;
float spotlightRadius;  // **Now it's dynamic!**
boolean spotlightActive = false;
int spotlightTimer = 0;

// **Processing Delay Variables**
class DelayedTrigger {
    int triggerTime;
    DelayedTrigger(int t) {
        this.triggerTime = t;
    }
}
ArrayList<DelayedTrigger> pendingTriggers = new ArrayList<>();
int spotlightDelay = 100; // **100ms Delay**

String[] fonts = {"Courier New", "Arial", "Georgia", "Verdana"};
int selectedFontIndex = 0;
PFont customFont;

void setup() {
  size(800, 800);
  frameRate(30);
  cellSize = width / cols;
  noiseValues = new float[cols][rows];

  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      noiseValues[i][j] = random(1000);
    }
  }

  oscP5 = new OscP5(this, 7402);
  maxAddress = new NetAddress("127.0.0.1", 7400);

  try {
    robot = new Robot();
  } catch (AWTException e) {
    println("Error initializing Robot: " + e.getMessage());
  }

  cp5 = new ControlP5(this);

  cp5.addSlider("transitionFactor")
     .setPosition(550, 10)
     .setSize(150, 20)
     .setRange(0, 1)
     .setValue(0.5)
     .onChange(event -> transitionFactor = event.getController().getValue());

  cp5.addTextfield("Input Text")
     .setPosition(20, 10)
     .setSize(300, 30)
     .setFont(createFont("Arial", 18))
     .setAutoClear(false)
     .onChange(event -> {
         inputText = cp5.get(Textfield.class, "Input Text").getText();
         if (inputText.length() > 50) {
           inputText = inputText.substring(0, 50);
         }
         sendOscMessage("/text", inputText);
     });

  cp5.addScrollableList("Font Selector")
     .setPosition(350, 10)
     .setSize(150, 100)
     .setBarHeight(30)
     .setItemHeight(20)
     .addItems(java.util.Arrays.asList(fonts))
     .onChange(event -> {
         selectedFontIndex = (int) event.getController().getValue();
         customFont = createFont(fonts[selectedFontIndex], cellSize * 0.8);
         textFont(customFont);
         sendOscMessage("/font", selectedFontIndex + 1);
     });

  customFont = createFont(fonts[selectedFontIndex], cellSize * 0.8);
  textFont(customFont);
  textAlign(CENTER, CENTER);
}

void draw() {
  background(22, 55, 162);

  timeFactor += 0.05;

  // **Check if it's time to activate any delayed spotlights**
  for (int i = pendingTriggers.size() - 1; i >= 0; i--) {
    if (millis() - pendingTriggers.get(i).triggerTime >= spotlightDelay) {
      activateSpotlight();
      pendingTriggers.remove(i);
    }
  }

  if (spotlightActive) {
    spotlightTimer--;
    if (spotlightTimer <= 0) {
      spotlightActive = false; 
    }
  }

  // **Step 1: Draw the Spotlight Effect (Background Light)**
  if (spotlightActive) {
    drawSpotlightGradient(spotlightX, spotlightY, spotlightRadius);
  }

  // **Step 2: Draw the Text (Always Black)**
  if (millis() - lastUpdateTime > updateInterval) {
    lastUpdateTime = millis();

    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        float baseX = i * cellSize + cellSize / 2;
        float baseY = j * cellSize + cellSize / 2;

        float waveX = baseX + map(noise(noiseValues[i][j] + timeFactor), 0, 1, -30, 30);
        float waveY = baseY + map(noise(noiseValues[i][j] + timeFactor + 1000), 0, 1, -30, 30);
        float x = lerp(baseX, waveX, transitionFactor);
        float y = lerp(baseY, waveY, transitionFactor);

        char displayChar = inputText.charAt((i + j) % inputText.length());

        fill(20, 50, 160); // **Always Black Text**
        textFont(customFont);
        textSize(cellSize);
        text(displayChar, x, y);
      }
    }
  }
}

// **Realistic Spotlight Effect: Lightens Background but Keeps Text Visible**
void drawSpotlightGradient(float x, float y, float radius) {
  noStroke();  
  for (float r = radius; r > 0; r -= 4) {  
    float alpha = map(r, 0, radius, 100, 0);  // **Soft Light Effect**
    fill(255, alpha);
    ellipse(x, y, r * 2, r * 2);
  }
}

// **Updated OSC Function: Adds a delay before activating the spotlight**
void oscEvent(OscMessage msg) {
    println(">>> Received OSC message! Raw: " + msg);
    
    if (msg.arguments().length > 0) {
        try {
            int receivedValue = msg.get(0).intValue();
            println("Received Integer: " + receivedValue);

            // **Every single `1` gets delayed but still activates**
            if (receivedValue == 1) {
                pendingTriggers.add(new DelayedTrigger(millis())); // Store timestamp
                println("Spotlight queued for activation in " + spotlightDelay + "ms.");
            }
        } catch (Exception e) {
            println("Error parsing integer: " + e.getMessage());
        }
    } else {
        println("Error: No arguments in OSC message.");
    }
}

// **Move Spotlight to a New Position with a Randomized Radius**
void activateSpotlight() {
  spotlightX = random(width);
  spotlightY = random(height);
  spotlightRadius = random(70, 200); // **Random spotlight size**
  spotlightActive = true;
  spotlightTimer = 30;  
  println("Spotlight activated at: " + spotlightX + ", " + spotlightY + " with radius: " + spotlightRadius);
}

// **Send OSC Messages to Max**
void sendOscMessage(String address, Object value) {
  OscMessage oscMsg = new OscMessage(address);
  if (value instanceof String) {
    oscMsg.add((String) value);
  } else if (value instanceof Integer) {
    oscMsg.add((Integer) value);
  }
  oscP5.send(oscMsg, maxAddress);
}
