@isTest
public with sharing class DonationsTriggerHandlerTest {
    @testSetup
    static void makeData(){
        Account anonAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId(),
            Name = 'Anonymous'
        );
        Database.insert(anonAccount);


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
        Database.insert(contactsToInsert);

        Programme_Events__c programmeTest = new Programme_Events__c(
            Name = 'Test Programme',
            Start_Date_Time__c = System.today(),
            End_Date_Time__c = Date.today().addDays(7),
            Event_Attire__c = 'Casual',
            Programme_Description__c = 'Testing'
        );

        Database.insert(programmeTest);


    }

    @isTest
    // Scenario :
    // create a donation with new contact detail
    public static void createDonation1(){
        Donations__c donationsToInsert = new Donations__c(
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
        );

        Insert donationsToInsert;
        
        donationsToInsert = [
            SELECT Id, Donor_Name__c, Donor_Account__c,  Tax_Recipient_Individual__c, Tax_Recipient_Organisation__c
            FROM Donations__c
            WHERE id = :donationsToInsert.id
        ];
        System.assert(donationsToInsert.Donor_Name__c != null);
        System.assert(donationsToInsert.Donor_Account__c != null);
        System.assert(donationsToInsert.Tax_Recipient_Individual__c == null);
        System.assert(donationsToInsert.Tax_Recipient_Organisation__c == null);
    }


    @isTest
    // Scenario : 
    // create a donation with new contact detail
    // and tax recipient to the same donor
    public static void createDonation2(){
        Donations__c donationToInsert = new Donations__c(
            RecordTypeId = Schema.SObjectType.Donations__c.getRecordTypeInfosByName().get('Cash').getRecordTypeId(),
            Donor_Type__c = 'Individual',
            Donation_Status__c = 'Cleared',
            Donation_Date__c = System.today(),
            Donation_Datetime__c = System.now(),
            Cleared_Datetime__c = System.now(),
            Full_Name_Entered__c = 'Test Individual 1',
            Email_Entered__c = 'test1@mail.com',
            ID_Type_Entered__c = 'NRIC',
            Tax_Recipient_ID_No_Entered__c = 'NRIC-test1',
            Tax_Recipient_Full_Name_Entered__c = 'Test Individual 1',
            Donation_Amount__c = 100,
            Payment_Method__c = 'Credit Card'
        );

        Insert donationToInsert;
    }


    @isTest
    // Scenario : 
    // create a donation with existing Contact as donor
    // and tax recipient to the same existing Contact
    public static void createDonation3(){

        Donations__c donationToInsert = new Donations__c(
            RecordTypeId = Schema.SObjectType.Donations__c.getRecordTypeInfosByName().get('Cash').getRecordTypeId(),
            Donor_Type__c = 'Individual',
            Donation_Status__c = 'Cleared',
            Donation_Date__c = System.today(),
            Donation_Datetime__c = System.now(),
            Cleared_Datetime__c = System.now(),
            Full_Name_Entered__c = 'testSetup individual 1',
            Email_Entered__c = 'testSetup1@mail.com',
            Address_Entered__c = 'Street 1',
            Address_Unit_Entered__c = '101',
            Address_Postal_Code_Entered__c = '123451',
            ID_Type_Entered__c = 'NRIC',
            Tax_Recipient_ID_No_Entered__c = 'NRIC-testSetup1',
            Tax_Recipient_Full_Name_Entered__c = 'testSetup individual 1',
            Donation_Amount__c = 100,
            Payment_Method__c = 'Credit Card'
        );

        Insert donationToInsert;
    }


    @isTest
    // Scenario : 
    // create a donation with a new Organisation Contact 
    // and tax recipient to the Organisation
    public static void createDonation4(){

        Donations__c donationToInsert = new Donations__c(
            RecordTypeId = Schema.SObjectType.Donations__c.getRecordTypeInfosByName().get('Cash').getRecordTypeId(),
            Donor_Type__c = 'Organisation',
            Donation_Status__c = 'Cleared',
            Donation_Date__c = System.today(),
            Donation_Datetime__c = System.now(),
            Cleared_Datetime__c = System.now(),
            Full_Name_Entered__c = 'Test Organisation 1',
            Email_Entered__c = 'testOrg1@mail.com',
            Address_Entered__c = 'Street 1',
            Address_Unit_Entered__c = '101',
            Address_Postal_Code_Entered__c = '123451',
            Organisation_Name_Entered__c = 'Organisation 1',
            ID_Type_Entered__c = 'UEN',
            Tax_Recipient_ID_No_Entered__c = 'UEN-ORG 1',
            Tax_Recipient_Full_Name_Entered__c = 'Organisation 1',
            Donation_Amount__c = 100,
            Payment_Method__c = 'Credit Card'
        );

        Insert donationToInsert;
    }


    @isTest
    // Scenario : 
    // create a donation with existing Organisation Contact 
    // and tax recipient to the Organisation
    public static void createDonation5(){
        Donations__c donationToInsert = new Donations__c(
            RecordTypeId = Schema.SObjectType.Donations__c.getRecordTypeInfosByName().get('Cash').getRecordTypeId(),
            Donor_Type__c = 'Organisation',
            Donation_Status__c = 'Cleared',
            Donation_Date__c = System.today(),
            Donation_Datetime__c = System.now(),
            Cleared_Datetime__c = System.now(),
            Full_Name_Entered__c = 'Test Organisation 1',
            Email_Entered__c = 'testOrg1@mail.com',
            Address_Entered__c = 'Street 1',
            Address_Unit_Entered__c = '101',
            Address_Postal_Code_Entered__c = '123451',
            Organisation_Name_Entered__c = 'Existing Organisation 1',
            ID_Type_Entered__c = 'UEN-Business',
            Tax_Recipient_ID_No_Entered__c = 'UEN-testSetup1',
            Tax_Recipient_Full_Name_Entered__c = 'Existing Organisation 1',
            Donation_Amount__c = 100,
            Payment_Method__c = 'Credit Card'
        );

        Insert donationToInsert;
    }



    @isTest
    // Scenario : 
    // create a donation with new Individual Email
    // and tax recipient to an existing contact which has blank email 
    // donor full name = tax recipient full name
    public static void createDonation6a(){
        Donations__c donationToInsert = new Donations__c(
            RecordTypeId = Schema.SObjectType.Donations__c.getRecordTypeInfosByName().get('Cash').getRecordTypeId(),
            Donor_Type__c = 'Individual',
            Donation_Status__c = 'Cleared',
            Donation_Date__c = System.today(),
            Donation_Datetime__c = System.now(),
            Cleared_Datetime__c = System.now(),
            Full_Name_Entered__c = 'testSetup individual 2',
            Email_Entered__c = 'test2@mail.com',
            Address_Entered__c = 'Street 1',
            Address_Unit_Entered__c = '101',
            Address_Postal_Code_Entered__c = '123451',
            ID_Type_Entered__c = 'FIN',
            Tax_Recipient_ID_No_Entered__c = 'FIN-testSetup2',
            Tax_Recipient_Full_Name_Entered__c = 'testSetup individual 2',
            Donation_Amount__c = 100,
            Payment_Method__c = 'Credit Card'
        );

        Insert donationToInsert;
    }


    @isTest
    // Scenario : 
    // create a donation with new Individual Email
    // and tax recipient to an existing contact which has blank email 
    // donor full name != tax recipient full name
    public static void createDonation6b(){
        Donations__c donationToInsert = new Donations__c(
            RecordTypeId = Schema.SObjectType.Donations__c.getRecordTypeInfosByName().get('Cash').getRecordTypeId(),
            Donor_Type__c = 'Individual',
            Donation_Status__c = 'Cleared',
            Donation_Date__c = System.today(),
            Donation_Datetime__c = System.now(),
            Cleared_Datetime__c = System.now(),
            Full_Name_Entered__c = 'testSetup individual 3',
            Email_Entered__c = 'test3@mail.com',
            Address_Entered__c = 'Street 1',
            Address_Unit_Entered__c = '101',
            Address_Postal_Code_Entered__c = '123451',
            ID_Type_Entered__c = 'FIN',
            Tax_Recipient_ID_No_Entered__c = 'FIN-testSetup2',
            Tax_Recipient_Full_Name_Entered__c = 'testSetup individual 2',
            Donation_Amount__c = 100,
            Payment_Method__c = 'Credit Card'
        );

        Insert donationToInsert;
    }



    @isTest
    // Scenario : 
    // create a donation with new Individual Email
    // and tax recipient to an existing contact which has email 
    public static void createDonation7(){
        Donations__c donationToInsert = new Donations__c(
            RecordTypeId = Schema.SObjectType.Donations__c.getRecordTypeInfosByName().get('Cash').getRecordTypeId(),
            Donor_Type__c = 'Individual',
            Donation_Status__c = 'Cleared',
            Donation_Date__c = System.today(),
            Donation_Datetime__c = System.now(),
            Cleared_Datetime__c = System.now(),
            Full_Name_Entered__c = 'testSetup individual 4',
            Email_Entered__c = 'test4@mail.com',
            ID_Type_Entered__c = 'NRIC',
            Tax_Recipient_ID_No_Entered__c = 'NRIC-testSetup1',
            Tax_Recipient_Full_Name_Entered__c = 'testSetup individual 1',
            Donation_Amount__c = 100,
            Payment_Method__c = 'Credit Card'
        );

        Insert donationToInsert;
    }



    @isTest
    // Scenario : 
    // create a donation with existing Contact
    // and new tax recipient which is different with the donor
    public static void createDonation8(){
        Donations__c donationToInsert = new Donations__c(
            RecordTypeId = Schema.SObjectType.Donations__c.getRecordTypeInfosByName().get('Cash').getRecordTypeId(),
            Donor_Type__c = 'Individual',
            Donation_Status__c = 'Cleared',
            Donation_Date__c = System.today(),
            Donation_Datetime__c = System.now(),
            Cleared_Datetime__c = System.now(),
            Full_Name_Entered__c = 'testSetup individual 1',
            Email_Entered__c = 'testSetup1@mail.com',
            ID_Type_Entered__c = 'NRIC',
            Tax_Recipient_ID_No_Entered__c = 'NRIC-testSetup5',
            Tax_Recipient_Full_Name_Entered__c = 'testSetup individual 5',
            Donation_Amount__c = 100,
            Payment_Method__c = 'Credit Card'
        );

        Insert donationToInsert;
    }


    @isTest
    // Scenario : 
    // create a donation with existing Contact with blank tax recipient
    // and new tax recipient with same full name with the donor
    public static void createDonation9a(){
        Donations__c donationToInsert = new Donations__c(
            RecordTypeId = Schema.SObjectType.Donations__c.getRecordTypeInfosByName().get('Cash').getRecordTypeId(),
            Donor_Type__c = 'Individual',
            Donation_Status__c = 'Cleared',
            Donation_Date__c = System.today(),
            Donation_Datetime__c = System.now(),
            Cleared_Datetime__c = System.now(),
            Full_Name_Entered__c = 'testSetup individual 3',
            Email_Entered__c = 'testSetup3@mail.com',
            ID_Type_Entered__c = 'NRIC',
            Tax_Recipient_ID_No_Entered__c = 'NRIC-testSetup3',
            Tax_Recipient_Full_Name_Entered__c = 'testSetup individual 3',
            Donation_Amount__c = 100,
            Payment_Method__c = 'Credit Card'
        );

        Insert donationToInsert;
    }



    @isTest
    // Scenario : 
    // create a donation with existing Contact with blank tax recipient
    // and new tax recipient with different full name with the donor
    public static void createDonation9b(){
        Donations__c donationToInsert = new Donations__c(
            RecordTypeId = Schema.SObjectType.Donations__c.getRecordTypeInfosByName().get('Cash').getRecordTypeId(),
            Donor_Type__c = 'Individual',
            Donation_Status__c = 'Cleared',
            Donation_Date__c = System.today(),
            Donation_Datetime__c = System.now(),
            Cleared_Datetime__c = System.now(),
            Full_Name_Entered__c = 'testSetup individual 3',
            Email_Entered__c = 'testSetup3@mail.com',
            ID_Type_Entered__c = 'NRIC',
            Tax_Recipient_ID_No_Entered__c = 'NRIC-testSetup6',
            Tax_Recipient_Full_Name_Entered__c = 'test individual 6',
            Donation_Amount__c = 100,
            Payment_Method__c = 'Credit Card'
        );

        Insert donationToInsert;
    }


    @isTest
    // Scenario : 
    // create a donation with existing contact by fill in donor_name__c directly
    public static void createDonation10(){
        try {
            Contact existContact = [
                SELECT Id
                FROM Contact
                WHERE Email = 'testSetup1@mail.com'
            ];


            Donations__c donationToInsert = new Donations__c(
                RecordTypeId = Schema.SObjectType.Donations__c.getRecordTypeInfosByName().get('Cash').getRecordTypeId(),
                Donor_Type__c = 'Individual',
                Donation_Status__c = 'Cleared',
                Donation_Date__c = System.today(),
                Donation_Datetime__c = System.now(),
                Cleared_Datetime__c = System.now(),
                Donation_Amount__c = 100,
                Payment_Method__c = 'Credit Card'
            );

            Insert donationToInsert;
            
        } catch (Exception e) {
            
        }
        
    }


    @isTest
    // Scenario : 
    // create a donation with anonymous
    public static void createDonation11(){

        Donations__c donationToInsert = new Donations__c(
            RecordTypeId = Schema.SObjectType.Donations__c.getRecordTypeInfosByName().get('Cash').getRecordTypeId(),
            Donor_Type__c = 'Anonymous',
            Donation_Status__c = 'Cleared',
            Donation_Date__c = System.today(),
            Donation_Datetime__c = System.now(),
            Cleared_Datetime__c = System.now(),
            Email_Entered__c = 'anon@mail.com',
            Donation_Amount__c = 100,
            Payment_Method__c = 'Credit Card'
        );

        Insert donationToInsert;
    }


    @isTest
    // Scenario : 
    // create a donation with new Contact Info
    // and new tax recipient with different last name
    public static void createDonation12(){
        Donations__c donationToInsert = new Donations__c(
            RecordTypeId = Schema.SObjectType.Donations__c.getRecordTypeInfosByName().get('Cash').getRecordTypeId(),
            Donor_Type__c = 'Individual',
            Donation_Status__c = 'Cleared',
            Donation_Date__c = System.today(),
            Donation_Datetime__c = System.now(),
            Cleared_Datetime__c = System.now(),
            Full_Name_Entered__c = 'test individual 7',
            Email_Entered__c = 'test7@mail.com',
            ID_Type_Entered__c = 'NRIC',
            Tax_Recipient_ID_No_Entered__c = 'NRIC-test8',
            Tax_Recipient_Full_Name_Entered__c = 'test individual 8',
            Donation_Amount__c = 100,
            Payment_Method__c = 'Credit Card'
        );

        Insert donationToInsert;
    }


    @isTest
    // Scenario : 
    // create bulk donation with only donor_name__c filled
    // combined testing with programme/event
    public static void createDonation13(){
        List<String> emailToRetrieveList = new List<String>{
            'testSetup1@mail.com',
            'testSetup3@mail.com',
            'testSetupOrganisation1@mail.com'
        };

        List<Contact> existContact = new List<Contact>([
            SELECT ID
            FROM Contact
            WHERE Email in :emailToRetrieveList
        ]);

        Programme_Events__c programmeTest = [
            SELECT ID
            FROM Programme_Events__c
            WHERE Name = 'Test Programme'
        ];


        List<Donations__c> donationsToInsertList = new List<Donations__c>();
        
        for(Contact cItem : existContact){
            donationsToInsertList.add(new Donations__c(
                RecordTypeId = Schema.SObjectType.Donations__c.getRecordTypeInfosByName().get('Cash').getRecordTypeId(),
                Donor_Type__c = 'Individual',
                Donation_Status__c = 'Cleared',
                Donation_Date__c = System.today(),
                Donation_Datetime__c = System.now(),
                Cleared_Datetime__c = System.now(),
                Donor_Name__c = cItem.id,
                Programme_Event__c = programmeTest.id,
                Donation_Amount__c = 100,
                Payment_Method__c = 'Credit Card'
            ));
        }

        Insert donationsToInsertList;
        
    }


    
}