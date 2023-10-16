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
                    Case[] o = [SELECT Contact.Id, Contact.Email, Contact.Name, Contact.MobilePhone, Contact.Phone
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
                    WorkOrder[] o = [SELECT Contact.Id, Contact.Email, Contact.Name, Contact.MobilePhone, Contact.Phone
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
     * Look up a WorkOrder based on an Id
     */
    @AuraEnabled
    public static WorkOrder getWorkOrder(Id recordId) {
        if (recordId != null) {
            if (HLSessionController.isWorkOrderAccessible()) {
                return [SELECT WorkOrder.Id, WorkOrder.ContactId
                        FROM WorkOrder
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
                            helplightning__Contact_Phone__c,
                            helplightning__Complete__c,
                            helplightning__Successful__c,
                            helplightning__Start_Time__c,
                            helplightning__End_Time__c,
                            helplightning__Duration__c,
                            helplightning__Type__c
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
                            helplightning__Contact_Phone__c,
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
                             helplightning__Contact_Phone__c,
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
                             helplightning__Contact_Phone__c,
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
            Map<helplightning__HLCall__c, List<helplightning.HLModelCall>> callMap =
                new Map<helplightning__HLCall__c, List<helplightning.HLModelCall>>();

            for (helplightning__HLCall__c call : calls) {
                System.debug('getting Info about call ' + call);
                List<helplightning.HLModelCall> hlCalls = new List<helplightning.HLModelCall>();
                String token = HLTokenHelper.getToken();

                // If we don't have an exact call id, then we'll get all the calls with-in a session
                //  and try to guess a match...
                if (call.helplightning__HLCall_id__c == null || call.helplightning__HLCall_Id__c.equals('')) {
                    hlCalls = helplightning.HLGaldrClient.getEnterpriseCall(token, call.helplightning__Session_Id__c);
                } else {
                    // we have a call id, so just pull the call directly!
                    helplightning.HLModelCall c = helplightning.HLGaldrClient.getEnterpriseCallById(token, call.helplightning__Session_Id__c, call.helplightning__HLCall_id__c);
                    if (c != null) {
                        hlCalls.add(c);
                    }
                }

                if (hlCalls != null && hlCalls.size() > 0) {
                    callMap.put(call, hlCalls);
                }
            }

            // now iterate through our map
            for (helplightning__HLCall__c call : callMap.keySet()) {
                List<helplightning.HLModelCall> results = callMap.get(call);

                if (results != null) {
                    // results is a list of calls, try to make matches
                    helplightning__HLCall__c matchedCall = helplightning.HLCallUtil.findCallMatch(call, results);
                    if (matchedCall != null) {
                        // a match was found, we need to update the
                        //  database with the changes.
                        if (schema.SObjectType.helplightning__HLCall__c.isUpdateable()) {
                            update matchedCall;

                            if (HLConfiguration.getCreateEvents() && matchedCall.helplightning__Complete__c) {
                                saveEvent(sObjectName, recordId,
                                          matchedCall.helplightning__Start_Time__c,
                                          matchedCall.helplightning__End_Time__c,
                                          matchedCall.helplightning__HLCall_Id__c);
                            }

                            if (HLConfiguration.getSaveAttachments() && matchedCall.helplightning__Complete__c) {
                                String callId = matchedCall.helplightning__HLCall_Id__c;

                                if (callId == null || callId.equals('')) {
                                    // No matching call ID
                                } else {
                                    // Save call attachments.
                                    // Need to wrap this in a future call method to prevent race conditions and DML errors
                                    saveAttachment(callId, recordId);
                                }
                            }
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
     * If we know the callId to associate with an HLCall, save it here
     */
    @AuraEnabled
    public static Boolean updateCallId(String callId, Id hlCallId){
        helplightning__HLCall__c[] call;
        call = [SELECT Id, helplightning__HLCall_Id__c
                FROM helplightning__HLCall__c
                WHERE Id = :hlCallId];

        if (call.size() > 0) {
            call[0].helplightning__HLCall_Id__c = callId;
            update call[0];

            return true;
        }

        return false;
    }

    /**
     * Check if an email is part of the enterprise associated
     *  with our private key.
     */
    @AuraEnabled
    public static Boolean checkRegistration() {
        try {
            String myUserEmail = helplightning.HLUserHelper.getLogin();
            Integer defaultWorkspace = null;
            String token = null;

            // First, we need to check if we are using a site level key
            // If no results are returned, we are using a workspace level key
            List<helplightning.HLModelWorkspace> workspaces = helplightning.HLGaldrClient.getWorkspaces();
            if (workspaces.size() != 0) {
              // If we have workspaces, we need to check for the default.
              defaultWorkspace = checkForDefaultWorkspace(workspaces);
              // Grab the default workspace token
              for (helplightning.HLModelWorkspace w: workspaces) {
                if (w.id == defaultWorkspace) {
                  token = w.token;
                  break;
                }
              }
            } else {
              token = helplightning.HLToken.build();
            }

            // Query the users in our enteprise, and filter
            //  for our email.
            List<helplightning.HLModelEnterpriseUser> users = helplightning.HLGaldrClient.searchEnterpriseUsers(token, myUserEmail);

            // After all web callouts are complete, we can set our flags.
            if (workspaces.size() != 0) {
              helplightning.HLConfiguration.setHasSiteKey(true);

              // Set the default workspace if it's not in the config.
              // This will avoid having to loop through each workspace.
              if (String.isBlank(HLConfiguration.getWorkspaceId())) {
                helplightning.HLConfiguration.setWorkspaceId(String.valueOf(defaultWorkspace));
              }
            }

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
     * Check for a default workspace
     */
    public static Integer checkForDefaultWorkspace(List<helplightning.HLModelWorkspace> workspaces) {
        try {
          String myUserEmail = helplightning.HLUserHelper.getLogin();
          Integer workspaceId = null;

          if (!String.isBlank(HLConfiguration.getWorkspaceId())) {
            // If we already have a set workspace id, use that
            return Integer.valueOf(HLConfiguration.getWorkspaceId());
          }
          // If we don't have a set default workspace, check for one
          for (helplightning.HLModelWorkspace w: workspaces) {
            List<helplightning.HLModelEnterpriseUser> users = helplightning.HLGaldrClient.searchEnterpriseUsers(w.token, myUserEmail);
            // Find the first user matching our email
            for (helplightning.HLModelEnterpriseUser u: users) {
              if (u.email == myUserEmail) {
                workspaceId = w.id;
                break;
              }
            }
            if (workspaceId != null) {
              break;
            }
          }
          return workspaceId;
        } catch (Exception e) {
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
            String token = HLTokenHelper.getToken();
            List<helplightning.HLModelSearchUser> users = helplightning.HLGaldrClient.searchUsers(token, email);


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
     * Create an HL session between us and another
     *  user actually using sessions.
     * This will return the Gss Auth info
     */
    @AuraEnabled
    public static Map<String,Object> makeSessionWith(String otherUsersEmail) {
        System.debug('makeSessionWith');

        try {
            // get our info
            String myUserEmail = helplightning.HLUserHelper.getLogin();
            helplightning.HLModelEnterpriseUser us = HLSessionController.getHLUser(myUserEmail);

            // get a token for the other user
            String token = HLTokenHelper.getToken();
            List<helplightning.HLModelSearchUser> os = helplightning.HLGaldrClient.searchUsers(token, otherUsersEmail);
            if (os == null || os.size() == 0) {
                return null;
            }
            String contactToken = os.get(0).token;

            // make a new session
            helplightning.HLModelSession session = helplightning.HLGaldrClient.createsession(us.authToken, new List<String>{contactToken});
            String sessionId = session.id;

            // ring the other person
            helplightning.HLModelVideoSession videoSession = helplightning.HLGaldrClient.sessionRequestVideo(us.authToken, session);

            // build a model
            helplightning.HLModelSessionAuth sessionAuth = new
                helplightning.HLModelSessionAuth(us.authToken, sessionId,
                                                 UserInfo.getName(), us.username, videoSession);

            return sessionAuth.serialize();
        } catch (helplightning.HLConfigurationException e) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        }
    }

    /**
     * Invite a user to a personal room.
     *  This will send out an email to them.
     */
    @AuraEnabled
    public static Map<String,Object> sendOneTimeUseLink(String otherUsersName, String otherUsersEmail, String otherUsersPhone, String message) {
        System.debug('sendOneTimeUseLink: ' + otherUsersName + ' email: ' + otherUsersEmail + ' phone: ' + otherUsersPhone);

        try {
            String myUserEmail = helplightning.HLUserHelper.getLogin();
            System.debug('myUserId=' + myUserEmail);

            // first get a list of users to find us, since
            //  we have to make this request as a specific user
            String token = HLTokenHelper.getToken();
            List<helplightning.HLModelEnterpriseUser> users = helplightning.HLGaldrClient.searchEnterpriseUsers(token, myUserEmail);
            if (users == null || users.size() == 0) {
                System.debug('Error finding our user.');
                return null;
            }

            // use the first user.
            String name = users.get(0).name;
            String username = users.get(0).username;
            String userToken = users.get(0).authToken;
            if (userToken == null) {
                System.debug('Invalid user token');
                return null;
            }

            // Now send out the invite. We use the user
            //  token we retrieved so that this acts
            //  on behalf of that user.
            Boolean result = helplightning.HLGaldrClient.sendOneTimeUseLink(userToken, otherUsersName, otherUsersEmail, otherUsersPhone, message);
            if (result == false) {
                System.debug('Failed to invite');
                return null;
            }

            // get our user info, which will give us our personal room session
            helplightning.HLModelAccount account = helplightning.HLGaldrClient.getInfo(userToken);

            return (new helplightning.HLMeetingRoomAuth(userToken, username, name, account.personalRoomSessionId)).serialize();
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
    private static boolean isWorkOrderAccessible() {
        return (Schema.sObjectType.WorkOrder.fields.Id.isAccessible() &&
                Schema.sObjectType.WorkOrder.fields.ContactId.isAccessible());
    }
    private static boolean isHLCallAccessible() {
        return (Schema.sObjectType.helplightning__HLCall__c.fields.Id.isAccessible() &&
                Schema.sObjectType.helplightning__HLCall__c.fields.helplightning__Session_Id__c.isAccessible() &&
                Schema.sObjectType.helplightning__HLCall__c.fields.helplightning__HLCall_Id__c.isAccessible() &&
                Schema.sObjectType.helplightning__HLCall__c.fields.helplightning__Contact_Email__c.isAccessible() &&
                Schema.sObjectType.helplightning__HLCall__c.fields.helplightning__Contact_Phone__c.isAccessible() &&
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
      String token = HLTokenHelper.getToken();

      List<helplightning.HLModelEnterpriseUser> users = helplightning.HLGaldrClient.searchEnterpriseUsers(token, email);

        if (users.size() == 0) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        }

        // return the first item
        return users.get(0);
    }

    @future
    private static void saveEvent(String sObjectName, String recordId, DateTime startTime, DateTime endTime, string callId) {
        Event e = new Event();
        e.StartDateTime = startTime;
        e.EndDateTime = endTime;
        e.Subject = 'Videochat';
        if (sObjectName == 'Case') {
            Case c = getCase(recordId);
            if (c != null) {
                e.WhatId = c.Id;
                e.WhoId = c.ContactId;
            }
        } else if (sObjectName == 'WorkOrder') {
            WorkOrder wo = getWorkOrder(recordId);
            if (wo != null) {
                e.WhatId = wo.Id;
                e.WhoId = wo.ContactId;
            }
        }

        if (callId == null || callId.equals('')) {
            e.Description = 'Call was unanswered';
        } else {
            e.Description = 'https://app.helplightning.net/calls/' + callId;
        }

        upsert e;
    }

    @future(callout = true)
    private static void saveAttachment(String callId, String recordId) {
        String token = HLTokenHelper.getToken();
        List<HLModelAttachment> attachments = helplightning.HLGaldrClient.getAttachments(token, callId);

        List<Attachment> toSave = new List<Attachment>();

        // We can't save attachments while making call-outs
        for (HLModelAttachment a: attachments) {
            // Only save screencaps for now
            if (a.mimeType == 'image/jpeg') {
                // Get the attachment blob from the presigned url
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(a.signedUrl);
                req.setMethod('GET');
                HttpResponse res = h.send(req);
                Blob bd = res.getBodyAsBlob();
                Attachment att = new Attachment(Name = a.fileName, Body = bd, ContentType = 'image/jpeg;charset=UTF-8', ParentId=recordId);
                toSave.add(att);
            }
        }

        for (Attachment a: toSave) {
            insert a;
        }
    }
}
