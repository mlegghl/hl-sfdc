({
    doInit : function(component, event, helper) {
        console.log("Initializing Help Lightning Component");

        var rId = component.get("v.recordId");
        var sObjectName = component.get("v.sObjectName");

        // create an eventHandler and store it in our component
        // We do this, because the only way to remove the event handler
        //  in our destroy is to pass in the EXACT same function
        // See: https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener
        var eventHandler = (evt) => {
            helper.messageHandler(component, helper, evt);
        };
        component.set("v.eventHandler", eventHandler);

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
                // show tabs after parent has checked for contact data
                component.set("v.showTabs", true);

                // get any calls associated with this record, and
                //  begin polling if necessary.
                helper.updateCalls(component, helper, function(response) {
                });

                if (response === false) {
                    // no contact, stop here.
                    return;
                }

                // the response from getContactForRecord is the contact's
                //  email address
                // Now validate if that contact is a registered HL user.
                helper.contactIsHLUser(component, helper, response, function(response) {
                });


            });
        });

        window.addEventListener('message', eventHandler);
    },

    doDestroy : function(component, event, helper) {
        // stop our timer if it is still running.
        var timer = component.get("v.pollTimer");
        if (timer) {
            window.clearInterval(timer);
        }

        var eventHandler = component.get("v.eventHandler");
        if (eventHandler) {
            window.removeEventListener('message', eventHandler);
        }
    },

    closeModal: function(component, event, helper) { 
      component.set("v.isModalOpen", false);
    },

    clickCall : function(component, event, helper) {
        var sObjectName = component.get("v.sObjectName");
        var rId = component.get("v.recordId");
        var email = event.getParam('email');

        var action = component.get("c.makeSessionWith");
        action.setParams({"otherUsersEmail": email});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                var r = response.getReturnValue();

                var webUrl = r.webUrl;
                var userToken = r.token;
                var sessionId = r.sessionId;
                var name = encodeURIComponent(r.displayName);
                var username = encodeURIComponent(r.username);
                var gssToken = r.gssInfo.token;
                var gssUrl = r.gssInfo.serverWSURL;

                var url = webUrl + '/webCall?displayName=' + name + '&nameOrEmail=' + username + '&userToken=' + userToken + '&gssToken=' + gssToken + '&gssUrl=' + gssUrl;

                // create a new HLCall
                helper.createNewCall(component, helper, sObjectName, rId, email, null, sessionId, false, url);
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
        var sendToEmail = event.getParam("email");
        var phone = event.getParam("phone");
        var message = event.getParam("message");
        var contactName = contact && contact.Name || '';

        var action = component.get("c.sendOneTimeUseLink");
        action.setParams({"otherUsersName": contactName, "otherUsersEmail": sendToEmail, "otherUsersPhone": phone, message: message});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                console.log("successfully invited to personal room");

                // show notification to user when helpspace link is sent
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "message": "Invite sent successfully."
                });
                toastEvent.fire();

                var r = response.getReturnValue();
                var webUrl = r.webUrl;
                var userToken = r.token;
                var name = r.name;
                var email = sendToEmail;
                var username = r.username;
                var sessionId = r.sessionId;

                var url = webUrl + '/webCall?displayName=' + name + '&nameOrEmail=' + username + '&userToken=' + userToken + '&mode=autoAccept';

                // create a new HLCall
                helper.createNewCall(component, helper, sObjectName, rId, email, phone, sessionId, true, url);
            } else {
                console.log("HL::sendOneTimeUseLink response failed: " + state);
            }
        });

        $A.enqueueAction(action);
    },

    clickCreateOneTimeUseLink : function(component, event, helper) {
        var sObjectName = component.get("v.sObjectName");
        var rId = component.get("v.recordId");
        var action = component.get("c.createOneTimeUseLink");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                var r = response.getReturnValue();
                var link = r?.link;
                var auth = r?.auth;

                // copy the mhs link to the clipboard
                navigator.clipboard.writeText(link.longLink);

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "message": "Invite link copied to the clipboard."
                });
                toastEvent.fire();

                var webUrl = auth.webUrl;
                var userToken = auth.token;
                var name = auth.name;
                var username = auth.username;
                var sessionId = auth.sessionId;

                // we don't have an email or phone for the one time use link
                var email = '';
                var phone = '';

                var url = webUrl + '/webCall?displayName=' + name + '&nameOrEmail=' + username + '&userToken=' + userToken + '&mode=autoAccept';

                // create a new HLCall
                helper.createNewCall(component, helper, sObjectName, rId, email, phone, sessionId, true, url);
            } else {
                console.log("HL::createOneTimeUseLink response failed: " + state);
            }
        });

        $A.enqueueAction(action);
    }
})
