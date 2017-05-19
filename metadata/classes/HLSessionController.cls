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
        return [ SELECT Id, Session_Id__c, HLCall_Id__c,
                 Complete__c, Successful__c,
                 Start_Time__c, Duration__c from HLCall__c
                 WHERE Case__c = :caseId
                 ORDER BY Start_Time__c DESC
                 ];
    }

    @AuraEnabled
    public static HLCall__c saveCall(HLCall__c call) {
        upsert call;

        return [ SELECT Id, Session_Id__c, HLCall_Id__c,
                 Complete__c, Successful__c,
                 Start_Time__c, Duration__c from HLCall__c
                 WHERE  Id = :call.id
                 ];
    }

    /**
     * update all the incomplete calls
     * related to a specific case
     */
    @AuraEnabled
    public static List<HLCall__c> updateCalls(Id caseId) {
        HLCall__c[] calls = [SELECT Id, Session_Id__c, HLCall_Id__c, Contact_Email__c,
                             Start_Time__c from HLCall__c WHERE Case__c = :caseId
                             AND Complete__c = false];


        /**
         * !mwd - we cannot make callouts
         *  in the middle of doing updates.
         * Therefore we will make all our callouts
         *  then check for updates in batch
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
                if (findCallMatchAndUpdate(call, (Object[])results)) {
                    // a match was found, we need to update the
                    //  database with the changes.
                    update call;
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

        Map<String, String> bodyParams = new Map<String, String>();
        bodyParams.put('dialer_email', myUserEmail);
        bodyParams.put('receiver_email', otherUsersEmail);

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


    /**
     * Look through all the hlCalls
     *  and see if we have a match,
     *  if so, update the relevant
     *  information in the call object.
     *
     * @return true if this found a match
     *  and updated the parameters.
     * THIS DOES NOT DO A DATABASE UPDATE!
     */
    public static Boolean findCallMatchAndUpdate(HLCall__c call, Object[] hlCalls) {
        System.debug('findCallMatchAndUpdate');

        // If we don't have an HLCall_Id, then we need to
        //  search through the list and try to find a call
        //  that was started at close to the same time
        //  as our call record. This is a little fuzzy
        //  and it just uses the closest match, not necessarily
        //  the best call.
        if (call.HLCall_id__c == null || call.HLCall_Id__c.equals('')) {
            // we haven't found a matching help lightning call
            //  see if any of these are close based on time
            Map<String,Object> closestObject = findClosestCall(call, hlCalls, 90000);
            System.debug('closestObject=' + closestObject);

            // if our closest match is within 90 seconds, we'll consider this good
            if (closestObject == null) {
                // no match, if it has been more than 3 minutes
                //  consider this a failure
                DateTime now = DateTime.now();
                if (now.getTime() - call.Start_Time__c.getTime() > 180000) {
                    System.debug('couldn\'t find a match after 3 minutes, assuming a failure');
                    call.Complete__c = true;
                    call.Successful__c = false;
                    call.Duration__c = 0;
                    call.End_Time__c = call.Start_Time__c;
                    return true;
                } else {
                    // no match, but hasn't been long enough yet
                    return false;
                }
            } else {
                System.debug('found a match!');

                // update everything we can
                call.HLCall_id__c = (String)closestObject.get('call_id');

                if ((Boolean)closestObject.get('complete')) {
                    System.debug('setting call as complete');
                    DateTime endTime = (DateTime)JSON.deserialize('"' + closestObject.get('end_time') + '"', DateTime.class);

                    call.Complete__c = true;
                    call.Successful__c = (Boolean)closestObject.get('successful');
                    call.Duration__c = (Decimal)closestObject.get('duration');
                    call.End_time__c = endTime;
                } else {
                    // The call is still pending.
                    //  we have match the call_id, so
                    //  future updates will be simpler.

                    System.debug('call is still pending');
                }
                return true;
            }
        } else {
            // we have a known call id, just find
            //  the correct call then

            for (Object c: hlCalls) {
                Map<String,Object> cc = (Map<String,Object>)c;
                String callId = (String)cc.get('call_id');

                if (call.HLCall_Id__c.equals(callId)) {
                    // do an update
                    if ((Boolean)cc.get('complete')) {
                        System.debug('setting call as complete');
                        DateTime endTime = (DateTime)JSON.deserialize('"' + cc.get('end_time') + '"', DateTime.class);

                        call.Complete__c = true;
                        call.Successful__c = (Boolean)cc.get('successful');
                        call.Duration__c = (Decimal)cc.get('duration');
                        call.End_time__c = endTime;
                    } else {
                        System.debug('call is still pending');
                    }

                    // stop execution
                    return true;
                }
            }
        }

        return false;
    }

    /**
     * Find an object that is closest to the
     *  start time without going over
     *  withingSeconds.
     * If no match is found, NULL is returned
     */
    public static Map<String, Object> findClosestCall(HLCall__c call, Object[] hlCalls,
                                                      Integer withinSeconds) {
        Map<String,Object> closestObject = null;
        Long closestTime = -1;

        for (Object c: hlCalls) {
            Map<String,Object> cc = (Map<String,Object>)c;
            System.debug('checking call ' + cc);

            String dialer = (String)((Map<String,Object>)cc.get('dialer')).get('email');
            String receiver = (String)((Map<String,Object>)cc.get('receiver')).get('email');

            // first make sure the receiver of this call
            //  matches the reciever of our desired call
            if (Userinfo.getUserEmail().equals(dialer)) {
                System.debug('we are the dialer');
                if (!call.Contact_Email__c.equals(receiver)) {
                    System.debug('found a call with a mismatching receiver: ' + receiver);
                    continue;
                }
            } else if (Userinfo.getUserEmail().equals(receiver)) {
                System.debug('we are the receiver');
                if (!call.Contact_Email__c.equals(dialer)) {
                    System.debug('found a call with a mismatching dialer: ' + dialer);
                    continue;
                }
            } else {
                System.debug('found a call where we aren\'t the dialer or receiver');
                continue;
            }

            // We parse the time by deserialize the time as a json string :- \
            DateTime d = (DateTime)JSON.deserialize('"' + cc.get('start_time') + '"', DateTime.class);
            System.debug('start_time=' + d);

            // find the difference in time
            Long timeDifference = Math.abs(call.Start_Time__c.getTime() - d.getTime());
            if (closestTime == -1 || timeDifference < closestTime) {
                closestTime = timeDifference;
                closestObject = cc;
            }
        }

        if (closestTime > withinSeconds) {
            // no match
            return null;
        } else {
            return closestObject;
        }
    }
}
