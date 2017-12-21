package com.reactlibrary;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.util.Log;

import com.sinch.android.rtc.calling.Call;

/**
 * Created by tamarabernad on 2017-09-07.
 */

public class PhoneActivityManager implements ServiceConnection, CallDelegate {

    private SinchService.SinchServiceInterface mSinchServiceInterface;
    public CallDelegate mDelegate;
    private String mCallId;
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
            mSinchServiceInterface.setDelegate(this);
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
        Call call = getSinchServiceInterface().getCall(mCallId);
        call.answer();
    }
    @Override
    public void didReceiveCall(String callId) {
        this.mCallId = callId;
        Log.d("PhoneActivity", "PhoneActivity onIncomingCall: ");
        mDelegate.didReceiveCall(callId);
    }
}
