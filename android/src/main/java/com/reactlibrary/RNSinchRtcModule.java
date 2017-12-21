
package com.reactlibrary;

import android.util.Log;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.util.HashMap;
import java.util.Map;

public class RNSinchRtcModule extends ReactContextBaseJavaModule implements CallDelegate {

  private final ReactApplicationContext reactContext;

  public RNSinchRtcModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
    PhoneActivityManager.getInstance().mDelegate = this;
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
  public void show(String message, int duration) {

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

  @Override
  public void didReceiveCall(String callId) {
    Log.d("SinchModule", "SinchModule onIncomingCall>> sending event: ");
    getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("didReceiveCall",null);
  }
}