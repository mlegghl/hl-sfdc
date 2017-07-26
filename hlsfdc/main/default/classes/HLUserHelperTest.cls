/* -*- Mode: java; -*- */

/**
 * HLUserHelperTest.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
private class HLUserHelperTest {
    @isTest
    static void testNoOverride() {
        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'support', Email='support@helplightning.com',
                          EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Chicago', UserName='support@helplightning.com');
        insert u;

        System.RunAs(u) {
            System.assertEquals('support@helplightning.com', helplightning.HLUserHelper.getLogin());
        }
    }

    @isTest
    static void testWithOverride() {
        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u1 = new User(Alias = 'user1', Email='user1@helplightning.com',
                           EmailEncodingKey='UTF-8', LastName='User1', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Chicago', UserName='user1@helplightning.com');
        insert u1;
        User u2 = new User(Alias = 'user2', Email='user2@helplightning.com',
                           EmailEncodingKey='UTF-8', LastName='User2', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Chicago', UserName='user2@helplightning.com');
        insert u2;

        System.RunAs(u1) {
            // set an override for this user.
            helplightning.HLConfiguration.setLoginOverride('blahblah234@helplightning.com');

            // make sure we get back the override instead.
            System.assertEquals('blahblah234@helplightning.com', helplightning.HLUserHelper.getLogin());
        }

        // verify user2 doesn't get this override
        System.RunAs(u2) {
            // make sure we don't get the override
            System.assertEquals('user2@helplightning.com', helplightning.HLUserHelper.getLogin());
        }

    }
}
