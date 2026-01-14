#pragma once
#include <stdint.h>


extern const uint8_t cat_idle[];
extern const uint8_t cat_eat[];
extern const uint8_t cat_sleep[];

void drawCatSprite(int x, int y, const uint8_t* sprite, int sats);
void drawSignalBars(int sats);
void drawSleepingCat();
void drawSearching();
void drawCelebration();
