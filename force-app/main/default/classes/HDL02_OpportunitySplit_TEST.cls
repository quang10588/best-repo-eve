/**
 * Created by Aurélien Clerc on 08/08/2019.
 */

@IsTest
private class HDL02_OpportunitySplit_TEST {

    @IsTest
    static void identifiantAffectation_TEST() {

        Test.startTest();

        Account acc = TestUtilities.initiateAccount();
        insert acc;

        Opportunity opp = TestUtilities.initiateOpportunity(acc.Id);
        insert opp;

        User u = TestUtilities.initiateUser();
        insert u;

        System.debug(u.Id);
        System.debug(UserInfo.getUserId());

        opp.OwnerId = u.Id;
        update opp;

        OpportunitySplit oppS = [SELECT Id, IdentifiantSplit__c FROM OpportunitySplit WHERE OpportunityId =: opp.Id LIMIT 1];
        System.assertEquals(oppS.IdentifiantSplit__c, 1);

        Test.stopTest();
    }

}