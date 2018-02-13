
package com.bluecall.sinch;

import android.content.Context;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class RNSinchRtcModule extends ReactContextBaseJavaModule implements CallDelegate, MessageDelegate {

  private final ReactApplicationContext reactContext;
  private final SinchNotificationHandlerable mNotificationHandler;

  public RNSinchRtcModule(ReactApplicationContext reactContext, SinchNotificationHandlerable notificationHandler) {
    super(reactContext);
    this.reactContext = reactContext;
    this.mNotificationHandler = notificationHandler;
    PhoneActivityManager.getInstance().mCallDelegate = this;
    PhoneActivityManager.getInstance().mMessageDelegate= this;
    PhoneActivityManager.getInstance().setContext(reactContext);
    Log.d("SinchModule", "created ");
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
  public void setDisplayName(String displayName){PhoneActivityManager.getInstance().setDisplayName(displayName);}

  @ReactMethod
  public void call(String username, Callback callback) {
    PhoneActivityManager.getInstance().call(username, callback);
  }

  @ReactMethod
  public void answer() {
    PhoneActivityManager.getInstance().answer();
  }

  @ReactMethod
  public void hangup() {
    PhoneActivityManager.getInstance().hangup();
  }

  @ReactMethod
  public void sendMessage(String recipientUserId, String textBody, ReadableMap headers, Callback callback){

    PhoneActivityManager.getInstance().sendMessage(recipientUserId, textBody, headers, callback);
  }

  @ReactMethod
  public void terminate(){

    PhoneActivityManager.getInstance().terminate();
  }

  @ReactMethod
  public void terminateGracefully(){

    PhoneActivityManager.getInstance().terminateGracefully();
  }


  //Call Delegate
  @Override
  public void didReceiveCall(String callId) {
    Log.d("SinchModule", "SinchModule onIncomingCall>> sending event: ");
    getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("didReceiveCall",null);
  }

  @Override
  public void callEndedWithReason(String reason, int duration) {
    Log.d("SinchModule", "SinchModule callEndedWithReason: ");
    WritableMap map = Arguments.createMap();
    map.putString("reason",reason);
    map.putInt("duration", duration);
    getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("callEndedWithReason", map);
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
  public void didReceiveMessage(Context context, String messageId, Map<String, String> headers, String senderId, List<String> recipients, String content, Date timeStamp) {

    WritableMap headerMap = Arguments.createMap();
    for (String key:headers.keySet()) {
        headerMap.putString(key,headers.get(key));
    }

    WritableArray recipientsArray =  Arguments.createArray();
    for(String recipient:recipients){
      recipientsArray.pushString(recipient);
    }

    WritableMap map = Arguments.createMap();
    map.putString("messageId",messageId);
    map.putMap("headers",headerMap);
    map.putString("senderId",senderId);
    map.putArray("recipients",recipientsArray);
    map.putString("content",content);
    map.putString("timeStamp",timeStamp.toString());

    getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("didReceiveMessage", map);

    //mNotificationHandler.handleReceivedMessage(context, messageId, headers, senderId, recipients, content, timeStamp);
  }

  @Override
  public void didSendMessage(String messageId, Map<String, String> headers, List<String> recipients, String content, Date timeStamp) {
    WritableMap headerMap = Arguments.createMap();
    for (String key:headers.keySet()) {
      headerMap.putString(key,headers.get(key));
    }

    WritableArray recipientsArray =  Arguments.createArray();
    for(String recipient:recipients){
      recipientsArray.pushString(recipient);
    }

    WritableMap map = Arguments.createMap();
    map.putString("messageId",messageId);
    map.putMap("headers",headerMap);
    map.putArray("recipients",recipientsArray);
    map.putString("content",content);
    map.putString("timeStamp",timeStamp.toString());

    getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("didSendMessage",map);
  }

  @Override
  public void didFailMessage(String messageId, Map<String, String> headers, List<String> recipients, String content, Date timeStamp, String errorMessage) {
    WritableMap headerMap = Arguments.createMap();
    for (String key:headers.keySet()) {
      headerMap.putString(key,headers.get(key));
    }

    WritableArray recipientsArray = Arguments.createArray();
    for(String recipient:recipients){
      recipientsArray.pushString(recipient);
    }

    WritableMap map = Arguments.createMap();
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

    WritableMap map = Arguments.createMap();
    map.putString("messageId",messageId);
    map.putString("recipientId",recipientId);
    map.putString("timeStamp",timeStamp.toString());


    getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("didDeliverMessage",map);
  }


}