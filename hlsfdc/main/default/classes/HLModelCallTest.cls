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

    @isTest
    public static void buildFromCall() {
        Object o = JSON.deserializeUntyped(HLModelCallTest.fromCallResult);
        helplightning.HLModelCall c = helplightning.HLModelCall.buildFromCall(o, 'xyz');

        System.assertEquals('xyz', c.sessionId);
        System.assertEquals('call_5b3aaf79-1803-4859-9228-6ebf1d0988c5', c.callId);
        System.assertEquals(DateTime.newInstanceGmt(2021, 3, 12, 21, 12, 39), c.startTime);
        System.assertEquals(DateTime.newInstanceGmt(2021, 3, 12, 21, 14, 13), c.endTime);
        System.assertEquals(true, c.complete);
        System.assertEquals(94, c.duration);
        System.assertEquals(true, c.successful);
    }

    @isTest
    public static void buildFromCallNull() {
        helplightning.HLModelCall c1 = helplightning.HLModelCall.buildFromCall(null, 'xyz');
        System.assertEquals(c1, null);

        // with a null call
        Map<String,Object> o = new Map<String,Object>();
        helplightning.HLModelCall c2 = helplightning.HLModelCall.buildFromCall(o, 'xyz');
        System.assertEquals(c2, null);

        // no end time
        Object o2 = JSON.deserializeUntyped(HLModelCallTest.fromCallResultNotEnded);
        helplightning.HLModelCall c3 = helplightning.HLModelCall.buildFromCall(o2, 'xyz');
        System.assertEquals(c3, null);

        // not ended reason
        Object o3 = JSON.deserializeUntyped(HLModelCallTest.fromCallResultNotSuccessful);
        helplightning.HLModelCall c4 = helplightning.HLModelCall.buildFromCall(o3, 'xyz');
        System.assertEquals(c4, null);
    }

    private static String result = '[{"successful":true,"start_time":"2018-05-25T18:19:11Z","session_id":"04a02af9-f4d9-4cd6-850f-19920e06ce46","receiver":{"name":"Small User2","id":"5","email":"small_u2@helplightning.com"},"end_time":"2018-05-25T18:24:21Z","duration":309,"dialer":{"name":"Small Admin","id":"3","email":"small_admin@helplightning.com"},"complete":true,"call_id":"call_9a034486-4fad-413e-9de1-2033ba810b39"}]';

    private static String fromCallResult = '{"error":false,"call":{"timestamp":"Mar 12, 2021 21:12","timeCallStarted":"1615583559.322","timeCallEnded":"1615583653.298","tags":[],"session":"call_5b3aaf79-1803-4859-9228-6ebf1d0988c5","requests":[{"requests":[{"to":{"username":"bubbie","name":"Bubbie","is_group":false,"id":"285","enterpriseId":"222","email":"bubbie@helplightning.com"},"timestamp":"2021-03-12T21:12:36.704131Z","reason":"accepted","from":{"username":"flapjack","name":"Flapjack","is_group":false,"id":"278","enterpriseId":"222","email":"flapjack@helplightning.com"}}],"request_id":"73f84682-37bc-4eae-a59f-bc861c854f3f"}],"requestFor":{"username":"bubbie","name":"Bubbie","is_group":false,"id":"285","enterpriseId":"222","email":"bubbie@helplightning.com"},"recordingUrl":"","recordingStatus":"finished","recordingError":"","receiverName":"Bubbie","receiverId":"285","receiver":{"username":"bubbie","name":"Bubbie","id":"285","enterpriseId":"222","email":"bubbie@helplightning.com"},"reasonCallEnded":"Call Ended","ratings":[],"participants":[{"username":"flapjack","name":"Flapjack","isAnonymous":false,"id":"278","enterpriseId":"222","email":"flapjack@helplightning.com"},{"username":"bubbie","name":"Bubbie","isAnonymous":false,"id":"285","enterpriseId":"222","email":"bubbie@helplightning.com"}],"intraEnterpriseCall":true,"groups":["Adults","Kids","Level 1 Support"],"dialerName":"Flapjack","dialerId":"278","dialer":{"username":"flapjack","name":"Flapjack","id":"278","enterpriseId":"222","email":"flapjack@helplightning.com"},"callDuration":94,"archive_id":null}}';

    private static String fromCallResultNotEnded = '{"error":false,"call":{"timestamp":"Mar 12, 2021 21:12","timeCallStarted":"1615583559.322","timeCallEnded":"","tags":[],"session":"call_5b3aaf79-1803-4859-9228-6ebf1d0988c5","requests":[{"requests":[{"to":{"username":"bubbie","name":"Bubbie","is_group":false,"id":"285","enterpriseId":"222","email":"bubbie@helplightning.com"},"timestamp":"2021-03-12T21:12:36.704131Z","reason":"accepted","from":{"username":"flapjack","name":"Flapjack","is_group":false,"id":"278","enterpriseId":"222","email":"flapjack@helplightning.com"}}],"request_id":"73f84682-37bc-4eae-a59f-bc861c854f3f"}],"requestFor":{"username":"bubbie","name":"Bubbie","is_group":false,"id":"285","enterpriseId":"222","email":"bubbie@helplightning.com"},"recordingUrl":"","recordingStatus":"finished","recordingError":"","receiverName":"Bubbie","receiverId":"285","receiver":{"username":"bubbie","name":"Bubbie","id":"285","enterpriseId":"222","email":"bubbie@helplightning.com"},"reasonCallEnded":"Call Ended","ratings":[],"participants":[{"username":"flapjack","name":"Flapjack","isAnonymous":false,"id":"278","enterpriseId":"222","email":"flapjack@helplightning.com"},{"username":"bubbie","name":"Bubbie","isAnonymous":false,"id":"285","enterpriseId":"222","email":"bubbie@helplightning.com"}],"intraEnterpriseCall":true,"groups":["Adults","Kids","Level 1 Support"],"dialerName":"Flapjack","dialerId":"278","dialer":{"username":"flapjack","name":"Flapjack","id":"278","enterpriseId":"222","email":"flapjack@helplightning.com"},"callDuration":94,"archive_id":null}}';

    private static String fromCallResultNotSuccessful = '{"error":false,"call":{"timestamp":"Mar 12, 2021 21:12","timeCallStarted":"1615583559.322","timeCallEnded":"1615583653.298","tags":[],"session":"call_5b3aaf79-1803-4859-9228-6ebf1d0988c5","requests":[{"requests":[{"to":{"username":"bubbie","name":"Bubbie","is_group":false,"id":"285","enterpriseId":"222","email":"bubbie@helplightning.com"},"timestamp":"2021-03-12T21:12:36.704131Z","reason":"accepted","from":{"username":"flapjack","name":"Flapjack","is_group":false,"id":"278","enterpriseId":"222","email":"flapjack@helplightning.com"}}],"request_id":"73f84682-37bc-4eae-a59f-bc861c854f3f"}],"requestFor":{"username":"bubbie","name":"Bubbie","is_group":false,"id":"285","enterpriseId":"222","email":"bubbie@helplightning.com"},"recordingUrl":"","recordingStatus":"finished","recordingError":"","receiverName":"Bubbie","receiverId":"285","receiver":{"username":"bubbie","name":"Bubbie","id":"285","enterpriseId":"222","email":"bubbie@helplightning.com"},"reasonCallEnded":"","ratings":[],"participants":[{"username":"flapjack","name":"Flapjack","isAnonymous":false,"id":"278","enterpriseId":"222","email":"flapjack@helplightning.com"},{"username":"bubbie","name":"Bubbie","isAnonymous":false,"id":"285","enterpriseId":"222","email":"bubbie@helplightning.com"}],"intraEnterpriseCall":true,"groups":["Adults","Kids","Level 1 Support"],"dialerName":"Flapjack","dialerId":"278","dialer":{"username":"flapjack","name":"Flapjack","id":"278","enterpriseId":"222","email":"flapjack@helplightning.com"},"callDuration":94,"archive_id":null}}';
}
