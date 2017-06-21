({
    doInit : function(component, event, helper) {
        console.log("doInit, revision 32o");

        var rId = component.get("v.recordId");

        var recordAction = component.get("c.getCase");
        recordAction.setParams({"recordId": rId});
        recordAction.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                var r = response.getReturnValue();
                // update our record
                component.set("v.record", r);

                //
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
            }
        });
        $A.enqueueAction(recordAction);
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
    },

    clickInviteToPersonalRoom : function(component, event, helper) {
        console.log("clickInviteToPersonalRoom");

        var r = component.get("v.record");
        var email = r.ContactEmail;
        var name = r.Contact.Name;

        var action = component.get("c.inviteToPersonalRoom");
        action.setParams({"otherUsersName": name, "otherUsersEmail": email});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                console.log("successfully invited to personal room");

                // !mwd - show a status update about this
            } else {
                console.log("failed to invite to personal room: " + state);
            }
        });

        $A.enqueueAction(action);
    }
})
