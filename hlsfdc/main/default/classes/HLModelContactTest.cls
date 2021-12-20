
/* -*- Mode: java; -*- */

/**
 * HLModelContactTest.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
public class HLModelContactTest {
    @isTest
    static void testBuildMany() {
        Object o = JSON.deserializeUntyped(HLModelContactTest.resultsMany);
        List<helplightning.HLModelContact> users = helplightning.HLModelContact.buildMany(o);

        System.assertEquals(users.size(), 1);

        // verify the first object
        helplightning.HLModelContact u = users.get(0);
        System.assertEquals(u.id, 3);
        System.assertEquals(u.name, 'Small Admin');
        System.assertEquals(u.username, 'small_admin');
        System.assertEquals(u.email, 'small_admin@helplightning.com');
        System.assertEquals(u.avatarURL, null);
    }

    @isTest
    static void testBuildManyWithEmptyResults() {
        Object o = JSON.deserializeUntyped(HLModelContactTest.emptyResults);
        List<helplightning.HLModelContact> users = helplightning.HLModelContact.buildMany(o);

        System.assertEquals(users.size(), 0);
    }

    @isTest
    static void testBuildManyWithNullResults() {
        List<helplightning.HLModelContact> users = helplightning.HLModelContact.buildMany(null);

        System.assertEquals(users.size(), 0);
    }

    @isTest
    static void testSerialize() {
        Object o = JSON.deserializeUntyped(HLModelContactTest.resultsMany);
        List<helplightning.HLModelContact> users = helplightning.HLModelContact.buildMany(o);

        // get the first person, and reserialize it
        helplightning.HLModelContact u = users.get(0);

        Map<String,Object> serialized = u.serialize();
        System.assertEquals(serialized.get('id'), (Object)3);
        System.assertEquals(serialized.get('username'), (Object)'small_admin');
        System.assertEquals(serialized.get('name'), (Object)'Small Admin');
        System.assertEquals(serialized.get('email'), (Object)'small_admin@helplightning.com');
        System.assertEquals(serialized.get('avatarUrl'), (Object)null);
    }

    private static String resultsMany = '{"entries":[{"id":3,"name": "Small Admin","username":"small_admin","avatar":{"url":null},"email":"small_admin@helplightning.com"}],"page":1,"page_size":20,"total_entries":2,"total_pages":1}';

    private static String emptyResults = '{"entries":[],"page":1,"page_size":20,"total_entries":0,"total_pages":1}';

}