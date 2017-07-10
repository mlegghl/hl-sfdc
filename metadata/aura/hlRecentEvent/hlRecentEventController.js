({
	doInit : function(component, event, helper) {
        console.log('hlRecentEventController::doInit');

		var item = component.get("v.item");

        // figure out the status
        if (item.helplightning__Complete__c) {
            if (item.helplightning__Successful__c) {
                component.set("v.status", "Completed");
            } else {
                component.set("v.status", "Not Answered");
            }
        } else {
            component.set("v.status", "In Progress");
        }
	}
})
