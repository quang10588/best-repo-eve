/**
 * Created by Aurélien Clerc on 07/06/2019.
 */

@IsTest
private class LTNG01_AllOpportunitiesByAccount_TEST {

    @IsTest
    static void allOpportunitiesByAccount_TEST() {
        Account acc = TestUtilities.initiateAccount();
        insert acc;

        Opportunity opp = TestUtilities.initiateOpportunity(acc.Id);
        insert opp;

        Test.startTest();

        LTNG01_AllOpportunitiesByAccount.AccountWrapper accW = LTNG01_AllOpportunitiesByAccount.getAllOpporutnitiesByAccount_APEX(acc.Id);
        System.assertEquals(accW.allOpportunitiesWrapper.size(), 1);

        Test.stopTest();
    }
}