({
    doInit: function() {
        window.open('https://bycn--dev--c.visualforce.com/apex/PDFGenerator?id=0069E00000ESCZpQAP&tour=&isdtp=p1');
    },
    close: function() {
        $A.get("e.force:closeQuickAction").fire();
    },
    set: function(component, event, helper) {
        var action = component.get("c.updateVersion");
        action.setParams({
            opportunityId: component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }
        });
        console.log(component.get("v.recordId"));
        $A.enqueueAction(action);
    }
})