

import java.net.*;
import java.io.*;
import controlP5.*;
import processing.svg.*;
import oscP5.*;
import netP5.*;


String apiKey = "54tgetucs2st"; 
String searchBird = "Owl"; 
boolean dataReceived = false;
OscP5 oscP5;
NetAddress maxMsp;

PShape usMap, birdIcon, flyingBirdIcon;
PFont coolFont;
ControlP5 cp5;
Textfield inputField;
float colorShift = 0;
float minLat = 24.396308, maxLat = 49.384358;
float minLng = -125.0, maxLng = -66.93457;

void setup() {
  size(1000, 600, P2D);
  smooth();
  background(255);
  
  // Initialize OSC for communication
  oscP5 = new OscP5(this, 12000); // Processing listens on port 12000
  maxMsp = new NetAddress("127.0.0.1", 7401); // Max MSP listens on port 7401

  usMap = loadShape("mapmap.svg");
  birdIcon = loadShape("bird-2.svg");
  flyingBirdIcon = loadShape("flyingbird.svg");

  coolFont = createFont("Arial", 16, true);
  textFont(coolFont);
  textAlign(CENTER, CENTER);
  fill(0);

  cp5 = new ControlP5(this);
  
    cp5.addButton("Start")
     .setPosition(20, 550)
     .setSize(50, 30)
     .onPress(new CallbackListener() {
       public void controlEvent(CallbackEvent event) {
         sendPlaybackOSC(1); // 发送 1
       }
     });

  // ✅ 添加 Stop 按钮（发送 0）
  cp5.addButton("Stop")
     .setPosition(80, 550)
     .setSize(50, 30)
     .onPress(new CallbackListener() {
       public void controlEvent(CallbackEvent event) {
         sendPlaybackOSC(0); // 发送 0
       }
     });
  
  inputField = cp5.addTextfield("Bird Name")
                  .setPosition(20, height - 100)
                  .setSize(120, 30)
                  .setFont(createFont("Arial", 14, true))
                  .setAutoClear(true);

  for (int i = 0; i < int(random(10, 20)); i++) {
    flock.add(new FlockBird(random(width), random(height)));
  }
}

void draw() {
  background(255);
  drawMapDots();
  updateAndDrawBirds();
  updateAndDrawFlock();

  fill(100);
  textSize(20);
  text("Recent Sightings for: " + searchBird, 800, 30);
}

// Spotlight 目标位置（每隔几秒变换）
float spotlightX, spotlightY;
float targetX, targetY;
float changeTime = 0; // 记录上次变化时间






// **US Map Dots**
void drawMapDots() {
  float mapX = 50, mapY = 80;
  float mapWidth = width - 100, mapHeight = height - 130;
  if (usMap == null) return;

  for (int i = 0; i < usMap.getChildCount(); i++) {
    PShape region = usMap.getChild(i);
    if (region == null || region.getVertexCount() < 2) continue;

    int numVertices = region.getVertexCount();
    for (int j = 0; j < numVertices - 1; j++) {
      PVector v1 = region.getVertex(j);
      PVector v2 = region.getVertex(j + 1);
      
      float segmentLength = PVector.dist(v1, v2);
      int numDots = max(2, int(segmentLength / 12));

      for (int k = 0; k < numDots; k++) {
        float t = k / float(numDots - 1);
        float x = lerp(v1.x, v2.x, t);
        float y = lerp(v1.y, v2.y, t);

        float sx = map(x, 0, usMap.width, mapX, mapX + mapWidth);
        float sy = map(y, 0, usMap.height, mapY, mapY + mapHeight);

        noStroke();

        // **Random Flash Effect**
        float flashIntensity = random(0, 1);  // Each dot flashes independently
        int colorIndex = int(random(4));  // Pick a random color

        color dotColor;
        if (colorIndex == 0) {
          dotColor = lerpColor(color(255, 255, 255), color(50, 100, 255), flashIntensity);  // White → Blue
        } else if (colorIndex == 1) {
          dotColor = lerpColor(color(255, 255, 255), color(180, 50, 255), flashIntensity);  // White → Purple
        } else if (colorIndex == 2) {
          dotColor = lerpColor(color(255, 255, 255), color(50, 255, 200), flashIntensity);  // White → Cyan
        } else {
          dotColor = lerpColor(color(255, 255, 255), color(255, 180, 50), flashIntensity);  // White → Orange
        }

        fill(dotColor);
        ellipse(sx, sy, 3, 3);  // Keep dots small but visible
      }
    }
  }
}



// **Latitude/Longitude to Grid**
PVector latLngToGrid(float lat, float lng) {
  float x = map(lng, minLng, maxLng, 50, width - 50);
  float y = map(lat, maxLat, minLat, 80, height - 50);
  return new PVector(x, y);
}

void sendPlaybackOSC(int value) {
  OscMessage msg = new OscMessage("/playback");
  msg.add(value);
  oscP5.send(msg, maxMsp);
  println("[OSC] Sent playback: " + value);
}


// **API Callbacks**
void keyPressed() {
  if (key == ENTER || key == RETURN) {
    String userInput = inputField.getText().trim();
    if (!userInput.isEmpty()) {
      searchBird = userInput;
      fetchBirdData();
    }
  }
}

void mousePressed() {
  for (Bird b : birds) {
    if (b.isClicked(mouseX, mouseY)) {
      sendBirdToMaxMSP(b.species);
      break; // 只发送一个鸟的名字
    }
  }
}

void sendBirdToMaxMSP(String birdName) {
  OscMessage msg = new OscMessage("/birdSound");
  msg.add(birdName);
  oscP5.send(msg, maxMsp);
  println("[OSC] Sent bird name to Max MSP: " + birdName);
}



void fetchBirdData() {
  String urlString = "https://api.ebird.org/v2/data/obs/US/recent?key=" + apiKey;
  String jsonData = fetchJSON(urlString);

  if (jsonData != null && !jsonData.equals("")) {
    parseBirdResponse(jsonData);
  }
}

void parseBirdResponse(String json) {
  JSONArray birdObservations = parseJSONArray(json);
  birds.clear();

  if (birdObservations != null && birdObservations.size() > 0) {
    for (int i = 0; i < birdObservations.size(); i++) {
      JSONObject bird = birdObservations.getJSONObject(i);
      String speciesName = bird.getString("comName");

      if (speciesName.toLowerCase().contains(searchBird.toLowerCase())) {
        float lat = bird.getFloat("lat");
        float lng = bird.getFloat("lng");
        String locationName = bird.getString("locName");

        PVector screenPos = latLngToGrid(lat, lng);
        birds.add(new Bird(screenPos, speciesName, locationName));
      }
    }
    dataReceived = birds.size() > 0;
  }
}

String fetchJSON(String urlString) {
  try {
    URL url = new URL(urlString);
    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
    conn.setRequestMethod("GET");

    BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
    StringBuilder response = new StringBuilder();
    String line;
    
    while ((line = reader.readLine()) != null) {
      response.append(line);
    }
    reader.close();
    
    return response.toString();
  } catch (Exception e) {
    e.printStackTrace();
    return null;
  }
}
