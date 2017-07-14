({
    doInit : function(component, event, helper) {
        console.log("doInit, revision 33r");

        var rId = component.get("v.recordId");
        var sObjectName = component.get("v.sObjectName");

        // make sure this component type is supported.
        var supportedComponent = (sObjectName === "Case" || sObjectName === "WorkOrder");
        if (!supportedComponent) {
            console.log("Unsupported component");

            component.set("v.hasErrors", true);
            component.set("v.errorMessage", "Help Lightning is not available for this component.");

            return;
        }

        // get our record
        var recordAction = component.get("c.getContactForRecord");
        recordAction.setParams({"sObjectName": sObjectName,
                                "recordId": rId});
        recordAction.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                var contact = response.getReturnValue();
                component.set("v.contact", contact);

                var email = contact.Email;

                // check if our contact is a Help Lightning User
                var action1 = component.get("c.isHLUser");
                action1.setParams({"email": email});
                action1.setCallback(this, function(response) {
                    var state = response.getState();
                    if (component.isValid() && state == "SUCCESS") {
                        component.set("v.contactIsHLUser", response.getReturnValue());
                    } else if (component.isValid && state == "ERROR") {
                        component.set("v.hasErrors", true);

                        console.log("setting error to: " + response.getError());
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                component.set("v.errorMessage", errors[0].message);
                            }
                        } else {
                            console.log("Unknown error during isHLUser");
                        }
                    }
                });
                $A.enqueueAction(action1);

                // get all the known calls associated with this case
                var action2 = component.get("c.updateCalls");
                action2.setParams({"sObjectName": sObjectName,
                                   "recordId": rId});
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

        var sObjectName = component.get("v.sObjectName");
        var rId = component.get("v.recordId");
        var contact = component.get("v.contact");
        var email = contact.Email;
        console.log("email " + email);

        var action = component.get("c.makeSessionWith");
        action.setParams({"otherUsersEmail": email});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                console.log("response is " + response.getReturnValue());

                // create a new HLCall
                helper.createNewCall(component, sObjectName, rId, email, response.getReturnValue());
            } else {
                console.log("response failed: " + state);
            }
        });

        $A.enqueueAction(action);
    },

    clickInviteToPersonalRoom : function(component, event, helper) {
        console.log("clickInviteToPersonalRoom");

        var contact = component.get("v.contact");
        var email = contact.Email;
        var name = contact.Name;

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
