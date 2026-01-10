# GPS BUDDY

A fun little ESP32-S3 GPS project that might evolve into a little tomogatchi GPS signal eater.

## Arduino CLI commands:

```bash
# check installed boards
arduino-cli core list
arduino-cli board list

# install if needed
arduino-cli config init
arduino-cli config set board_manager.additional_urls \
https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json

# update index
arduino-cli core update-index
arduino-cli core install esp32:esp32

# check and install libraries
arduino-cli lib search <library-name>

arduino-cli lib search TinyGPSPlus

arduino-cli lib install TinyGPSPlus


```

### compile

```bash
arduino-cli compile \
  --fqbn esp32:esp32:esp32 \
  GPSBuddy
```

### load

```bash
  arduino-cli upload \
  -p /dev/ttyUSB0 \
  --fqbn esp32:esp32:esp32 \
  GPSBuddy
```

### compile + load

```bash
arduino-cli compile -u -v \
  -p /dev/ttyUSB0 \
  --fqbn esp32:esp32:esp32 \
  GPSBuddy
```
