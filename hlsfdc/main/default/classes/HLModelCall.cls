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
                       helplightning.HLModelCallUser receiver, Integer workboxId) {
        this.sessionId = sessionId;
        this.callId = callId;
        this.startTime = startTime;
        this.endTime = endTime;
        this.complete = complete;
        this.duration = duration;
        this.successful = successful;
        this.dialer = dialer;
        this.receiver = receiver;
        this.workboxId = workboxId;
    }

    /**
     * Build a model from a JSON response object.
     */
    public static HLModelCall build(Object result) {
        Map<String,Object> s = (Map<String,Object>)result;

        String startTimeString = (String)s.get('start_time');
        String endTimeString = (String)s.get('end_time');

        if (String.isEmpty(startTimeString) || String.isEmpty(endTimeString)) {
            return null;
        }

        DateTime startTime = (DateTime)JSON.deserialize('"' + startTimeString + '"', DateTime.class);
        DateTime endTime = (DateTime)JSON.deserialize('"' + endTimeString + '"', DateTime.class);

        return new HLModelCall((String)s.get('session_id'),
                               (String)s.get('call_id'),
                               startTime,
                               endTime,
                               (Boolean)s.get('complete'),
                               (Decimal)s.get('duration'),
                               (Boolean)s.get('successful'),
                               helplightning.HLModelCallUser.build(s.get('dialer')),
                               helplightning.HLModelCallUser.build(s.get('receiver')),
                               (Integer)s.get('workbox_id')
                               );
    }

    /**
     * Build from a single call result. This parses the model returned by
     *  (/v1/enterprise/calls/:id)
     */
    public static HLModelCall buildFromCall(Object result, String sessionId) {
        Map<String,Object> s = (Map<String,Object>)result;
        if (s == null) {
            System.debug('HLModelCall.buildFromCall: S null result');
            return null;
        }

        Map<String,Object> call = (Map<String,Object>)s.get('call');
        if (call == null) {
            System.debug('HLModelCall.buildFromCall: call null result');
            return null;
        }
        
        String startTimeString = (String)call.get('timeCallStarted');
        String endTimeString = (String)call.get('timeCallEnded');
        Integer workboxId = (Integer)call.get('workbox_id');

        if (String.isEmpty(startTimeString) || String.isEmpty(endTimeString)) {
            System.debug('HLModelCall.buildFromCall: time empty: ' + startTimeString + ' ' + endTimeString);
            return null;
        }

        // Wait until the call is over...
        String reason = (String)call.get('reasonCallEnded');
        if (String.isEmpty(reason)) {
            // TODO: why does this break the call?
            System.debug('HLModelCall.buildFromCall: reason empty: ' + reason);
            // return null;
        }

        // start / end times are unix timestamps in seconds. Convert to milliseconds
        Long st = Decimal.valueOf(startTimeString).longValue() * 1000L;
        Long et = Decimal.valueOf(endTimeString).longValue() * 1000L;
        DateTime startTime = DateTime.newInstance(st);
        DateTime endTime = DateTime.newInstance(et);

        Boolean complete = !String.isEmpty(endTimeString);
        Boolean successful = reason == 'Call Ended';

        return new HLModelCall(sessionId,
                               (String)call.get('session'), // session is actually the call id
                               startTime,
                               endTime,
                               complete,
                               (Decimal)call.get('callDuration'),
                               successful,
                               helplightning.HLModelCallUser.build(call.get('dialer')),
                               helplightning.HLModelCallUser.build(call.get('receiver')),
                               workboxId
                               );
    }

    public static List<HLModelCall> buildMany(Object results) {
        List<HLModelCall> calls = new List<HLModelCall>();

        if (results != null) {
            for (Object call: (List<Object>)results) {
                HLModelCall newCall = HLModelCall.build(call);
                if (newCall != null) {
                    calls.add(newCall);
                }
            }
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
    @auraEnabled
    public Integer workboxId = 0;
}
