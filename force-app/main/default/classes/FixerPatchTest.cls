@isTest
public with sharing class FixerPatchTest {
    @testSetup
    static void makeData(){
        List<Donations__c> donationToInsertList = new List<Donations__c>{
            new Donations__c(
                RecordTypeId = Schema.SObjectType.Donations__c.getRecordTypeInfosByName().get('Cash').getRecordTypeId(),
                Donor_Type__c = 'Individual',
                Donation_Status__c = 'Cleared',
                Donation_Date__c = System.today(),
                Donation_Datetime__c = System.now(),
                Cleared_Datetime__c = System.now(),
                Full_Name_Entered__c = 'Test 1',
                Email_Entered__c = 'test1@mail.com',
                Donation_Amount__c = 100,
                Payment_Method__c = 'Credit Card'
            )
        };

        insert donationToInsertList;
    }


    @isTest
    public static void fixDuplicateTaxReceiptNoTest(){
        FixerPatch.fixDuplicateTaxReceiptNo();
    }
}