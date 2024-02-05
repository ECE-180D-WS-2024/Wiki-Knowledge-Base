# PlatformIO

## Introduction

PlatformIO [[1](https://platformio.org/)] is a toolchain for embedded C/C++ development. The development team supports a VSCode extension which is the primary and most straightforward way of using the toolchain. There is also a CLI which can be used if the VSCode extension is too limited. PlatformIO supports many common embedded platforms including Arduino and ESP32. A list of supported embedded platforms and the corresponding libraries can be found in the PlatformIO registry [[2](https://registry.platformio.org/)], which acts as a package dependency management solution similar to tools like `pip` and `cargo`.

The remainder of this guide assumes the reader is developing embedded code using the Arduino framework. If the reader has previously used Arduino IDE, the coding portions of this guide will feel very familiar. However, note that PlatformIO can take advantage of other frameworks like Espressif's IoT Development Framework [[3](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/index.html)]. For an industry example of PlatformIO being used with ESP-IDF, refer to Tidbyt's hardware development kit [[4](https://github.com/tidbyt/hdk)].

## Installation

PlatformIO provides two interfaces: VSCode extension and CLI. The VSCode extension includes the CLI. However if one wishes to do something like create a CI/CD pipeline to automate unit testing, then they can install the standalone CLI. Since these kinds of use-cases are outside the scope of this guide, we will focus on the VSCode extension. For more advanced users who wish to setup these more complicated solutions, follow PlatformIO's official guide on installing the CLI [[5](https://docs.platformio.org/en/latest/core/installation/index.html)].

The following steps are pulled straight from PlatformIDE's official guide for convenience.

1. Install VSCode
2. Open the extension manager

<img src="https://github.com/ECE-180D-WS-2024/Wiki-Knowledge-Base/blob/main/Images/nnhien/image.png">

*Figure 1.* VSCode's extension manager icon found in the sidebar

3. Search for "platformio ide"

4. Install "PlatformIO IDE"

<img src="https://github.com/ECE-180D-WS-2024/Wiki-Knowledge-Base/blob/main/Images/nnhien/image-1.png">

*Figure 2.* Searching for PlatformIDE in the extension manager

A new tab will appear in the same sidebar where the extension manager was found. This is where the GUI controls for PlatformIO IDE are found.

<img src="https://github.com/ECE-180D-WS-2024/Wiki-Knowledge-Base/blob/main/Images/nnhien/image-2.png">

*Figure 3.* PlatformIO IDE's icon found in the sidebar

### udev rules for Linux users

If the reader is developing on Linux, they will need to add some `udev` rules to allow PlatformIO IDE to upload firmware to connected boards [[6](https://docs.platformio.org/en/latest/core/installation/udev-rules.html)].

In terminal, run

```sh
curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/develop/platformio/assets/system/99-platformio-udev.rules | sudo tee /etc/udev/rules.d/99-platformio-udev.rules
```

Restart the `udev` service. The exact command will vary depending on system configuration. On Ubuntu, one can run

`sudo service udev restart`.

If the `udev` service doesn't exist, run

```
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Readers using Ubuntu or Debian may need to add their user to the `dialout` and `plugdev` groups:

```sh
sudo usermod -aG dialout $USER
sudo usermod -aG plugdev $USER
```

Readers using Arch Linux may need to add their user to the `uucp` and `lock` groups:

```sh
sudo usermod -aG uucp $USER
sudo usermod -aG lock $USER
```

> For user group changes to take effect, log out and log in again.

After the udev rules have been added, physically unplug and reconnect the board.

## Getting Started

We will write and upload a simple firmware using the Arduino framework which blinks an LED on an board implementing the ESP32 platform.

### Creating your first project

To create a new project,

1. Open the PlatformIO extension
2. Select "Create New Project"
3. In the new VSCode tab that opens, select "New Project"
   1. Under "Name", name the project something descriptive. This guide assumes "blink" was chosen.
   2. Under "Board", search for the physical hardware you are developing for. If you purchased the board specified by the syllabus, the corresponding board will be "SparkFun ESP32-S2 Thing Plus"
   3. Under "Framework", use "Arduino"
   4. Change the project location if desired
   5. Select "Finish"

After PlatformIO finishes initial setup, a new directory will be added to your VSCode workspace in the explorer tab. This directory contains your new project. The file structure reflects good C++ development practices. It's best practice to respect the following important locations:

`lib/`: Contains the source code for libraries manually managed by the developer. One might take advantage of `git`'s submodules to automatically track changes to libraries not provided by PlatformIO's registry. **Typically this directory will be left untouched,** since for most of our use-cases we use libraries provided by PlatformIO's registry.

`includes/`: To be populated by `.h` and/or `.hpp` files containing constants, function headers, etc. During the development process VSCode will by default search for function headers and constants defined here when providing auto-completion suggestions. Similarly, when building your firmware PlatformIO will automatically search for function headers and constants defined in header files located here. 

`src/`: To be populated by `.c` and/or `.cpp` files containing implementations of functions defined in the header files located in `includes/`

`platformio.ini`: The project configuration file. More advanced project configuration can be done in here, such as specifying different build environments, the communications protocal to be used when uploading firmware to a board, the target device file to use when uploading firmware, 

> **Note:** The reader familiar with Arduino IDE might note that PlatformIO does not abstract away the more complicated nuances of project structure. If this is intimidating, the reader can simply do everything in `src/main.cpp` and everything will be as if the reader was using Arduino IDE. They still get VSCode's syntax highlighting, auto-completion, and extensions as nice additions.

### Writing and uploading the firmware

Open `src/main.cpp` and replace the default contents with the following:

```cpp
#include <Arduino.h>

void setup() {
  // put your setup code here, to run once:
  pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  digitalWrite(LED_BUILTIN, HIGH);
  delay(500);
  digitalWrite(LED_BUILTIN, LOW);
  delay(500);
}
```

Connect your Arduino to your computer using a cable which supports data transfer. 

> Note that not all USB cables support data transfer - if the subsequent steps fail, it is likely you have a cable which can only transmit power.

Open PlatformIO's VSCode controls and select "Upload and Monitor"

<img src="https://github.com/ECE-180D-WS-2024/Wiki-Knowledge-Base/blob/main/Images/nnhien/image-3.png">

*Figure 4.* Location of "Upload and Monitor" in PlatformIO's VSCode controls

Wait for the firmware to build and upload. One the upload is complete, the light on your board will start to blink!

## Libraries

Libraries are pieces of code written to solve a frequently encountered problem and released to a community of developers. Libraries are often used to implement communications protocals like MQTT or enable developers to interface with hardware on the board like WiFi chips. Developers use libraries written by other developers so they don't have to reinvent the wheel.

PlatformIO's registry provides a plethora of libraries. In the following sections, we will add the `ArduinoJson` library as a dependency for our project and demonstrate how to use it in our firmware implementation. `ArduinoJson` provides a simple to use interface to serialize data structures in JSON format. Its full feature set is outside the scope of this guide.

### Adding the library

Open the PlatformIO VSCode controls. Under the "Quick Access" pane, select "Libraries"

<img src="https://github.com/ECE-180D-WS-2024/Wiki-Knowledge-Base/blob/main/Images/nnhien/image-4.png">

*Figure 5.* Location of "Libraries" under "Quick Access"

Search for "arduinojson"

<img src="https://github.com/ECE-180D-WS-2024/Wiki-Knowledge-Base/blob/main/Images/nnhien/image-5.png">

*Figure 6.* ArduinoJson's entry in the PlatformIO registry

Click on "ArduinoJson". Select "Add to Project". Under "Select a project", select our "blink" project.

<img src="https://github.com/ECE-180D-WS-2024/Wiki-Knowledge-Base/blob/main/Images/nnhien/image-6.png">

*Figure 7.* Adding ArduinoJson as a dependency to the `blink` project

Select "Add"

Once finished, the library will have been added to your project. You can confirm this by inspecting `platformio.ini`. A new option named `lib_deps` will have been added with a single entry.

<img src="https://github.com/ECE-180D-WS-2024/Wiki-Knowledge-Base/blob/main/Images/nnhien/image-7.png">

*Figure 8.* ArduinoJson's entry in `platformio.ini`

### Using the library

The following is a toy example of using the `ArduinoJson` library in our firmware implementation. Each time we change the state of the `LED_BUILTIN` pin, we will change the state of a variable. We then serialize this variable into a JSON object and print it to the serial monitor. In an actual implementation, the serialized object can be transmitted to some other computer to be consumed by using some other communications protocol, such as MQTT.

In `src/main.cpp`, use the following code:

```cpp
#include <Arduino.h>
#include <ArduinoJson.h>

boolean led_on;

JsonDocument board_state;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  while (!Serial);

  pinMode(LED_BUILTIN, OUTPUT);
  led_on = false;
}

void loop() {
  // put your main code here, to run repeatedly:
  digitalWrite(LED_BUILTIN, HIGH);
  led_on = true;
  board_state["led_on"] = led_on;
  serializeJsonPretty(board_state, Serial);
  delay(500);

  digitalWrite(LED_BUILTIN, LOW);
  led_on = false;
  board_state["led_on"] = led_on;
  serializeJsonPretty(board_state, Serial);
  delay(500);
}
```


A major difference is the addition of `#include <ArduinoJson.h>`. Note that `lib/` is still empty; when PlatformIO builds the firmware binary, it checks `platformio.ini` for library dependencies and automatically links them. The library source is located in `${projectRoot}/.pio/libdeps/`.

> If the `libdeps/` directory does not exist, try building the project first.

## Sources

[1] https://platformio.org/

[2] https://registry.platformio.org/

[3] https://docs.espressif.com/projects/esp-idf/en/latest/esp32/index.html

[4] https://github.com/tidbyt/hdk 

[5] https://docs.platformio.org/en/latest/core/installation/index.html 

[6] https://docs.platformio.org/en/latest/core/installation/udev-rules.html