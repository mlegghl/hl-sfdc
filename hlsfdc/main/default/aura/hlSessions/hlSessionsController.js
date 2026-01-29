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

            // Initialize workbox for this record (create if doesn't exist)
            helper.initWorkbox(component, helper, sObjectName, rId);

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
    },

    doDestroy : function(component, event, helper) {
        // stop our timer if it is still running.
        var timer = component.get("v.pollTimer");
        if (timer) {
            window.clearInterval(timer);
        }

        // Do any cleanup. This would normally have been removed, but
        //  if the user navigated away, while a Help Lightning call
        //  was in progress, this may linger.
        helper.removeMessageHandler(component);
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
            var r = response.getReturnValue();
            if (component.isValid() && state == "SUCCESS" && r) {
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
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "message": "Failed to create a call."
                });
                toastEvent.fire();
                console.log("HL::makeSessionWith response failed: " + state);
            }
        });
        $A.enqueueAction(action);
    },

    clickSendOneTimeUseLink : function(component, event, helper) {
        var sObjectName = component.get("v.sObjectName");
        var rId = component.get("v.recordId");

        var guestName = event.getParam("name");
        var sendToEmail = event.getParam("email");
        var phone = event.getParam("phone");
        var message = event.getParam("message");

        var action = component.get("c.sendOneTimeUseLink");
        action.setParams({
            "otherUsersName": guestName,
            "otherUsersEmail": sendToEmail,
            "otherUsersPhone": phone,
            "message": message,
            "sObjectName": sObjectName,
            "recordId": rId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var r = response.getReturnValue();
            if (component.isValid() && state == "SUCCESS" && r) {
                console.log("successfully created help thread invite");

                // show notification to user when help thread invite is sent
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "message": "Invite sent successfully."
                });
                toastEvent.fire();

                var webUrl = r.webUrl;
                var userToken = r.token;
                var workboxId = r.workboxId;
                var email = sendToEmail;

                // Build the help thread external URL with workbox id from response
                var url = webUrl + '/help-thread-external'
                  + '?userToken=' + encodeURIComponent(userToken)
                  + '&workboxId=' + encodeURIComponent(workboxId)
                  + '&action=join_session';

                // create a new HLCall using workboxId as the sessionId
                helper.createNewCall(component, helper, sObjectName, rId, email, phone, String(workboxId), true, url);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "message": "Failed to send invite."
                });
                toastEvent.fire();
                console.log("HL::sendOneTimeUseLink response failed: " + state);
            }
        });

        $A.enqueueAction(action);
    },

    clickCreateOneTimeUseLink : function(component, event, helper) {
        var sObjectName = component.get("v.sObjectName");
        var rId = component.get("v.recordId");
        var action = component.get("c.createOneTimeUseLink");
        action.setParams({
            "sObjectName": sObjectName,
            "recordId": rId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var r = response.getReturnValue();
            console.log("HL::createOneTimeUseLink response state:", state);
            console.log("HL::createOneTimeUseLink response:", JSON.stringify(r));
            if (component.isValid() && state == "SUCCESS" && r) {
                var link = r.link;
                var webUrl = r.webUrl;
                var userToken = r.token;
                var workboxId = r.workboxId;
                console.log("HL::createOneTimeUseLink - link:", link, "webUrl:", webUrl, "workboxId:", workboxId);

                // Copy the link to the clipboard
                // NOTE: navigator.clipboard is not available in Lightning Locker, but works with orgs that have Lightning Web Security enabled.
                // LWS is enabled by default in new orgs (winter 2023+), but can be disabled in existing orgs. The recommended approach is to enable LWS.
                // If LWS is disabled, we will fallback to using execCommand to copy the link to the clipboard. (SFDC-114)
                if (navigator.clipboard && navigator.clipboard.writeText) {
                    navigator.clipboard.writeText(link).then(function() {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "success",
                            "message": "Invite link copied to the clipboard."
                        });
                        toastEvent.fire();
                    }).catch(function() {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "error",
                            "message": "Failed to copy invite link to clipboard."
                        });
                        toastEvent.fire();
                    });
                } else {
                    // Fallback: try deprecated execCommand (for Lightning Locker)
                    try {
                        var textArea = document.createElement("textarea");
                        textArea.value = link;
                        textArea.style.cssText = 'position:absolute;left:-9999px;opacity:0;';
                        textArea.setAttribute('readonly', '');
                        document.body.appendChild(textArea);
                        textArea.select();
                        var successful = document.execCommand('copy');
                        document.body.removeChild(textArea);
                        
                        if (successful) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type": "success",
                                "message": "Invite link copied to the clipboard."
                            });
                            toastEvent.fire();
                        } else {
                            throw new Error('execCommand failed');
                        }
                    } catch (err) {
                        // If all else fails, show the link to the user in a toast
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "info",
                            "message": "Invite link created: " + link
                        });
                        toastEvent.fire();
                    }
                }

                // we don't have an email or phone for the one time use link
                var email = '';
                var phone = '';

                // Build the help thread external URL with workbox id from response
                var url = webUrl + '/help-thread-external'
                  + '?userToken=' + encodeURIComponent(userToken)
                  + '&workboxId=' + encodeURIComponent(workboxId)
                  + '&action=join_session';

                // create a new HLCall using workboxId as the sessionId
                helper.createNewCall(component, helper, sObjectName, rId, email, phone, String(workboxId), true, url);
            } else {
                var errors = response.getError();
                var errorMessage = "Failed to create invite link.";
                if (errors && errors[0] && errors[0].message) {
                    errorMessage = errors[0].message;
                }
                console.error("HL::createOneTimeUseLink response failed - state:", state);
                console.error("HL::createOneTimeUseLink errors:", JSON.stringify(errors));
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "message": errorMessage
                });
                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);
    },

    clickOpenChat : function(component, event, helper) {
        var sObjectName = component.get("v.sObjectName");
        var rId = component.get("v.recordId");
        
        console.log("HL::clickOpenChat - sObjectName:", sObjectName, "recordId:", rId);
        
        // Get the info needed to open the chat (user token, workbox ID, web URL)
        var action = component.get("c.getOpenChatInfo");
        action.setParams({
            "sObjectName": sObjectName,
            "recordId": rId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var r = response.getReturnValue();
            console.log("HL::clickOpenChat response:", JSON.stringify(r));
            
            if (component.isValid() && state == "SUCCESS" && r) {
                var userToken = r.userToken;
                var workboxId = r.workboxId;
                var webUrl = r.webUrl;
                
                // Build URL without action parameter (just opens chat, no call)
                var url = webUrl + '/help-thread-external'
                  + '?userToken=' + encodeURIComponent(userToken)
                  + '&workboxId=' + encodeURIComponent(workboxId);
                
                console.log("HL::clickOpenChat opening URL:", url);
                
                // Open in new window
                var callWindow = window.open(url, "hlPopupWindow", "width=800,height=600");
                if (callWindow) {
                    component.set("v.callWindow", callWindow);
                    window.addEventListener("message", component.get("v.eventHandler"));
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "message": "Failed to open chat window. Please allow popups for this site."
                    });
                    toastEvent.fire();
                }
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "message": "Failed to get Help Thread details."
                });
                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);
    }
})
