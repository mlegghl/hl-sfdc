/* -*- Mode: java; -*- */

/**
 * HLCallUtil.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

public class HLCallUtil {
    /**
     * Look through all the hlCalls
     *  and see if we have a match,
     *  if so, update the relevant
     *  information in the call object.
     *
     * @return a new HLCall__c or null if no match
     */
    public static HLCall__c findCallMatch(HLCall__c call, Object[] hlCalls) {
        System.debug('findCallMatch');

        // make a clone. We don't want to have any side-effects
        //  so we don't modify the original, but presever the id
        //  and do a deep clone
        HLCall__c updatedCall = call.clone(true, true);

        // If we don't have an HLCall_Id, then we need to
        //  search through the list and try to find a call
        //  that was started at close to the same time
        //  as our call record. This is a little fuzzy
        //  and it just uses the closest match, not necessarily
        //  the best call.
        if (updatedCall.HLCall_id__c == null || updatedCall.HLCall_Id__c.equals('')) {
            // we haven't found a matching help lightning call
            //  see if any of these are close based on time
            Map<String,Object> closestObject = findClosestCall(call, hlCalls, 90000);
            System.debug('closestObject=' + closestObject);

            // if our closest match is within 90 seconds, we'll consider this good
            if (closestObject == null) {
                // no match, if it has been more than 3 minutes
                //  consider this a failure
                DateTime now = DateTime.now();
                if (now.getTime() - updatedCall.Start_Time__c.getTime() > 180000) {
                    System.debug('couldn\'t find a match after 3 minutes, assuming a failure');
                    updatedCall.Complete__c = true;
                    updatedCall.Successful__c = false;
                    updatedCall.Duration__c = 0;
                    updatedCall.End_Time__c = updatedCall.Start_Time__c;

                    return updatedCall;
                } else {
                    // no match, but hasn't been long enough yet
                    return null;
                }
            } else {
                System.debug('found a match!');

                // update everything we can
                updatedCall.HLCall_id__c = (String)closestObject.get('call_id');

                if ((Boolean)closestObject.get('complete')) {
                    System.debug('setting call as complete');
                    DateTime endTime = (DateTime)JSON.deserialize('"' + closestObject.get('end_time') + '"', DateTime.class);

                    updatedCall.Complete__c = true;
                    updatedCall.Successful__c = (Boolean)closestObject.get('successful');
                    updatedCall.Duration__c = (Decimal)closestObject.get('duration');
                    updatedCall.End_time__c = endTime;

                } else {
                    // The call is still pending.
                    //  we have match the call_id, so
                    //  future updates will be simpler.

                    System.debug('call is still pending');
                }

                return updatedCall;
            }
        } else {
            // we have a known call id, just find
            //  the correct call then

            for (Object c: hlCalls) {
                Map<String,Object> cc = (Map<String,Object>)c;
                String callId = (String)cc.get('call_id');

                if (updatedCall.HLCall_Id__c.equals(callId)) {
                    // do an update
                    if ((Boolean)cc.get('complete')) {
                        System.debug('setting call as complete');
                        DateTime endTime = (DateTime)JSON.deserialize('"' + cc.get('end_time') + '"', DateTime.class);

                        updatedCall.Complete__c = true;
                        updatedCall.Successful__c = (Boolean)cc.get('successful');
                        updatedCall.Duration__c = (Decimal)cc.get('duration');
                        updatedCall.End_time__c = endTime;
                    } else {
                        System.debug('call is still pending');
                    }

                    // stop execution
                    return updatedCall;
                }
            }
        }

        return null;
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
            if (HLUserHelper.getLogin().equals(dialer)) {
                System.debug('we are the dialer');
                if (!call.Contact_Email__c.equals(receiver)) {
                    System.debug('found a call with a mismatching receiver: ' + receiver);
                    continue;
                }
            } else if (HLUserHelper.getLogin().equals(receiver)) {
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
