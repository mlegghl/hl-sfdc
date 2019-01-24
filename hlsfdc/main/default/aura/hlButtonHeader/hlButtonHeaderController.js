({
    clickCall : function(component, event, helper) {
        // call the parent handler
        var event = component.getEvent('onCallClick');
        event.fire();
    },

    toggleInviteForm : function(component, event, helper) {
        component.set('v.showInviteForm', !component.get('v.showInviteForm'));
    },

    sendInvite : function(component, event, helper) {
        // call the parent handler
        var event = component.getEvent('onInviteClick');
        var email = component.find('contactEmail').get('v.value');
        var phone = component.find('contactPhone').get('v.value');
        var message = component.get('v.inviteMessage');

        event.setParam("email", email);
        event.setParam("phone", phone.replace(/[^+\d]/g, ''));
        event.setParam("message", message);
        event.fire();
    },

    cancelInvite : function(component, event, helper) {
        component.set('v.showInviteForm', false);
        component.set('v.contactPhone', '');
        component.set('v.inviteMessage', '');
    }
})
