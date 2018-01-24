
package com.bluecall.sinch;

import android.util.Log;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

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
    getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("didReceiveMessage",null);
  }

  @Override
  public void didSendMessage(String messageId, Map<String, String> headers, List<String> recipients, String content, Date timeStamp) {
    getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("didSendMessage",null);
  }

  @Override
  public void didFailMessage(String messageId, Map<String, String> headers, List<String> recipients, String content, Date timeStamp, String errorMessage) {
    getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("didFailMessage",null);
  }

  @Override
  public void didDeliverMessage(String messageId, String recipientId, Date timeStamp) {
    getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("didDeliverMessage",null);
  }
}