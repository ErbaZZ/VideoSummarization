import processing.video.*;
   
Movie theMov; 
int x,y = 0;
float movDur;
float frRate;
int windowWidth = 1080;
int windowHeight = 480;
String s = "";
int frameWidth = windowWidth / 6;
int frameHeight = windowHeight / 4;
int mode = 0;
float frCut = 0;
int frNum;
int dur;
int[] previousFrame;
int numPixels;
float minTime;
float lastTime = 0;
boolean first = true;

void setup() { 
  size(1080 , 480);
  background(255);
  textSize(20);
  noStroke();
  fill(0);
  text("Type u to select uniform summarization\n    or n to select non-uniform summarization\nand press enter", 50, 380);
  theMov = new Movie(this, "vid.mov"){
   @ Override public void eosEvent() {
      super.eosEvent();
      saveImg();
    } 
  };
  
}

void move() {
  if (x + frameWidth >= windowWidth){
    x = 0;
    y += frameHeight;
  }
  else {
    x += frameWidth;
  }
}

void saveImg() {
  if (mode == 111) {
    save("Out_uniform.jpg");
  }
  else {
    save("Out_non_uniform.jpg");
  }
  mode = 99;
}

void draw() {
  if (mode != 111 && mode != 99 && mode != 2) {
    fill(0);
    rect(0 , 455, windowWidth , 25);
    fill(255);
    text(s, 10, 475);
  }
  else if (mode == 111) {
    if (theMov.available()) {
      theMov.read();
      if(frCut <= movDur) {
        image(theMov, x, y, frameWidth, frameHeight);
        move();
        frCut += frRate;
        theMov.jump(frCut);
      }
      else {
        saveImg();
      }
    }
  }
  else if (mode == 2) {
    if (theMov.available()) {
      theMov.read();
      theMov.loadPixels();
      numPixels = theMov.width * theMov.height;
      minTime = theMov.duration() / 40;
      if (first) {
        previousFrame = new int[numPixels];
        arrayCopy(theMov.pixels, previousFrame);
        first = false;
      }
      float movementSum = 0; // Amount of movement in the frame
      for (int i = 0; i < numPixels; i++) {
        color currColor = theMov.pixels[i];
        color prevColor = previousFrame[i];
        // Extract the red, green, and blue components from current pixel
        float currR = (currColor >> 16) & 0xFF; // Like red(), but faster
        float currG = (currColor >> 8) & 0xFF;
        float currB = currColor & 0xFF;
        // Extract red, green, and blue components from previous pixel
        float prevR = (prevColor >> 16) & 0xFF;
        float prevG = (prevColor >> 8) & 0xFF;
        float prevB = prevColor & 0xFF;
        // Compute the difference of the red, green, and blue values
        float diffR = abs(currR - prevR);
        float diffG = abs(currG - prevG);
        float diffB = abs(currB - prevB);
        movementSum += diffR + diffG + diffB;
        previousFrame[i] = currColor;
      }
      movementSum /= numPixels;
      if (movementSum > 200 && theMov.time() - lastTime > minTime) {
        lastTime = theMov.time();
        move();
      }
      image(theMov, x, y, frameWidth, frameHeight);
    }
  }
}

void keyPressed() {
  
  if ( mode != 111 && mode != 2 ) {
    
    if (key == BACKSPACE) {
      if (s.length() > 0) s = s.substring(0, s.length() - 1);
    }
    else if (key != TAB && key != ENTER && key != RETURN && key != ESC && key != DELETE) {
      s = s + key;
    }
  
  }
  if (keyCode == ENTER || keyCode == RETURN) {
    if (mode == 0) {
      if (s.equals("u")) {
        mode = 1;
        fill(255);
        rect(0 , 280, windowWidth , 175);
        fill(0);
        text("Type the number of frames you want to summarize the video into,\nthen press enter.", 50, 400);
      }
      else if (s.equals("n")) {
        background(0);
        theMov.play();
        mode = 2;
      }
    }
    else if (mode == 1) {
      
      frNum = Integer.parseInt(s);
      int i = 1;
      while (i*3*i*2 < frNum) {
        i++;
      }
      frameWidth = windowWidth / (i*3);
      frameHeight = windowHeight / (i*2);
      mode = 11;
      fill(255);
      rect(0 , 280, windowWidth , 175);
      fill(0);
      text("Type the duration of the video you want to summarize (0 for the whole video),\nthen press enter.", 50, 400);
    }
    else if (mode == 11) {
      dur = Integer.parseInt(s);
      background(0);
      theMov.play();
      theMov.read();
      image(theMov, x, y, frameWidth, frameHeight);
      movDur = theMov.duration();
      if (dur < movDur && dur > 0) movDur = dur;
      frRate = movDur / (float)(frNum); 
      mode = 111;
    }
    s = "";
  }

  
}