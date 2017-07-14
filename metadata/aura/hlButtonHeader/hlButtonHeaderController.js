({
    clickCall : function(component, event, helper) {
        console.log("hlButtonHeaderController::clickCall");

        // call the parent handler
        var event = component.getEvent('onCallClick');
        event.fire();
    },

    clickInviteToPersonalRoom : function(component, event, helper) {
        console.log("hlButtonHeaderController::clickInviteToPersonalRoom");

        // call the parent handler
        var event = component.getEvent('onInviteClick');
        event.fire();
    }
})
