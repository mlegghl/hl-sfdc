({
    doInit : function(component, event, helper) {
        // to prevent 2 way binding issues, set another attribute with the default phone and email if it exists
        var phone = component.get("v.defaultPhone");
        var email = component.get("v.defaultEmail");
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
        var event = component.getEvent('onInviteClick');
        var phone = component.get("v.contactPhone") || '';
        var email = component.get("v.contactEmail");
        var message = component.get('v.inviteMessage');

        if (email == '' && phone == '') {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "warning",
                "message": "Please enter a valid email or phone."
            });
            toastEvent.fire();
        } else {
            event.setParam("email", email);
            event.setParam("phone", phone.replace(/[^+\d]/g, ''));
            event.setParam("message", message);
            event.fire();
        }

        
    }
})
