#include "Scenes.h"

#include "gps_animations.h"

Scene currentScene = SCENE_GPS;
Scene lastScene = SCENE_COUNT;

// Button
void handleNextButton() {
  bool state = digitalRead(BUTTON1_PIN);

  if (lastNextButtonState == HIGH && state == LOW) {
    currentScene = (Scene)((currentScene + 1) % SCENE_COUNT);
  }

  lastNextButtonState = state;
}

void handleBackButton() {
  bool state = digitalRead(BUTTON2_PIN);

  if (lastBackButtonState == HIGH && state == LOW) {
    currentScene = (Scene)((currentScene + SCENE_COUNT - 1) % SCENE_COUNT);
  }
  lastBackButtonState = state;
}

// Horizontal Dilution of Precision (HDOP)
const char* hdopScore() {
  if (!gps.hdop.isValid()) return "No Fix";

  float hdop = gps.hdop.hdop();

  if (hdop <= 1.0) return "Excellent";
  if (hdop <= 2.0) return "Good";
  if (hdop <= 5.0) return "Ok";
  return "Poor";
}

// Scenes

bool celebrating = true;
unsigned long lockTime = 0;

void drawGPSScene() {
  while (gpsSerial.available()) {
    gps.encode(gpsSerial.read());
  }

  if (gps.charsProcessed() < 10) {
    drawSleepingCat();
    return;
  }

  if (!gps.location.isValid()) {
    drawSearching();
    celebrating = true;
    return;
  }

  if (celebrating) {
    if (!lockTime) lockTime = millis();
    drawCelebration();
    if (millis() - lockTime > 2500) {
      celebrating = false;
      lockTime = 0;
    }
    return;
  }
  {
    display.setTextSize(1);
    display.clearDisplay();
    display.setCursor(0, 0);
    display.print("LAT: ");
    display.println(gps.location.lat(), 6);
    display.print("LON: ");
    display.println(gps.location.lng(), 6);
    drawSignalBars(gps.satellites.value());
    drawCatSprite(100, 40, cat_idle, gps.satellites.value());
    display.display();
  }
}

void drawStatsScene() {
  display.setTextSize(1);
  display.setCursor(0, 0);
  display.println("GPS STATS");

  display.print("Sats: ");
  display.println(gps.satellites.value());

  display.print("HDOP: ");
  if (gps.hdop.isValid())
    display.println(gps.hdop.hdop(), 1);
  else
    display.println("--");

  display.print("Quality: ");
  display.println(hdopScore());
  display.display();
}

void drawDebugScene() {
  display.clearDisplay();
  display.setCursor(0, 0);
  display.println("DEBUG");
  display.print("Chars: ");
  display.println(gps.charsProcessed());
  display.print("Sentences: ");
  display.println(gps.sentencesWithFix());
  display.display();
}

void utcTimeScene() {
  display.clearDisplay();
  display.setCursor(0, 0);
  display.println("UTC Time");
  if (gps.time.isValid()) {
    display.print("H:");
    display.println(gps.time.hour());
    display.print("M:");
    display.print(gps.time.minute());
    display.print("S:");
    display.print(gps.time.second());
  } else {
    display.print("No Time Data");
  }
  display.println("DATE:");
  if (gps.date.isValid()) {
    display.print(gps.date.day());
    display.print(".");
    display.print(gps.date.month());
    display.print(".");
    display.print(gps.date.year());
  } else {
    display.print("No Date Data");
  }
  display.display();
}

void headingScene() {
  display.clearDisplay();
  display.setCursor(0, 0);
  display.println("Heading:");
  if (gps.course.isValid()) {
    display.println(gps.course.deg(), 0);
    display.print(" ");
    display.println(TinyGPSPlus::cardinal(gps.course.deg()));
  } else {
    display.println("--");
  }
  display.display();
}

void speedScene() {
  display.clearDisplay();
  display.setCursor(0, 0);
  display.println("Speed: ");
  if (gps.speed.isValid()) {
    display.println(gps.speed.mph(), 1);
  } else {
    display.println("--");
  }
  display.display();
}

void altScene() {
  display.clearDisplay();
  display.setCursor(0, 0);
  display.println("Altitude: ");
  if (gps.altitude.isValid()) {
    display.println("ft: ");
    display.println(gps.altitude.feet());
    display.println("m: ");
    display.println(gps.altitude.meters());
  } else {
    display.println("--");
  }
  display.display();
}

void eyesScene(){
  display.setTextSize(1);
    display.clearDisplay();
    display.setCursor(0, 0);
    drawSprite(64,32, eyes_idle); //rework drawCatSprite to just draw sprites
    display.display();
}

void drawScene() {
  switch (currentScene) {
    case SCENE_GPS:
      drawGPSScene();
      break;
    case SCENE_STATS:
      drawStatsScene();
      break;
    case SCENE_DEBUG:
      drawDebugScene();
      break;
    case SCENE_DATE:
      utcTimeScene();
      break;
    case SCENE_HEADING:
      headingScene();
      break;
    case SCENE_SPEED:
      speedScene();
      break;
    case SCENE_ALT:
      altScene();
      break;
    case SCENE_EYES:
      eyesScene();
  }
}
