package com.bluecall.sinch;

import android.util.Log;

import com.sinch.android.rtc.PushPair;
import com.sinch.android.rtc.calling.Call;
import com.sinch.android.rtc.messaging.Message;
import com.sinch.android.rtc.messaging.MessageClient;
import com.sinch.android.rtc.messaging.MessageClientListener;
import com.sinch.android.rtc.messaging.MessageDeliveryInfo;
import com.sinch.android.rtc.messaging.MessageFailureInfo;
import com.sinch.android.rtc.messaging.WritableMessage;

import java.util.List;

/**
 * Created by tamarabernad on 2018-01-23.
 */

public class SinchMessagesManager implements MessageClientListener {
    MessageDelegate mDelegate;

    @Override
    public void onIncomingMessage(MessageClient messageClient, Message message) {
        Log.d("SinchMessagesManager", "onIncomingMessage");
        mDelegate.didReceiveMessage(message.getMessageId(),message.getHeaders(), message.getSenderId(), message.getTextBody(), message.getTimestamp());
    }

    @Override
    public void onMessageSent(MessageClient messageClient, Message message, String s) {
        Log.d("SinchMessagesManager", "onMessageSent");
        mDelegate.didSendMessage(message.getMessageId(), message.getHeaders(), message.getRecipientIds(), message.getTextBody(), message.getTimestamp());
    }

    @Override
    public void onMessageFailed(MessageClient messageClient, Message message, MessageFailureInfo messageFailureInfo) {
        Log.d("SinchMessagesManager", "onMessageFailed");
        mDelegate.didFailMessage(message.getMessageId(), message.getHeaders(), message.getRecipientIds(), message.getTextBody(), message.getTimestamp(), messageFailureInfo.getSinchError().getMessage());
    }

    @Override
    public void onMessageDelivered(MessageClient messageClient, MessageDeliveryInfo messageDeliveryInfo) {
        Log.d("SinchMessagesManager", "onMessageDelivered");
        mDelegate.didDeliverMessage(messageDeliveryInfo.getMessageId(), messageDeliveryInfo.getRecipientId(), messageDeliveryInfo.getTimestamp());
    }

    @Override
    public void onShouldSendPushData(MessageClient messageClient, Message message, List<PushPair> list) {
        Log.d("SinchMessagesManager", "onShouldSendPushData");
    }
}
