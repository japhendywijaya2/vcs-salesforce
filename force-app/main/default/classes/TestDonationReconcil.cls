@isTest
public class TestDonationReconcil {
    static testMethod void runTest() {
        // Insert Account
        Account actObj = new Account();
        actObj.name = 'testAcc';
        actObj.Identification_no__c = '101';
        actObj.Identification_Type__c = 'pan';
        actObj.billingPostalCode='1001';
        insert actObj;
        Contact conObj = new Contact(firstname = 'test',lastname='con', Surname__c='User',Salutation='Mr.');
        conObj.mailingStreet = 'Test';
        conObj.mailingCity = 'Test';
        conObj.Email = 'test@interaktiv.sg';
        conObj.mailingCountry = 'Test';
        conObj.MailingPostalCode='20202';
        conObj.Title='Engineer';
        conObj.Donor_Type__c = 'Individual';

        insert conObj;
        
        Programme_Events__c programEventObj= new Programme_Events__c(
        name='testing',
        Engagement_Type__c='Direct',
        Programme_Description__c='Test',
        Event_Attire__c='Casual',
        Venue_of_Event_or_Mobilisation__c='test',
        Start_Date_Time__c= system.now(),
        End_Date_Time__c=system.now()     
        );
        insert programEventObj;
        
        Donations__c donationObj= new Donations__c(
        Donor_Account__c= actObj.id,
        Programme_Event__c=programEventObj.id,
        Donor_Name__c= conObj.id,
      //  ID_Type__c='NRIC',
        Donation_Date__c=system.today(),
        Donation_Datetime__c= system.now(),
        Donation_Amount__c=600,
        Donor_Type__c='Individual'
        //Cleared_Date__c=system.today()
        );
        insert donationObj;
        Donations__c donationObj1= new Donations__c(
        Donor_Account__c= actObj.id,       
        Donor_Name__c= conObj.id,
      //  ID_Type__c='UEN-Business',
        Donation_Date__c=system.today(),
        Donation_Datetime__c= system.now(),
        Donation_Amount__c=600,
        Donor_Type__c='Organisation'
        //Cleared_Date__c=system.today()
        );
        insert donationObj1;
        Test.startTest();
        DonationReconcilController dc = new DonationReconcilController(null);
        dc.donation.Donation_Date__c = Date.today().addDays(-2);
        dc.donation.Cleared_Date__c = Date.today().addDays(2);
        dc.donation.Donation_Status__c = 'Received';
        dc.search();
        dc.selectAll();
        dc.calculateSelected();
        dc.donation1.Donation_Status__c = 'Cleared';
        dc.save();
        dc.unselectAll();

           
    }
}