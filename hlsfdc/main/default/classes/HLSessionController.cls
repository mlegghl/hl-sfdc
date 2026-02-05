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
            if (token == null) {
                System.debug('No token found. This user doesnt exist');
                return false;
            }
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

    @AuraEnabled
    public static HLModelWorkboxDetails getWorkboxByCallId(String callId) {
        try {
            String token = HLTokenHelper.getToken();
            helplightning.HLModelWorkboxDetails details = helplightning.HLGaldrClient.getWorkboxByCallId(token, callId);
            return details;
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
            helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
            helplightning.HLModelSessionAuth sessionAuth = new
                helplightning.HLModelSessionAuth(environment.url,
                                                 us.authToken, sessionId,
                                                 UserInfo.getName(), us.username, videoSession);

            return sessionAuth.serialize();
        } catch (helplightning.HLConfigurationException e) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        }
    }

    /**
     * Get or create a workbox for a Case/WorkOrder.
     * Called on page init to ensure a workbox exists for this record.
     * Returns the workbox ID and whether it was newly created.
     */
    @AuraEnabled
    public static Map<String,Object> initWorkbox(String sObjectName, String recordId) {
        System.debug('initWorkbox: sObjectName=' + sObjectName + ' recordId=' + recordId);

        try {
            String myUserEmail = helplightning.HLUserHelper.getLogin();
            System.debug('myUserId=' + myUserEmail);

            String token = HLTokenHelper.getToken();
            List<helplightning.HLModelEnterpriseUser> users = helplightning.HLGaldrClient.searchEnterpriseUsers(token, myUserEmail);
            if (users == null || users.size() == 0) {
                System.debug('Error finding our user.');
                return null;
            }

            String userToken = users.get(0).authToken;
            if (userToken == null) {
                System.debug('Invalid user token');
                return null;
            }

            // Get or create a persistent workbox for this Case/WorkOrder
            Map<String,Object> workboxInfo = getOrCreateWorkbox(userToken, sObjectName, recordId);
            if (workboxInfo == null) {
                System.debug('Failed to get or create workbox');
                return null;
            }

            Integer workboxId = (Integer)workboxInfo.get('workboxId');
            Boolean isNew = (Boolean)workboxInfo.get('isNew');

            Map<String,Object> result = new Map<String,Object>();
            result.put('workboxId', workboxId);
            result.put('isNew', isNew);
            return result;
        } catch (helplightning.HLConfigurationException e) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        }
    }

    /**
     * Get workbox details including participants and custom fields.
     * Returns the full workbox info from the Help Lightning API.
     */
    @AuraEnabled
    public static HLModelWorkboxDetails getWorkboxDetails(String sObjectName, String recordId) {
        System.debug('getWorkboxDetails: sObjectName=' + sObjectName + ' recordId=' + recordId);

        try {
            // Check if a workbox exists for this record
            helplightning__HLWorkbox__c existingRecord = getExistingWorkbox(sObjectName, recordId);
            if (existingRecord == null) {
                System.debug('No workbox found for this record');
                return null;
            }

            String myUserEmail = helplightning.HLUserHelper.getLogin();
            String token = HLTokenHelper.getToken();
            List<helplightning.HLModelEnterpriseUser> users = helplightning.HLGaldrClient.searchEnterpriseUsers(token, myUserEmail);
            if (users == null || users.size() == 0) {
                System.debug('Error finding our user.');
                return null;
            }

            String userToken = users.get(0).authToken;
            if (userToken == null) {
                System.debug('Invalid user token');
                return null;
            }

            // Fetch workbox details from API - now returns properly structured model
            Integer workboxId = Integer.valueOf(existingRecord.helplightning__Workbox_Id__c);
            helplightning.HLModelWorkboxDetails workboxDetails = helplightning.HLGaldrClient.getWorkboxById(userToken, workboxId);

            if (workboxDetails == null) {
                System.debug('Failed to fetch workbox details');
                return null;
            }

            return workboxDetails;
        } catch (helplightning.HLConfigurationException e) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        }
    }

    /**
     * Get the Help Lightning environment URL.
     */
    @AuraEnabled
    public static String getEnvironmentUrl() {
        try {
            helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
            return environment.url;
        } catch (helplightning.HLConfigurationException e) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        }
    }

    /**
     * Get the info needed to open the chat window.
     * Returns the user token (not workbox token), workbox ID, and web URL.
     */
    @AuraEnabled
    public static Map<String,Object> getOpenChatInfo(String sObjectName, String recordId) {
        System.debug('getOpenChatInfo: sObjectName=' + sObjectName + ' recordId=' + recordId);

        try {
            // Check if a workbox exists for this record
            helplightning__HLWorkbox__c existingRecord = getExistingWorkbox(sObjectName, recordId);
            if (existingRecord == null) {
                System.debug('No workbox found for this record');
                return null;
            }

            String myUserEmail = helplightning.HLUserHelper.getLogin();
            String token = HLTokenHelper.getToken();
            List<helplightning.HLModelEnterpriseUser> users = helplightning.HLGaldrClient.searchEnterpriseUsers(token, myUserEmail);
            if (users == null || users.size() == 0) {
                System.debug('Error finding our user.');
                return null;
            }

            String userToken = users.get(0).authToken;
            if (userToken == null) {
                System.debug('Invalid user token');
                return null;
            }

            Integer workboxId = Integer.valueOf(existingRecord.helplightning__Workbox_Id__c);
            helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());

            Map<String,Object> result = new Map<String,Object>();
            result.put('userToken', userToken);
            result.put('workboxId', workboxId);
            result.put('webUrl', environment.url);
            return result;
        } catch (helplightning.HLConfigurationException e) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        }
    }

    /**
     * Resend an invite to a guest in the workbox.
     * Uses the guest's UUID (not ID) as required by the API.
     */
    @AuraEnabled
    public static void resendGuestInvite(String sObjectName, String recordId, String guestUuid) {
        System.debug('resendGuestInvite: sObjectName=' + sObjectName + ' recordId=' + recordId + ' guestUuid=' + guestUuid);

        try {
            // Get the workbox token
            String myUserEmail = helplightning.HLUserHelper.getLogin();
            String token = HLTokenHelper.getToken();
            List<helplightning.HLModelEnterpriseUser> users = helplightning.HLGaldrClient.searchEnterpriseUsers(token, myUserEmail);
            if (users == null || users.size() == 0) {
                throw new AuraHandledException('Error finding user.');
            }

            String userToken = users.get(0).authToken;
            if (userToken == null) {
                throw new AuraHandledException('Invalid user token.');
            }

            // Get the workbox info to get the token
            Map<String,Object> workboxInfo = getOrCreateWorkbox(userToken, sObjectName, recordId);
            if (workboxInfo == null) {
                throw new AuraHandledException('Failed to get workbox.');
            }

            String workboxToken = (String)workboxInfo.get('workboxToken');

            // Resend the invite
            Map<String,Object> result = helplightning.HLGaldrClient.resendGuestInvite(workboxToken, guestUuid);
            if (result == null) {
                throw new AuraHandledException('Failed to resend invite.');
            }
        } catch (helplightning.HLConfigurationException e) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        }
    }

    /**
     * Remove a guest from the workbox.
     * Uses the guest's UUID (not ID) as required by the API.
     */
    @AuraEnabled
    public static void removeGuest(String sObjectName, String recordId, String guestUuid) {
        System.debug('removeGuest: sObjectName=' + sObjectName + ' recordId=' + recordId + ' guestUuid=' + guestUuid);

        try {
            // Get the workbox token
            String myUserEmail = helplightning.HLUserHelper.getLogin();
            String token = HLTokenHelper.getToken();
            List<helplightning.HLModelEnterpriseUser> users = helplightning.HLGaldrClient.searchEnterpriseUsers(token, myUserEmail);
            if (users == null || users.size() == 0) {
                throw new AuraHandledException('Error finding user.');
            }

            String userToken = users.get(0).authToken;
            if (userToken == null) {
                throw new AuraHandledException('Invalid user token.');
            }

            // Get the workbox info to get the token
            Map<String,Object> workboxInfo = getOrCreateWorkbox(userToken, sObjectName, recordId);
            if (workboxInfo == null) {
                throw new AuraHandledException('Failed to get workbox.');
            }

            String workboxToken = (String)workboxInfo.get('workboxToken');

            // Remove the guest
            helplightning.HLGaldrClient.removeGuestFromWorkbox(workboxToken, guestUuid);
        } catch (helplightning.HLConfigurationException e) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        }
    }

    /**
     * Close a workbox (change status to CLOSED).
     */
    @AuraEnabled
    public static void closeWorkbox(String sObjectName, String recordId) {
        System.debug('closeWorkbox: sObjectName=' + sObjectName + ' recordId=' + recordId);

        try {
            // Get the workbox token
            String myUserEmail = helplightning.HLUserHelper.getLogin();
            String token = HLTokenHelper.getToken();
            List<helplightning.HLModelEnterpriseUser> users = helplightning.HLGaldrClient.searchEnterpriseUsers(token, myUserEmail);
            if (users == null || users.size() == 0) {
                throw new AuraHandledException('Error finding user.');
            }

            String userToken = users.get(0).authToken;
            if (userToken == null) {
                throw new AuraHandledException('Invalid user token.');
            }

            // Get the workbox info to get the token
            Map<String,Object> workboxInfo = getOrCreateWorkbox(userToken, sObjectName, recordId);
            if (workboxInfo == null) {
                throw new AuraHandledException('Failed to get workbox.');
            }

            String workboxToken = (String)workboxInfo.get('workboxToken');

            // Close the workbox
            helplightning.HLGaldrClient.closeWorkbox(workboxToken);
        } catch (helplightning.HLConfigurationException e) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        }
    }

    /**
     * Reopen a closed workbox
     */
    @AuraEnabled
    public static void reopenWorkbox(String sObjectName, String recordId) {
        System.debug('reopenWorkbox: sObjectName=' + sObjectName + ' recordId=' + recordId);

        try {
            // Get the workbox token
            String myUserEmail = helplightning.HLUserHelper.getLogin();
            String token = HLTokenHelper.getToken();
            List<helplightning.HLModelEnterpriseUser> users = helplightning.HLGaldrClient.searchEnterpriseUsers(token, myUserEmail);
            if (users == null || users.size() == 0) {
                throw new AuraHandledException('Error finding user.');
            }

            String userToken = users.get(0).authToken;
            if (userToken == null) {
                throw new AuraHandledException('Invalid user token.');
            }

            // Get the workbox info to get the token
            Map<String,Object> workboxInfo = getOrCreateWorkbox(userToken, sObjectName, recordId);
            if (workboxInfo == null) {
                throw new AuraHandledException('Failed to get workbox.');
            }

            String workboxToken = (String)workboxInfo.get('workboxToken');

            // Reopen the workbox
            helplightning.HLGaldrClient.reopenWorkbox(workboxToken);
        } catch (helplightning.HLConfigurationException e) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        }
    }

    /**
     * Save custom field values to a workbox
     */
    @AuraEnabled
    public static void saveCustomFields(String sObjectName, String recordId, List<Map<String,Object>> fieldValues) {
        System.debug('saveCustomFields: sObjectName=' + sObjectName + ' recordId=' + recordId);
        System.debug('fieldValues: ' + JSON.serialize(fieldValues));

        try {
            // Get the workbox token
            String myUserEmail = helplightning.HLUserHelper.getLogin();
            String token = HLTokenHelper.getToken();
            List<helplightning.HLModelEnterpriseUser> users = helplightning.HLGaldrClient.searchEnterpriseUsers(token, myUserEmail);
            if (users == null || users.size() == 0) {
                throw new AuraHandledException('Error finding user.');
            }

            String userToken = users.get(0).authToken;
            if (userToken == null) {
                throw new AuraHandledException('Invalid user token.');
            }

            // Get the workbox info to get the token
            Map<String,Object> workboxInfo = getOrCreateWorkbox(userToken, sObjectName, recordId);
            if (workboxInfo == null) {
                throw new AuraHandledException('Failed to get workbox.');
            }

            String workboxToken = (String)workboxInfo.get('workboxToken');

            // Build the payload
            helplightning.HLModelUpdateWorkbox payload = new helplightning.HLModelUpdateWorkbox();
            payload.values = fieldValues;

            System.debug('Saving custom fields with workboxToken: ' + workboxToken);
            System.debug('Payload values: ' + JSON.serialize(payload.values));

            // Save the custom fields
            Boolean success = helplightning.HLGaldrClient.saveCustomFields(workboxToken, payload);
            if (!success) {
                throw new AuraHandledException('Failed to save custom fields to Help Lightning.');
            }
        } catch (helplightning.HLConfigurationException e) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        }
    }

    /**
     * Create a help thread (workbox) for copy link flow.
     *  This uses the persistent workbox and returns the link for copying.
     */
    @AuraEnabled
    public static Map<String,Object> createOneTimeUseLink(String sObjectName, String recordId) {
        System.debug('createOneTimeUseLink: sObjectName=' + sObjectName + ' recordId=' + recordId);

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

            // Get or create a persistent workbox for this Case/WorkOrder
            Map<String,Object> workboxInfo = getOrCreateWorkbox(userToken, sObjectName, recordId);
            if (workboxInfo == null) {
                System.debug('Failed to get or create workbox');
                return null;
            }

            Integer workboxId = (Integer)workboxInfo.get('workboxId');
            String workboxToken = (String)workboxInfo.get('workboxToken');
            Boolean isNew = (Boolean)workboxInfo.get('isNew');
            System.debug('Using workbox id=' + workboxId + ' (isNew=' + isNew + ')');

            // Call silent invite with the workbox token to get the guest link
            Map<String,Object> inviteResponse = helplightning.HLGaldrClient.createWorkboxInviteSilent(workboxToken, 'Guest');
            if (inviteResponse == null) {
                System.debug('Failed to create silent invite');
                return null;
            }

            // Get the link from the invite response
            String link = (String)inviteResponse.get('link');

            helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());

            // Return the workbox info along with auth info and the link from the API
            Map<String,Object> result = new Map<String,Object>();
            result.put('workboxId', workboxId);
            result.put('workboxToken', workboxToken);
            result.put('link', link);
            result.put('webUrl', environment.url);
            result.put('token', userToken);
            result.put('name', name);
            result.put('username', username);
            return result;
        } catch (helplightning.HLConfigurationException e) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        }
    }

    /**
     * Invite a user to a help thread (workbox).
     *  This will create a workbox and send out an email/SMS invite to them.
     */
    @AuraEnabled
    public static Map<String,Object> sendOneTimeUseLink(String otherUsersName, String otherUsersEmail, String otherUsersPhone, String message, String sObjectName, String recordId) {
        System.debug('sendOneTimeUseLink: ' + otherUsersName + ' email: ' + otherUsersEmail + ' phone: ' + otherUsersPhone + ' sObjectName: ' + sObjectName + ' recordId: ' + recordId);

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

            // Get or create a persistent workbox for this Case/WorkOrder
            Map<String,Object> workboxInfo = getOrCreateWorkbox(userToken, sObjectName, recordId);
            if (workboxInfo == null) {
                System.debug('Failed to get or create workbox');
                return null;
            }

            Integer workboxId = (Integer)workboxInfo.get('workboxId');
            String workboxToken = (String)workboxInfo.get('workboxToken');
            Boolean isNew = (Boolean)workboxInfo.get('isNew');
            System.debug('Using workbox id=' + workboxId + ' (isNew=' + isNew + ')');

            // Send the invite using the workbox token
            Map<String,Object> inviteResult = helplightning.HLGaldrClient.sendWorkboxInvite(workboxToken, otherUsersEmail, otherUsersPhone, otherUsersName);
            if (inviteResult == null) {
                System.debug('Failed to send workbox invite');
                return null;
            }

            helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());

            // Return the workbox info along with auth info
            Map<String,Object> result = new Map<String,Object>();
            result.put('workboxId', workboxId);
            result.put('workboxToken', workboxToken);
            result.put('webUrl', environment.url);
            result.put('token', userToken);
            result.put('name', name);
            result.put('username', username);
            return result;
        } catch (helplightning.HLConfigurationException e) {
            throw new AuraHandledException('The Help Lightning component must be configured first.');
        }
    }

    /** Private Helper Functions **/

    /**
     * Get a formatted title for the workbox based on the Case or WorkOrder.
     * Returns format like 'Case - 00001234' or 'Work Order - 00005678'
     */
    private static String getRecordNumber(String sObjectName, String recordId) {
        if (String.isEmpty(sObjectName) || String.isEmpty(recordId)) {
            return null;
        }

        try {
            if (sObjectName == 'Case') {
                List<Case> cases = [SELECT CaseNumber FROM Case WHERE Id = :recordId LIMIT 1];
                if (cases.size() > 0) {
                    return 'Case - ' + cases[0].CaseNumber;
                }
            } else if (sObjectName == 'WorkOrder') {
                List<WorkOrder> workOrders = [SELECT WorkOrderNumber FROM WorkOrder WHERE Id = :recordId LIMIT 1];
                if (workOrders.size() > 0) {
                    return 'Work Order - ' + workOrders[0].WorkOrderNumber;
                }
            }
        } catch (Exception e) {
            System.debug('Error getting record number: ' + e.getMessage());
        }

        return null;
    }

    /**
     * Get the existing HLWorkbox record for a Case/WorkOrder, or null if none exists.
     */
    private static helplightning__HLWorkbox__c getExistingWorkbox(String sObjectName, String recordId) {
        if (String.isEmpty(sObjectName) || String.isEmpty(recordId)) {
            return null;
        }

        try {
            List<helplightning__HLWorkbox__c> workboxes;
            if (sObjectName == 'Case') {
                workboxes = [SELECT Id, helplightning__Workbox_Id__c 
                            FROM helplightning__HLWorkbox__c 
                            WHERE helplightning__Case__c = :recordId 
                            ORDER BY CreatedDate DESC 
                            LIMIT 1];
            } else if (sObjectName == 'WorkOrder') {
                workboxes = [SELECT Id, helplightning__Workbox_Id__c 
                            FROM helplightning__HLWorkbox__c 
                            WHERE helplightning__Work_Order__c = :recordId 
                            ORDER BY CreatedDate DESC 
                            LIMIT 1];
            } else {
                return null;
            }

            if (workboxes != null && workboxes.size() > 0) {
                return workboxes[0];
            }
        } catch (Exception e) {
            System.debug('Error getting existing workbox: ' + e.getMessage());
        }

        return null;
    }

    /**
     * Save a new HLWorkbox record linking a Case/WorkOrder to a workbox ID.
     */
    private static helplightning__HLWorkbox__c saveWorkboxRecord(String sObjectName, String recordId, Integer workboxId) {
        if (String.isEmpty(sObjectName) || String.isEmpty(recordId) || workboxId == null) {
            return null;
        }

        try {
            helplightning__HLWorkbox__c workbox = new helplightning__HLWorkbox__c();
            workbox.helplightning__Workbox_Id__c = workboxId;

            if (sObjectName == 'Case') {
                workbox.helplightning__Case__c = recordId;
            } else if (sObjectName == 'WorkOrder') {
                workbox.helplightning__Work_Order__c = recordId;
            }

            insert workbox;
            return workbox;
        } catch (Exception e) {
            System.debug('Error saving workbox record: ' + e.getMessage());
        }

        return null;
    }

    /**
     * Get or create a workbox for a Case/WorkOrder.
     * Returns a map with workboxId, workboxToken, and isNew flag.
     */
    private static Map<String,Object> getOrCreateWorkbox(String userToken, String sObjectName, String recordId) {
        Map<String,Object> result = new Map<String,Object>();

        // Check if a workbox already exists for this record
        helplightning__HLWorkbox__c existingRecord = getExistingWorkbox(sObjectName, recordId);

        if (existingRecord != null) {
            // Workbox exists, fetch fresh info from API
            Integer workboxId = Integer.valueOf(existingRecord.helplightning__Workbox_Id__c);
            helplightning.HLModelWorkboxDetails workboxDetails = helplightning.HLGaldrClient.getWorkboxById(userToken, workboxId);

            if (workboxDetails != null) {
                result.put('workboxId', workboxId);
                result.put('workboxToken', workboxDetails.workboxToken);
                result.put('isNew', false);
                return result;
            }
            // If we couldn't fetch the workbox, it may have been deleted. Create a new one.
            System.debug('Could not fetch existing workbox ' + workboxId + ', creating new one');
        }

        // Create a new workbox
        String workboxTitle = getRecordNumber(sObjectName, recordId);
        Map<String,Object> workbox = helplightning.HLGaldrClient.createWorkbox(userToken, workboxTitle);

        if (workbox == null) {
            System.debug('Failed to create workbox');
            return null;
        }

        Integer workboxId = (Integer)workbox.get('id');
        String workboxToken = (String)workbox.get('token');

        // Save the workbox record to link it to the Case/WorkOrder
        saveWorkboxRecord(sObjectName, recordId, workboxId);

        result.put('workboxId', workboxId);
        result.put('workboxToken', workboxToken);
        result.put('isNew', true);
        return result;
    }

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
        // Note: Workbox_Id__c is not included here as it's optional and may not exist in older orgs
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
        // Note: Workbox_Id__c is not included here as it's optional and may not exist in older orgs
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
            helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
            e.Description = environment.url + '/calls/' + callId;
        }

        upsert e;
    }

    @future(callout = true)
    private static void saveAttachment(String callId, String recordId) {
        String token = HLTokenHelper.getToken();
        List<HLModelAttachment> attachments = helplightning.HLGaldrClient.getAttachments(token, callId);

        List<ContentVersion> toSave = new List<ContentVersion>();

        // We can't save attachments while making call-outs
        for (HLModelAttachment a: attachments) {
            // Only save screencaps for now
            // In order to avoid duplicates, we need to check if the file already exists in the toSave list
            // This code might need to be removed when we change how thumbnails are saved
            Boolean fileExists = false;

            // Since apex doesn't have a contains method for lists, we have to do this ugly mess.
            for (ContentVersion c: toSave) {
                if (c.Title == a.fileName) {
                    fileExists = true;
                    break;
                }
            }

            if (a.type == 'incall' && (a.mimeType == 'image/jpeg' || a.mimeType == 'image/png') && !fileExists) {
              // Get the file from signed URL
              Http h = new Http();
              HttpRequest req = new HttpRequest();
              req.setEndpoint(a.signedUrl);
              req.setMethod('GET');
              HttpResponse res = h.send(req);
              Blob bd = res.getBodyAsBlob();
              // Determine file extension based on mime type
              String fileExt = a.mimeType == 'image/png' ? '.png' : '.jpg';
              // Create a new ContentVersion object
              ContentVersion conVer = new ContentVersion();
              conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
              conVer.PathOnClient = a.fileName + fileExt;
              conVer.Title = a.fileName; // Display name of the files
              conVer.VersionData = bd;
              toSave.add(conVer);
            }
        }

        for (ContentVersion a: toSave) {
            insert a;
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:a.Id].ContentDocumentId;
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = recordId;
            conDocLink.ContentDocumentId = conDoc;
            // Specify the share type
            // V = Viewer permission. The user can explicitly view but not edit the shared file.
            // C = Collaborator permission. The user can explicitly view and edit the shared file.
            // I = Inferred permission. The user’s permission is determined by the related record.
            conDocLink.shareType = 'I';
            insert conDocLink;
        }
    }
}
