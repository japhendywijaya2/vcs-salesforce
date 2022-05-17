@isTest
public class DonationTest {
    @isTest
  /**  private static void runTest(){
        // create contact
        // create recurring donation
        // create donation
        // update donation to cleared
        
        Contact c = new Contact();
        c.LastName = 'Testing';
        c.RecordTypeId = Utils.GetRecordTypeId('Contact', 'Individual');
        //c.Email_Personal__c = 'testing@interaktiv.sg';
        c.Email = 'testingers@interaktiv.sg';
        c.Donor_Type__c = 'Individual';
        insert(c);
        
        c = [SELECT Id, AccountId, LastName FROM Contact WHERE Id = :c.Id limit 1];
        
        Recurring_Donation__c rd = new Recurring_Donation__c();
        rd.Amount__c = 100;
        rd.Donor_Name__c = c.Id;
        rd.Account__c = c.AccountId;
        rd.Start_Date__c = Date.today();
        rd.End_Date__c = Date.today().addDays(90);
        rd.Frequency__c = 'Monthly';
        rd.RD_Status__c = 'Approved';
        rd.Payment_Method__c = 'Credit Card';
        insert(rd);
        
        rd = [SELECT Id, Frequency__c,Amount__c FROM Recurring_Donation__c WHERE Id = :rd.Id limit 1];
        system.debug(rd);
        
        Donations__c d = new Donations__c();
        d.Donor_Account__c = c.AccountId;
        d.Recurring_Donation__c = rd.Id;
        d.Donor_Name__c= c.Id;
        d.Donation_Datetime__c = Datetime.now();
        //d.Cleared_Datetime__c = Datetime.now();
        d.Donation_Amount__c = rd.Amount__c;
        d.Donation_Status__c = 'Cleared';
        d.Frequency_Type__c= 'Recurring';
        d.Payment_Method__c = 'Credit Card';
        d.Donor_Type__c='Individual';
        //d.Frequency_Period__c = 'Monthly';
        insert(d);
        
        Donations__c d1 = new Donations__c();
        d1.Donor_Account__c = c.AccountId;
        d1.Donor_Name__c = c.Id;
        d1.Donation_Datetime__c = Datetime.now();
        d1.Cleared_Datetime__c = Datetime.now();
        d1.Donation_Amount__c = rd.Amount__c;
		d1.Donor_Type__c='Individual';
        d1.Donation_Status__c = 'Cleared';
        d1.Tax_Deductible__c = true;
		d1.Payment_Method__c = 'Credit Card';
        insert(d1);


        Donations__c d2 = new Donations__c();
        d2.Donor_Account__c = c.AccountId;
        d2.Donor_Name__c = c.Id;
        d2.Donation_Datetime__c = Datetime.now();
        d2.Cleared_Datetime__c = Datetime.now();
        d2.Donation_Amount__c = rd.Amount__c;
		d2.Donor_Type__c='Individual';
        d2.Donation_Status__c = 'Received';
        d2.Tax_Deductible__c = true;
		d2.Payment_Method__c = 'Credit Card';
        d2.Recurring_Donation__c = rd.Id;
        d2.Frequency_Type__c = 'Recurring';
        //d2.Frequency_Period__c = 'Monthly';
        insert(d2);
    
        Donations__c d3 = [SELECT Id, Donor_Account__c, Donation_Status__c FROM Donations__c WHERE Donation_Status__c = 'Received' AND Recurring_Donation__c = :rd.Id limit 1];
        system.debug(d3);
        d3.Cleared_Datetime__c = Datetime.now();
        d3.Donation_Status__c = 'Cleared';
        update(d3);
		
    } **/
    
    public static void runTest2(){
        Contact c = new Contact();
        c.LastName = 'test1';
        c.RecordTypeId = Utils.GetRecordTypeId('Contact', 'Individual');
        c.Email = 'test1@gmail.com';
        c.Donor_Type__c = 'Individual';
        c.isTaxRecipient__c = true;
        c.ID_Type__c = 'NRIC';
        c.ID_No__c = 'S71080T82';
        c.Tax_Recipient_Full_Name__c = 'test1';
        insert(c);
        
        c = [SELECT Id, AccountId, LastName FROM Contact WHERE Id = :c.Id limit 1];
        
        Donations__c d = new Donations__c();
        d.Donor_Account__c = c.AccountId;
        d.Donor_Name__c= c.Id;
        d.Email_Entered__c = 'test1@gmail.com';
        d.Donation_Datetime__c = Datetime.now();
        d.Donation_Amount__c = 10;
        d.Donation_Status__c = 'Cleared';
        d.Payment_Method__c = 'Credit Card';
        d.Cleared_Datetime__c = Datetime.now();
        d.Donor_Type__c='Individual';
        d.Tax_Recipient_ID_No_Entered__c = 'S71080T82';
        d.ID_Type_Entered__c = 'NRIC';
        d.Tax_Recipient_Full_Name_Entered__c = 'test1';
        insert(d);
        
    }
    
