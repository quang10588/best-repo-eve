/**
 * Created by Aurélien Clerc on 19/07/2019.
 */

public with sharing class LTNG02_GoogleMaps {

    @AuraEnabled
    public static GoogleMapWrapper getAddress_APEX(String recordId){

        Id sObjectId = recordId;

        String sObjectName = sObjectId.getSobjectType().getDescribe().getName();

        SObject so = Database.query('SELECT Id, Street__c, City__c, toLabel(Country__c), Adresse_CP__c FROM ' + sObjectName + ' WHERE Id = \'' + sObjectId + '\'');

        return new GoogleMapWrapper(so);

    }

    public class GoogleMapWrapper{
        @AuraEnabled public String street;
        @AuraEnabled public String city;
        @AuraEnabled public String cp;
        @AuraEnabled public String country;
        @AuraEnabled public Integer zoomLevel;
        @AuraEnabled public Boolean showFooter;

        public GoogleMapWrapper(SObject so){
            this.street     = (String)so.get('Street__c');
            this.city       = (String)so.get('City__c');
            this.country    = (String)so.get('Country__c');
            this.cp         = (String)so.get('Adresse_CP__c');
            this.zoomLevel  = 16;
            this.showFooter = true;
        }
    }

}