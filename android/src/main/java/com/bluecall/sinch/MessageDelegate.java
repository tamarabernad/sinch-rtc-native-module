package com.bluecall.sinch;

import android.content.Context;

import java.lang.reflect.Array;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * Created by tamarabernad on 2018-01-24.
 */

public interface MessageDelegate {

    void didReceiveMessage(Context context, String messageId, Map<String, String> headers, String senderId, List<String> recipients, String content, Date timeStamp);
    void didSendMessage(String messageId, Map<String, String> headers, List<String> recipients, String content, Date timeStamp);
    void didFailMessage(String messageId, Map<String, String> headers, List<String> recipients, String content, Date timeStamp, String errorMessage);
    void didDeliverMessage(String messageId, String recipientId, Date timeStamp);
}