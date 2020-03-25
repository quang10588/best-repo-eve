/**
 * Created by Aurélien Clerc on 06/06/2019.
 */
({
    doInit : function(cmp, event, helper){
        helper.doInit(cmp);
    },

    toggleSection : function(cmp, event, helper){
        var isOpen = cmp.get('v._isOpen');
        cmp.set('v._isOpen', isOpen == true ? false : true);
    }
})