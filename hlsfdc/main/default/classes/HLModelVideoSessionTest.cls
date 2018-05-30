/* -*- Mode: java; -*- */

/**
 * HLModelVideoSessionTest.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
public class HLModelVideoSessionTest {
    @isTest
    static void testBuild() {
        Object o = JSON.deserializeUntyped(HLModelVideoSessionTest.result);
        helplightning.HLModelVideoSession s = helplightning.HLModelVideoSession.build(o);

        System.assertEquals(s.token, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE1Mjk4NTQ1ODMsImlhdCI6MTUyNzI2MjU4MywiaXNzIjoiR2hhemFsIiwianRpIjoiOTYwNjQ1ZmUtYmQ3Mi00MGY0LTk4ZDgtMTczYzAzMDk5MzNiIiwibmJmIjoxNTI3MjYyNTgyLCJwZW0iOnsic2Vzc2lvbiI6MTA3NTF9LCJzdWIiOiJTZXNzaW9uOmFmMzA0MjYyLWQyMzItNDA0YS05YjhiLTdjMTNlZTU3MDY2MSIsInR5cCI6ImFjY2VzcyIsInZlciI6IjEwMCJ9.8hIO8_h0SevOU6w5DP-_-t1lcrzTp_9BePRojbBanzA');
        System.assertEquals(s.serverURL, 'gss+ssl://containers-us.helplightning.net:40178');
        System.assertEquals(s.serverWSURL, 'wss://containers-us.helplightning.net:40177');
    }

    @isTest
    static void testNull() {
        helplightning.HLModelVideoSession s = helplightning.HLModelVideoSession.build(null);
        System.assertEquals(s, null);
    }

    @isTest
    static void testSerialize() {
        Object o = JSON.deserializeUntyped(HLModelVideoSessionTest.result);
        helplightning.HLModelVideoSession s = helplightning.HLModelVideoSession.build(o);

        Map<String,Object> gss = s.serialize();
        System.assertEquals(gss.get('token'), (Object)'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE1Mjk4NTQ1ODMsImlhdCI6MTUyNzI2MjU4MywiaXNzIjoiR2hhemFsIiwianRpIjoiOTYwNjQ1ZmUtYmQ3Mi00MGY0LTk4ZDgtMTczYzAzMDk5MzNiIiwibmJmIjoxNTI3MjYyNTgyLCJwZW0iOnsic2Vzc2lvbiI6MTA3NTF9LCJzdWIiOiJTZXNzaW9uOmFmMzA0MjYyLWQyMzItNDA0YS05YjhiLTdjMTNlZTU3MDY2MSIsInR5cCI6ImFjY2VzcyIsInZlciI6IjEwMCJ9.8hIO8_h0SevOU6w5DP-_-t1lcrzTp_9BePRojbBanzA');
        System.assertEquals(gss.get('serverURL'), (Object)'gss+ssl://containers-us.helplightning.net:40178');
        System.assertEquals(gss.get('serverWSURL'), (Object)'wss://containers-us.helplightning.net:40177');
    }

    private static String result = '{"gss_info":{"wsserver":"wss://containers-us.helplightning.net:40177","token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE1Mjk4NTQ1ODMsImlhdCI6MTUyNzI2MjU4MywiaXNzIjoiR2hhemFsIiwianRpIjoiOTYwNjQ1ZmUtYmQ3Mi00MGY0LTk4ZDgtMTczYzAzMDk5MzNiIiwibmJmIjoxNTI3MjYyNTgyLCJwZW0iOnsic2Vzc2lvbiI6MTA3NTF9LCJzdWIiOiJTZXNzaW9uOmFmMzA0MjYyLWQyMzItNDA0YS05YjhiLTdjMTNlZTU3MDY2MSIsInR5cCI6ImFjY2VzcyIsInZlciI6IjEwMCJ9.8hIO8_h0SevOU6w5DP-_-t1lcrzTp_9BePRojbBanzA","server":"gss+ssl://containers-us.helplightning.net:40178"}}';
}
