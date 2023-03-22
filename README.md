
# React Native Module

## Prerequisites

Akamai BMP native module requires the following minimum versions for Android and iOS

 * Android API 15 (Android 4.0.4) or above
 * iOS version 8.0 or above
 * React Native 0.41 or above


## Download 
Download Akamai BMP React Native module from [Bot Manager SDK Downloads](https://control.akamai.com/apps/security-config/#/sdk-downloads) page.

## For React Native v0.61 and above

To add the Akamai BMP React Native module to your React Native app, run:

`$ npm install <download_location>/AkamaiBMP-ReactNative-x.y.z.tgz –save`

where `x.y.z` in the file name is the version of the AkamaiBMP module.

Install and link native dependencies

To install the module and link, run:

`$ react-native install react-native-akamaibmp`

## For React Native v0.60 and below
 
To add the Akamai BMP React Native module to your React Native app, run:

`$ npm install <download_location>/AkamaiBMP-ReactNative-x.y.z.tgz –save`

where `x.y.z` in the file name is the version of the AkamaiBMP module.

To install and link the module automatically, run:

`$ react-native link react-native-akamaibmp`


## Integration

The BMP SDK collects behavioral data while the user is interacting with the application. The
behavioral data, also known as sensor data, includes the device characteristics, device
orientation, accelerometer data, touch events, etc. Akamai BMP SDK provides a simple API to
detect bot activities and defend against malicious bot and account takeover.

### Import AkamaiBMP module

Once the native module has been added to your project, you can import AkamaiBMP native module in your JavaScript file `index.ios.js`, `index.android.js` or `App.js` as shown below:

```javascript
import { NativeModules } from 'react-native';
const { AkamaiBMP } = NativeModules;
```

### Collect Sensor Data
The BMP SDK’s sensor data contains serialized user behavioral data and device information.
However, the device information doesn’t contain any information that will identify this device
uniquely.
You can retrieve sensor data from the module by calling the `AkamaiBMP.getSensorData`
method. Sensor data should be sent in the REST API request as detailed below.

```javascript
// Get the BMP sensor data
AkamaiBMP.getSensorData((sd) => {
});
```

***Important:*** *Call the getSensorData method only on REST API requests to URLs that will be configured for protection in Bot Manager Premier Mobile. Do not call the getSensorData method for non-protected URLs.*

### Send Sensor Data
After the sensor data is retrieved from the module, it should be sent in `X-acf-sensor-data`
HTTP header as part your applications REST API (HTTP/S) request. We recommend using
HTTPS for the REST API request to ensure the integrity of sensor data and prevent
eavesdropping. Send the `X-acf-sensor-data` header ONLY on HTTP requests to URLs configured for protection in Bot Manager Premier Mobile. *Do not send the header and sensor data on every HTTP request the app makes.*

```javascript
AkamaiBMP.getSensorData((sd) => {
  // send the sensor data in the API request
});
```

### Evaluate the Akamai Edge Response
Akamai edge server inspects sensor data and takes the predefined action on the request if the
request is classified as BOT, otherwise Akamai sends the request to the origin server.

When the app makes a request, Akamai evaluates the sensor data at the edge. If the request is
classified as human, the traffic continues to the origin server and the response is sent back to
the app. If the request is BOT, there are two possible actions, `monitor` and `deny`.
 * If the action is `monitor`, the traffic is allowed and the request is sent to the origin server.
 * If the action is `deny`, a `403` HTTP response is sent back to the app, and the app should
handle the situation and take appropriate action.


### Logging
Akamai BMP plugin logs some messages at all log levels to verify the SDK initialization. These
messages are helpful in identifying any integration issue and ensure the plugin is initialized
successfully.

In addition to these messages, the plugin logs additional messages at `info`, `warn` and `error` levels, to verify and debug that the SDK is working correctly. The default log level for the plugin is set to log ​warning​ and ​error​ messages only.​ This behavior can be changed by calling
`setLogLevel` API.

To set the log level, call `AkamaiBMP.setLogLevel` API with one of the log levels specified
below:
 * `AkamaiBMP.logLevelInfo` - Print all messages
 * `AkamaiBMP.logLevelWarn` - (Default)​ Print warning and error messages only
 * `AkamaiBMP.logLevelError` - Print error messages only
 * `AkamaiBMP.logLevelNone` - Turn off all log messages from the SDK

For example, to see all messages:
```javascript
// Set the log level to Info
AkamaiBMP.setLogLevel(AkamaiBMP.logLevelInfo);
```

  