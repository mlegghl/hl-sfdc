/* -*- Mode: java; -*- */

/**
 * HLModelAccountTest.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
public class HLModelAccountTest {
    @isTest
    static void build() {
        Object o = JSON.deserializeUntyped(HLModelAccountTest.result);
        helplightning.HLModelAccount a = helplightning.HLModelAccount.build('token', o);

        System.assertEquals(4, a.id);
        System.assertEquals('Small User1', a.name);
        System.assertEquals('small_u1', a.username);
        System.assertEquals('small_u1@helplightning.com', a.email);
        System.assertEquals('token', a.authToken);
        System.assertEquals('/path/avatar.jpg', a.avatarURL);
        System.assertEquals(true, a.available);
        System.assertEquals(true, a.active);
        System.assertEquals(0, a.status);
        System.assertEquals('/meet/small_u1', a.personalRoomURL);
        System.assertEquals('311ec593-9a40-49f0-b34c-7f8a901de076', a.personalRoomSessionId);
    }

    @isTest
    static void buildNull() {
        helplightning.HLModelAccount a = helplightning.HLModelAccount.build('token', null);
        System.assertEquals(null, a);
    }

    private static String result = '{"username":"small_u1","updated_at":"2018-05-30T18:32:06.356536Z","status":0,"role_name":"User","role_id":3,"personal_room_url":"/meet/small_u1","personal_room_session_id":"311ec593-9a40-49f0-b34c-7f8a901de076","permissions":["manage_account","manage_personal_contacts","web_login"],"name":"Small User1","is_first_login":true,"is_confirmed":true,"invitation_sent_at":"","id":4,"enterprise_id":3,"email_confirmed":true,"email":"small_u1@helplightning.com","confirmed_at":"2016-10-27T15:32:00.000000Z","confirmation_sent_at":"","avatar":{"thumb":"/path/thumb.jpg","original":"/path/avatar.jpg"},"available":true,"active":true}';
}
