package com.bluecall.sinch;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;

import com.facebook.react.bridge.ReadableMap;
import com.sinch.android.rtc.calling.Call;

/**
 * Created by tamarabernad on 2017-09-07.
 */

public class PhoneActivityManager implements ServiceConnection {

    private SinchService.SinchServiceInterface mSinchServiceInterface;
    public CallDelegate mCallDelegate;
    public MessageDelegate mMessageDelegate;

    private static PhoneActivityManager instance = null;
    protected PhoneActivityManager() {
        // Exists only to defeat instantiation.
    }
    public void setContext(Context context){
        context.bindService(new Intent(context, SinchService.class), this,
                Context.BIND_AUTO_CREATE);
    }
    public static PhoneActivityManager getInstance() {
        if(instance == null) {
            instance = new PhoneActivityManager();
        }
        return instance;
    }
    @Override
    public void onServiceConnected(ComponentName componentName, IBinder iBinder) {
        if (SinchService.class.getName().equals(componentName.getClassName())) {
            mSinchServiceInterface = (SinchService.SinchServiceInterface) iBinder;
            mSinchServiceInterface.setCallDelegate(mCallDelegate);
            mSinchServiceInterface.setMessageDelegate(mMessageDelegate);
        }
    }

    @Override
    public void onServiceDisconnected(ComponentName componentName) {
        if (SinchService.class.getName().equals(componentName.getClassName())) {
            mSinchServiceInterface = null;
        }
    }

    public SinchService.SinchServiceInterface getSinchServiceInterface() {
        return mSinchServiceInterface;
    }

    public void init(String appKey, String appSecret, String environment) {
        getSinchServiceInterface().init(appKey, appSecret, environment);
    }

    public void login(String username){
        if (!getSinchServiceInterface().isStarted()) {
            getSinchServiceInterface().startClient(username);
        }
    }

    public void call(String username){
        Call call = getSinchServiceInterface().callUser(username);
        String callId = call.getCallId();
    }

    public void answer() {
        getSinchServiceInterface().answer();
    }

    public void sendMessage(String recipientUserId, String textBody, ReadableMap headers) {
        getSinchServiceInterface().sendMessage(recipientUserId, textBody,headers);
    }
}
