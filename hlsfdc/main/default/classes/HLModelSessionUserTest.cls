/* -*- Mode: java; -*- */

/**
 * HLModelSessionUserTest.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
public class HLModelSessionUserTest {
    @isTest
    public static void build() {
        Object o = JSON.deserializeUntyped(HLModelSessionUserTest.result);
        helplightning.HLModelSessionUser u = helplightning.HLModelSessionUser.build(o);

        System.assertEquals(u.id, 3);
        System.assertEquals(u.name, '');
        System.assertEquals(u.token, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE1Mjk4NTQzNDUsImlhdCI6MTUyNzI2MjM0NSwiaXNzIjoiR2hhemFsIiwianRpIjoiM2ZjZjc1ZGYtZWNjNS00Yjk1LWEwMTktZjk1YjE0NWIyYTlmIiwibmJmIjoxNTI3MjYyMzQ0LCJwZW0iOnsidXNlciI6MTIyODh9LCJzdWIiOiJVc2VyOjMiLCJ0eXAiOiJhY2Nlc3MiLCJ2ZXIiOiIxMDAifQ.q0JelI39xoDj4wzihRuwrkCNJB0J3XqPvzv2nRcSlD8');
        System.assertEquals(u.username, 'small_admin');
        System.assertEquals(u.avatarURL, null);
    }

    private static String result = '{"username":"small_admin","token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE1Mjk4NTQzNDUsImlhdCI6MTUyNzI2MjM0NSwiaXNzIjoiR2hhemFsIiwianRpIjoiM2ZjZjc1ZGYtZWNjNS00Yjk1LWEwMTktZjk1YjE0NWIyYTlmIiwibmJmIjoxNTI3MjYyMzQ0LCJwZW0iOnsidXNlciI6MTIyODh9LCJzdWIiOiJVc2VyOjMiLCJ0eXAiOiJhY2Nlc3MiLCJ2ZXIiOiIxMDAifQ.q0JelI39xoDj4wzihRuwrkCNJB0J3XqPvzv2nRcSlD8","status":0,"name":"","id":3,"avatar":{"thumb":null,"original":null}}';
}