    @isTest
    public static void runTest3(){
        
        Donations__c d = new Donations__c();
     
        d.RecordTypeId = Schema.SObjectType.Donations__c.getRecordTypeInfosByName().get('Cash').getRecordTypeId();
        d.Donor_Type__c = 'Organisation';
        d.Donation_Date__c = Date.today();
        d.Donation_Datetime__c = datetime.now();
        d.Cleared_Datetime__c = datetime.now();
        d.Full_Name_Entered__c = 'Bruce';
        d.Email_Entered__c = 'bruce@mail.com';
        d.Donation_Amount__c = 10;
        d.Donation_Status__c = 'Cleared';
        d.Payment_Method__c = 'Credit Card';
        
        insert(d);
        
    }
    /**
    @isTest
    public static void runTest4(){
        List<Donations__c> listD = new List<Donations__c>();
        
        Contact c = new Contact();
        c.LastName = 'test1';
        c.RecordTypeId = Utils.GetRecordTypeId('Contact', 'Individual');
        c.Email = 'test1@gmail.com';
        c.Donor_Type__c = 'Individual';
        c.isTaxRecipient__c = true;
        c.ID_Type__c = 'NRIC';
        c.ID_No__c = 'S71080T82';
        c.Tax_Recipient_Full_Name__c = 'test1';
        insert(c);
        c = [SELECT Id, AccountId, LastName FROM Contact WHERE Id = :c.Id limit 1];
        
        Donations__c d = new Donations__c();
        d.Donor_Account__c = c.AccountId;
        d.Donor_Name__c= c.Id;
        d.Email_Entered__c = 'test1@gmail.com';
        d.Donation_Datetime__c = Datetime.now();
        d.Donation_Amount__c = 10;
        d.Donation_Status__c = 'Cleared';
        d.Payment_Method__c = 'Credit Card';
        d.Cleared_Datetime__c = Datetime.now();
        d.Donor_Type__c='Individual';
        d.Tax_Recipient_ID_No_Entered__c = 'S71080T82';
        d.ID_Type_Entered__c = 'NRIC';
        d.Tax_Recipient_Full_Name_Entered__c = 'test1';
        insert(d);
        
        Contact c2 = new Contact();
        c2.LastName = 'test2';
        c2.RecordTypeId = Utils.GetRecordTypeId('Contact', 'Individual');
        c2.Email = 'test2@gmail.com';
        c2.Donor_Type__c = 'Individual';
        c2.isTaxRecipient__c = true;
        c2.ID_Type__c = 'NRIC';
        c2.ID_No__c = 'S71080T82';
        c2.Tax_Recipient_Full_Name__c = 'test2';
        insert(c2);
        c2 = [SELECT Id, AccountId, LastName FROM Contact WHERE Id = :c.Id limit 1];
        
        Donations__c d2 = new Donations__c();
        d2.Donor_Account__c = c2.AccountId;
        d2.Donor_Name__c= c2.Id;
        d2.Email_Entered__c = 'test2@gmail.com';
        d2.Donation_Datetime__c = Datetime.now();
        d2.Donation_Amount__c = 10;
        d2.Donation_Status__c = 'Cleared';
        d2.Payment_Method__c = 'Credit Card';
        d2.Cleared_Datetime__c = Datetime.now();
        d2.Donor_Type__c='Individual';
        d2.Tax_Recipient_ID_No_Entered__c = 'S71080T82';
        d2.ID_Type_Entered__c = 'NRIC';
        d2.Tax_Recipient_Full_Name_Entered__c = 'test2';
        insert(d);
        
        listD.add(d);
        listD.add(d2);
        
        DonationsTriggerHandler Dhan = new DonationsTriggerHandler();
        Dhan.getAccountIdBulk(listD);
    }**/
}