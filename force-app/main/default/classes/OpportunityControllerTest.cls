@isTest
public class OpportunityControllerTest {
    @testSetup static void setup() {
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;
        
        List<Opportunity> opps = new List<Opportunity>();
        opps.add(new Opportunity (
            Name='Test Opportunity 1',
            StageName='Test Stage1',
            CloseDate=Date.today(),
            AccountId=testAcc.id
        ));
        opps.add(new Opportunity (
            Name='Test Opportunity 2',
            StageName='Test Stage1',
            CloseDate=Date.today(),
            AccountId=testAcc.id,
            Version_date_1__c=date.parse('10/12/2019')
        ));
        opps.add(new Opportunity (
            Name='Test Opportunity 3',
            StageName='Test Stage1',
            CloseDate=Date.today(),
            AccountId=testAcc.id,
            Version_date_1__c=date.parse('10/12/2019'),
            Version_date_2__c=date.parse('11/12/2019')
        ));
        opps.add(new Opportunity (
            Name='Test Opportunity 4',
            StageName='Test Stage1',
            CloseDate=Date.today(),
            AccountId=testAcc.id,
            Version_date_1__c=date.parse('10/12/2019'),
            Version_date_2__c=date.parse('11/12/2019'),
            Version_date_3__c=date.parse('12/12/2019')
        ));
        insert opps;
    }
    
    @isTest static void testUpdateVersionCreation() {
        
        OpportunityController c = new OpportunityController();
        
        OpportunityController.updateVersion([SELECT Id FROM Opportunity WHERE Name='Test Opportunity 1' LIMIT 1].Id);
        
        Opportunity o = [SELECT Id,Version_date_1__c,Version_date_2__c,Version_date_3__c FROM Opportunity WHERE Name='Test Opportunity 1' LIMIT 1];
        System.assertEquals(Date.today(), o.Version_date_1__c);
        System.assertEquals(null, o.Version_date_2__c);
        System.assertEquals(null, o.Version_date_3__c);
        
        // Try to update in same day
        OpportunityController.updateVersion([SELECT Id FROM Opportunity WHERE Name='Test Opportunity 1' LIMIT 1].Id);
        o = [SELECT Id,Version_date_1__c,Version_date_2__c,Version_date_3__c FROM Opportunity WHERE Name='Test Opportunity 1' LIMIT 1];
        System.assertEquals(Date.today(), o.Version_date_1__c);
        System.assertEquals(null, o.Version_date_2__c);
        System.assertEquals(null, o.Version_date_3__c);
    }
    
    @isTest static void testUpdateVersion1st() {
        
        OpportunityController.updateVersion([SELECT Id FROM Opportunity WHERE Name='Test Opportunity 2' LIMIT 1].Id);
        
        Opportunity o = [SELECT Id,Version_date_1__c,Version_date_2__c,Version_date_3__c FROM Opportunity WHERE Name='Test Opportunity 2' LIMIT 1];
        System.assertEquals(date.parse('10/12/2019'), o.Version_date_1__c);
        System.assertEquals(Date.today(), o.Version_date_2__c);
        System.assertEquals(null, o.Version_date_3__c);
        
        // Try to update in same day
        OpportunityController.updateVersion([SELECT Id FROM Opportunity WHERE Name='Test Opportunity 2' LIMIT 1].Id);
        o = [SELECT Id,Version_date_1__c,Version_date_2__c,Version_date_3__c FROM Opportunity WHERE Name='Test Opportunity 2' LIMIT 1];
        System.assertEquals(date.parse('10/12/2019'), o.Version_date_1__c);
        System.assertEquals(Date.today(), o.Version_date_2__c);
        System.assertEquals(null, o.Version_date_3__c);
    }
    
    @isTest static void testUpdateVersion2nd() {
        
        OpportunityController.updateVersion([SELECT Id FROM Opportunity WHERE Name='Test Opportunity 3' LIMIT 1].Id);
        
        Opportunity o = [SELECT Id,Version_date_1__c,Version_date_2__c,Version_date_3__c FROM Opportunity WHERE Name='Test Opportunity 3' LIMIT 1];
        System.assertEquals(date.parse('10/12/2019'), o.Version_date_1__c);
        System.assertEquals(date.parse('11/12/2019'), o.Version_date_2__c);
        System.assertEquals(Date.today(), o.Version_date_3__c);
        
        // Try to update in same day
        OpportunityController.updateVersion([SELECT Id FROM Opportunity WHERE Name='Test Opportunity 3' LIMIT 1].Id);
        o = [SELECT Id,Version_date_1__c,Version_date_2__c,Version_date_3__c FROM Opportunity WHERE Name='Test Opportunity 3' LIMIT 1];
        System.assertEquals(date.parse('10/12/2019'), o.Version_date_1__c);
        System.assertEquals(date.parse('11/12/2019'), o.Version_date_2__c);
        System.assertEquals(Date.today(), o.Version_date_3__c);
    }
    
    @isTest static void testUpdateVersionMore() {
        
        OpportunityController.updateVersion([SELECT Id FROM Opportunity WHERE Name='Test Opportunity 4' LIMIT 1].Id);
        
        Opportunity o = [SELECT Id,Version_date_1__c,Version_date_2__c,Version_date_3__c FROM Opportunity WHERE Name='Test Opportunity 4' LIMIT 1];
        System.assertEquals(date.parse('10/12/2019'), o.Version_date_1__c);
        System.assertEquals(date.parse('11/12/2019'), o.Version_date_2__c);
        System.assertEquals(Date.today(), o.Version_date_3__c);
        
        // Try to update in same day
        OpportunityController.updateVersion([SELECT Id FROM Opportunity WHERE Name='Test Opportunity 4' LIMIT 1].Id);
        o = [SELECT Id,Version_date_1__c,Version_date_2__c,Version_date_3__c FROM Opportunity WHERE Name='Test Opportunity 4' LIMIT 1];
        System.assertEquals(date.parse('10/12/2019'), o.Version_date_1__c);
        System.assertEquals(date.parse('11/12/2019'), o.Version_date_2__c);
        System.assertEquals(Date.today(), o.Version_date_3__c);
    }
}