package com.bluecall.sinch;

import android.media.AudioManager;
import android.util.Log;
import android.widget.Toast;

import com.sinch.android.rtc.PushPair;
import com.sinch.android.rtc.calling.Call;
import com.sinch.android.rtc.calling.CallEndCause;
import com.sinch.android.rtc.calling.CallListener;

import java.util.List;

/**
 * Created by tamarabernad on 2018-01-10.
 */

public class SinchCallManager {
    static final String TAG = SinchCallManager.class.getSimpleName();

    public Call mSinchCall;
    public CallDelegate mDelegate;

    public SinchCallManager(Call call, CallDelegate delegate) {
        super();
        mSinchCall = call;
        mSinchCall.addCallListener(new SinchCallListener());
        mDelegate = delegate;
    }
    public void answer() {
        mSinchCall.answer();
    }
    public void hangup() {
        if (mSinchCall != null) {
            mSinchCall.hangup();
        }
    }
    private void endCall() {
       // mAudioPlayer.stopProgressTone();
        if (mSinchCall != null) {
            mSinchCall.hangup();
        }
    }
    private class SinchCallListener implements CallListener {

        @Override
        public void onCallEnded(Call call) {
            CallEndCause cause = call.getDetails().getEndCause();
            mDelegate.callEndedWithReason(cause.toString());
            Log.d(TAG, "Call ended. Reason: " + cause.toString());
            //mAudioPlayer.stopProgressTone();
            //setVolumeControlStream(AudioManager.USE_DEFAULT_STREAM_TYPE);
            String endMsg = "Call ended: " + call.getDetails().toString();
            endCall();
        }

        @Override
        public void onCallEstablished(Call call) {
            Log.d(TAG, "Call established");
            mDelegate.callDidEstablish();
            //mAudioPlayer.stopProgressTone();
            //setVolumeControlStream(AudioManager.STREAM_VOICE_CALL);
        }

        @Override
        public void onCallProgressing(Call call) {
            Log.d(TAG, "Call progressing");
            mDelegate.callDidProgress();
           // mAudioPlayer.playProgressTone();
        }

        @Override
        public void onShouldSendPushNotification(Call call, List<PushPair> pushPairs) {
            // no need to implement if you use managed push
        }

    }
}
