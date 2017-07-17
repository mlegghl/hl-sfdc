({
    clickCall : function(component, event, helper) {
        // call the parent handler
        var event = component.getEvent('onCallClick');
        event.fire();
    },

    clickInviteToPersonalRoom : function(component, event, helper) {
        // call the parent handler
        var event = component.getEvent('onInviteClick');
        event.fire();
    }
})
