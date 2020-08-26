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
    public static helplightning__HLCall__c findCallMatch(helplightning__HLCall__c call, List<helplightning.HLModelCall> hlCalls) {
        System.debug('findCallMatch');

        // make a clone. We don't want to have any side-effects
        //  so we don't modify the original, but presever the id
        //  and do a deep clone
        helplightning__HLCall__c updatedCall = call.clone(true, true);

        // If we don't have an HLCall_Id, then we need to
        //  search through the list and try to find a call
        //  that was started at close to the same time
        //  as our call record. This is a little fuzzy
        //  and it just uses the closest match, not necessarily
        //  the best call.
        if (updatedCall.helplightning__HLCall_id__c == null || updatedCall.helplightning__HLCall_Id__c.equals('')) {
            // we haven't found a matching help lightning call
            //  see if any of these are close based on time
            helplightning.HLModelCall closestObject = findClosestCall(call, hlCalls, 90000);
            System.debug('closestObject=' + closestObject);

            // if our closest match is within 90 seconds, we'll consider this good
            if (closestObject == null) {
                // no match, if it has been more than 3 minutes
                //  consider this a failure
                DateTime now = DateTime.now();
                if (now.getTime() - updatedCall.helplightning__Start_Time__c.getTime() > 180000) {
                    System.debug('couldn\'t find a match after 3 minutes, assuming a failure');
                    updatedCall.helplightning__Complete__c = true;
                    updatedCall.helplightning__Successful__c = false;
                    updatedCall.helplightning__Duration__c = 0;
                    updatedCall.helplightning__End_Time__c = updatedCall.helplightning__Start_Time__c;

                    return updatedCall;
                } else {
                    // no match, but hasn't been long enough yet
                    return null;
                }
            } else {
                System.debug('found a match!');

                // update everything we can
                updatedCall.helplightning__HLCall_id__c = closestObject.callId;

                if (closestObject.complete) {
                    System.debug('setting call as complete');

                    updatedCall.helplightning__Complete__c = true;
                    updatedCall.helplightning__Successful__c = closestObject.successful;
                    updatedCall.helplightning__Duration__c = closestObject.duration;
                    updatedCall.helplightning__End_time__c = closestObject.endTime;

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

            for (helplightning.HLModelCall c: hlCalls) {
                String callId = c.callId;

                if (updatedCall.helplightning__HLCall_Id__c.equals(callId)) {
                    // do an update
                    if (c.complete) {
                        System.debug('setting call as complete');

                        updatedCall.helplightning__Complete__c = true;
                        updatedCall.helplightning__Successful__c = c.successful;
                        updatedCall.helplightning__Duration__c = c.duration;
                        updatedCall.helplightning__End_time__c = c.endTime;
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
    public static helplightning.HLModelCall findClosestCall(helplightning__HLCall__c call, List<helplightning.HLModelCall> hlCalls,
                                                      Integer withinSeconds) {
        helplightning.HLModelCall closestObject = null;
        Long closestTime = -1;

        for (helplightning.HLModelCall c: hlCalls) {
            String dialer = c.dialer.email;
            String receiver = c.receiver.email;

            if (helplightning.HLUserHelper.getLogin().equalsIgnoreCase(receiver) || helplightning.HLUserHelper.getLogin().equalsIgnoreCase(dialer)) {
                System.debug('we are in the call');
            } else {
                System.debug('found a call where we aren\'t the dialer or receiver');
                continue;
            }

            DateTime d = c.startTime;

            // find the difference in time
            Long timeDifference = Math.abs(call.helplightning__Start_Time__c.getTime() - d.getTime());
            if (closestTime == -1 || timeDifference < closestTime) {
                closestTime = timeDifference;
                closestObject = c;
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
