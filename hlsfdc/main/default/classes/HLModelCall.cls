/* -*- Mode: java; -*- */

/**
 * HLModelCall.cls
 *
 * Copyright (c) 2018 HelpLightning Inc.
 * https://helplightning.com
 */

public class HLModelCall {
    /**
     * A Model representing a Call object.
     */
    public HLModelCall(String sessionId, String callId,
                       DateTime startTime, DateTime endTime,
                       Boolean complete, Decimal duration, Boolean successful,
                       helplightning.HLModelCallUser dialer,
                       helplightning.HLModelCallUser receiver) {
        this.sessionId = sessionId;
        this.callId = callId;
        this.startTime = startTime;
        this.endTime = endTime;
        this.complete = complete;
        this.duration = duration;
        this.successful = successful;
        this.dialer = dialer;
        this.receiver = receiver;
    }

    /**
     * Build a model from a JSON response object.
     */
    public static HLModelCall build(Object result) {
        Map<String,Object> s = (Map<String,Object>)result;

        DateTime startTime = (DateTime)JSON.deserialize('"' + s.get('start_time') + '"', DateTime.class);
        DateTime endTime = (DateTime)JSON.deserialize('"' + s.get('end_time') + '"', DateTime.class);

        return new HLModelCall((String)s.get('session_id'),
                               (String)s.get('call_id'),
                               startTime,
                               endTime,
                               (Boolean)s.get('complete'),
                               (Decimal)s.get('duration'),
                               (Boolean)s.get('successful'),
                               helplightning.HLModelCallUser.build(s.get('dialer')),
                               helplightning.HLModelCallUser.build(s.get('receiver'))
                               );
    }

    public static List<HLModelCall> buildMany(Object results) {
        List<HLModelCall> calls = new List<HLModelCall>();

        for (Object call: (List<Object>)results) {
            calls.add(HLModelCall.build(call));
        }

        return calls;
    }

    public String sessionId = '';
    public String callId = '';
    public DateTime startTime;
    public DateTime endTime;
    public Boolean complete;
    public Decimal duration;
    public Boolean successful;
    public helplightning.HLModelCallUser dialer;
    public helplightning.HLModelCallUser receiver;
}
