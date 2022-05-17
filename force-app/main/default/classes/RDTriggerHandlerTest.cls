@isTest
public class RDTriggerHandlerTest {
    //@isTest
    // scenario
    // creating Contact
    // then create RD with that Contact
    // then create a donation tagged to the contact and RD so the RDTriggerHandler will be able to create next donation record
    @isTest
    public static void rd(){
        Contact contactToInsert = new Contact(
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId(),
            Donor_Type__c = 'Individual',
            lastName = 'testSetup individual 1',
            Email = 'testSetup1@mail.com',
            ID_Type__c = 'NRIC',
            ID_No__c = 'NRIC-testSetup1',
            Tax_Recipient_Full_Name__c = 'testSetup individual 1'
        );
        Insert contactToInsert;

        Recurring_Donation__c rdToInsert = new Recurring_Donation__c(
            Donor_Name__c = contactToInsert.id,
            Amount__c = 100,
            Start_Date__c = System.today(),
            Payment_Method__c = 'Credit Card',
            Frequency__c = 'Monthly',
            RD_Status__c = 'Pending',
            Tax_Deductible__c = true,
            Tax_Recipient_Individual__c = contactToInsert.id
        );
        Insert rdToInsert;

        Donations__c donationToInsert = new Donations__c(
            RecordTypeId = Schema.SObjectType.Donations__c.getRecordTypeInfosByName().get('Cash').getRecordTypeId(),
            Donor_Type__c = 'Individual',
            Donation_Status__c = 'Cleared',
            Donation_Date__c = System.today(),
            Donation_Datetime__c = System.now(),
            Cleared_Datetime__c = System.now(),
            Frequency_Type__c = 'Recurring',
            Recurring_Donation__c = rdToInsert.id,
            Donor_Name__c = contactToInsert.id,
            Tax_Recipient_Individual__c = contactToInsert.id,
            Tax_Deductible__c = true,
            Donation_Amount__c = 100,
            Payment_Method__c = 'Credit Card'
        );
        Insert donationToInsert;

    }

    @isTest
    public static void runTest4(){
        RDTriggerHandler.getNextDeductionDate(Date.today(), 'Monthly', false);
        RDTriggerHandler.getNextDeductionDate(Date.today(), 'Weekly', false);
        RDTriggerHandler.getNextDeductionDate(Date.today(), 'Bi weekly', false);
        RDTriggerHandler.getNextDeductionDate(Date.today(), 'Bi monthly', false);
        RDTriggerHandler.getNextDeductionDate(Date.today(), 'Quarterly', false);
        RDTriggerHandler.getNextDeductionDate(Date.today(), 'Half Yearly', false);
        RDTriggerHandler.getNextDeductionDate(Date.today(), 'Yearly', false);
        RDTriggerHandler.getNextDeductionDate(Date.today(), 'Negative', false);
        RDTriggerHandler.getNextDeductionDate(Date.newInstance(2022, 1, 16), 'Weekly', true);
    }
}