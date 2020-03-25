/**
 * Created by Aurélien Clerc on 06/06/2019.
 */

public without sharing class LTNG01_AllOpportunitiesByAccount {

    @AuraEnabled
    public static AccountWrapper getAllOpporutnitiesByAccount_APEX(String recordId){

        List<Opportunity> allOpportunities = [SELECT Id, Name, Owner.Name, OwnerId, StageName, CloseDate, Operation__c, Operation__r.Name, toLabel(Prestation__c) FROM Opportunity WHERE AccountId =: recordId];

        return new AccountWrapper(allOpportunities);
    }

    public class AccountWrapper{
        @AuraEnabled public List<OpportunityWrapper> allOpportunitiesWrapper;

        public AccountWrapper(List<Opportunity> allOpportunities){

            this.allOpportunitiesWrapper = new List<OpportunityWrapper>();

            for(Opportunity opp : allOpportunities){
                this.allOpportunitiesWrapper.add(new OpportunityWrapper(opp));
            }
        }
    }

    public class OpportunityWrapper{
        @AuraEnabled public Opportunity opp;
        @AuraEnabled public String Name;
        @AuraEnabled public String prestationName;
        @AuraEnabled public String ownerLink;
        @AuraEnabled public String ownerName;
        @AuraEnabled public String StageName;
        @AuraEnabled public Date CloseDate;
        @AuraEnabled public String operationLink;
        @AuraEnabled public String operationName;


        public OpportunityWrapper(Opportunity opp){
            this.opp = opp;
            this.Name = opp.Name;
            this.ownerLink = opp.OwnerId != null ? '/' + opp.OwnerId : '';
            this.StageName = opp.StageName;
            this.CloseDate = opp.CloseDate;
            this.operationLink = opp.Operation__c != null ? '/' + opp.Operation__c : '';
            this.operationName = opp.Operation__r.Name;
            this.prestationName = opp.Prestation__c;
            this.ownerName = opp.Owner.Name;
        }
    }

}