/* -*- Mode: java; -*- */

/**
 * HLSessionController.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */
public with sharing class HLSessionController {
    /**
     * Return a specific record based on
     *  a type and an id.
     * This only works for:
     *  - Case
     *  - WorkOrder
     */
    @AuraEnabled
    public static Contact getContactForRecord(String sObjectName, Id recordId) {
        if (recordId != null) {
            if (sObjectName == 'Case') {
                Case[] o = [ SELECT Contact.Id, Contact.Email, Contact.Name from Case
                             WHERE Id = :recordId
                             ];
                if (o != null && o.size() > 0) {
                    return o.get(0).Contact;
                }
            } else if (sObjectName == 'WorkOrder') {
                WorkOrder[] o = [ SELECT Contact.Id, Contact.Email, Contact.Name from WorkOrder
                                  WHERE Id = :recordId
                                  ];
                if (o != null && o.size() > 0) {
                    return o.get(0).Contact;
                }
            } else {
                System.debug('Invalid record type: ' + sObjectName);
                return null;
            }
        }

        return null;
    }

    /**
     * Look up a Case based on an Id
     */
    @AuraEnabled
    public static Case getCase(Id recordId) {
        if (recordId != null) {
            return [ SELECT Case.Id, Case.ContactId, Case.ContactEmail, Case.Contact.Name
                     FROM Case
                     WHERE Id = :recordId
                     ];
        }

        return null;
    }

    /**
     * Look up all the calls associated with
     *  a record in Salesforce
     */
    @AuraEnabled
    public static List<HLCall__c> getCallsForRecord(String sObjectName, Id recordId) {
        if (recordId != null) {
            if (sObjectName == 'Case') {
                return [ SELECT Id, Session_Id__c,
                         HLCall_Id__c,
                         Contact_Email__c,
                         Complete__c,
                         Successful__c,
                         Start_Time__c,
                         End_Time__c,
                         Duration__c
                         FROM HLCall__c
                         WHERE Case__c = :recordId
                         ORDER BY Start_Time__c DESC
                         ];
            } else if (sObjectName == 'WorkOrder') {
                return [ SELECT Id, Session_Id__c,
                         HLCall_Id__c,
                         Contact_Email__c,
                         Complete__c,
                         Successful__c,
                         Start_Time__c,
                         End_Time__c,
                         Duration__c
                         FROM HLCall__c
                         WHERE Work_Order__c = :recordId
                         ORDER BY Start_Time__c DESC
                         ];
            } else {
                System.debug('Invalid record type: ' + sObjectName);
            }
        }

        return new List<HLCall__c>();
    }

    @AuraEnabled
    public static HLCall__c saveCall(HLCall__c call) {
        if (call != null) {
            upsert call;

            return [ SELECT Id,
                     Session_Id__c,
                     HLCall_Id__c,
                     Complete__c,
                     Successful__c,
                     Start_Time__c,
                     Duration__c
                     FROM HLCall__c
                     WHERE Id = :call.id
                     ];
        } else {
            return null;
        }
    }

    /**
     * update all the incomplete calls
     * related to a specific record.
     */
    @AuraEnabled
    public static List<HLCall__c> updateCalls(String sObjectName, Id recordId) {
        try {
            if (recordId == null) {
                return new List<HLCall__c>();
            }

            if (sObjectName != 'Case' && sObjectName != 'WorkOrder') {
                System.debug('Invalid record type: ' + sObjectName);
                return new List<HLCall__c>();
            }

            HLCall__c[] calls;

            if (sObjectName == 'Case') {
                calls = [SELECT Id,
                         Session_Id__c,
                         HLCall_Id__c,
                         Contact_Email__c,
                         Start_Time__c
                         FROM HLCall__c
                         WHERE Case__c = :recordId
                         AND Complete__c = false
                         LIMIT 25];
            } else if (sObjectName == 'WorkOrder') {
                calls = [SELECT Id,
                         Session_Id__c,
                         HLCall_Id__c,
                         Contact_Email__c,
                         Start_Time__c
                         FROM HLCall__c
                         WHERE Work_Order__c = :recordId
                         AND Complete__c = false
                         LIMIT 25];
            }


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
            return getCallsForRecord(sObjectName, recordId);
        } catch (HLConfigurationException e) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        }
    }

    /**
     * Check if an email is part of the enterprise associated
     *  with our private key.
     */
    @AuraEnabled
    public static Boolean checkRegistration() {
        try {
            String myUserEmail = HLUserHelper.getLogin();

            // Query the users in our enteprise, and filter
            //  for our email.
            HLRequest request = new HLRequest(HLToken.build(), '/enterprise/users');
            Object results = request.get(new Map<String,String> {
                    'filter' => 'email=' + myUserEmail
                        });
            if (results == null || ((Map<String,Object>)results).get('total_entries') != 1) {
                System.debug('Error finding our user. Unexpected results are: ' + results);
                return false;
            } else {
                // we are in the list!
                return true;
            }
        } catch (HLConfigurationException e) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        }
    }

    /**
     * Check if an email is associated with
     * a registered help lightning user.
     */
    @AuraEnabled
    public static Boolean isHLUser(String email) {
        System.debug('isHLUser: ' + email);

        try {
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

        } catch (HLConfigurationException e) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        }
    }

    /**
     * Create an HL session between us
     *  and another user
     */
    @AuraEnabled
    public static String makeSessionWith(String otherUsersEmail) {
        System.debug('makeSessionWith');

        try {
            String myUserEmail = HLUserHelper.getLogin();
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

        } catch (HLConfigurationException e) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        }
    }

    /**
     * Invite a user to a personal room.
     *  This will send out an email to them.
     */
    @AuraEnabled
    public static Boolean inviteToPersonalRoom(String otherUsersName, String otherUsersEmail) {
        System.debug('inviteToPersonalRoom: ' + otherUsersName + ' ' + otherUsersEmail);

        try {
            String myUserEmail = HLUserHelper.getLogin();
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

        } catch (HLConfigurationException e) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        }
    }
}
