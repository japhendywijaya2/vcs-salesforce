@isTest
public with sharing class DonationsTriggerTest {
    @isTest
    public static void DonationsTriggerTest() {
        Contact newContact = new Contact(
            lastName = 'Test contact',
            Email = 'test@mail.com',
            Donor_Type__c = 'Individual'
        );

        Database.SaveResult saveResult  = Database.insert(newContact);
        System.assertEquals(true, saveResult.isSuccess());
    }
}