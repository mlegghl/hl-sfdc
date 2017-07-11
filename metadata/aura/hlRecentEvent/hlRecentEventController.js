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

        // figure out the duration
        if (item.helplightning__Complete__c) {
            if (item.helplightning__Duration__c > 60 * 60) {
                // hours
                var hours = Math.floor(item.helplightning__Duration__c / 60 / 60);
                var minutes = Math.floor((item.helplightning__Duration__c / 60) - (hours * 60));
                var seconds = item.helplightning__Duration__c - (hours * 60 * 60) - (minutes * 60);

                component.set("v.duration", hours + 'h' + minutes + 'm' + seconds + 's');
            } else if (item.helplightning__Duration__c > 60) {
                var minutes = Math.floor(item.helplightning__Duration__c / 60);
                var seconds = item.helplightning__Duration__c - (minutes * 60);

                component.set("v.duration", minutes + 'm' + seconds + 's');
            } else {
                component.set("v.duration", item.helplightning__Duration__c + 's');
            }
        } else {
            /* not complete yet */
            component.set("v.duration", "");
        }
	}
})
