# Bluetooth Low Energy

## Introduction

Bluetooth Low Energy (BLE) [[1](https://www.bluetooth.com/learn-about-bluetooth/tech-overview/)] is a short-range wireless technology standard focusing on low-power devices. While it may not have the data throughput or range of its predecessor, Bluetooth Classic, it excels at maintaining low power usage, enabling it to be used much more easily with mobile and IOT devices.

In this article, we will explain the basics of BLE and give a small tutorial on using BLE to send the Interntial Measurement Unit (IMU) data from an `Arduino Nano 33 IOT` [[2](https://store-usa.arduino.cc/products/arduino-nano-33-iot)], a powerful, compact, and low-cost microcontroller board with a built-in IMU and wireless capabilities, to a laptop running `Node.js` using the library `Noble` [[3](https://www.npmjs.com/package/@abandonware/noble)], a BLE central controller module for javascript.

## Background

### Architecture

The BLE architecture is based on a layered protocol, where each layer relies on the abstractions provided by the layers under it. These layers are generally grouped into 3 components: **application**, **host**, and **controller**.

![Bluetooth Low Energy Protocol Architecture](https://github.com/ECE-180D-WS-2024/Wiki-Knowledge-Base/blob/main/Images/JacobLevinson/Image0.png)

### BLE Protocol Layers

Although layers beneath the Security Manager and Attribute Protocol layers are not necessary to understand for users of the BLE protocol, we will touch on them briefly as well for completeness sake.

### Physical Layer

The physical layer (PHY) refers to the physical radio used in BLE communication. BLE uses the 2.4GHz ISM band (2.402–2.480 GHz utilized), consisting of 40 channels with 2 MHz spacing as well as a frequency-hopping transceiver.

### Link Layer

The link layer is the layer above the physical layer, which is responsible for scanning, advertising, and creating and maintaining connections by managing its state.

![Link Layer State Diagram](https://github.com/ECE-180D-WS-2024/Wiki-Knowledge-Base/blob/main/Images/JacobLevinson/Image1.webp)

### Host Controller Interface

The Host Controller Interface (HCI) layer is a standard protocol defined by the Bluetooth specification that allows the Host component to communicate with the Controller component. These components do not even necessarily exist inside the same chip, but they often are for simplicity. The HCI can use an API or standard interfaces such as UART, SPI, or USB.

### Logical Link Control and Adaptation Protocol (L2CAP)

The Logical Link Control and Adaptation Protocol (L2CAP) layer acts as a protocol multiplexing layer. It takes multiple protocols from the upper layers and places them in standard BLE packets for the lower layers. This data encapuslation allows the above layers to use BLE with an easy abstraction.

### Attribute Protocol

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
+ Peripheral: a device that Advertises and accepts Connections from Central devices. In our tutorial, this will be the Arduino Nano 33 IOT, which advertises its IMU Data service and accepts a connecting from our laptop.

Note that some BLE devices can act as multiple of these roles, depending on the context. For example, a smartphone may act as a central device when communicating with a smartwatch and also act as a peripheral when downloading a file from another smartphone.
