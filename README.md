
# react-native-sinch-rtc

## STILL UNDER DEVELOPMENT, DON'T USE!

## Getting started

`$ npm install react-native-sinch-rtc --save`

## Add Library

### Android

1. Download [Sinch SDK](https://www.sinch.com/downloads/) for Android and move sinch .aar library file to your android folder in a libs folder
2. In module gradle file:
Add to repositories
`flatDir { dirs './libs' }`
`maven { url 'https://maven.google.com'  }`

To dependencies
`compile 'com.google.firebase:firebase-messaging:11.8.0'`

And apply plugin
`apply plugin: 'com.google.gms.google-services'`

3. To project gradle file:
`classpath 'com.google.gms:google-services:3.1.1'`

### iOS

1. Add Sinch dependency to your Podfile inside ios folder`pod 'SinchRTC'`
2. Inside ios folder run `pod install`
3. Add Header Search Path `$(SRCROOT)/../node_modules/react-native-sinch-rtc/ios/Classes`


## Link Automatic

`$ react-native link react-native-sinch-rtc`

## Link Manually

#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-sinch-rtc` and add `RNSinchRtc.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNSinchRtc.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainApplication.java`
  - Add `import com.reactlibrary.RNSinchRtcPackage;` to the imports at the top of the file
  - Add `new RNSinchRtcPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-sinch-rtc'
  	project(':react-native-sinch-rtc').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-sinch-rtc/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-sinch-rtc')
  	```

## Setup

### Android
Add Keys, Secret and Environment to your Manifest

```xml
<service android:name="com.bluecall.sinch.SinchService">
    <meta-data android:name="messages_handler" android:value="com.bluecallapp.utils.sinch.MessagesHandler" />
    <meta-data
        android:name="SINCH_APP_KEY"
        android:value="@string/SINCH_APP_KEY" />
    <meta-data
        android:name="SINCH_APP_SECRET"
        android:value="@string/SINCH_APP_SECRET" />
    <meta-data
        android:name="SINCH_ENVIRONMENT"
        android:value="@string/SINCH_ENVIRONMENT" />
</service>

```

### iOS
Add Keys, Secret and Environment to the Module initialization

```Objective-C

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{

  [RNSinchRtc initialize:@{@"isMessagingEnabled":@YES,
                           @"appKey":@"",
                           @"appSecret":@"",
                           @"host":@"",
                           }];
}
```



## Usage

### React Native

#### Calling
```javascript
import { NativeModules } from 'react-native';

NativeModules.RNSinchRtc.login('username');
NativeModules.RNSinchRtc.setDisplayName('username');

NativeModules.RNSinchRtc.call('user_id', callId => {
    console.log(callId);
}

NativeModules.RNSinchRtc.hangup();


const emitter = Platform.OS === 'android' ? DeviceEventEmitter : new NativeEventEmitter(NativeModules.RNSinchRtc);
emitter.addListener('callEndedWithReason', event => {
    console.log(event.duration);
    console.log(event.reason);
});

emitter.addListener('callDidEstablish', event => {});
emitter.addListener('callDidProgress', event => {});
```


### Android

#### Notifications
The developer is reponsible of how the Notifications are shown for the incoming Instant Messages. To handle the notifications the class will need to implement `MessagesHandlerable`, this class will implement:
- `onIncomingMessage` at this point you have the option to present a local notification
- `onSendingMessage` at this point the user is sending a message and the developer has the option to do any required treatment needed for the sent message.

