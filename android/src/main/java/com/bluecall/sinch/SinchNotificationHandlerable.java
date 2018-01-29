package com.bluecall.sinch;

import java.util.Date;
import java.util.Map;

/**
 * Created by tamarabernad on 2018-01-29.
 */

public interface SinchNotificationHandlerable {
    void handleReceivedMessage(String messageId, Map<String, String> headers, String senderId, String content, Date timeStamp);
}
