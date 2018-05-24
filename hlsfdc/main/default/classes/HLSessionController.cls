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
                if (HLSessionController.isContactFromCaseAccessible()) {
                    Case[] o = [SELECT Contact.Id, Contact.Email, Contact.Name
                                FROM Case
                                WHERE Id = :recordId
                                ];
                    if (o != null && o.size() > 0) {
                        return o.get(0).Contact;
                    }
                } else {
                    System.debug('Insufficient Access to record: ' + sObjectName);
                    return null;
                }
            } else if (sObjectName == 'WorkOrder') {
                if (HLSessionController.isContactFromWorkOrderAccessible()) {
                    WorkOrder[] o = [SELECT Contact.Id, Contact.Email, Contact.Name
                                     FROM WorkOrder
                                     WHERE Id = :recordId
                                     ];
                    if (o != null && o.size() > 0) {
                        return o.get(0).Contact;
                    }
                } else {
                    System.debug('Insufficient Access to record: ' + sObjectName);
                    return null;
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
            if (HLSessionController.isCaseAccessible()) {
                return [SELECT Case.Id, Case.ContactId, Case.ContactEmail, Case.Contact.Name
                        FROM Case
                        WHERE Id = :recordId
                        ];
            } else {
                System.debug('Insufficient Access to record');
                return null;
            }
        }

        return null;
    }

    /**
     * Look up all the calls associated with
     *  a record in Salesforce
     */
    @AuraEnabled
    public static List<helplightning__HLCall__c> getCallsForRecord(String sObjectName, Id recordId) {
        if (recordId != null) {
            if (sObjectName == 'Case') {
                if (HLSessionController.isHLCallWithCaseAccessible()) {
                    return [SELECT Id,
                            helplightning__Session_Id__c,
                            helplightning__HLCall_Id__c,
                            helplightning__Contact_Email__c,
                            helplightning__Complete__c,
                            helplightning__Successful__c,
                            helplightning__Start_Time__c,
                            helplightning__End_Time__c,
                            helplightning__Duration__c
                            FROM helplightning__HLCall__c
                            WHERE helplightning__Case__c = :recordId
                            ORDER BY helplightning__Start_Time__c DESC
                            ];
                } else {
                    System.debug('Insufficient Access to helplightning__HLCall__c');
                }
            } else if (sObjectName == 'WorkOrder') {
                if (HLSessionController.isHLCallWithWorkOrderAccessible()) {
                    return [SELECT Id,
                            helplightning__Session_Id__c,
                            helplightning__HLCall_Id__c,
                            helplightning__Contact_Email__c,
                            helplightning__Complete__c,
                            helplightning__Successful__c,
                            helplightning__Start_Time__c,
                            helplightning__End_Time__c,
                            helplightning__Duration__c
                            FROM helplightning__HLCall__c
                            WHERE helplightning__Work_Order__c = :recordId
                            ORDER BY helplightning__Start_Time__c DESC
                            ];
                } else {
                    System.debug('Insufficient Access to helplightning__HLCall__c');
                }
            } else {
                System.debug('Invalid record type: ' + sObjectName);
            }
        }

        return new List<helplightning__HLCall__c>();
    }

    @AuraEnabled
    public static helplightning__HLCall__c saveCall(helplightning__HLCall__c call) {
        if (call != null) {
            if (HLSessionController.isHLCallAccessible() &&
                HLSessionController.isHLCallUpdateable()) {
                upsert call;

                return [SELECT Id,
                        helplightning__Session_Id__c,
                        helplightning__HLCall_Id__c,
                        helplightning__Complete__c,
                        helplightning__Successful__c,
                        helplightning__Start_Time__c,
                        helplightning__Duration__c
                        FROM helplightning__HLCall__c
                        WHERE Id = :call.id
                        ];
            } else {
                System.debug('Insufficient Write access to helplightning__HLCall__c');
                return null;
            }
        } else {
            return null;
        }
    }

    /**
     * update all the incomplete calls
     * related to a specific record.
     */
    @AuraEnabled
    public static List<helplightning__HLCall__c> updateCalls(String sObjectName, Id recordId) {
        try {
            if (recordId == null) {
                return new List<helplightning__HLCall__c>();
            }

            if (sObjectName != 'Case' && sObjectName != 'WorkOrder') {
                System.debug('Invalid record type: ' + sObjectName);
                return new List<helplightning__HLCall__c>();
            }

            helplightning__HLCall__c[] calls = new List<helplightning__HLCall__c>();

            if (sObjectName == 'Case') {
                if (HLSessionController.isHLCallWithCaseAccessible()) {
                    calls = [SELECT Id,
                             helplightning__Session_Id__c,
                             helplightning__HLCall_Id__c,
                             helplightning__Contact_Email__c,
                             helplightning__Start_Time__c
                             FROM helplightning__HLCall__c
                             WHERE helplightning__Case__c = :recordId
                             AND helplightning__Complete__c = false
                             LIMIT 25];
                } else {
                    System.debug('Insufficient Access to helplightning__HLCall__c');
                }
            } else if (sObjectName == 'WorkOrder') {
                if (HLSessionController.isHLCallWithWorkOrderAccessible()) {
                    calls = [SELECT Id,
                             helplightning__Session_Id__c,
                             helplightning__HLCall_Id__c,
                             helplightning__Contact_Email__c,
                             helplightning__Start_Time__c
                             FROM helplightning__HLCall__c
                             WHERE helplightning__Work_Order__c = :recordId
                             AND helplightning__Complete__c = false
                             LIMIT 25];
                } else {
                    System.debug('Insufficient Access to helplightning__HLCall__c');
                }
            }

            /**
             * !mwd - we cannot make callouts
             *  in the middle of doing updates.
             * Therefore we will make all our callouts
             *  then check for updates in batch
             * !mwd - we also need to put a hard limit
             *  on how many calls we check.
             */
            Map<helplightning__HLCall__c, Object> callMap = new Map<helplightning__HLCall__c, Object>();
            for (helplightning__HLCall__c call : calls) {
                System.debug('getting Info about call ' + call);
                helplightning.HLRequest request = new helplightning.HLRequest(helplightning.HLToken.build(),
                                                                              '/enterprise/sessions/' + call.helplightning__Session_Id__c);

                Object results = request.get();

                // try to find a match based on a fuzzy start time
                System.debug('result of /sessions/calls/ ' + results);

                if (results != null) {
                    callMap.put(call, results);
                }
            }

            // now iterate through our map
            for (helplightning__HLCall__c call : callMap.keySet()) {
                Object results = callMap.get(call);

                if (results != null) {
                    // results is a list of calls, try to make matches
                    helplightning__HLCall__c matchedCall = helplightning.HLCallUtil.findCallMatch(call, (Object[])results);
                    if (matchedCall != null) {
                        // a match was found, we need to update the
                        //  database with the changes.
                        if (schema.SObjectType.helplightning__HLCall__c.isUpdateable()) {
                            update matchedCall;
                        } else {
                            System.debug('Insufficient Access for updatting helplightning__HLCall__c');
                        }
                    }
                }
            }

            // return a fresh list of all calls
            return getCallsForRecord(sObjectName, recordId);
        } catch (helplightning.HLConfigurationException e) {
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
            String myUserEmail = helplightning.HLUserHelper.getLogin();

            // Query the users in our enteprise, and filter
            //  for our email.
            List<helplightning.HLModelEnterpriseUser> users = helplightning.HLGaldrClient.searchEnterpriseUsers(myUserEmail);
            if (users.size() == 0) {
                return false;
            } else {
                // we are in the list!
                return true;
            }
        } catch (helplightning.HLConfigurationException e) {
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
            List<helplightning.HLModelSearchUser> users = helplightning.HLGaldrClient.searchUsers(email);


            // Unfortunately, the results don't include the email field
            //  (for privacy reasons), so we can't 100% verify this is
            //  a match (since the /search api actually matches on additional
            //  fields outside of our control). Therefore, we'll just assume
            //  that if our results list > 0, then this email is probably
            //  a user.
            if (users.size() > 0)
                return true;

            return false;

        } catch (helplightning.HLConfigurationException e) {
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
            String myUserEmail = helplightning.HLUserHelper.getLogin();
            System.debug('myUserId=' + myUserEmail);

            String sessionId = helplightning.HLGaldrClient.makeEnterpriseCall(myUserEmail, otherUsersEmail);
            return sessionId;
        } catch (helplightning.HLConfigurationException e) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        }
    }

    /**
     * Create an HL session between us and another
     *  user actually using sessions.
     * This will return the Gss Auth info
     */
    @AuraEnabled
    public static Map<String,Object> makeSessionWith2(String otherUsersEmail) {
        System.debug('makeSessionWith2');

        try {
            // get our info
            String myUserEmail = helplightning.HLUserHelper.getLogin();
            helplightning.HLModelEnterpriseUser us = HLSessionController.getHLUser(myUserEmail);

            // get a token for the other user
            Map<String,String> params = new Map<String,String>();
            params.put('search_term', otherUsersEmail);

            helplightning.HLRequest request = new helplightning.HLRequest(helplightning.HLToken.build(),
                                                                          '/search');
            Object results = request.post(params);
            if (results == null || ((Object[])results).size() == 0) {
                throw new AuraHandledException('Invalid contact');
            }
            Map<String, Object> c = (Map<String, Object>)(((Object[])results).get(0));
            String contactToken = (String)c.get('token');

            // make a new session
            request = new helplightning.HLRequest(us.authToken,
                                                  '/sessions');
            Map<String,Object> sessionParams = new Map<String,Object>();
            List<String> l = new List<String>();
            l.add(contactToken);
            sessionParams.put('contact_tokens', l);

            Map<String,Object> sessionResults = (Map<String,Object>)(request.post(sessionParams));
            String sessionId = (String)sessionResults.get('id');

            // ring the other person
            request = new helplightning.HLRequest(us.authToken,
                                                  '/sessions/' + sessionId + '/video');
            Map<String,String> videoParams = new Map<String,String>();
            videoParams.put('session_token', (String)sessionResults.get('token'));

            Map<String,Object> videoResults = (Map<String,Object>)(request.post(videoParams));

            // return the a map with the session id and the gss auth info
            videoResults.put('token', us.authToken);
            videoResults.put('session_id', sessionId);
            videoResults.put('display_name', UserInfo.getName());

            return videoResults;
        } catch (helplightning.HLConfigurationException e) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        }
    }

    /**
     * Get our token
     */
    @AuraEnabled
    public static Map<String, Object> getInfo() {
        try {
            String myUserEmail = helplightning.HLUserHelper.getLogin();

            helplightning.HLModelEnterpriseUser u = HLSessionController.getHLUser(myUserEmail);

            // Map<String, Object> user = new Map<String, Object>();
            // user.put('id', u.get('id'));
            // user.put('name', u.get('name'));
            // user.put('username', u.get('username'));
            // user.put('email', u.get('email'));
            // user.put('avatarURL', ((Map<String, Object>)(u.get('avatar'))).get('original'));
            // user.put('token', u.get('token'));
            Map<String, Object> user = u.serialize();

            return user;
        } catch (helplightning.HLConfigurationException e) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        }
    }

    /**
     * We want to initiate a call with another HL user.
     * We need to get this contact's information
     */
    @AuraEnabled
    public static Map<String, Object> getUserInfo(String userEmail) {
        try {
            helplightning.HLModelEnterpriseUser u = HLSessionController.getHLUser(userEmail);
            //Map<String, Object> u = HLSessionController.getHLUser(userEmail);

            // Map<String, Object> user = new Map<String, Object>();
            // user.put('id', u.get('id'));
            // user.put('name', u.get('name'));
            // user.put('email', u.get('email'));
            // user.put('avatarURL', ((Map<String, Object>)(u.get('avatar'))).get('original'));
            // user.put('token', u.get('token'));
            Map<String, Object> user = u.serialize();

            return user;
        } catch (helplightning.HLConfigurationException e) {
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
            String myUserEmail = helplightning.HLUserHelper.getLogin();
            System.debug('myUserId=' + myUserEmail);

            // first get a list of users to find us, since
            //  we have to make this request as a specific user
            helplightning.HLRequest request = new helplightning.HLRequest(helplightning.HLToken.build(), '/enterprise/users');
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

            if (userToken == null) {
                System.debug('Invalid user token');
                return false;
            }

            // Now send out the invite. We use the user
            //  token we retrieved so that this acts
            //  on behalf of that user.
            request = new helplightning.HLRequest(userToken, '/personal_room/invite');
            results = request.post(new Map<String, String> {
                    'name' => otherUsersName,
                        'email' => otherUsersEmail
                        });

            if (results == null) {
                System.debug('Failed to invite');
                return false;
            }

            return true;

        } catch (helplightning.HLConfigurationException e) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        }
    }

    /** Private Helper Functions **/
    private static boolean isContactFromCaseAccessible() {
        return (Schema.sObjectType.Contact.fields.Id.isAccessible() &&
                Schema.sObjectType.Contact.fields.Email.isAccessible() &&
                Schema.sObjectType.Contact.fields.Name.isAccessible() &&
                Schema.sObjectType.Case.fields.Id.isAccessible());
    }
    private static boolean isContactFromWorkOrderAccessible() {
        return (Schema.sObjectType.Contact.fields.Id.isAccessible() &&
                Schema.sObjectType.Contact.fields.Email.isAccessible() &&
                Schema.sObjectType.Contact.fields.Name.isAccessible() &&
                Schema.sObjectType.WorkOrder.fields.Id.isAccessible());
    }
    private static boolean isCaseAccessible() {
        return (Schema.sObjectType.Case.fields.Id.isAccessible() &&
                Schema.sObjectType.Case.fields.ContactId.isAccessible() &&
                Schema.sObjectType.Case.fields.ContactEmail.isAccessible() &&
                Schema.sObjectType.Contact.fields.Name.isAccessible());
    }
    private static boolean isHLCallAccessible() {
        return (Schema.sObjectType.helplightning__HLCall__c.fields.Id.isAccessible() &&
                Schema.sObjectType.helplightning__HLCall__c.fields.helplightning__Session_Id__c.isAccessible() &&
                Schema.sObjectType.helplightning__HLCall__c.fields.helplightning__HLCall_Id__c.isAccessible() &&
                Schema.sObjectType.helplightning__HLCall__c.fields.helplightning__Contact_Email__c.isAccessible() &&
                Schema.sObjectType.helplightning__HLCall__c.fields.helplightning__Complete__c.isAccessible() &&
                Schema.sObjectType.helplightning__HLCall__c.fields.helplightning__Successful__c.isAccessible() &&
                Schema.sObjectType.helplightning__HLCall__c.fields.helplightning__Start_Time__c.isAccessible() &&
                Schema.sObjectType.helplightning__HLCall__c.fields.helplightning__End_Time__c.isAccessible() &&
                Schema.sObjectType.helplightning__HLCall__c.fields.helplightning__Duration__c.isAccessible());
    }
    private static boolean isHLCallWithCaseAccessible() {
        return (HLSessionController.isHLCallAccessible() &&
                Schema.sObjectType.helplightning__HLCall__c.fields.helplightning__Case__c.isAccessible());
    }
    private static boolean isHLCallWithWorkOrderAccessible() {
        return (HLSessionController.isHLCallAccessible() &&
                Schema.sObjectType.helplightning__HLCall__c.fields.helplightning__Work_Order__c.isAccessible());
    }
    private static boolean isHLCallUpdateable() {
        return (Schema.sObjectType.helplightning__HLCall__c.fields.helplightning__Session_Id__c.isUpdateable() &&
                Schema.sObjectType.helplightning__HLCall__c.fields.helplightning__HLCall_Id__c.isUpdateable() &&
                Schema.sObjectType.helplightning__HLCall__c.fields.helplightning__Complete__c.isUpdateable() &&
                Schema.sObjectType.helplightning__HLCall__c.fields.helplightning__Successful__c.isUpdateable() &&
                Schema.sObjectType.helplightning__HLCall__c.fields.helplightning__Start_Time__c.isUpdateable() &&
                Schema.sObjectType.helplightning__HLCall__c.fields.helplightning__Duration__c.isUpdateable());
    }

    private static helplightning.HLModelEnterpriseUser getHLUser(String email) {
        // Query the users in our enteprise, and filter
        //  for our email.
        helplightning.HLRequest request = new helplightning.HLRequest(helplightning.HLToken.build(), '/enterprise/users');
        Object results = request.get(new Map<String,String> {
                'filter' => 'email=' + email
                    });
        if (results == null || ((Map<String,Object>)results).get('total_entries') != 1) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        } else {
            // we are in the list!
            List<helplightning.HLModelEnterpriseUser> users = helplightning.HLModelEnterpriseUser.buildMany(results);

            // return the first item
            return users.get(0);
        }
    }
}
