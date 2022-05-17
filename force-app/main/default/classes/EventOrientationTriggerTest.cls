@isTest 
public class EventOrientationTriggerTest {
    @isTest
    public static void methodTest(){
        Id recordIDTest = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        contact con = new contact();
        con.recordTypeId = recordIDTest;
        con.LastName = 'test';
        con.FirstName = 'test';
        con.Email = 'test@mail.com';
        con.Donor_Type__c = 'Individual';
        insert con;
        contact conList = [Select id,Name From Contact Where id = :con.Id];
        System.debug('-=-=0000=---=-='+conList);
        Event e = new Event();
        e.StartDateTime=system.today();
        e.EndDateTime=system.today()+5;
        e.subject='Scheduled Orientation';
        insert e;
        task taskRecord = new task();
        taskRecord.WhoId = conList.Id;
        taskRecord.Subject='Donni';
        taskRecord.Status='New';
        taskRecord.Priority='Normal';
        taskRecord.Interview_Outcome__c = 'Accepted';
        
        insert taskRecord;  
        
        taskRecord.Priority='Normal';
        update taskRecord;
    }


     @isTest
    public static void methodTest1(){
        Id recordIDTest = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        contact con = new contact();
        con.recordTypeId = recordIDTest;
        con.LastName = 'test';
        con.FirstName = 'test';
        con.Email = 'test@mail.com';
        con.Donor_Type__c = 'Individual';
        insert con;
        

        contact conList = [Select id, Name From Contact Where id = :con.Id];
        System.debug('-=-=0000=---=-='+conList);
        RecordType eventRecordTypeId = [
            SELECT Id, Name, DeveloperName, NamespacePrefix, Description 
            FROM RecordType
            WHERE Name = 'Scheduled Orientation'
                AND DeveloperName = 'Scheduled_Orientation'
        ];

        Event e = new Event();
        e.recordTypeId = eventRecordTypeId.id;
        e.StartDateTime=system.today();
        e.EndDateTime=system.today()+1;
        e.subject='Scheduled Orientation';
        insert e;
        
        Event e1 = new Event();
        e1.recordTypeId = eventRecordTypeId.id;
        e1.StartDateTime=system.today().addDays(5);
        e1.EndDateTime=system.today().addDays(6);
        e1.subject='Scheduled Orientation';
        insert e1;
        
        task taskRecord = new task();
        taskRecord.WhoId = conList.Id;
        taskRecord.Subject='Donni';
        taskRecord.Status='New';
        taskRecord.Priority='Normal';
        //taskRecord.Interview_Outcome__c = 'Accepted';
        insert taskRecord;  

        taskRecord.Interview_Outcome__c = 'Accepted';
        //taskRecord.Priority='Normal';
        update taskRecord;
    }


    @isTest
    public static void methodTest2(){
        Id recordIDTest = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        contact con = new contact();
        con.recordTypeId = recordIDTest;
        con.LastName = 'test';
        con.FirstName = 'test';
        con.Email = 'test@mail.com';
        con.Donor_Type__c = 'Individual';
        insert con;
        
        task taskRecord = new task();
        taskRecord.WhoId = con.Id;
        taskRecord.Subject='Donni';
        taskRecord.Status='New';
        taskRecord.Priority='Normal';
        //taskRecord.Interview_Outcome__c = 'Accepted';
        insert taskRecord; 


        Task t = [SELECT Id, WhoId, Missed_Cal__c, Status FROM Task WHERE WhoId = :con.id limit 1];
        system.debug('===========status============='+t.Status);
        t.Missed_Cal__c = '1st call';
        update(t);
        t.Missed_Cal__c = '2nd call';
        update(t);
        t.Missed_Cal__c = '3rd call';
        update(t);
    }


    @isTest
    public static void orientationDeclined(){
        Id recordIDTest = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        contact con = new contact();
        con.recordTypeId = recordIDTest;
        con.LastName = 'test';
        con.FirstName = 'test';
        con.Email = 'test@mail.com';
        con.Donor_Type__c = 'Individual';
        insert con;
        
        Event e = new Event();
        e.ActivityDateTime = Datetime.now().addDays(5);
        e.RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Scheduled Orientation').getRecordTypeId();
        //e.StartDateTime = Datetime.now().addDays(5);
        e.DurationInMinutes = 60;
        e.Subject = 'Scheduled Orientation';
        insert e;

        task taskRecord = new task();
        taskRecord.WhoId = con.Id;
        taskRecord.Subject='Donni';
        taskRecord.Status='New';
        taskRecord.Priority='Normal';
        //taskRecord.Interview_Outcome__c = 'Accepted';
        insert taskRecord; 


        Task t = [SELECT Id, WhoId, Missed_Cal__c, Status, Interview_Outcome__c FROM Task WHERE WhoId = :con.id limit 1];
        system.debug('===========status============='+t.Status);
        t.Interview_Outcome__c = 'Accepted';
        t.Send_Orientation_Invitation__c = true;
        //t.Orientation_Date__c = Date.today();
        update(t);
        Event e1 = [SELECT Id, WhoId, Interview_Outcome__c, Event_Status__c FROM Event WHERE WhoId = :con.id limit 1];
        e1.Event_Status__c = 'Declined';
        update e1;
        
    }

}