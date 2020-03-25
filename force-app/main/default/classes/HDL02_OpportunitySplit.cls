/**
 * Created by Aurélien Clerc on 31/07/2019.
 */

public class HDL02_OpportunitySplit implements ITrigger{

    Map<Id, List<OpportunitySplit>> oppSplitsDeletedByOpportunityId = new Map<Id, List<OpportunitySplit>>();
    Map<Id, List<OpportunitySplit>> oppSplitsByOpportunityId = new Map<Id, List<OpportunitySplit>>();
    Map<Id, Id> ownerIdByOpportunityId = new Map<Id, Id>();
    List<OpportunitySplit> oppSplitsToUpdate = new List<OpportunitySplit>();
    List<Decimal> allIdentifiants = new List<Decimal>();
    public static Decimal lastIdentifiant = 0;

    public void bulkBefore(){

        if(Trigger.isInsert && !Test.isRunningTest()){
            lastIdentifiant = [SELECT LastIdentifant__c FROM LastIdentifiantOpportunitySplit__c].LastIdentifant__c;
        }

        if(Trigger.isDelete){
            for(OpportunitySplit oppS : (List<OpportunitySplit>)Trigger.old){
                if(oppSplitsDeletedByOpportunityId.get(oppS.OpportunityId) == null){
                    oppSplitsDeletedByOpportunityId.put(oppS.OpportunityId, new List<OpportunitySplit>());
                    oppSplitsByOpportunityId.put(oppS.OpportunityId, new List<OpportunitySplit>());
                }
                else{
                    oppSplitsDeletedByOpportunityId.get(oppS.OpportunityId).add(oppS);
                }
            }

            for(Opportunity opp : [SELECT Id, OwnerId FROM Opportunity WHERE Id IN :oppSplitsDeletedByOpportunityId.keySet()]){
                ownerIdByOpportunityId.put(opp.Id, opp.OwnerId);
            }

            for(OpportunitySplit oppS : [SELECT Id, OpportunityId, SplitOwnerId FROM OpportunitySplit WHERE OpportunityId IN :oppSplitsDeletedByOpportunityId.keySet()]) {
                oppSplitsByOpportunityId.get(oppS.OpportunityId).add(oppS);
            }
        }
    }

    public void bulkAfter(){
    }


    public void beforeInsert(SObject so){
        OpportunitySplit newOppS = (OpportunitySplit) so;
        System.debug('beforeInsert');
        System.debug(so);
        System.debug(lastIdentifiant);

        lastIdentifiant = lastIdentifiant + 1;

        allIdentifiants.add(lastIdentifiant);

        newOppS.IdentifiantSplit__c = lastIdentifiant;

    }

    public void beforeUpdate(SObject oldSo, SObject so){
        OpportunitySplit oldOppS = (OpportunitySplit) oldSo;
        OpportunitySplit newOppS = (OpportunitySplit) so;
        System.debug('beforeUpdate');
        System.debug(so);
    }

    public void beforeDelete(SObject so){
        OpportunitySplit deletdOppS = (OpportunitySplit) so;
        System.debug('beforeDelete');
        System.debug(so);

        for(OpportunitySplit oppS : oppSplitsByOpportunityId.get(deletdOppS.OpportunityId)){
            if(oppS.SplitOwnerId == ownerIdByOpportunityId.get(oppS.OpportunityId)){
                oppS.IdentifiantSplit__c = deletdOppS.IdentifiantSplit__c;
                oppSplitsToUpdate.add(oppS);
            }
        }

    }

    public void beforeUndelete(SObject so){
    }


    public void afterInsert(SObject so){
        System.debug('afterInsert');
        System.debug(so);
    }

    public void afterUpdate(SObject oldSo, SObject so){
        System.debug('afterUpdate');
        System.debug(so);
    }

    public void afterDelete(SObject so){
        System.debug('afterDelete');
        System.debug(so);
    }

    public void afterUndelete(SObject so){
    }


    public void andFinally(){

        if(!oppSplitsToUpdate.isEmpty()){
            update oppSplitsToUpdate;
        }

        if(!allIdentifiants.isEmpty() && !Test.isRunningTest()){
            LastIdentifiantOpportunitySplit__c lIoS = LastIdentifiantOpportunitySplit__c.getOrgDefaults();
            System.debug(lIoS.LastIdentifant__c);
            lIoS.LastIdentifant__c = allIdentifiants[allIdentifiants.size() - 1];
            System.debug(lIoS.LastIdentifant__c);
            update lIoS;
        }
    }
}