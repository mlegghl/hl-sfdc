/* -*- Mode: java; -*- */

/**
 * HLModelCallTest.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
public class HLModelCallTest {
    @isTest
    public static void buildMany() {
        Object o = JSON.deserializeUntyped(HLModelCallTest.result);
        List<helplightning.HLModelCall> calls = helplightning.HLModelCall.buildMany(o);

        System.assertEquals(1, calls.size());

        helplightning.HLModelCall c = calls.get(0);
        System.assertEquals('04a02af9-f4d9-4cd6-850f-19920e06ce46', c.sessionId);
        System.assertEquals('call_9a034486-4fad-413e-9de1-2033ba810b39', c.callId);
        System.assertEquals(DateTime.newInstanceGmt(2018, 5, 25, 18, 19, 11), c.startTime);
        System.assertEquals(DateTime.newInstanceGmt(2018, 5, 25, 18, 24, 21), c.endTime);
        System.assertEquals(true, c.complete);
        System.assertEquals(309, c.duration);
        System.assertEquals(true, c.successful);

        System.assertEquals('3', c.dialer.id);
        System.assertEquals('Small Admin', c.dialer.name);
        System.assertEquals('small_admin@helplightning.com', c.dialer.email);

        System.assertEquals('5', c.receiver.id);
        System.assertEquals('Small User2', c.receiver.name);
        System.assertEquals('small_u2@helplightning.com', c.receiver.email);
    }

    @isTest
    public static void buildNull() {
        List<helplightning.HLModelCall> calls = helplightning.HLModelCall.buildMany(null);

        System.assertEquals(0, calls.size());
    }

    private static String result = '[{"successful":true,"start_time":"2018-05-25T18:19:11Z","session_id":"04a02af9-f4d9-4cd6-850f-19920e06ce46","receiver":{"name":"Small User2","id":"5","email":"small_u2@helplightning.com"},"end_time":"2018-05-25T18:24:21Z","duration":309,"dialer":{"name":"Small Admin","id":"3","email":"small_admin@helplightning.com"},"complete":true,"call_id":"call_9a034486-4fad-413e-9de1-2033ba810b39"}]';
}
