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
        event.setParam("email", component.get('v.contactEmail'));
        event.setParam("phone", component.get('v.contactPhone').replace(/\D+/g, ''))
        event.setParam("message", component.get('v.inviteMessage'));
        event.fire();
    },

    cancelInvite : function(component, event, helper) {
        component.set('v.showInviteForm', false);
        component.set('v.contactPhone', '');
        component.set('v.inviteMessage', '');
    }
})
