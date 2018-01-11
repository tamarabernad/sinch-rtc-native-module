package com.bluecall.sinch;

/**
 * Created by tamarabernad on 2017-09-11.
 */

public interface CallDelegate {
    void didReceiveCall(String callId);
    void callEndedWithReason(String reason);
    void callDidEstablish();
    void callDidProgress();
    void callDidChangeStatus(String status);
}
