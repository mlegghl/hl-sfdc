({
    createNewCall : function(component, caseObj, email, sessionId) {
        console.log("creating new session");
        var newCall = {'sobjectType': 'HLCall__c',
                       'Case__c': caseObj.Id,
                       'Contact_Email__c': email,
                       'Session_Id__c': sessionId,
                       'Type__c': 'Direct'}

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
