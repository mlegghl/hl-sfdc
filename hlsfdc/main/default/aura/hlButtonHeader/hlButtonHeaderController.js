({
    clickCall : function(component, event, helper) {
        // call the parent handler
        var event = component.getEvent('onCallClick');
        event.fire();
    },

    toggleInviteForm : function(component, event, helper) {
        component.set('v.showInviteForm', !component.get('v.showInviteForm'))
    },

    clickEmailOneTimeUseLink : function(component, event, helper) {
        // call the parent handler
        var event = component.getEvent('onInviteClick');
        event.setParam("email", component.get('v.contactEmail'));
        event.setParam("phone", "")
        event.setParam("message", component.get('v.inviteMessage'));
        event.fire();
    },

    clickTextOneTimeUseLink : function(component, event, helper) {
        // call the parent handler
        var event = component.getEvent('onInviteClick');
        event.setParam("email", "");
        event.setParam("phone", component.get('v.contactPhone').replace(/\D+/g, ''))
        event.setParam("message", component.get('v.inviteMessage'));
        event.fire();
    }
})
