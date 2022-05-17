@isTest
public class ContactTriggerTest {
    @TestSetup
    static void makeData(){
        List<Contact> contactsToInsert = new List<Contact>{
            new Contact(
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId(),
                Donor_Type__c = 'Individual',
                lastName = 'testSetup individual 1',
                Email = 'testSetup1@mail.com',
                ID_Type__c = 'NRIC',
                ID_No__c = 'NRIC-testSetup1',
                Tax_Recipient_Full_Name__c = 'testSetup individual 1'
            ),
            new Contact(
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId(),
                Donor_Type__c = 'Individual',
                lastName = 'testSetup individual 2',
                Email = null,
                ID_Type__c = 'FIN',
                ID_No__c = 'FIN-testSetup2',
                Tax_Recipient_Full_Name__c = 'testSetup individual 2',
                isTaxRecipient__c = true
            ),
            new Contact(
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId(),
                Donor_Type__c = 'Individual',
                lastName = 'testSetup individual 3',
                Email = 'testSetup3@mail.com',
                ID_Type__c = null,
                ID_No__c = null,
                Tax_Recipient_Full_Name__c = null
            ),
            new Contact(
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId(),
                Donor_Type__c = 'Organisation',
                lastName = 'testSetup organisation 1',
                Email = 'testSetupOrganisation1@mail.com',
                Organisation_Name__c = 'Existing Organisation 1',
                Tax_Recipient_Id_Type_Org__c = 'UEN-Business',
                Tax_Recipient_ID_No_Org__c = 'UEN-testSetup1'
            )
        };

        Insert contactsToInsert;
    }

	@isTest
    public static void createAccount() {
        List<Account> testAccount = new List<Account>();
        testAccount.add(new Account(Name = 'test acc1'));
        testAccount.add(new Account(Name = 'test acc2'));
        
        insert testAccount;
        
        List<Contact> testContact = new List<Contact>();
    }
}