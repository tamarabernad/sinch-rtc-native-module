package com.bluecall.sinch;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.bridge.ReadableType;
import com.facebook.react.bridge.WritableArray;
import com.sinch.android.rtc.ClientRegistration;
import com.sinch.android.rtc.MissingGCMException;
import com.sinch.android.rtc.NotificationResult;
import com.sinch.android.rtc.PushPair;
import com.sinch.android.rtc.Sinch;
import com.sinch.android.rtc.SinchClient;
import com.sinch.android.rtc.SinchClientListener;
import com.sinch.android.rtc.SinchError;
import com.sinch.android.rtc.calling.Call;
import com.sinch.android.rtc.calling.CallClient;
import com.sinch.android.rtc.calling.CallClientListener;
import com.sinch.android.rtc.messaging.MessageClient;
import com.sinch.android.rtc.messaging.MessageClientListener;
import com.sinch.android.rtc.messaging.MessageDeliveryInfo;
import com.sinch.android.rtc.messaging.MessageFailureInfo;
import com.sinch.android.rtc.messaging.WritableMessage;

import android.app.Service;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.content.pm.ServiceInfo;
import android.os.Binder;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;

import java.util.List;
import java.util.Map;

public class SinchService extends Service {
    static final String TAG = SinchService.class.getSimpleName();

    public CallDelegate mCallDelegate;
    public MessageDelegate mMessageDelegate;

    private MessagesHandlerable _mMessagesHandler;

    private Boolean mMessagesEnabled= true;

    private PersistedSettings mSettings;
    private SinchServiceInterface mSinchServiceInterface = new SinchServiceInterface();
    private SinchClient mSinchClient;

    private StartFailedListener mListener;
    private SinchCallManager mCallManager;

    @Override
    public void onCreate() {
        super.onCreate();
        mSettings = new PersistedSettings(getApplicationContext());
    }

    private void createClient(String username) {
        ServiceInfo ai = null;
        String appkey="";
        String appSecret="";
        String appEnvironment="";
        try {
            ComponentName myService = new ComponentName(SinchService.this, SinchService.this.getClass());
            ai = getPackageManager().getServiceInfo(myService, PackageManager.GET_META_DATA);
            Bundle bundle = ai.metaData;
            appkey = bundle.getString("SINCH_APP_KEY");
            appSecret = bundle.getString("SINCH_APP_SECRET");
            appEnvironment= bundle.getString("SINCH_ENVIRONMENT");

        } catch (Exception e) {
            e.printStackTrace();
        }


        mSinchClient = Sinch.getSinchClientBuilder().context(getApplicationContext()).userId(username)
                .applicationKey(appkey)
                .applicationSecret(appSecret)
                .environmentHost(appEnvironment).build();

        mSinchClient.setSupportCalling(true);

        if(mMessagesEnabled){
            mSinchClient.setSupportMessaging(mMessagesEnabled);
            mSinchClient.getMessageClient().addMessageClientListener(new SinchMessageClientListener());
        }


        //TODO: Is this needed?
        try {
            mSinchClient.setSupportManagedPush(true);
        }catch (MissingGCMException e){
            Log.d("SinchService",e.getLocalizedMessage());
        }

        mSinchClient.addSinchClientListener(new MySinchClientListener());
        mSinchClient.getCallClient().addCallClientListener(new SinchCallClientListener());

    }

    @Override
    public void onDestroy() {
        if (mSinchClient != null && mSinchClient.isStarted()) {
            mSinchClient.terminate();
        }
        super.onDestroy();
    }

    private void start(String username) {
        if (mSinchClient == null) {
            mSettings.setUsername(username);
            createClient(username);
        }
        Log.d(TAG, "Starting SinchClient");

        try {
            mSinchClient.start();
        } catch (Exception ex) {
            Log.d(TAG, "Error: " + ex.getMessage());
            createClient(username);
            mSinchClient.start();
        }
    }

    private void stop() {
        if (mSinchClient != null) {
            mSinchClient.terminate();
            mSinchClient = null;
        }
    }

    private boolean isStarted() {
        return (mSinchClient != null && mSinchClient.isStarted());
    }

