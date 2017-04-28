({
    doInit : function(component, event, helper) {
	    console.log("doInit, revision 2");

//        var action = component.get("c.getAuthInfo");
//        action.setCallback(this, function(response) {
//            var state = response.getState();
//            if (component.isValid() && state == "SUCCESS") {
//                console.log("response is now " + response.getReturnValue());
//                component.set("v.authInfo", response.getReturnValue());
//            } else {
//                console.log("response failed: " + state);
//            }
//        });

//        $A.enqueueAction(action);
    },

    recordUpdatedEvt : function(component, event, helper) {
        console.log("recordUpdatedEvt");

        var r = component.get("v.record");
        //console.log(r);

        // get all the known calls associated with this case
        var action = component.get("c.getCalls");
        action.setParams({"caseId": r.Id});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                component.set("v.calls", response.getReturnValue());
            }
        });

        $A.enqueueAction(action);
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
                //component.set("v.sessionId", response.getReturnValue());

                // create a new HLCall
                helper.createNewCall(component, r, email, response.getReturnValue());

                // show the call details
                //console.log("remving invisible class");
                //var d = component.find("hl-call-details--div");
                //console.log("div=" + d);
                //$A.util.removeClass(d, "invisible");
                // add some call details
                //component.find("hl-call-details").innerHTML("Call starting ...");
                // $A.createComponent("ui:outputTextArea"
                //                    {"value": ""
                //                    },
                //                    function(newLabel, status, errorMessage) {
                //                        console.log("finished creating component");
                //                        if (status == "SUCCESS") {
                //                            var c = component.find("hl-call-details");
                //                            c.push(newLabel);
                //                        }
                //                    });

            } else {
                console.log("response failed: " + state);
            }
        });

        $A.enqueueAction(action);
    }
})
