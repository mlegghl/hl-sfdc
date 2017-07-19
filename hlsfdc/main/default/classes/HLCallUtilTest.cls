/**
 * HLCallUtilTest.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
private class HLCallUtilTest {

    /**
     * Find a call match for an HLCall that:
     *  - has never been matched on (doesn't have a callId yet)
     *  - is already complete
     *  - is successful
     * This should mark the call as a successful,
     *  completed call, and fill in the callId, duration,
     *  endTime, and other important values.
     */
    @isTest
    static void testFindCallMatchCompleted() {
        HLCall__c call = new HLCall__c(Contact_Email__c = 'contact@helplightning.com',
                                       Start_Time__c = DateTime.newInstanceGMT(2016, 10, 14, 11, 46, 0));

        // mock up some help lightning calls that the api would have returned
        Object[] hlCalls = new Object[]{
            new Map<String,Object>{
                'call_id' => '1234',
                    'dialer' => new Map<String,String>{ 'email' => 'support@helplightning.com' },
                    'receiver' => new Map<String,String>{ 'email' => 'contact@helplightning.com' },
                    'start_time' => '2016-10-14T11:46:01-05',
                    'end_time' => '2016-10-14T11:52:00-05',
                    'complete' => true,
                    'successful' => true,
                    'duration' => (6 * 60)
                    }
        };

        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'support', Email='support@helplightning.com',
                          EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='GMT', UserName='support@helplightning.com');

        System.runAs(u) {
            HLCall__c result = HLCallUtil.findCallMatch(call, hlCalls);

            System.assertNotEquals(result, null);
            System.assertEquals(result.HLCall_Id__c, '1234');
            System.assertEquals(result.Complete__c, true);
            System.assertEquals(result.Successful__c, true);
            System.assertEquals(result.Duration__c, 360);
        }
    }

    /**
     * Try to find a match for an HLCall that:
     *  - started more than 3 minutes ago
     *  - has never been matched on (doesn't have a callId yet)
     *  - is NOT in our list of calls
     * This should give up, mark the call as a
     *  completed and failed call.
     */
    @isTest
    static void testFindCallWithoutMatchTimeout() {
        HLCall__c call = new HLCall__c(Contact_Email__c = 'contact@helplightning.com',
                                       Start_Time__c = DateTime.newInstanceGMT(2016, 10, 14, 11, 46, 0));

        // mock up some help lightning calls that the api would have returned
        Object[] hlCalls = new Object[]{
        };

        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'support', Email='support@helplightning.com',
                          EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='GMT', UserName='support@helplightning.com');

        System.runAs(u) {
            HLCall__c result = HLCallUtil.findCallMatch(call, hlCalls);

            System.assertNotEquals(result, null);
            System.assertEquals(result.HLCall_Id__c, null);
            System.assertEquals(result.Complete__c, true);
            System.assertEquals(result.Successful__c, false);
            System.assertEquals(result.Duration__c, 0);
        }
    }

    /**
     * Try to find a match for an HLCall that:
     *  - started less than 3 minutes ago
     *  - has never been matched on (doesn't have a callId yet)
     *  - is NOT in our list of calls
     * This should return a null object, indicating that
     *  it didn't find a match, but is too early to give up on.
     */
    @isTest
    static void testFindCallWithoutMatch() {
        // create a call for right now
        HLCall__c call = new HLCall__c(Contact_Email__c = 'contact@helplightning.com',
                                       Start_Time__c = DateTime.now());

        // no matched calls
        Object[] hlCalls = new Object[]{
        };

        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'support', Email='support@helplightning.com',
                          EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='GMT', UserName='support@helplightning.com');

        System.runAs(u) {
            HLCall__c result = HLCallUtil.findCallMatch(call, hlCalls);

            System.assertEquals(result, null);
        }
    }

    /**
     * Try to find a match for an HLCall that:
     *  - started less than 3 minutes ago
     *  - has never been matched on (doesn't have a callId yet)
     *  - is NOT in our list of calls
     * This should return a null object, indicating that
     *  it didn't find a match, but is too early to give up on.
     * This is the same as the above test, except we provide
     *  a list of several possibilities that don't match.
     */
    @isTest
    static void testFindCallWithoutMatch2() {
        // create a call for right now
        HLCall__c call = new HLCall__c(Contact_Email__c = 'contact@helplightning.com',
                                       Start_Time__c = DateTime.now());

        // no matched calls
        Object[] hlCalls = new Object[]{
            new Map<String,Object>{
                'call_id' => 'aabb',
                    'dialer' => new Map<String,String>{ 'email' => 'support@helplightning.com' },
                    'receiver' => new Map<String,String>{ 'email' => 'contact@helplightning.com' },
                    'start_time' => '2016-10-14T10:20:01-05',
                    'end_time' => '2016-10-14T10:22:00-05',
                    'complete' => true,
                    'successful' => true,
                    'duration' => (6 * 60)
                    },
            new Map<String,Object>{
                'call_id' => 'ccdd',
                    'dialer' => new Map<String,String>{ 'email' => 'support@helplightning.com' },
                    'receiver' => new Map<String,String>{ 'email' => 'contact@helplightning.com' },
                    'start_time' => '2016-10-14T10:25:31-05',
                    'end_time' => '2016-10-14T10:26:00-05',
                    'complete' => true,
                    'successful' => false,
                    'duration' => 0
                    }

        };

        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'support', Email='support@helplightning.com',
                          EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='GMT', UserName='support@helplightning.com');

        System.runAs(u) {
            HLCall__c result = HLCallUtil.findCallMatch(call, hlCalls);

            System.assertEquals(result, null);
        }
    }

    /**
     * Try to find a match for an HLCall that:
     *  - has already been matched on (has a valid callId)
     *  - has not yet been marked as complete
     *  - is IN our list of calls
     *  - is NOT yet complete
     * This should return a call object with no
     *  additional information filled in, since it
     *  isn't complete yet.
     */
    @isTest
    static void testFindMatchedCallIncomplete() {
        HLCall__c call = new HLCall__c(Contact_Email__c = 'contact@helplightning.com',
                                       Start_Time__c = DateTime.newInstanceGMT(2016, 10, 14, 11, 46, 0),
                                       HLCall_Id__c = '1234');

        // mock up some help lightning calls that the api would have returned
        Object[] hlCalls = new Object[]{
            new Map<String,Object>{
                'call_id' => '1234',
                    'dialer' => new Map<String,String>{ 'email' => 'support@helplightning.com' },
                    'receiver' => new Map<String,String>{ 'email' => 'contact@helplightning.com' },
                    'start_time' => '2016-10-14T11:46:01-05',
                    'end_time' => '',
                    'complete' => false,
                    'successful' => false,
                    'duration' => 0
                    }
        };

        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'support', Email='support@helplightning.com',
                          EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='GMT', UserName='support@helplightning.com');

        System.runAs(u) {
            HLCall__c result = HLCallUtil.findCallMatch(call, hlCalls);

            System.assertNotEquals(result, null);
            System.assertEquals(result.HLCall_Id__c, '1234');
            System.assertEquals(result.Complete__c, false);
            System.assertEquals(result.Successful__c, false);
            System.assertEquals(result.Duration__c, null);
        }
    }

    /**
     * Try to find a match for an HLCall that:
     *  - has already been matched on (has a valid callId)
     *  - has not yet been marked as complete
     *  - is IN our list of calls
     *  - IS complete
     * This should return a call object and mark
     *  the call as complete, successful, and fill in
     *  additional information.
     */
    @isTest
    static void testFindMatchedCallComplete() {
        HLCall__c call = new HLCall__c(Contact_Email__c = 'contact@helplightning.com',
                                       Start_Time__c = DateTime.newInstanceGMT(2016, 10, 14, 11, 46, 0),
                                       HLCall_Id__c = '1234');

        // mock up some help lightning calls that the api would have returned
        Object[] hlCalls = new Object[]{
            new Map<String,Object>{
                'call_id' => '1234',
                    'dialer' => new Map<String,String>{ 'email' => 'support@helplightning.com' },
                    'receiver' => new Map<String,String>{ 'email' => 'contact@helplightning.com' },
                    'start_time' => '2016-10-14T11:46:01-05',
                    'end_time' => '2016-10-14T11:52:01-05',
                    'complete' => true,
                    'successful' => false,
                    'duration' => 360
                    }
        };

        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'support', Email='support@helplightning.com',
                          EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='GMT', UserName='support@helplightning.com');

        System.runAs(u) {
            HLCall__c result = HLCallUtil.findCallMatch(call, hlCalls);

            System.assertNotEquals(result, null);
            System.assertEquals(result.HLCall_Id__c, '1234');
            System.assertEquals(result.Complete__c, true);
            System.assertEquals(result.Successful__c, false);
            System.assertEquals(result.Duration__c, 360);
        }
    }

    /**
     * Try to find a call where our user
     *  is the receiever instead of the dialer
     */
    @isTest
    static void testFindMatchedCallAsReceiver() {
        HLCall__c call = new HLCall__c(Contact_Email__c = 'contact@helplightning.com',
                                       Start_Time__c = DateTime.newInstanceGMT(2016, 10, 14, 11, 46, 0));

        // mock up some help lightning calls that the api would have returned
        Object[] hlCalls = new Object[]{
            new Map<String,Object>{
                'call_id' => '1234',
                    'dialer' => new Map<String,String>{ 'email' => 'contact@helplightning.com' },
                    'receiver' => new Map<String,String>{ 'email' => 'support@helplightning.com' },
                    'start_time' => '2016-10-14T11:46:01-05',
                    'end_time' => '2016-10-14T11:52:00-05',
                    'complete' => true,
                    'successful' => true,
                    'duration' => (6 * 60)
                    }
        };

        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'support', Email='support@helplightning.com',
                          EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='GMT', UserName='support@helplightning.com');

        System.runAs(u) {
            HLCall__c result = HLCallUtil.findCallMatch(call, hlCalls);

            System.assertNotEquals(result, null);
            System.assertEquals(result.HLCall_Id__c, '1234');
            System.assertEquals(result.Complete__c, true);
            System.assertEquals(result.Successful__c, true);
            System.assertEquals(result.Duration__c, 360);
        }
    }

    /**
     * Include in the search list a call where
     *  we are neither the dialer or reciever.
     * This call should just be skipped.
     */
    @isTest
    static void testInvalidDialerReciever() {
        HLCall__c call = new HLCall__c(Contact_Email__c = 'contact@helplightning.com',
                                       Start_Time__c = DateTime.now());

        // mock up some help lightning calls that the api would have returned
        Object[] hlCalls = new Object[]{
            new Map<String,Object>{
                'call_id' => '1234',
                    'dialer' => new Map<String,String>{ 'email' => 'user1@helplightning.com' },
                    'receiver' => new Map<String,String>{ 'email' => 'user2@helplightning.com' },
                    'start_time' => '2016-10-14T11:46:01-05',
                    'end_time' => '2016-10-14T11:52:00-05',
                    'complete' => true,
                    'successful' => true,
                    'duration' => (6 * 60)
                    }
        };

        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'support', Email='support@helplightning.com',
                          EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='GMT', UserName='support@helplightning.com');

        System.runAs(u) {
            HLCall__c result = HLCallUtil.findCallMatch(call, hlCalls);

            System.assertEquals(result, null);
        }
    }

    /**
     * Test where our list of possible calls
     *  has multiple that could match based on
     *  the start time.
     * This should return the call with the closest
     *  start time.
     */
    @isTest
    static void testMultipleMatches() {
        HLCall__c call = new HLCall__c(Contact_Email__c = 'contact@helplightning.com',
                                       Start_Time__c = DateTime.newInstanceGMT(2016, 10, 14, 11, 46, 0));

        // mock up some help lightning calls that the api would have returned
        Object[] hlCalls = new Object[]{
            new Map<String,Object>{
                'call_id' => 'aabbcc',
                    'dialer' => new Map<String,String>{ 'email' => 'support@helplightning.com' },
                    'receiver' => new Map<String,String>{ 'email' => 'contact@helplightning.com' },
                    'start_time' => '2016-10-14T11:45:50-05',
                    'end_time' => '2016-10-14T11:50:34-05',
                    'complete' => true,
                    'successful' => true,
                    'duration' => 284
                    },
            new Map<String,Object>{
                'call_id' => '1234',
                    'dialer' => new Map<String,String>{ 'email' => 'support@helplightning.com' },
                    'receiver' => new Map<String,String>{ 'email' => 'contact@helplightning.com' },
                    'start_time' => '2016-10-14T11:46:01-05',
                    'end_time' => '2016-10-14T11:52:00-05',
                    'complete' => true,
                    'successful' => true,
                    'duration' => 360
                    },
            new Map<String,Object>{
                'call_id' => 'xxyyzz',
                    'dialer' => new Map<String,String>{ 'email' => 'support@helplightning.com' },
                    'receiver' => new Map<String,String>{ 'email' => 'contact@helplightning.com' },
                    'start_time' => '2016-10-14T11:46:12-05',
                    'end_time' => '2016-10-14T11:56:32-05',
                    'complete' => true,
                    'successful' => true,
                    'duration' => 620
                    }

        };

        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'support', Email='support@helplightning.com',
                          EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='GMT', UserName='support@helplightning.com');

        System.runAs(u) {
            HLCall__c result = HLCallUtil.findCallMatch(call, hlCalls);

            System.assertNotEquals(result, null);
            System.assertEquals(result.HLCall_Id__c, '1234');
            System.assertEquals(result.Complete__c, true);
            System.assertEquals(result.Successful__c, true);
            System.assertEquals(result.Duration__c, 360);
        }
    }

    /**
     * Try to match an HLCall that:
     *  - matches us as the dialer
     *  - incorrectly matches the receiver
     * This should return a NULL call
     */
    @isTest
    static void testMatchInvalidReceiver() {
        // create a call for right now
        HLCall__c call = new HLCall__c(Contact_Email__c = 'contact@helplightning.com',
                                       Start_Time__c = DateTime.now());

        // no matched calls
        Object[] hlCalls = new Object[]{
            new Map<String,Object>{
                'call_id' => 'aabb',
                    'dialer' => new Map<String,String>{ 'email' => 'support@helplightning.com' },
                    'receiver' => new Map<String,String>{ 'email' => 'invalid-contact@helplightning.com' },
                    'start_time' => '2016-10-14T10:20:01-05',
                    'end_time' => '2016-10-14T10:22:00-05',
                    'complete' => true,
                    'successful' => true,
                    'duration' => (6 * 60)
                    }
        };

        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'support', Email='support@helplightning.com',
                          EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='GMT', UserName='support@helplightning.com');

        System.runAs(u) {
            HLCall__c result = HLCallUtil.findCallMatch(call, hlCalls);

            System.assertEquals(result, null);
        }
    }

    /**
     * Try to match an HLCall that:
     *  - matches us as the receiver
     *  - incorrectly matches the dialer
     * This should return a NULL call
     */
    @isTest
    static void testMatchInvalidDialer() {
        // create a call for right now
        HLCall__c call = new HLCall__c(Contact_Email__c = 'contact@helplightning.com',
                                       Start_Time__c = DateTime.now());

        // no matched calls
        Object[] hlCalls = new Object[]{
            new Map<String,Object>{
                'call_id' => 'aabb',
                    'dialer' => new Map<String,String>{ 'email' => 'invalid-contact@helplightning.com' },
                    'receiver' => new Map<String,String>{ 'email' => 'support@helplightning.com' },
                    'start_time' => '2016-10-14T10:20:01-05',
                    'end_time' => '2016-10-14T10:22:00-05',
                    'complete' => true,
                    'successful' => true,
                    'duration' => (6 * 60)
                    }
        };

        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'support', Email='support@helplightning.com',
                          EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='GMT', UserName='support@helplightning.com');

        System.runAs(u) {
            HLCall__c result = HLCallUtil.findCallMatch(call, hlCalls);

            System.assertEquals(result, null);
        }
    }

    /**
     * Try to match an HLCall that:
     *  - we already have a callId for
     *  - the callId we are trying to match for
     *    isn't in our list of calls.
     * This should return NULL
     */
    @isTest
    static void testMissingMatchedCall() {
        HLCall__c call = new HLCall__c(Contact_Email__c = 'contact@helplightning.com',
                                       Start_Time__c = DateTime.newInstanceGMT(2016, 10, 14, 11, 46, 0),
                                       HLCall_Id__c = '1234');

        // mock up some help lightning calls that the api would have returned
        // Don't include 1234
        Object[] hlCalls = new Object[]{
            new Map<String,Object>{
                'call_id' => 'aabbcc',
                    'dialer' => new Map<String,String>{ 'email' => 'support@helplightning.com' },
                    'receiver' => new Map<String,String>{ 'email' => 'contact@helplightning.com' },
                    'start_time' => '2016-10-14T11:46:01-05',
                    'end_time' => '',
                    'complete' => false,
                    'successful' => false,
                    'duration' => 0
                    }
        };

        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'support', Email='support@helplightning.com',
                          EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='GMT', UserName='support@helplightning.com');

        System.runAs(u) {
            HLCall__c result = HLCallUtil.findCallMatch(call, hlCalls);

            System.assertEquals(result, null);
        }
    }
}
