@isTest
public class ContactTest {
    @isTest
    public static void runTest1(){
        List<Contact> listCont = new List<Contact>();
        
        Contact c1 = new Contact();
        c1.LastName = 'Test 123';
        c1.Email = 'abc123@testclass.com';
        c1.Donor_Type__c = 'Individual';
        c1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        c1.Volunteer__c = true;
        c1.Resignation_Date__c = Date.today();
        c1.Reason_of_Declined__c = 'Yes';
        c1.Dormant_Start_Date__c = Date.today();
        c1.Dormant_End_Date__c = Date.today();
        insert(c1);
        
        Contact c2 = new Contact();
        c2.LastName = 'Test 123';
        c2.Email = 'abc123@testclass.com';
        c2.Donor_Type__c = 'Individual';
        c2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        c2.Volunteer__c = true;
        c2.Resignation_Date__c = Date.newInstance(2022, 1, 10);
        c2.Reason_of_Declined__c = 'Yes';
        c2.Dormant_Start_Date__c = Date.newInstance(2022, 1, 19);
        c2.Dormant_End_Date__c = Date.newInstance(2022, 1, 20);
        c2.Orientation_Completed__c = true;
        c2.Last_Assignment_Date__c = Date.newInstance(2022, 1, 25);
        
        Contact c3 = new Contact();
        c3.LastName = 'Test 123';
        c3.Email = 'abc123@testclass.com';
        c3.Donor_Type__c = 'Individual';
        c3.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        c3.Volunteer__c = true;
        c3.Resignation_Date__c = Date.newInstance(2022, 1, 10);
        c3.Reason_of_Declined__c = 'Yes';
        c3.Dormant_Start_Date__c = Date.newInstance(2022, 1, 19);
        c3.Dormant_End_Date__c = Date.newInstance(2022, 1, 20);
        c3.Orientation_Completed__c = false;
        
       // if(c.Dormant_Start_Date__c == null && c.Dormant_End_Date__c == null && 
       //    c.Resignation_Date__c == null && c.Reason_of_Declined__c == null)
        
        Contact c4 = new Contact();
        c4.LastName = 'Test 123';
        c4.Email = 'abc123@testclass.com';
        c4.Donor_Type__c = 'Individual';
        c4.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        c4.Volunteer__c = true;
        c4.Resignation_Date__c = null;
        c4.Dormant_Start_Date__c = null;
        c4.Dormant_End_Date__c = null;
        c4.Orientation_Completed__c = true;
        c4.Last_Assignment_Date__c = Date.newInstance(2022, 1, 25);
        
        Contact c5 = new Contact();
        c5.LastName = 'Test 123';
        c5.Email = 'abc123@testclass.com';
        c5.Donor_Type__c = 'Individual';
        c5.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        c5.Volunteer__c = true;
        c5.Resignation_Date__c = null;
        c5.Reason_of_Declined__c = null;
        c5.Dormant_Start_Date__c = null;
        c5.Dormant_End_Date__c = null;
        //c5.Orientation_Completed__c = true;
        c5.Reason_of_Declined__c = 'Yes';
        c5.Last_Assignment_Date__c = Date.newInstance(2022, 1, 25);
        
        
        Contact c6 = new Contact();
        c6.LastName = 'Test 123';
        c6.Email = 'abc123@testclass.com';
        c6.Donor_Type__c = 'Individual';
        c6.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        c6.Volunteer__c = true;
        c6.Reason_of_Declined__c = null;
        c6.Dormant_Start_Date__c = null;
        c6.Dormant_End_Date__c = null;
        c6.Last_Assignment_Date__c = Date.newInstance(2022, 1, 25);
        
        Contact c7 = new Contact();
        c7.LastName = 'Test 123';
        c7.Email = 'abc123@testclass.com';
        c7.Donor_Type__c = 'Individual';
        c7.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        c7.Volunteer__c = true;
        c7.Resignation_Date__c = null;
        c7.Dormant_Start_Date__c = null;
        c7.Dormant_End_Date__c = null;
        c7.Last_Assignment_Date__c = Date.newInstance(2022, 1, 25);
        c7.Volunteer_Accepted_Date__c = Date.newInstance(2022, 1, 26);
        
        Contact c8 = new Contact();
        c8.LastName = 'Test 123';
        c8.Email = 'abc123@testclass.com';
        c8.Donor_Type__c = 'Individual';
        c8.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        c8.Volunteer__c = true;
        c8.Resignation_Date__c = null;
        c8.Dormant_Start_Date__c = null;
        c8.Dormant_End_Date__c = null;
        c8.Last_Assignment_Date__c = Date.newInstance(2022, 1, 25);
        c8.Reason_of_Declined__c = 'Yes';
        
        listCont.add(c1);
        listCont.add(c2);
        listCont.add(c3);
        listCont.add(c4);
        listCont.add(c5);
        listCont.add(c6);
        listCont.add(c7);
        listCont.add(c8);
        
        ContactTriggerHandler.setVolunteerStatus(listCont);
    }
    
    @isTest
    public static void runTest2(){
        List<Contact> listCont = new List<Contact>();
        
        Contact c = new Contact();
        c.LastName = 'test1';
        c.RecordTypeId = Utils.GetRecordTypeId('Contact', 'Individual');
        c.Email = 'test1@gmail.com';
        c.Donor_Type__c = 'Individual';
        insert(c);
        
        c = [SELECT Id, AccountId, LastName FROM Contact WHERE Id = :c.Id limit 1];
        
        Contact c2 = new Contact();
        c2.LastName = 'test2';
        c2.RecordTypeId = Utils.GetRecordTypeId('Contact', 'Individual');
        c2.Email = 'test2@gmail.com';
        c2.Donor_Type__c = 'Individual';
        insert(c2);
        c2 = [SELECT Id, AccountId, LastName FROM Contact WHERE Id = :c2.Id limit 1];
        
        listCont.add(c);
        listCont.add(c2);
        
        ContactTriggerHandler.createAccount(listCont);
    }
}