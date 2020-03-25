/**
 * Created by Aurélien Clerc on 19/07/2019.
 */
({

    doInit : function(cmp){
        var action = cmp.get('c.getAddress_APEX');
        var recordId = cmp.get('v.recordId');
        cmp.set('v.isDisplay', false);

        console.log('Helper DoInit');

        console.log(recordId);

        action.setParams({recordId : recordId});

        action.setCallback(this, function(response){
           var state = response.getState();

           if (cmp.isValid() && state === 'SUCCESS'){
               var result = response.getReturnValue();
                console.log(result);
               cmp.set('v.mapMarkers', [{
                   location: {
                       Street: result.street,
                       City: result.city,
                       Country: result.country
                   },
                   title : result.street,
                   description : result.cp + ' ' + result.city + ' ' + result.country
               }]);
               cmp.set('v.zoomLevel', result.zoomLevel);
               cmp.set('v.showFooter', result.showFooter);
           }
           else {
               console.log(response.getError());
           }

           setTimeout($A.getCallback(function(){ cmp.set('v.isDisplay', true);}), 1000);
       });
       $A.enqueueAction(action);
    },

     initialize : function(cmp){



        var mapOptions = {
          zoom: 8,
          center: new google.maps.LatLng(-34.397, 150.644)
        };

        cmp.set('v.map', new google.maps.Map(document.getElementById('map-canvas'), mapOptions));

        console.log(cmp.get('v.map'));

    }

})