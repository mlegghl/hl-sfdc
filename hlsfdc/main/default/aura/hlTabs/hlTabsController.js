({
    doInit : function(component, event, helper) {
        // to prevent 2 way binding issues, set another attribute with the default phone number if it exists
        var phone = component.get("v.defaultPhone");
        component.set("v.contactPhone", phone);
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
        var email = component.find('contactEmail').get('v.value');
        var phone = component.find('contactPhone').get('v.value') || '';
        var message = component.get('v.inviteMessage');

        event.setParam("email", email);
        event.setParam("phone", phone.replace(/[^+\d]/g, ''));
        event.setParam("message", message);
        event.fire();
    }
})
