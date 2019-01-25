({
    doInit : function(component, event, helper) {
        console.log("Initializing Help Lightning Component");

        var rId = component.get("v.recordId");
        var sObjectName = component.get("v.sObjectName");

        // make sure this component type is supported.
        if (!helper.isSupportedComponent(component, sObjectName)) {
            return;
        }

        // validate we are a help lightning user, in our enterprise
        helper.checkRegistration(component, helper, function(response) {
            if (!response) {
                // invalid user, stop here.
                return
            }

            // get our record
            helper.getContactForRecord(component, helper, function(response) {
                if (response === false) {
                    // no contact, stop here.
                    return;
                }

                // the response from getContactForRecord is the contact's
                //  email address
                // Now validate if that contact is a registered HL user.
                helper.contactIsHLUser(component, helper, response, function(response) {
                });

                // get any calls associated with this record, and
                //  begin polling if necessary.
                helper.updateCalls(component, helper, function(response) {
                });
            });
        });

        window.addEventListener('message', (event) => {
            const message = event.data;
            if (message.type === 'CALL_CONNECTED') {
                var callId = message.callId;
                var hlCallId = message.state;

                if (callId && hlCallId) {
                    helper.updateCallId(component, callId, hlCallId);
                }
            }
        })
    },

    doDestroy : function(component, event, helper) {
        // stop our timer if it is still running.
        var timer = component.get("v.pollTimer");
        if (timer) {
            window.clearInterval(timer);
        }
    },

    clickCall : function(component, event, helper) {
        var sObjectName = component.get("v.sObjectName");
        var rId = component.get("v.recordId");
        var contact = component.get("v.contact");
        var email = contact.Email;

        var action = component.get("c.makeSessionWith");
        action.setParams({"otherUsersEmail": email});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                var r = response.getReturnValue();

                var userToken = r.token;
                var sessionId = r.sessionId;
                var name = encodeURIComponent(r.displayName);
                var gssToken = r.gssInfo.token;
                var gssUrl = r.gssInfo.serverWSURL;

                var url = 'https://app.helplightning.net/webCall?displayName=' + name + '&nameOrEmail=&userToken=' + userToken + '&gssToken=' + gssToken + '&gssUrl=' + gssUrl;

                // create a new HLCall
                helper.createNewCall(component, helper, sObjectName, rId, email, sessionId, false, url);
            } else {
                console.log("HL::makeSessionWith response failed: " + state);
            }
        });
        $A.enqueueAction(action);
    },

    clickSendOneTimeUseLink : function(component, event, helper) {
        var sObjectName = component.get("v.sObjectName");
        var rId = component.get("v.recordId");

        var contact = component.get("v.contact");
        var email = event.getParam("email");
        var phone = event.getParam("phone");
        var message = event.getParam("message");
        var contactName = contact.Name;

        var action = component.get("c.sendOneTimeUseLink");
        action.setParams({"otherUsersName": contactName, "otherUsersEmail": email, "otherUsersPhone": phone, message: message});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                console.log("successfully invited to personal room");
                var r = response.getReturnValue();

                var userToken = r.token;
                var name = r.name;
                var username = r.username;
                var sessionId = r.sessionId;

                var url = 'https://app.helplightning.net/webCall?displayName=' + name + '&nameOrEmail=' + username + '&userToken=' + userToken + '&mode=autoAccept';

                // create a new HLCall
                helper.createNewCall(component, helper, sObjectName, rId, email, sessionId, true, url);
            } else {
                console.log("HL::sendOneTimeUseLink response failed: " + state);
            }
        });

        $A.enqueueAction(action);
    }
})
