/* -*- Mode: java; -*- */

/**
 * HLModelSearchUserTest.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
public class HLModelSearchUserTest {
    @isTest
    public static void buildMany() {
        Object o = JSON.deserializeUntyped(HLModelSearchUserTest.result);
        List<helplightning.HLModelSearchUser> s = helplightning.HLModelSearchUser.buildMany(o);

        System.assertEquals(1, s.size());

        helplightning.HLModelSearchUser u = s.get(0);
        System.assertEquals(1045, u.id);
        System.assertEquals('Personal 1', u.name);
        System.assertEquals('p_1', u.username);
        System.assertEquals('avatar/avatar.png', u.avatarURL);
        System.assertEquals('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE1Mjk4NTQyNjEsImlhdCI6MTUyNzI2MjI2MSwiaXNzIjoiR2hhemFsIiwianRpIjoiYWFjYzA2MWYtMTNlZS00YzE2LTkzMTAtOTg3OGZkYTI4M2IwIiwibmJmIjoxNTI3MjYyMjYwLCJwZW0iOnsidXNlciI6MTIyODh9LCJzdWIiOiJVc2VyOjEwNDUiLCJ0eXAiOiJhY2Nlc3MiLCJ2ZXIiOiIxMDAifQ.gvrXbGD2YWyncbtBQzhyskBvYwjFl2Nb4EGNR9eAMZ4', u.token);
    }

    @isTest
    public static void buildManyNull() {
        List<helplightning.HLModelSearchUser> s = helplightning.HLModelSearchUser.buildMany(null);

        System.assertEquals(0, s.size());
    }

    private static String result = '[{"username":"p_1","token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE1Mjk4NTQyNjEsImlhdCI6MTUyNzI2MjI2MSwiaXNzIjoiR2hhemFsIiwianRpIjoiYWFjYzA2MWYtMTNlZS00YzE2LTkzMTAtOTg3OGZkYTI4M2IwIiwibmJmIjoxNTI3MjYyMjYwLCJwZW0iOnsidXNlciI6MTIyODh9LCJzdWIiOiJVc2VyOjEwNDUiLCJ0eXAiOiJhY2Nlc3MiLCJ2ZXIiOiIxMDAifQ.gvrXbGD2YWyncbtBQzhyskBvYwjFl2Nb4EGNR9eAMZ4","name":"Personal 1","id":1045,"avatar":{"thumb":"avatar/thumb.png","original":"avatar/avatar.png"},"active":true}]';
}
