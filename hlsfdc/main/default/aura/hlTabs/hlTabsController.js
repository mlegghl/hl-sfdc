({
    handleOpenChat : function(component, event, helper) {
        // Forward the LWC event to the parent Aura component
        var workboxId = event.getParam('workboxId');
        var actionType = event.getParam('actionType');
        var auraEvent = component.getEvent('onOpenChatClick');
        auraEvent.setParam("workboxId", workboxId);
        auraEvent.setParam("actionType", actionType || null);
        auraEvent.fire();
    }
})
