/* -*- Mode: java; -*- */

/**
 * HLModelSessionTest.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
public class HLModelSessionTest {
    @isTest
    public static void build() {
        Object o = JSON.deserializeUntyped(HLModelSessionTest.result);
        helplightning.HLModelSession s = helplightning.HLModelSession.build(o);

        System.assertEquals(s.id, 'af304262-d232-404a-9b8b-7c13ee570661');
        System.assertEquals(s.token, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdHRyaWJ1dGVzIjpbXSwiYXVkIjoiR2hhemFsIiwiZXhwIjoxNTI5ODU0MzQ1LCJpYXQiOjE1MjcyNjIzNDUsImlzcyI6IkdoYXphbCIsImp0aSI6IjgwMTE0MjRlLTgzOTItNDkzYy04ZDc1LTRiNjE3YzQ4ZTk3OSIsIm5iZiI6MTUyNzI2MjM0NCwib3JpZ2luYXRvciI6MywicGVtIjp7InNlc3Npb24iOjEwNzUxfSwic3ViIjoiU2Vzc2lvbjphZjMwNDI2Mi1kMjMyLTQwNGEtOWI4Yi03YzEzZWU1NzA2NjEiLCJ0eXAiOiJhY2Nlc3MiLCJ2ZXIiOiIxMDAifQ.h4G4qMUgWYp8xy__WqJVFW72uruQYa-fGZCzG1MGaFI');
        System.assertEquals(s.videoActive, false);
        System.assertEquals(s.users.size(), 2);

        // validate the users
        helplightning.HLModelSessionUser u1 = s.users.get(0);
        helplightning.HLModelSessionUser u2 = s.users.get(1);

        System.assertEquals(u1.id, 3);
        System.assertEquals(u1.name, '');
        System.assertEquals(u1.token, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE1Mjk4NTQzNDUsImlhdCI6MTUyNzI2MjM0NSwiaXNzIjoiR2hhemFsIiwianRpIjoiM2ZjZjc1ZGYtZWNjNS00Yjk1LWEwMTktZjk1YjE0NWIyYTlmIiwibmJmIjoxNTI3MjYyMzQ0LCJwZW0iOnsidXNlciI6MTIyODh9LCJzdWIiOiJVc2VyOjMiLCJ0eXAiOiJhY2Nlc3MiLCJ2ZXIiOiIxMDAifQ.q0JelI39xoDj4wzihRuwrkCNJB0J3XqPvzv2nRcSlD8');
        System.assertEquals(u1.username, 'small_admin');
        System.assertEquals(u1.avatarURL, null);

        System.assertEquals(u2.id, 1045);
        System.assertEquals(u2.name, '');
        System.assertEquals(u2.token, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE1Mjk4NTQzNDUsImlhdCI6MTUyNzI2MjM0NSwiaXNzIjoiR2hhemFsIiwianRpIjoiZGY4MmFmZGQtYWE3Yi00NGM5LWFmNDQtZmY0MWNmNmVhOTI5IiwibmJmIjoxNTI3MjYyMzQ0LCJwZW0iOnsidXNlciI6MTIyODh9LCJzdWIiOiJVc2VyOjEwNDUiLCJ0eXAiOiJhY2Nlc3MiLCJ2ZXIiOiIxMDAifQ.lB_Big1jVmA_Bb2DQLiQsSS--Y9GkQi3zB1o5SQ-ICE');
        System.assertEquals(u2.username, 'p_1');
        System.assertEquals(u2.avatarURL, null);
    }

    @isTest
    public static void buildNull() {
        helplightning.HLModelSession s = helplightning.HLModelSession.build(null);

        System.assertEquals(s, null);
    }

    private static String result = '{"video_active":false,"users":[{"username":"small_admin","token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE1Mjk4NTQzNDUsImlhdCI6MTUyNzI2MjM0NSwiaXNzIjoiR2hhemFsIiwianRpIjoiM2ZjZjc1ZGYtZWNjNS00Yjk1LWEwMTktZjk1YjE0NWIyYTlmIiwibmJmIjoxNTI3MjYyMzQ0LCJwZW0iOnsidXNlciI6MTIyODh9LCJzdWIiOiJVc2VyOjMiLCJ0eXAiOiJhY2Nlc3MiLCJ2ZXIiOiIxMDAifQ.q0JelI39xoDj4wzihRuwrkCNJB0J3XqPvzv2nRcSlD8","status":0,"name":"","id":3,"avatar":{"thumb":null,"original":null}},{"username":"p_1","token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE1Mjk4NTQzNDUsImlhdCI6MTUyNzI2MjM0NSwiaXNzIjoiR2hhemFsIiwianRpIjoiZGY4MmFmZGQtYWE3Yi00NGM5LWFmNDQtZmY0MWNmNmVhOTI5IiwibmJmIjoxNTI3MjYyMzQ0LCJwZW0iOnsidXNlciI6MTIyODh9LCJzdWIiOiJVc2VyOjEwNDUiLCJ0eXAiOiJhY2Nlc3MiLCJ2ZXIiOiIxMDAifQ.lB_Big1jVmA_Bb2DQLiQsSS--Y9GkQi3zB1o5SQ-ICE","status":0,"name":"","id":1045,"avatar":{"thumb":null,"original":null}}],"updated_at":"2018-05-25T15:32:26Z","token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdHRyaWJ1dGVzIjpbXSwiYXVkIjoiR2hhemFsIiwiZXhwIjoxNTI5ODU0MzQ1LCJpYXQiOjE1MjcyNjIzNDUsImlzcyI6IkdoYXphbCIsImp0aSI6IjgwMTE0MjRlLTgzOTItNDkzYy04ZDc1LTRiNjE3YzQ4ZTk3OSIsIm5iZiI6MTUyNzI2MjM0NCwib3JpZ2luYXRvciI6MywicGVtIjp7InNlc3Npb24iOjEwNzUxfSwic3ViIjoiU2Vzc2lvbjphZjMwNDI2Mi1kMjMyLTQwNGEtOWI4Yi03YzEzZWU1NzA2NjEiLCJ0eXAiOiJhY2Nlc3MiLCJ2ZXIiOiIxMDAifQ.h4G4qMUgWYp8xy__WqJVFW72uruQYa-fGZCzG1MGaFI","pin":"","id":"af304262-d232-404a-9b8b-7c13ee570661"}';
}
