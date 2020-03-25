({
    doInit: function(component, event, helper) {
        var opId = component.get("v.recordId");
        var pdfUrl = window.location.origin + '/apex/PDFGenerator?id='+opId+'&tour=&isdtp=p1';
        window.open(pdfUrl);
        setTimeout(function() {
            component.closeQuickAction();
        }, 3000);
    },
    handleClose : function(cmp, event) { 
        var wasDismissed = $A.get("e.force:closeQuickAction");
        wasDismissed.fire();       
    },
})