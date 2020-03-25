/**
 * Created by NDU1 on 06/06/2019.
 */
@IsTest
public with sharing class UserHandlerTest {
    @isTest
    public static void testConnaissances() {
        User u = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrateur Système'].Id,
                LastName = 'last',
                Email = 'puser000@amamama.com',
                Username = 'puser000@amamama.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'

        );
        insert u;
        u = [SELECT Id, IdUniqueUtilisateur__c FROM USER WHERE Id=:u.Id];
        System.debug(u.IdUniqueUtilisateur__c);
    }
}