@isTest
private class PDFGeneratorControllerTest {
    @testSetup static void setup() {
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;
        
        User[] users = new List<User>();
        users.add(new User(
            entite__c='LINKCITY',
            UO__c='LCCSO',
            Username='test1@bycntest.com', 
            LastName='Test 1 user', 
            Email='test1@bycntest.com', 
            Alias='Tes1', 
            TimeZoneSidKey='GMT', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            ProfileId=[SELECT Id FROM Profile LIMIT 1].Id, 
            LanguageLocaleKey='en_US'
        ));
        
        users.add(new User(
            Username='test2@bycntest.com', 
            LastName='Test 2 user', 
            Email='test2@bycntest.com', 
            Alias='Test2', 
            TimeZoneSidKey='GMT', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            ProfileId=[SELECT Id FROM Profile LIMIT 1].Id, 
            LanguageLocaleKey='en_US'
        ));

        insert users;
        
        List<Opportunity> opps = new List<Opportunity>();
        
        opps.add(new Opportunity (
            Name='Test Opportunity',
            StageName='Test Stage1',
            CloseDate=Date.today(),
            AccountId=testAcc.id,
            Street__c='Street',
            ZIPCode__c='00000',
            City__c='City',
            OwnerId=users.get(0).Id,
            CurrencyIsoCode='EUR',
            Amount=120000,
            CoutPrevisionnelDesEtudes__c=5000
        ));
        
        opps.add(new Opportunity (
            Name='Test Opportunity No ZipCode',
            StageName='Test Stage2',
            CloseDate=Date.today(),
            AccountId=testAcc.id,
            Street__c='Street',
            City__c='City',
            OwnerId=users.get(1).Id,
            CurrencyIsoCode='GBP'
        ));
        
        insert opps;
        
        Stakeholder__c[] stakeholderList = new List<Stakeholder__c>();
        
        stakeholderList.add(new Stakeholder__c(
            Opportunity__c=opps.get(0).Id,
            AccountMission__c='1'
        ));
        
        stakeholderList.add(new Stakeholder__c(
            Opportunity__c=opps.get(0).Id,
            AccountMission__c='25'
        ));
       
        for(Integer i=0; i<12; i++) {
            stakeholderList.add(new Stakeholder__c(
                Opportunity__c=opps.get(0).Id,
                AccountMission__c='105'
            ));
        }
        
        insert stakeholderList;
        
        // For Opportunity 1, something's ok
        List<Offre__c> offres = new List<Offre__c>();
        offres.add(new Offre__c(
        	DeliveredOfferDate__c=Date.parse('20/01/2020'),
            Opportunity__c=opps.get(0).Id
        ));
        offres.add(new Offre__c(
        	DeliveredOfferDate__c=Date.parse('22/01/2020'),
            Opportunity__c=opps.get(0).Id
        ));
        offres.add(new Offre__c(
        	DeliveredOfferDate__c=Date.parse('25/01/2020'),
            Opportunity__c=opps.get(0).Id
        ));
        
        // For Opportunity 2, out of index offres
        offres.add(new Offre__c(
        	DeliveredOfferDate__c=Date.today(),
            Opportunity__c=opps.get(1).Id
        ));
        offres.add(new Offre__c(
        	DeliveredOfferDate__c=Date.today(),
            Opportunity__c=opps.get(1).Id
        ));
        insert offres;
        
        DV_Flow_AP__PlacesAPI__c testGoogleApiKey = new DV_Flow_AP__PlacesAPI__c(DV_Flow_AP__key__c='test google api key');
        insert testGoogleApiKey;
    }
    static PDFGeneratorController getPDFGeneratorController(String oppName) {
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name=:oppName];
        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        return new PDFGeneratorController(sc);
    }
    static Attachment getCurrentMapId(String id) {
        Attachment att;
        List<Attachment> atts = [SELECT Id, Name, Body FROM Attachment WHERE Id=:id LIMIT 1];
        if(atts.size() > 0) {
           att = atts[0];
        }
        return att;
    }
    
    @isTest static void testConvertCurrencyFormatUnit_K() {
        System.assertEquals('2,00 K', PDFGeneratorController.convertCurrencyFormat(2000, 'K'));
    }
    @isTest static void testConvertCurrencyFormatUnit_M() {
        System.assertEquals('1,25 M', PDFGeneratorController.convertCurrencyFormat(1250000, 'M'));
    }
    @isTest static void testConvertCurrencyFormatUnit_empty() {
        System.assertEquals('2 000,00', PDFGeneratorController.convertCurrencyFormat(2000, null));
    }
    @isTest static void testConvertCurrencyFormatThreeArguments() {
        System.assertEquals('USD 2,00 K', PDFGeneratorController.convertCurrencyFormat(2000, 'K', 'USD'));
    }
    @isTest static void testConvertCurrencyFormatFourArguments() {
        System.assertEquals('2,00', PDFGeneratorController.convertCurrencyFormat(2000, 'K', 'USD', true));
    }
    @isTest static void testBuildProjectAddress() {
        String oppName = 'Test Opportunity';
        Opportunity o = PDFGeneratorController.getOppExtraFields([SELECT Id FROM Opportunity WHERE Name=:oppName]);
        
        String address1 = PDFGeneratorController.buildProjectAddress(o);
        system.assertEquals('Street, 00000 City, France', address1);
        
        // Test for empty zip code case
        o.ZIPCode__c = null;
        String address2 = PDFGeneratorController.buildProjectAddress(o);
        system.assertEquals('Street, City, France', address2);
    }
    
    @isTest static void testGetOffresDate() {
        String oppName = 'Test Opportunity';
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name=:oppName];
        List<Date> dates = PDFGeneratorController.getOffresDate(o.Id);
        System.assertEquals(3, dates.size(), 'getOffresDate length (maximum=3)');
        System.assertEquals(Date.parse('20/01/2020'), dates.get(0), 'date remise offre 1');
        System.assertEquals(Date.parse('22/01/2020'), dates.get(1), 'date remise offre 2');
        System.assertEquals(Date.parse('25/01/2020'), dates.get(2), 'date remise offre 3');
    }
    
    @isTest static void testStakeholderCases() {
        String oppName = 'Test Opportunity';
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name=:oppName];
        List<Stakeholder__c> allStakeholdes = PDFGeneratorController.getListStakeholder(o.Id);
        
        testGetListDeAMOAccount(PDFGeneratorController.getListDeAMOAccount(allStakeholdes));
        testGetListArchirecteAccount(PDFGeneratorController.getListArchirecteAccount(allStakeholdes));
        testGetListLesBetAccount(PDFGeneratorController.getListLesBetAccount(allStakeholdes));
        
    }
    
    @isTest static void testCoverageController() {
        PDFGeneratorController c = getPDFGeneratorController('Test Opportunity');
        testGetListDeAMOAccount(c.listDeAMO);
        testGetListArchirecteAccount(c.listArchitectes);
        testGetListLesBetAccount(c.listLesBet);
    }
    
    private static void testGetListDeAMOAccount(List<Stakeholder__c> stakeholders) {
        for(Stakeholder__c r : stakeholders) {
            if(r.AccountMission__c != null && r.AccountMission__c.isNumeric()) {
                Integer missionId = r.AccountMission__c != null ? integer.valueof(r.AccountMission__c) : 0;
                if(missionId < 1 || missionId > 10) {
                    System.assert(false, 'getListDeAMOAccount, AccountMission__c not between 1-10');
                }
            }
        }
    }
    
    private static void testGetListArchirecteAccount(List<Stakeholder__c> stakeholders) {
        for(Stakeholder__c r : stakeholders) {
            if(r.AccountMission__c != null && r.AccountMission__c.isNumeric()) {
                Integer missionId = r.AccountMission__c != null ? integer.valueof(r.AccountMission__c) : 0;
                if(missionId < 20 || missionId > 30) {
                    System.assert(false, 'listArchitectes, AccountMission__c not between 20-30');
                }
            }
        }
    }
    
    private static void testGetListLesBetAccount(List<Stakeholder__c> stakeholders) {
        if(stakeholders.size() > 10) {
            System.assert(false, 'getListLesBetAccount, the result limit 10 records');
        }
        for(Stakeholder__c r : stakeholders) {
            if(r.AccountMission__c != null && r.AccountMission__c.isNumeric()) {
                Integer missionId = r.AccountMission__c != null ? integer.valueof(r.AccountMission__c) : 0;
                if(missionId < 100 || missionId > 200) {
                    System.assert(false, 'getListLesBetAccount, AccountMission__c not between 100-200');
                }
            }
        }
    }

    
    @isTest static void testGetMap() {
        PDFGeneratorController c = getPDFGeneratorController('Test Opportunity');
        HttpMockFactory mock = new HttpMockFactory(200, 'OK', 'get map ok', new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mock);
        Attachment currentMap;
        
        Test.startTest();
        
        c.initAction();
        currentMap = getCurrentMapId(c.mapImageId);
        
        Test.stopTest();
        system.assertEquals(Blob.valueOf('get map ok'), currentMap.Body);
    }
    
    // Map image non cached
    @isTest static void testGetMapNonCached() {
        PDFGeneratorController c = getPDFGeneratorController('Test Opportunity No ZipCode');
        HttpMockFactory mock = new HttpMockFactory(200, 'OK', 'get map ok', new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mock);
        Attachment currentMap;
        Test.startTest();
        
        c.initAction();
        currentMap = getCurrentMapId(c.mapImageId);
        
        Test.stopTest();
        system.assertEquals(Blob.valueOf('get map ok'), currentMap.Body);
    }
    
    // Map image is cached
    @isTest static void testGetMapCached() {
        PDFGeneratorController c = getPDFGeneratorController('Test Opportunity');
        HttpMockFactory mock = new HttpMockFactory(200, 'OK', 'get map ok', new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mock);
        Attachment currentMap;
        
        // Add Cached map for the Opportunity
        String location = EncodingUtil.urlEncode(c.projectAddress, 'UTF-8');
        String mapFileName = 'GOOGLE_STATIC_MAP__' + location + '.png';
        Attachment d = new Attachment();
        d.name = mapFileName;
        d.body = Blob.valueof('test image');
        d.parentId = c.opportunity.Id;
        insert d;

        Test.startTest();
        
        c.initAction();
        currentMap = getCurrentMapId(c.mapImageId);
        
        Test.stopTest();
        
        system.assertEquals(Blob.valueOf('test image'), currentMap.Body); 
    }
    
    // For the address of the project was changed
    @isTest static void testGetMapOldAddress() {
        PDFGeneratorController c = getPDFGeneratorController('Test Opportunity');
        HttpMockFactory mock = new HttpMockFactory(200, 'OK', 'get map ok', new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mock);
        
        Attachment currentMap;
        
        Attachment d = new Attachment();
        d.name = 'new name';
        d.body = Blob.valueof('test image');
        d.parentId = c.opportunity.Id;
        insert d;
        
        Test.startTest();
        
        c.initAction();
        currentMap = getCurrentMapId(c.mapImageId);
        
        Test.stopTest();
        
        system.assertEquals(Blob.valueOf('get map ok'), currentMap.Body); 
    }
}