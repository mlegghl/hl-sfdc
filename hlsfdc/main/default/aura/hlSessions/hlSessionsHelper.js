({
    /**
     * Make sure we support this component type.
     * If not, set an error and return false.
     */
    isSupportedComponent : function(component, sObjectName) {
        var supportedComponent = (sObjectName === "Case" || sObjectName === "WorkOrder");
        if (!supportedComponent) {
            console.log("Unsupported component");

            component.set("v.hasErrors", true);
            component.set("v.errorMessage", "Help Lightning is not available for this component.");

            return false;
        }

        return true;
    },

    /**
     * Check if the user we are logged in as is a
     *  valid help lightning user and is part of
     *  the enterprise associated with the configured key.
     */
    checkRegistration : function(component, helper, callback) {
        var action = component.get("c.checkRegistration");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                var result = false;

                var isRegistered = response.getReturnValue();
                if (isRegistered) {
                    result = true;
                } else {
                    // we can't continue
                    component.set("v.hasErrors", true);
                    component.set("v.errorMessage",
                                  "Unable to log in to Help Lightning. Please <a href=\"/apex/HelpLightning_UserSetup\" class=\"uiOutputURL\" target=\"_blank\">configure</a> your Help Lightning account in your Custom Settings.");

                    result = false;
                }
            } else if (component.isValid && state == "ERROR") {
                helper.setErrors(component, "checkRegistration", response);

                result = false;
            }

            // execute our callback
            callback(result);
        });

        $A.enqueueAction(action);
    },

    /**
     * Check to see if this record has a valid contact.
     *
     * Calls the callback with a return value of either:
     *  false -> No valid contact
     *  email:String -> the contact's email
     */
    getContactForRecord : function(component, helper, callback) {
        var rId = component.get("v.recordId");
        var sObjectName = component.get("v.sObjectName");

        var recordAction = component.get("c.getContactForRecord");
        recordAction.setParams({"sObjectName": sObjectName,
                                "recordId": rId});
        recordAction.setCallback(this, function(response) {
            var result = false;

            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                var contact = response.getReturnValue();

                // It is possible that this record does not have
                //  a contact associated with it.
                if (contact == null || contact.Email == null || contact.Email == '') {
                    component.set("v.hasErrors", true);
                    component.set("v.errorMessage",
                                  "Please add a contact with a valid email to this record.");

                } else {
                    component.set("v.contact", contact);
                    result = contact.Email;
                }
            } else if (component.isValid() && state == "ERROR") {
                helper.setErrors(component, "getContactForRecord", response);
            }

            // execute our callback
            callback(result);
        });

        $A.enqueueAction(recordAction);
    },

    /**
     * Check if an email of a contact is a registered
     *  help lightning user.
     */
    contactIsHLUser : function(component, helper, email, callback) {
        // check if our contact is a Help Lightning User
        var action = component.get("c.isHLUser");
        action.setParams({"email": email});
        action.setCallback(this, function(response) {
            var result = false;

            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                result = response.getReturnValue();
                component.set("v.contactIsHLUser", response.getReturnValue());
            } else if (component.isValid && state == "ERROR") {
                helper.setErrors(component, "isHLUser", response);
            }

            // execute our callback
            callback(result);
        });

        $A.enqueueAction(action);
    },

    /**
     * Do an initial update of the calls associated
     *  with this record, and begin polling if
     *  necessary
     */
    updateCalls : function(component, helper, callback) {
        var rId = component.get("v.recordId");
        var sObjectName = component.get("v.sObjectName");

        // get all the known calls associated with this case
        var action = component.get("c.updateCalls");
        action.setParams({"sObjectName": sObjectName,
                           "recordId": rId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                component.set("v.calls", response.getReturnValue());
            } else if (component.isValid && state == "ERROR") {
                helper.setErrors(component, "updateCalls", response);
            }

            // begin polling for new calls
            helper.beginPolling(component, helper);

            // call our callback.
            callback(true);
        });

        $A.enqueueAction(action);
    },

    createNewCall : function(component, helper, sObjectName, recordId, email, sessionId, fromInvite) {
        console.log("creating new session and attaching it to a " + sObjectName);
        var supportedComponent = (sObjectName === "Case" || sObjectName === "WorkOrder");
        if (!supportedComponent) {
            console.log('Unable to createNewCall for unsupported component: ' + sObjectName);
            return;
        }

        var newCall;

        var callType = fromInvite ? "Invitation" : "Direct"

        if (sObjectName === "Case") {
                newCall = {'sobjectType': 'helplightning__HLCall__c',
                           'helplightning__Case__c': recordId,
                           'helplightning__Contact_Email__c': email,
                           'helplightning__Session_Id__c': sessionId,
                           'helplightning__Type__c': callType}
        } else if (sObjectName == "WorkOrder") {
                newCall = {'sobjectType': 'helplightning__HLCall__c',
                           'helplightning__Work_Order__c': recordId,
                           'helplightning__Contact_Email__c': email,
                           'helplightning__Session_Id__c': sessionId,
                           'helplightning__Type__c': callType}
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
                var calls = response.getReturnValue();
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
    },

    setErrors : function(component, method, response) {
        component.set("v.hasErrors", true);

        var errors = response.getError();
        if (errors) {
            if (errors[0] && errors[0].message) {
                component.set("v.errorMessage", errors[0].message);
            }
        } else {
            console.log("HL::" + method + " response failed: " + response);
        }
    }
})
