#pragma once
#include <Adafruit_SSD1306.h>
#include <TinyGPS++.h>
#include "animations.h"

enum Scene {
  SCENE_GPS,
  SCENE_STATS,
  SCENE_DEBUG,
  SCENE_DATE,
  SCENE_HEADING,
  SCENE_SPEED,
  SCENE_ALT,
  SCENE_EYES,
  SCENE_COUNT // needs to be last
};

extern Scene currentScene;
extern Scene lastScene;

extern TinyGPSPlus gps;
extern HardwareSerial gpsSerial;
extern Adafruit_SSD1306 display;

extern bool celebrating;
extern unsigned long lockTime;

static bool lastNextButtonState = HIGH;
static bool lastBackButtonState = HIGH;


#define BUTTON1_PIN 4
#define BUTTON2_PIN 2

void handleNextButton();
void handleBackButton();

void drawScene();
void drawSprite();