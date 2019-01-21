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
        var email = component.get('v.contactEmail');
        var phone = component.get('v.contactPhone') || '';
        var message = component.get('v.inviteMessage');

        event.setParam("email", email);
        event.setParam("phone", phone.replace(/\D+/g, ''));
        event.setParam("message", message);
        event.fire();
    },

    cancelInvite : function(component, event, helper) {
        component.set('v.showInviteForm', false);
        component.set('v.contactPhone', '');
        component.set('v.inviteMessage', '');
    }
})
