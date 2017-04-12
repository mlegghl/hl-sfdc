({
    doInit : function(component, event, helper) {
	console.log("doInit");  
        
//        var action = component.get("c.getAuthInfo");        
//        action.setCallback(this, function(response) {
//            var state = response.getState();
//            if (component.isValid() && state == "SUCCESS") {
//                console.log("response is now " + response.getReturnValue());
//                component.set("v.authInfo", response.getReturnValue());
//            } else {
//                console.log("response failed: " + state);
//            }
//        });
                          	
//        $A.enqueueAction(action);
    },
    
    recordUpdatedEvt : function(component, event, helper) {
        console.log("recordUpdatedEvt");
        
        //var r = component.get("v.record");
        //console.log(r);
    },
    
    clickCall : function(component, event, helper) {
        console.log("clickCall");
        
        var r = component.get("v.record");
        var email = r.ContactEmail;
        console.log("email " + email);
        
        var action = component.get("c.makeSessionWith");
        action.setParams({"otherUsersEmail": email});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                console.log("response is " + response.getReturnValue());
            } else {
                console.log("response failed: " + state);
            }
        });
                          	
        $A.enqueueAction(action);
    }
})
