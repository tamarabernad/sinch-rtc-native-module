package com.bluecall.sinch;

import android.app.Service;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;

import com.google.firebase.messaging.RemoteMessage;
import com.sinch.android.rtc.SinchHelpers;

import java.util.Map;

/**
 * Created by tamarabernad on 2018-06-14.
 */

public class SinchNotificationHandler {

    public static void onMessageReceived(final RemoteMessage remoteMessage, final Context applicationContext){
        Map data = remoteMessage.getData();
        if (SinchHelpers.isSinchPushPayload(data)) {
            new ServiceConnection() {
                private Map payload;

                @Override
                public void onServiceConnected(ComponentName name, IBinder service) {
                    if (payload != null) {
                        SinchService.SinchServiceInterface sinchService = (SinchService.SinchServiceInterface) service;
                        if (sinchService != null) {
                            sinchService.relayRemotePushNotificationPayload(payload);
                        }
                    }
                    payload = null;
                }

                @Override
                public void onServiceDisconnected(ComponentName name) {}

                public void relayMessageData(Map<String, String> data) {
                    payload = data;
                    applicationContext.bindService(new Intent(applicationContext, SinchService.class), this, Context.BIND_AUTO_CREATE);
                }
            }.relayMessageData(data);
        }
    }
}
