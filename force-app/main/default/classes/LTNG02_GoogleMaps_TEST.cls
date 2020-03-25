/**
 * Created by Aurélien Clerc on 19/07/2019.
 */

@IsTest
private class LTNG02_GoogleMaps_TEST {

    @IsTest
    static void getAddress_TEST() {
        Account acc = TestUtilities.initiateAccount();
        insert acc;

        Opportunity opp = TestUtilities.initiateOpportunity(acc.Id);
        insert opp;

        Test.startTest();

        LTNG02_GoogleMaps.GoogleMapWrapper gooW = LTNG02_GoogleMaps.getAddress_APEX(opp.Id);

        Test.stopTest();
    }

}