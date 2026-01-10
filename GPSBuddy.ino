/*

A fun little ESP32-S3 GPS project that might evolve into a little tomogatchi GPS
signal eater.

inspired by:
https://randomnerdtutorials.com/guide-to-neo-6m-gps-module-with-arduino/

ESP32-S3 default I2C pins
SDA → GPIO 8
SCL → GPIO 9

gps UART:
GPS RX → GPIO 43 ESP TX
GPS TX → GPIO 44 ESP RX
*/

#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <TinyGPS++.h>
#include <Wire.h>

#include "gps_animations.h"

// GPS
#define GPS_RX 44
#define GPS_TX 43
#define GPS_BAUD 9600

TinyGPSPlus gps;
HardwareSerial gpsSerial(1);

// OLED
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_ADDR 0x3C

// ESP32-S3 I2C
#define SDA_PIN 8
#define SCL_PIN 9

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

void setup() {
  Serial.begin(115200);

  // GPS serial
  gpsSerial.begin(GPS_BAUD, SERIAL_8N1, GPS_RX, GPS_TX);
  Serial.println("GPS Serial started");

  // I2C
  Wire.begin(SDA_PIN, SCL_PIN);

  // OLED init
  if (!display.begin(SSD1306_SWITCHCAPVCC, OLED_ADDR)) {
    Serial.println("OLED not found");
    while (true);
  }

  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
}

static bool celebrating = true;
static unsigned long lockTime = 0;

void loop() {
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

  // Normal GPS display
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