    @Override
    public IBinder onBind(Intent intent) {
        return mSinchServiceInterface;
    }

    private MessagesHandlerable getmMessageHandler(){
        if(_mMessagesHandler == null){

            ServiceInfo ai = null;
            try {
                ComponentName myService = new ComponentName(SinchService.this, SinchService.this.getClass());
                ai = getPackageManager().getServiceInfo(myService, PackageManager.GET_META_DATA);
                Bundle bundle = ai.metaData;
                String handlerClassStr = bundle.getString("messages_handler");
                _mMessagesHandler  = (MessagesHandlerable)Class.forName(handlerClassStr).newInstance();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return _mMessagesHandler;
    }

    public class SinchServiceInterface extends Binder {

        public Call callUser(String userId) {
            Call call = mSinchClient.getCallClient().callUser(userId);
            mCallManager = new SinchCallManager(call, mCallDelegate);
            return call;
        }
        public void setCallDelegate(CallDelegate delegate){
            SinchService.this.mCallDelegate = delegate;
        }
        public void setMessageDelegate(MessageDelegate delegate){
            SinchService.this.mMessageDelegate = delegate;
        }
        public String getUserName() {
            return mSinchClient.getLocalUserId();
        }

        public boolean isStarted() {
            return SinchService.this.isStarted();
        }

        public void startClient(String userName) {
            start(userName);
        }

        public void stopClient() {
            stop();
        }

        public void setStartListener(StartFailedListener listener) {
            mListener = listener;
        }

        public Call getCall(String callId) {
            return mSinchClient.getCallClient().getCall(callId);
        }

        public NotificationResult relayRemotePushNotificationPayload(final Map payload) {
            if (mSinchClient == null && !mSettings.getUsername().isEmpty()) {
                createClient(mSettings.getUsername());
            } else if (mSinchClient == null && mSettings.getUsername().isEmpty()) {
                Log.e(TAG, "Can't start a SinchClient as no username is available, unable to relay push.");
                return null;
            }
            NotificationResult result = mSinchClient.relayRemotePushNotificationPayload(payload);
            if(result.isMessage()){
                mSinchClient.startListeningOnActiveConnection();
            }
            return result;
        }
        public void answer() {
            mCallManager.answer();
        }
        public void hangup() {
            mCallManager.hangup();
        }
        public void setDisplayName(String displayName){
            if(displayName == null)return;
            mSinchClient.setPushNotificationDisplayName(displayName);
        }
        public void sendMessage(String recipientUserId, String textBody, ReadableMap headers, Callback callback) {
            if (isStarted()) {

                WritableMessage message = new WritableMessage(recipientUserId, textBody);
                ReadableMapKeySetIterator iterator = headers.keySetIterator();
                while (iterator.hasNextKey()) {
                    String key = iterator.nextKey();
                    ReadableType type = headers.getType(key);
                    if(type == ReadableType.String){
                        message.addHeader(key, headers.getString(key));
                    }
                }

                mSinchClient.getMessageClient().send(message);

                WritableArray recipientsArray =  Arguments.createArray();
                for(String recipient:message.getRecipientIds()){
                    recipientsArray.pushString(recipient);
                }

                getmMessageHandler().onSendingMessage(SinchService.this, message.getMessageId(), message.getHeaders(), this.getUserName(), message.getRecipientIds(), message.getTextBody());
                callback.invoke(message.getMessageId(), recipientsArray, message.getTextBody());

            }
        }
        public void terminateGracefully(){
            if (mSinchClient != null) {
                mSinchClient.stopListeningOnActiveConnection();
                mSinchClient.terminateGracefully();
            }
        }
        public void terminate(){
            if (mSinchClient != null) {
                mSinchClient.stopListeningOnActiveConnection();
                mSinchClient.terminate();
            }
        }
    }

    public interface StartFailedListener {

        void onStartFailed(SinchError error);

        void onStarted();
    }

    private class MySinchClientListener implements SinchClientListener {

        @Override
        public void onClientFailed(SinchClient client, SinchError error) {
            if (mListener != null) {
                mListener.onStartFailed(error);
            }
            mSinchClient.terminate();
            mSinchClient = null;
        }

        @Override
        public void onClientStarted(SinchClient client) {
            Log.d(TAG, "SinchClient started");
            if (mListener != null) {
                mListener.onStarted();
            }
        }

        @Override
        public void onClientStopped(SinchClient client) {
            Log.d(TAG, "SinchClient stopped");
        }

        @Override
        public void onLogMessage(int level, String area, String message) {
            switch (level) {
                case Log.DEBUG:
                    Log.d(area, message);
                    break;
                case Log.ERROR:
                    Log.e(area, message);
                    break;
                case Log.INFO:
                    Log.i(area, message);
                    break;
                case Log.VERBOSE:
                    Log.v(area, message);
                    break;
                case Log.WARN:
                    Log.w(area, message);
                    break;
            }
        }

        @Override
        public void onRegistrationCredentialsRequired(SinchClient client,
                                                      ClientRegistration clientRegistration) {
        }
    }

    private class SinchCallClientListener implements CallClientListener {

        @Override
        public void onIncomingCall(CallClient callClient, Call call) {
            Log.d(TAG, "onIncomingCall: " + call.getCallId());
            mCallDelegate.didReceiveCall(call.getCallId());
            mCallManager = new SinchCallManager(call, mCallDelegate);
            /*Intent intent = new Intent(SinchService.this, IncomingCallScreenActivity.class);
            intent.putExtra(CALL_ID, call.getCallId());
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            SinchService.this.startActivity(intent);*/
        }
    }
    private class SinchMessageClientListener implements MessageClientListener {

        @Override
        public void onIncomingMessage(MessageClient messageClient, com.sinch.android.rtc.messaging.Message message) {
            getmMessageHandler().onIncomingMessage(SinchService.this, message.getMessageId(), message.getHeaders(), message.getSenderId(), message.getRecipientIds(), message.getTextBody(), message.getTimestamp());

            if(mMessageDelegate != null) {
                //App is in foreground and ReactNative context
                mMessageDelegate.didReceiveMessage(SinchService.this, message.getMessageId(), message.getHeaders(), message.getSenderId(), message.getRecipientIds(), message.getTextBody(), message.getTimestamp());
            }
        }

        @Override
        public void onMessageSent(MessageClient messageClient, com.sinch.android.rtc.messaging.Message message, String s) {
            Log.d(TAG, "onMessageSent");
            mMessageDelegate.didSendMessage(message.getMessageId(), message.getHeaders(), message.getRecipientIds(), message.getTextBody(), message.getTimestamp());
        }

        @Override
        public void onMessageFailed(MessageClient messageClient, com.sinch.android.rtc.messaging.Message message, MessageFailureInfo messageFailureInfo) {
            Log.d(TAG, "onMessageFailed");
            mMessageDelegate.didFailMessage(message.getMessageId(), message.getHeaders(), message.getRecipientIds(), message.getTextBody(), message.getTimestamp(), messageFailureInfo.getSinchError().getMessage());
        }

        @Override
        public void onMessageDelivered(MessageClient messageClient, MessageDeliveryInfo messageDeliveryInfo) {
            Log.d(TAG, "onMessageDelivered");
            mMessageDelegate.didDeliverMessage(messageDeliveryInfo.getMessageId(), messageDeliveryInfo.getRecipientId(), messageDeliveryInfo.getTimestamp());
        }

        @Override
        public void onShouldSendPushData(MessageClient messageClient, com.sinch.android.rtc.messaging.Message message, List<PushPair> list) {
            Log.d(TAG, "onShouldSendPushData");
        }
    }


    private class PersistedSettings {

        private SharedPreferences mStore;

        private static final String PREF_KEY = "Sinch";

        public PersistedSettings(Context context) {
            mStore = context.getSharedPreferences(PREF_KEY, MODE_PRIVATE);
        }

        public String getUsername() {
            return mStore.getString("Username", "");
        }

        public void setUsername(String username) {
            SharedPreferences.Editor editor = mStore.edit();
            editor.putString("Username", username);
            editor.commit();
        }
    }
}