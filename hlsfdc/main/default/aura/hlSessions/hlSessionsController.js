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

                // create a new HLCall
                helper.createNewCall(component, helper, sObjectName, rId,
                                     email, sessionId);

                var url = 'https://app-dev.helplightning.net/webCall?displayName=' + name + '&nameOrEmail=&userToken=' + userToken + '&gssToken=' + gssToken + '&gssUrl=' + gssUrl;

                // open a new window with this url
                window.open(url, 'webcall', 'toolbar=0,status=0,width=1500,height=900')

            } else {
                console.log("HL::makeSessionWith response failed: " + state);
            }
        });
        $A.enqueueAction(action);
    },

    clickInviteToPersonalRoom : function(component, event, helper) {
        var sObjectName = component.get("v.sObjectName");
        var rId = component.get("v.recordId");

        var contact = component.get("v.contact");
        var email = contact.Email;
        var contactName = contact.Name;

        var action = component.get("c.inviteToPersonalRoom");
        action.setParams({"otherUsersName": contactName, "otherUsersEmail": email});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                console.log("successfully invited to personal room");
                var r = response.getReturnValue();

                var userToken = r.token;
                var sessionId = r.sessionId;
                var name = encodeURIComponent(r.displayName);
                var gssToken = r.gssInfo.token;
                var gssUrl = r.gssInfo.serverWSURL;

                // create a new HLCall
                helper.createNewCall(component, helper, sObjectName, rId,
                                     email, sessionId);

                var url = 'https://app-dev.helplightning.net/webCall?displayName=' + name + '&nameOrEmail=&userToken=' + userToken + '&gssToken=' + gssToken + '&gssUrl=' + gssUrl;

                // open a new window with this url
                window.open(url, 'webcall', 'toolbar=0,status=0,width=1500,height=900')
            } else {
                console.log("HL::inviteToPersonalRoom response failed: " + state);
            }
        });

        $A.enqueueAction(action);
    }
})
