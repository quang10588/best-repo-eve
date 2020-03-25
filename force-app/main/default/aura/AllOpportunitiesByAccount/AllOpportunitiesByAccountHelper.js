/**
 * Created by Aurélien Clerc on 06/06/2019.
 */
({
    doInit : function(cmp){
        var action = cmp.get('c.getAllOpporutnitiesByAccount_APEX');
        var recordId = cmp.get('v.recordId');

        action.setParams({recordId : recordId});

        action.setCallback(this, function(response){
           var state = response.getState();

           if (cmp.isValid() && state === 'SUCCESS'){
               var result = response.getReturnValue();

               cmp.set('v.data', result.allOpportunitiesWrapper);
               cmp.set('v._isInit', true);

               console.log(cmp.get('v.data'));

           }
           else {
               console.log(response.getError());
           }
       });
       $A.enqueueAction(action);
    }
})