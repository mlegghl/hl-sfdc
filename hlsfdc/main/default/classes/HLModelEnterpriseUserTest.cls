/* -*- Mode: java; -*- */

/**
f * HLModelEnterpriseUserTest.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
public class HLModelEnterpriseUserTest {
    @isTest
    static void testBuildMany() {
        Object o = JSON.deserializeUntyped(HLModelEnterpriseUserTest.resultsMany);
        List<helplightning.HLModelEnterpriseUser> users = helplightning.HLModelEnterpriseUser.buildMany(o);

        System.assertEquals(users.size(), 2);

        // verify the first object
        helplightning.HLModelEnterpriseUser u = users.get(0);
        System.assertEquals(u.id, 3);
        System.assertEquals(u.name, 'Small Admin');
        System.assertEquals(u.username, 'small_admin');
        System.assertEquals(u.email, 'small_admin@helplightning.com');
        System.assertEquals(u.available, true);
        System.assertEquals(u.status, 0);
        System.assertEquals(u.avatarURL, null);
        System.assertEquals(u.authToken, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE1Mjk4NDgwODgsImlhdCI6MTUyNzI1NjA4OCwiaXNzIjoiR2hhemFsIiwianRpIjoiOTQyNTc3MTctNjUyYS00NWZhLWJiNDMtMTViMDk0ZjkwMWM5IiwibmJmIjoxNTI3MjU2MDg3LCJwZW0iOnsidXNlciI6ODc2MTczMzkxNzIwfSwic3ViIjoiVXNlcjozIiwidHlwIjoiYWNjZXNzIiwidmVyIjoiMTAwIn0.l49W4r7hz9LIKYEibvK67Vpwhj90EmapNmmd6e1kKrs');
        System.assertEquals(u.personalRoomURL, null);
    }

    @isTest
    static void testBuildManyWithEmptyResults() {
        Object o = JSON.deserializeUntyped(HLModelEnterpriseUserTest.emptyResults);
        List<helplightning.HLModelEnterpriseUser> users = helplightning.HLModelEnterpriseUser.buildMany(o);

        System.assertEquals(users.size(), 0);
    }

    @isTest
    static void testBuildManyWithNullResults() {
        List<helplightning.HLModelEnterpriseUser> users = helplightning.HLModelEnterpriseUser.buildMany(null);

        System.assertEquals(users.size(), 0);
    }

    @isTest
    static void testSerialize() {
        Object o = JSON.deserializeUntyped(HLModelEnterpriseUserTest.resultsMany);
        List<helplightning.HLModelEnterpriseUser> users = helplightning.HLModelEnterpriseUser.buildMany(o);

        // get the first person, and reserialize it
        helplightning.HLModelEnterpriseUser u = users.get(0);

        Map<String,Object> serialized = u.serialize();
        System.assertEquals(serialized.get('id'), (Object)3);
    }

    private static String resultsMany = '{"entries":[{"active":true,"available":true,"avatar":{"original":null,"thumb":null},"confirmation_sent_at":"2016-10-27T15:32:00.000000Z","confirmed_at":"","created_at":"2016-10-27T15:32:00.000000Z","email":"small_admin@helplightning.com","email_confirmed":false,"enterprise_id":3,"first_call_at":"","id":3,"invitation_sent_at":"","is_confirmed":false,"is_first_login":true,"name":"Small Admin","permissions":["enterprise_admin","manage_account","manage_billing","manage_groups","manage_personal_contacts","manage_reports","manage_sessions","manage_storefront","manage_users","web_login"],"role_id":1,"role_name":"EnterpriseAdmin","status":0,"token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE1Mjk4NDgwODgsImlhdCI6MTUyNzI1NjA4OCwiaXNzIjoiR2hhemFsIiwianRpIjoiOTQyNTc3MTctNjUyYS00NWZhLWJiNDMtMTViMDk0ZjkwMWM5IiwibmJmIjoxNTI3MjU2MDg3LCJwZW0iOnsidXNlciI6ODc2MTczMzkxNzIwfSwic3ViIjoiVXNlcjozIiwidHlwIjoiYWNjZXNzIiwidmVyIjoiMTAwIn0.l49W4r7hz9LIKYEibvK67Vpwhj90EmapNmmd6e1kKrs","updated_at":"2016-10-27T15:32:00.000000Z","username":"small_admin"},{"active":true,"available":true,"avatar":{"original":null,"thumb":null},"confirmation_sent_at":"","confirmed_at":"2016-10-27T15:32:00.000000Z","created_at":"2016-10-27T15:32:00.000000Z","email":"small_u1@helplightning.com","email_confirmed":true,"enterprise_id":3,"first_call_at":"","id":4,"invitation_sent_at":"","is_confirmed":true,"is_first_login":true,"name":"Small User1","permissions":["manage_account","manage_personal_contacts","web_login"],"role_id":3,"role_name":"User","status":0,"token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE1Mjk4NDgwODgsImlhdCI6MTUyNzI1NjA4OCwiaXNzIjoiR2hhemFsIiwianRpIjoiZTBlMzYzNTgtZmMwOC00MmVmLWE0MmItNTRhNjE3YmZlOTYwIiwibmJmIjoxNTI3MjU2MDg3LCJwZW0iOnsidXNlciI6ODc2MTczMzkxNzIwfSwic3ViIjoiVXNlcjo0IiwidHlwIjoiYWNjZXNzIiwidmVyIjoiMTAwIn0.FvYXMv8eac8QlkIrlIXGA4bYRRa9zGVNaNPgZE2C_us","updated_at":"2016-10-27T15:32:01.000000Z","username":"small_u1"}],"page":1,"page_size":20,"total_entries":2,"total_pages":1}';

    private static String emptyResults = '{"entries":[],"page":1,"page_size":20,"total_entries":0,"total_pages":1}';

}
