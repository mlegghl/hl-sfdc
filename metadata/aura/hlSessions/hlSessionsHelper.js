({
    createNewCall : function(component, helper, sObjectName, recordId, email, sessionId) {
        console.log("creating new session and attaching it to a " + sObjectName);
        var supportedComponent = (sObjectName === "Case" || sObjectName === "WorkOrder");
        if (!supportedComponent) {
            console.log('Unable to createNewCall for unsupported component: ' + sObjectName);
            return;
        }

        var newCall;

        if (sObjectName === "Case") {
                newCall = {'sobjectType': 'helplightning__HLCall__c',
                           'helplightning__Case__c': recordId,
                           'helplightning__Contact_Email__c': email,
                           'helplightning__Session_Id__c': sessionId,
                           'helplightning__Type__c': 'Direct'}
        } else if (sObjectName == "WorkOrder") {
                newCall = {'sobjectType': 'helplightning__HLCall__c',
                           'helplightning__Work_Order__c': recordId,
                           'helplightning__Contact_Email__c': email,
                           'helplightning__Session_Id__c': sessionId,
                           'helplightning__Type__c': 'Direct'}
        }

        var action = component.get("c.saveCall");
        action.setParams({"call": newCall})
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                var sessions = component.get("v.calls");
                // insert at the beginning
                sessions.splice(0, 0, response.getReturnValue());
                component.set("v.calls", sessions);
            }
        });

        $A.enqueueAction(action);

        // begin polling
        helper.beginPolling(component, helper);
    },

    beginPolling : function(component, helper) {
        var timer = component.get("v.pollTimer");
        if (timer != null) {
            // nothing to do, timer is already working
            return
        } else {
            // create a timer and begin polling
            var timer = window.setInterval(
                $A.getCallback(function() {
                    helper.pollCalls(component, helper)
                }), 30000);

            component.set("v.pollTimer", timer);
        }
    },

    pollCalls : function(component, helper) {
        var rId = component.get("v.recordId");
        var sObjectName = component.get("v.sObjectName");

        var action = component.get("c.updateCalls");
        action.setParams({"sObjectName": sObjectName,
                           "recordId": rId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                calls = response.getReturnValue();
                component.set("v.calls", calls);

                // if all the calls are complete, stop
                var complete = calls.every(function(call) {
                    return call.helplightning__Complete__c == true;
                });
                if (complete) {
                    // stop polling
                    var timer = component.get("v.pollTimer");
                    if (timer) {
                        window.clearInterval(timer);

                        // clear out the timer
                        component.set("v.pollTimer", null);
                    } else {
                        console.log("HL: Tried to stop polling, but timer doesn't exist anymore");
                    }
                }
            } else {
                // there was an error polling for calls
                //  let it try again later.
                console.log("HL:updateCalls failed: " + state);
            }
        });

        $A.enqueueAction(action);
    }
})
