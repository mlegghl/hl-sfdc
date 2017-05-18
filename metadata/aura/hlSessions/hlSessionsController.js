({
    doInit : function(component, event, helper) {
	    console.log("doInit, revision 23");
    },

    recordUpdatedEvt : function(component, event, helper) {
        console.log("recordUpdatedEvt");

        var r = component.get("v.record");
        var email = r.ContactEmail;

        // check if our contact is a Help Lightning User
        var action1 = component.get("c.isHLUser");
        action1.setParams({"email": email});
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                component.set("v.contactIsHLUser", response.getReturnValue());
            }
        });
        $A.enqueueAction(action1);

        // get all the known calls associated with this case
        var action2 = component.get("c.updateCalls");
        action2.setParams({"caseId": r.Id});
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                component.set("v.calls", response.getReturnValue());
            }
        });

        $A.enqueueAction(action2);
    },

    clickCall : function(component, event, helper) {
        console.log("clickCall");

        var r = component.get("v.record");
        var email = r.ContactEmail;
        console.log("email " + email);

        var action = component.get("c.makeSessionWith");
        action.setParams({"otherUsersEmail": email});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                console.log("response is " + response.getReturnValue());

                // create a new HLCall
                helper.createNewCall(component, r, email, response.getReturnValue());
            } else {
                console.log("response failed: " + state);
            }
        });

        $A.enqueueAction(action);
    }
})
