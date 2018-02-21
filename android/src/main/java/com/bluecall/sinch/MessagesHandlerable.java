package com.bluecall.sinch;

import android.content.Context;

import com.sinch.android.rtc.messaging.MessageClient;

import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * Created by tamarabernad on 2018-02-20.
 */

public interface MessagesHandlerable {
    void onIncomingMessage(Context context, String messageId, Map<String, String> headers, String senderId, List<String> recipients, String content, Date timeStamp);
    void onSendingMessage(Context context, String messageId, Map<String, String> headers, String senderId, List<String> recipients, String content);
}
