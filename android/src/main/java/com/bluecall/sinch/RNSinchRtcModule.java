
package com.bluecall.sinch;

import android.util.Log;

import com.facebook.react.bridge.Dynamic;
import com.facebook.react.bridge.JavaOnlyArray;
import com.facebook.react.bridge.JavaOnlyMap;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.bridge.ReadableType;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.lang.reflect.Array;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class RNSinchRtcModule extends ReactContextBaseJavaModule implements CallDelegate, MessageDelegate {

  private final ReactApplicationContext reactContext;

  public RNSinchRtcModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
    PhoneActivityManager.getInstance().mCallDelegate = this;
    PhoneActivityManager.getInstance().mMessageDelegate= this;
    PhoneActivityManager.getInstance().setContext(reactContext);
  }

  @Override
  public String getName() {
    return "RNSinchRtc";
  }

  @Override
  public Map<String, Object> getConstants() {
    final Map<String, Object> constants = new HashMap<>();
    return constants;
  }

  @ReactMethod
  public void init(String appKey, String appSecret, String environment) {
    PhoneActivityManager.getInstance().init(appKey, appSecret, environment);
  }

  @ReactMethod
  public void login(String username) {
    PhoneActivityManager.getInstance().login(username);
  }

  @ReactMethod
  public void call(String username) {
    PhoneActivityManager.getInstance().call(username);
  }

  @ReactMethod
  public void answer() {
    PhoneActivityManager.getInstance().answer();
  }

  @ReactMethod
  public void sendMessage(String recipientUserId, String textBody, ReadableMap headers){

    PhoneActivityManager.getInstance().sendMessage(recipientUserId, textBody, headers);
  }


  //Call Delegate
  @Override
  public void didReceiveCall(String callId) {
    Log.d("SinchModule", "SinchModule onIncomingCall>> sending event: ");
    getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("didReceiveCall",null);
  }

  @Override
  public void callEndedWithReason(String reason) {
    Log.d("SinchModule", "SinchModule callEndedWithReason: ");
    getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("callEndedWithReason",reason);
  }

  @Override
  public void callDidEstablish() {
    Log.d("SinchModule", "SinchModule callDidEstablish: ");
    getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("callDidEstablish", null);
  }

  @Override
  public void callDidProgress() {
    Log.d("SinchModule", "SinchModule callDidProgress: ");
    getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("callDidProgress", null);
  }

  @Override
  public void callDidChangeStatus(String status) {
    Log.d("SinchModule", "SinchModule callDidChangeStatus: ");
    getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("callDidChangeStatus", status);
  }


  //Message Delegate
  @Override
  public void didReceiveMessage(String messageId, Map<String, String> headers, String senderId, String content, Date timeStamp) {

    JavaOnlyMap headerMap = new JavaOnlyMap();
    for (String key:headers.keySet()) {
        headerMap.putString(key,headers.get(key));
    }

    JavaOnlyMap map = new JavaOnlyMap();
    map.putString("messageId",messageId);
    map.putMap("headers",headerMap);
    map.putString("senderId",senderId);
    map.putString("content",content);
    map.putString("timeStamp",timeStamp.toString());

    getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("didReceiveMessage",map);
  }

  @Override
  public void didSendMessage(String messageId, Map<String, String> headers, List<String> recipients, String content, Date timeStamp) {
    JavaOnlyMap headerMap = new JavaOnlyMap();
    for (String key:headers.keySet()) {
      headerMap.putString(key,headers.get(key));
    }

    JavaOnlyArray recipientsArray = new JavaOnlyArray();
    for(String recipient:recipients){
      recipientsArray.pushString(recipient);
    }

    JavaOnlyMap map = new JavaOnlyMap();
    map.putString("messageId",messageId);
    map.putMap("headers",headerMap);
    map.putArray("recipients",recipientsArray);
    map.putString("content",content);
    map.putString("timeStamp",timeStamp.toString());

    getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("didSendMessage",map);
  }

  @Override
  public void didFailMessage(String messageId, Map<String, String> headers, List<String> recipients, String content, Date timeStamp, String errorMessage) {
    JavaOnlyMap headerMap = new JavaOnlyMap();
    for (String key:headers.keySet()) {
      headerMap.putString(key,headers.get(key));
    }

    JavaOnlyArray recipientsArray = new JavaOnlyArray();
    for(String recipient:recipients){
      recipientsArray.pushString(recipient);
    }

    JavaOnlyMap map = new JavaOnlyMap();
    map.putString("messageId",messageId);
    map.putMap("headers",headerMap);
    map.putArray("recipients",recipientsArray);
    map.putString("content",content);
    map.putString("timeStamp",timeStamp.toString());
    map.putString("error",errorMessage);

    getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("didFailMessage",map);
  }

  @Override
  public void didDeliverMessage(String messageId, String recipientId, Date timeStamp) {

    JavaOnlyMap map = new JavaOnlyMap();
    map.putString("messageId",messageId);
    map.putString("recipientId",recipientId);
    map.putString("timeStamp",timeStamp.toString());


    getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("didDeliverMessage",map);
  }


}