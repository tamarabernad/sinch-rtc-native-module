package com.bluecall.sinch;

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

    public MessageClient mMessageClient;

    public void sendMessage(String recipientUserId, String textBody) {
        WritableMessage message = new WritableMessage(recipientUserId, textBody);
        mMessageClient.send(message);
    }

    @Override
    public void onIncomingMessage(MessageClient messageClient, Message message) {

    }

    @Override
    public void onMessageSent(MessageClient messageClient, Message message, String s) {

    }

    @Override
    public void onMessageFailed(MessageClient messageClient, Message message, MessageFailureInfo messageFailureInfo) {

    }

    @Override
    public void onMessageDelivered(MessageClient messageClient, MessageDeliveryInfo messageDeliveryInfo) {

    }

    @Override
    public void onShouldSendPushData(MessageClient messageClient, Message message, List<PushPair> list) {

    }
}
