# cordova-plugin-gctouch-id
TouchID Plugin (Cordova) for iOS

Author: [Giulio Caruso aka rdn](https://twitter.com/iosdeveloper87)

<p align="center"><img src="https://github.giuliocaruso.it/GCTouchID/images/logotouchid.jpg" alt="GCTouchID"></p>

[![Language](https://img.shields.io/badge/language-objective--c-green.svg)](https://developer.apple.com/reference/objectivec)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/rdn87/cordova-plugin-gctouch-id/blob/master/LICENSE)

## Index

1. [Description](#1-description)
2. [Technical Documentation](2-technical-documentation)
3. [Screenshots](#3-screenshots)
4. [Adding the Plugin](#4-adding-the-plugin)
5. [Sample Code](#5-sample-code)
6. [To Do](#6-to-do)
7. [License](#7-license)

## 1. Description

With this plug-in Cordova you can use the TouchID sensor **(iPhone 5S/iPhone 6/iPhone 6 Plus/iPhone 7/iPhone 7 Plus/iPad with Touch ID Sensor)** for Authenticate in your App

The Plugin is only iOS Platform.

**Requirements**
===========
| **iOS** | 
|---------|
|   8.0+  |

## 2. Technical Documentation

In this plugin there are 3 basic methods:
- `isAvailable`
- `authWithTouchID`
- `setPassword`

**[isAvailable]**: Returns a flag **true** or **false** if the touch id is available for that type of **Device**. (*No input parameters*)

**[authWithTouchID]**: This method tries to access with **Touch ID** <br> *These are input parameters:*<br>
**insertPwd**: In this parameter you can enter the **string** true or false, set false if u want Basic Authentication with only Touch ID (*Optional if u want Basic Authentication only Touch ID*)<br>
**textValue**: In this parameter you can enter the **string** for label of Button (*Required*)<br>
**message**: In this parameter you can enter the **string** for Touch ID popup text (*Required*)<br>
**security**: In this parameter you can enter the **string** true or false, false for Auth with **NSUsersDefaults** Instead it is true to use the **KeyChain** (Optional if u want Basic Authentication only Touch ID)<br>

**[setPassword]**: This method allows you to save in **NSUsersDefaults** or **KeyChain** your password that you have chosen as Fallback.<br> *These are input parameters:*<br>
**password**: In this parameter you can enter the **string** of your password
**security**: In this parameter you can enter the **string** true or false, false for Auth with **NSUsersDefaults** Instead it is true to use the **KeyChain**

## 3. Screenshot
<img src="https://github.giuliocaruso.it/GCTouchID/screen/1.jpg" alt="GCTouchID" width="260">&nbsp;
<img src="https://github.giuliocaruso.it/GCTouchID/screen/2.jpg" alt="GCTouchID" width="260">&nbsp;
<img src="https://github.giuliocaruso.it/GCTouchID/screen/3.jpg" alt="GCTouchID" width="260">&nbsp;
<img src="https://github.giuliocaruso.it/GCTouchID/screen/4.jpg" alt="GCTouchID" width="260">&nbsp;

# DOCS

# 4. Adding the Plugin

Use the Cordova CLI and type in the following command:

`cordova plugin add https://github.com/rdn87/cordova-plugin-gctouch-id.git`

# 5. Sample Code
You can find it in the DEMO folder.

# 6. TO DO
- [x] Add Basic Authentication with Touch ID
- [x] Add NSUsersDefaults support
- [x] Add UITextField input text support
- [x] Add Keychain support
- [x] Improve code 
- [x] Add npm repo

# 7. License

cordova-plugin-gctouch-id is available under the MIT license. See the **[LICENSE](https://github.com/rdn87/cordova-plugin-gctouch-id/blob/master/LICENSE)** file for more info.
