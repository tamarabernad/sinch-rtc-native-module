
# react-native-sinch-rtc

## STILL UNDER DEVELOPMENT, DON'T USE!

## Getting started

`$ npm install react-native-sinch-rtc --save`

### Mostly automatic installation

`$ react-native link react-native-sinch-rtc`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-sinch-rtc` and add `RNSinchRtc.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNSinchRtc.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
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


## Usage
```javascript
import RNSinchRtc from 'react-native-sinch-rtc';

// TODO: What to do with the module?
RNSinchRtc;
```

react-native link

Copy paste .aar to your android folder
  repositories flatDir { dirs './libs' }


  dependencies
compile "com.facebook.react:react-native:+"  // From node_modules
    compile 'com.google.firebase:firebase-messaging:11.8.0'

    apply plugin: 'com.google.gms.google-services'

    repositories 
    maven { url 'https://maven.google.com'  }

To project
    classpath 'com.google.gms:google-services:3.1.1'


    Add to main project google-services.json
