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
            System.assertEquals('support@helplightning.com', HLUserHelper.getLogin());
        }
    }

    @isTest
    static void testWithOverride() {
        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'support', Email='support@helplightning.com',
                          EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Chicago', UserName='support@helplightning.com');
        insert u;

        // set an override for this user.
        HLConfiguration.setLoginOverride('override@helplightning.com');

        System.RunAs(u) {
            System.assertEquals('override@helplightning.com', HLUserHelper.getLogin());
        }

    }
}
