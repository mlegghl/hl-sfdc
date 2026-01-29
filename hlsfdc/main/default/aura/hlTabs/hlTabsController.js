({
    doInit : function(component, event, helper) {
        // to prevent 2 way binding issues, set another attribute with the default values if they exist
        var name = component.get("v.defaultName");
        var phone = component.get("v.defaultPhone");
        var email = component.get("v.defaultEmail");
        component.set("v.contactName", name);
        component.set("v.contactPhone", phone);
        component.set("v.contactEmail", email);
    },
    clickCall : function(component, event, helper) {
        // get contact email from contacts call handler
        const contactEmail = event.getParam('email')

        // call the parent handler
        var e = component.getEvent('onCallClick');
        e.setParam("email", contactEmail);
        e.fire();
    },

    sendInvite : function(component, event, helper) {
        // call the parent handler
        var inviteEvent = component.getEvent('onInviteClick');
        var name = component.get("v.contactName") || '';
        var phone = component.get("v.contactPhone") || '';
        var email = component.get("v.contactEmail") || '';
        var message = component.get('v.inviteMessage');

        if (email == '' && phone == '') {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "warning",
                "message": "Please enter a valid email or phone."
            });
            toastEvent.fire();
        } else {
            inviteEvent.setParam("name", name.trim());
            inviteEvent.setParam("email", email);
            inviteEvent.setParam("phone", phone.replace(/[^+\d]/g, ''));
            inviteEvent.setParam("message", message);
            inviteEvent.fire();
        }
    },

    copyLink : function(component, event, helper) {
        // call the parent handler
        var event = component.getEvent('onCopyLinkClick');
        event.fire();
    },

    handleOpenChat : function(component, event, helper) {
        // Forward the LWC event to the parent Aura component
        var workboxId = event.getParam('workboxId');
        var auraEvent = component.getEvent('onOpenChatClick');
        auraEvent.setParam("workboxId", workboxId);
        auraEvent.fire();
    }
})
