/**
 * HLSessionController.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */
public with sharing class HLSessionController {
    /**
     * Look up all the calls associated with
     *  a case in Salesforce
     */
    @AuraEnabled
    public static List<HLCall__c> getCalls(Id caseId) {
        if (caseId != null) {
            return [ SELECT Id, Session_Id__c, HLCall_Id__c,
                     Complete__c, Successful__c,
                     Start_Time__c, Duration__c from HLCall__c
                     WHERE Case__c = :caseId
                     ORDER BY Start_Time__c DESC
                     ];
        } else {
            return new List<HLCall__c>();
        }
    }

    @AuraEnabled
    public static HLCall__c saveCall(HLCall__c call) {
        if (call != null) {
            upsert call;

            return [ SELECT Id, Session_Id__c, HLCall_Id__c,
                     Complete__c, Successful__c,
                     Start_Time__c, Duration__c from HLCall__c
                     WHERE  Id = :call.id
                     ];
        } else {
            return null;
        }
    }

    /**
     * update all the incomplete calls
     * related to a specific case
     */
    @AuraEnabled
    public static List<HLCall__c> updateCalls(Id caseId) {
        if (caseId == null) {
            return new List<HLCall__c>();
        }

        HLCall__c[] calls = [SELECT Id, Session_Id__c, HLCall_Id__c, Contact_Email__c,
                             Start_Time__c from HLCall__c WHERE Case__c = :caseId
                             AND Complete__c = false LIMIT 25];


        /**
         * !mwd - we cannot make callouts
         *  in the middle of doing updates.
         * Therefore we will make all our callouts
         *  then check for updates in batch
         * !mwd - we also need to put a hard limit
         *  on how many calls we check.
         */
        Map<HLCall__c, Object> callMap = new Map<HLCall__c, Object>();
        for (HLCall__c call : calls) {
            System.debug('getting Info about call ' + call);
            HLRequest request = new HLRequest(HLToken.build(),
                                              '/enterprise/sessions/' + call.Session_Id__c);

            Object results = request.get();

            // try to find a match based on a fuzzy start time
            System.debug('result of /sessions/calls/ ' + results);

            if (results != null) {
                callMap.put(call, results);
            }
        }

        // now iterate through our map
        for (HLCall__c call : callMap.keySet()) {
            Object results = callMap.get(call);

            if (results != null) {
                // results is a list of calls, try to make matches
                HLCall__c matchedCall = HLCallUtil.findCallMatch(call, (Object[])results);
                if (matchedCall != null) {
                    // a match was found, we need to update the
                    //  database with the changes.
                    update matchedCall;
                }
            }
        }

        // return a fresh list of all calls
        return getCalls(caseId);
    }

    /**
     * Check if an email is associated with
     * a registered help lightning user.
     */
    @AuraEnabled
    public static Boolean isHLUser(String email) {
        System.debug('isHLUser: ' + email);

        Map<String,String> params = new Map<String,String>();
        params.put('search_term', email);

        HLRequest request = new HLRequest(HLToken.build(), '/search');
        Object results = request.post(params);

        // Unfortunately, the results don't include the email field
        //  (for privacy reasons), so we can't 100% verify this is
        //  a match (since the /search api actually matches on additional
        //  fields outside of our control). Therefore, we'll just assume
        //  that if our results list > 0, then this email is probably
        //  a user.
        if (results != null && ((Object[])results).size() > 0) {
            return true;
        }

        return false;
    }

    /**
     * Create an HL session between us
     *  and another user
     */
    @AuraEnabled
    public static String makeSessionWith(String otherUsersEmail) {
        System.debug('makeSessionWith');

        String myUserEmail = Userinfo.getUserEmail();
        System.debug('myUserId=' + myUserEmail);

        Map<String, String> bodyParams = new Map<String, String> {
                'dialer_email' => myUserEmail,
                'receiver_email' => otherUsersEmail
        };

        HLRequest request = new HLRequest(HLToken.build(), '/enterprise/calls');
        Object results = request.post(bodyParams);
        if (results != null) {
            Map<String, Object> resultsMap = (Map<String,Object>)results;
            System.debug('results=' + resultsMap);

            return (String)resultsMap.get('id');
        } else {
            return null;
        }
    }

    /**
     * Invite a user to a personal room.
     *  This will send out an email to them.
     */
    @AuraEnabled
    public static Boolean inviteToPersonalRoom(String otherUsersName, String otherUsersEmail) {
        System.debug('inviteToPersonalRoom: ' + otherUsersName + ' ' + otherUsersEmail);

        String myUserEmail = Userinfo.getUserEmail();
        System.debug('myUserId=' + myUserEmail);

        // first get a list of users to find us, since
        //  we have to make this request as a specific user
        HLRequest request = new HLRequest(HLToken.build(), '/enterprise/users');
        Object results = request.get(new Map<String,String> {
                'filter' => 'email=' + myUserEmail
        });
        if (results == null || ((Map<String,Object>)results).get('total_entries') != 1) {
            System.debug('Error finding our user. Unexpected results are: ' + results);
            return false;
        }
        Map<String,Object> resultsMap = (Map<String,Object>)results;
        Object[] entries = (Object[])resultsMap.get('entries');
        // We are the first Entry
        Map<String,Object> entry = (Map<String,Object>)entries[0];
        System.debug('entry=' + entry);
        String userToken = (String)entry.get('token');
        System.debug('token=' + userToken);
        if (userToken == null) {
            System.debug('Invalid user token');
            return false;
        }

        // Now send out the invite. We use the user
        //  token we retrieved so that this acts
        //  on behalf of that user.
        request = new HLRequest(userToken, '/personal_room/invite');
        results = request.post(new Map<String, String> {
                'name' => otherUsersName,
                'email' => otherUsersEmail
        });

        if (results == null) {
            System.debug('Failed to invite');
            return false;
        }

        return true;
    }
}
