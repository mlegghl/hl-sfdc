({
    createNewCall : function(component, sObjectName, recordId, email, sessionId) {
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
    }
})
