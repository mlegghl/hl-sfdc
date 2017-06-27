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
        helplightning__HLCall__c call = new helplightning__HLCall__c(helplightning__Contact_Email__c = 'contact@helplightning.com',
                                                                     helplightning__Start_Time__c = DateTime.parse('10/14/2016 11:46 AM'));

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
                          TimeZoneSidKey='America/Chicago', UserName='support@helplightning.com');

        System.runAs(u) {
            helplightning__HLCall__c result = HLCallUtil.findCallMatch(call, hlCalls);

            System.assertNotEquals(result, null);
            System.assertEquals(result.helplightning__HLCall_Id__c, '1234');
            System.assertEquals(result.helplightning__Complete__c, true);
            System.assertEquals(result.helplightning__Successful__c, true);
            System.assertEquals(result.helplightning__Duration__c, 360);
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
        helplightning__HLCall__c call = new helplightning__HLCall__c(helplightning__Contact_Email__c = 'contact@helplightning.com',
                                                                     helplightning__Start_Time__c = DateTime.parse('10/14/2016 11:46 AM'));

        // mock up some help lightning calls that the api would have returned
        Object[] hlCalls = new Object[]{
        };

        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'support', Email='support@helplightning.com',
                          EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Chicago', UserName='support@helplightning.com');

        System.runAs(u) {
            helplightning__HLCall__c result = HLCallUtil.findCallMatch(call, hlCalls);

            System.assertNotEquals(result, null);
            System.assertEquals(result.helplightning__HLCall_Id__c, null);
            System.assertEquals(result.helplightning__Complete__c, true);
            System.assertEquals(result.helplightning__Successful__c, false);
            System.assertEquals(result.helplightning__Duration__c, 0);
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
        helplightning__HLCall__c call = new helplightning__HLCall__c(helplightning__Contact_Email__c = 'contact@helplightning.com',
                                                                     helplightning__Start_Time__c = DateTime.now());

        // no matched calls
        Object[] hlCalls = new Object[]{
        };

        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'support', Email='support@helplightning.com',
                          EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Chicago', UserName='support@helplightning.com');

        System.runAs(u) {
            helplightning__HLCall__c result = HLCallUtil.findCallMatch(call, hlCalls);

            System.assertEquals(result, null);
        }
    }

}
