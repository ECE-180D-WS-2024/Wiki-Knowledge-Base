# Bluetooth Low Energy

## Introduction

Bluetooth Low Energy (BLE) [[1](https://www.bluetooth.com/learn-about-bluetooth/tech-overview/)] is a short-range wireless technology standard focusing on low-power devices. While it may not have the data throughput or range of its predecessor, Bluetooth Classic, it excels at maintaining low power usage, enabling it to be used much more easily with mobile and IoT devices.

In this article, we will explain the basics of BLE and give a small tutorial on using BLE to send the Interntial Measurement Unit (IMU) data from an `Arduino Nano 33 IOT` [[2](https://store-usa.arduino.cc/products/arduino-nano-33-iot)], a powerful, compact, and low-cost microcontroller board with a built-in IMU and wireless capabilities, to a laptop running `Node.js` using the library `Noble` [[3](https://www.npmjs.com/package/@abandonware/noble)], a BLE central controller module for javascript.

## Background

### Architecture

The BLE architecture is based on a layered protocol, where each layer relies on the abstractions provided by the layers under it. These layers are generally grouped into 3 components: **application**, **host**, and **controller**.

![Bluetooth Low Energy Protocol Architecture](https://github.com/ECE-180D-WS-2024/Wiki-Knowledge-Base/blob/main/Images/JacobLevinson/Image0.png)

### BLE Protocol Layers

Although layers beneath the Security Manager and Attribute Protocol layers are not necessary to understand for users of the BLE protocol, we will touch on them briefly as well for completeness sake.

### Physical Layer (PHY)

The physical layer (PHY) refers to the physical radio used in BLE communication. BLE uses the 2.4GHz ISM band (2.402–2.480 GHz utilized), consisting of 40 channels with 2 MHz spacing as well as a frequency-hopping transceiver.

### Link Layer

The link layer is the layer above the physical layer, which is responsible for scanning, advertising, and creating and maintaining connections by managing its state.

![Link Layer State Diagram](https://github.com/ECE-180D-WS-2024/Wiki-Knowledge-Base/blob/main/Images/JacobLevinson/Image1.webp)

### Host Controller Interface (HCI)

The Host Controller Interface (HCI) layer is a standard protocol defined by the Bluetooth specification that allows the Host component to communicate with the Controller component. These components do not even necessarily exist inside the same chip, but they often are for simplicity. The HCI can use an API or standard interfaces such as UART, SPI, or USB.

### Logical Link Control and Adaptation Protocol (L2CAP)

The Logical Link Control and Adaptation Protocol (L2CAP) layer acts as a protocol multiplexing layer. It takes multiple protocols from the upper layers and places them in standard BLE packets for the lower layers. This data encapuslation allows the above layers to use BLE with an easy abstraction.

### Attribute Protocol (ATT)

The Attribute Protocol (ATT) defines how a BLE device can expose data or attributes.

### Generic Attribute Profile (GATT)

The Generic Attribute Profile (GATT) defines the format of the data exposed by a BLE device. It also defines the procedures needed to access the data exposed by a device.

There are two roles within GATT: **Server** and **Client**. The Server is the device that exposes the data it would like to share or send. This data could be actual payload data (i.e., packets of an MP3 file, sensor data) or information about the device itself (i.e., battery level, device name).

A Client is the device that the server will send this data to. Note that a BLE device can act both as a Client and Server simultaneously.

To understand the GATT, you need to understand Services and Characteristics. Services are a grouping of one or more Attributes (a generic term for any type of data exposed by the server). It groups together related information, for example, IMU data.

A Characteristic is always part of a Service, which is a piece of data associated with that service. For example, X-Axis Acceleration could be a characteristic of the IMU Data Service.

To interact with these characteristics, we can perform operations on them. In BLE, there are six types of operations on Characteristics:

1. Commands
2. Requests
3. Responses
4. Notifications
5. Indications
6. Confirmations

### Generic Access Profile

The Generic Access Profile (GAP) provides a framework that defines how BLE devices interact with each other. This includes:

+ Roles of BLE devices
+ Advertisements (Broadcasting, Discovery, Advertisement parameters, Advertisement data)
+ Connection establishment (initiating connections, accepting connections, connection parameters)
+ Security

The different roles of a Bluetooth LE device are:

+ Broadcaster: a device that sends out Advertisements and does not receive packets or allow connections from others.
+ Observer: a device that listens to others sending out Advertising Packets but does not initiate a connection with an Advertising device.
+ Central: a device that discovers and listens to other devices that are Advertising, and can connect to the advertising device. In our tutorial, this will be our laptop, which receives the IMU data from the Arduino Nano 33 IOT.
+ Peripheral: a device that Advertises and accepts Connections from Central devices. In our tutorial, this will be the Arduino Nano 33 IOT, which advertises its IMU Accelerometer Data service and accepts a connecting from our laptop.

Note that some BLE devices can act as multiple of these roles, depending on the context. For example, a smartphone may act as a central device when communicating with a smartwatch and also act as a peripheral when downloading a file from another smartphone.

## Tutorial

### Materials

For this tutorial, you will need an `Arduino Nano 33 IOT` with USB Micro B cable and a laptop capable of BLE. We will be using the Arduino IDE.

1. In the Arduino IDE, open the boards manager (Tools->Board->Board Manager) and search for the Arduino Nano 33 IOT to find and download the appropriate board manager.
2. Open the library manager (Tools->Manage Libraries) and search for and download the `ArduinoBLE` and `Arduino_LSM6DS3` libraries.
3. Now we will create a new sketch, and include these libraries and define some constants for the UUID of our service and characteristics:

```cpp
#include <ArduinoBLE.h>
#include <Arduino_LSM6DS3.h>

#define BLE_UUID_ACCELEROMETER_SERVICE "1101"
#define BLE_UUID_ACCELEROMETER_X "2101"
#define BLE_UUID_ACCELEROMETER_Y "2102"
#define BLE_UUID_ACCELEROMETER_Z "2103"

#define BLE_DEVICE_NAME "Nano33IOT"
#define BLE_LOCAL_NAME "Nano33IOT"
```

4. We now create our service and define some floats that will later store the IMU data:

```cpp
BLEService accelerometerService(BLE_UUID_ACCELEROMETER_SERVICE);

BLEFloatCharacteristic accelerometerCharacteristicX(BLE_UUID_ACCELEROMETER_X, BLERead | BLENotify);
BLEFloatCharacteristic accelerometerCharacteristicY(BLE_UUID_ACCELEROMETER_Y, BLERead | BLENotify);
BLEFloatCharacteristic accelerometerCharacteristicZ(BLE_UUID_ACCELEROMETER_Z, BLERead | BLENotify);

float x, y, z;
```

5. We now define our setup function. In this function, we will initialize the IMU and BLE modules, add characteristics to our BLE service, add our service, and then advertise our service after initializing the data of each characteristic.

```cpp
void setup()
{
  pinMode(LED_BUILTIN, OUTPUT);


  // initialize IMU
  if (!IMU.begin())
  {
    Serial.println("Failed to initialize IMU!");
    while (1)
      ;
  }


  Serial.print("Accelerometer sample rate = ");
  Serial.print(IMU.accelerationSampleRate());
  Serial.println("Hz");


  // initialize BLE
  if (!BLE.begin())
  {
    Serial.println("Starting Bluetooth® Low Energy module failed!");
    while (1)
      ;
  }


  // set advertised local name and service UUID
  BLE.setDeviceName(BLE_DEVICE_NAME);
  BLE.setLocalName(BLE_LOCAL_NAME);
  BLE.setAdvertisedService(accelerometerService);


  accelerometerService.addCharacteristic(accelerometerCharacteristicX);
  accelerometerService.addCharacteristic(accelerometerCharacteristicY);
  accelerometerService.addCharacteristic(accelerometerCharacteristicZ);


  BLE.addService(accelerometerService);


  accelerometerCharacteristicX.writeValue(0);
  accelerometerCharacteristicY.writeValue(0);
  accelerometerCharacteristicZ.writeValue(0);


  // start advertising
  BLE.advertise();


  Serial.println("BLE Accelerometer Peripheral");
}
```

6. Finally, we will write our loop. In this loop, we will simply read the X, Y, and Z acceleraometer data from the IMU and write them to our characteristics accordingly:

```cpp
void loop()
{
  BLEDevice central = BLE.central();


  if (IMU.accelerationAvailable())
  {
    digitalWrite(LED_BUILTIN, HIGH);
    IMU.readAcceleration(x, y, z);


    accelerometerCharacteristicX.writeValue(x);
    accelerometerCharacteristicY.writeValue(y);
    accelerometerCharacteristicZ.writeValue(z);
  }
  else
  {
    digitalWrite(LED_BUILTIN, LOW);
  }
}
```

7. Now we will upload this by first selecting the correct board (Tools->Board->Arduino SAMD->Arduino Nano 33 IOT), selecting the correct COM port (Tools->Port) and then clicking the right facing arrow in the top-left to upload the sketch.

8. Now that we have completed the peripheral side, we will need to create the controller side on for the laptop. Begin by installing `node.js` on your laptop.

9. Create a directory, navigate to it, and run

```sh
npm init -y
```

10. Next install the noble module using

```sh
npm install @abandonware/noble
```

11. Now we will begin writing our node.js code. Create a file called `central.js` in the project directory. We will begin by requiring the noble module, and defining some constants to be used later:

```js
const noble = require('@abandonware/noble');


const uuid_service = "1101"; // IMU Accelerometer Service UUID
const uuid_values = ["2101", "2102", "2103"]; // Array of UUIDs for X, Y, and Z Axis characteristics


let sensorValues = {};
```

12. Next we will define the function for when the program starts up and the state changes to "powered on". In this function we scan for the UUID of the IMU Accelerometer service from the Arduino Nano 33 IOT:

```js
noble.on('stateChange', async (state) => {
    if (state === 'poweredOn') {
        console.log("start scanning");
        await noble.startScanningAsync([uuid_service], false);
    }
});
```

13. We also need to define the function for when the service is successfully discovered. In this function we will connect to the peripheral found, discover its characteristics, and then call a function called `readData` for each of the characteristics.

```js
noble.on('discover', async (peripheral) => {
    await noble.stopScanningAsync();
    await peripheral.connectAsync();
    const { characteristics } = await peripheral.discoverSomeServicesAndCharacteristicsAsync([uuid_service], uuid_values);


    // Read data for each characteristic
    characteristics.forEach((characteristic) => {
        readData(characteristic);
    });
});
```

14. Finally, we must define this `readData` function. In this function, we will read from the characteristic, console.log the value, and then set a timeout of 10 milliseconds for when to call readData once again. This way, our program is continuously reading new values from the IMU Accelerometer service:

```js
// read data periodically
let readData = async (characteristic) => {
    const value = (await characteristic.readAsync());
    const uuid = characteristic.uuid;
    sensorValues[uuid] = value.readFloatLE(0);
    console.log(`Characteristic ${uuid}: ${sensorValues[uuid]}`);


    // read data again in t milliseconds
    setTimeout(() => {
        readData(characteristic);
    }, 10);
}
```

15. Now that we have completed our node.js code, we can run it by typing in our terminal:

```sh
node central.js
```

16. We should now see a stream of accelerometer values from our Arduino Nano 33 IOT in our terminal!

## Conclusion

In this article, we've delved into the intricacies of Bluetooth Low Energy (BLE) through an exploration of its architecture and a practical tutorial on interfacing with an Arduino Nano 33 IoT with a laptop via Node.js. This exploration highlighted BLE's significance in IoT applications, emphasizing its low power consumption and efficient data transfer capabilities, which make it ideally suited for a wide range of applications, from wearable technology to home automation systems. The detailed tutorial provided a hands-on approach to utilizing BLE, showcasing the ease with which developers can implement BLE services and characteristics to facilitate seamless device-to-device communication.

BLE is an important technology in the IoT landscape, enabling the development of innovative, energy-efficient solutions that enhance connectivity and interaction between devices. Through this concise overview and tutorial, we've illustrated BLE's potential to be utilized to enhance our daily lives with wireless connectivity. As IoT continues to evolve, BLE's role is undeniably pivotal, and previews a world where all our devices will be connected in an IoT.

## Sources

[1] <https://www.bluetooth.com/learn-about-bluetooth/tech-overview/>

[2] <https://store-usa.arduino.cc/products/arduino-nano-33-iot>

[3] <https://www.npmjs.com/package/@abandonware/noble>

[4] <https://www.bluetooth.com/learn-about-bluetooth/tech-overview/>

[5] <https://www.rfwireless-world.com/Terminology/BLE-Protocol-Stack-Architecture.html>
