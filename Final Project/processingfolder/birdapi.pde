class Bird {
  PVector position;
  String species;
  String location;
  boolean isHovered = false;

  Bird(PVector pos, String species, String location) {
    this.position = pos;
    this.species = species;
    this.location = location;
  }

  void update() {
    float d = dist(mouseX, mouseY, position.x, position.y);
    isHovered = d < 12;
  }

  void display() {
    shape(birdIcon, position.x - 8, position.y - 8, 16, 16);
    if (isHovered) {
      fill(0);
      textSize(14);
      textAlign(CENTER, CENTER);
      text(species + " - " + location, position.x, position.y - 20);
    }
  }

  // ✅ **添加 isClicked() 方法**
  boolean isClicked(float mx, float my) {
    float d = dist(mx, my, position.x, position.y);
    return d < 12; // 12 以内算是被点击
  }
}



ArrayList<Bird> birds = new ArrayList<>();

void updateAndDrawBirds() {
  for (Bird b : birds) {
    b.update();
    b.display();
  }
}
