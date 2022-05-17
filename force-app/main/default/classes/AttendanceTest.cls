@isTest public class AttendanceTest {
	@isTest static void TestAttendanceUpload(){
    	Contact c1 = new Contact();
        c1.LastName = 'Test 123';
        c1.Email = 'abc123@testclass.com';
        c1.Donor_Type__c = 'Individual';
        c1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        insert(c1);
        
        Volunteer_Request__c v1 = new Volunteer_Request__c();
        v1.RecordTypeId = Schema.SObjectType.Volunteer_Request__c.getRecordTypeInfosByName().get('Indirect').getRecordTypeId();
        v1.Name = 'Test VR';
        v1.Start_Date__c = Date.today().addDays(3);
        v1.End_Date__c = Date.today().addDays(9);
        v1.Start_Time__c = Time.newInstance(5, 0, 0, 0);
        v1.End_Time__c = Time.newInstance(11, 0, 0, 0);
        v1.Recruitment_Deadline__c = Date.today().addDays(2);
        v1.Request_Date__c = Date.today();
        v1.Email__c = 'abc@test.com';
        v1.Number_of_Volunteers_Required__c = 10;
        v1.Minimum_Volunteer_Required__c = 10;
        v1.Contact_Number__c = '08689';
        v1.Important_Information_Patient_Background__c = 'Test';
        insert(v1);
        v1 = [SELECT Id, Name, Volunteer_Request_No__c FROM Volunteer_Request__c WHERE Id = :v1.Id];
        
        Assigned_Volunteer__c a1 = new Assigned_Volunteer__c();
        a1.Volunteer_Request__c = v1.Id;
        a1.Contact__c = c1.Id;
        a1.Assignee_Status__c = 'Contacted';
        insert(a1);
        
        String strData = 'Record Type,Programme/Event,Volunteer Request No.,Account,Name,Email,Mobile,Date In,Time In,Date Out,Time Out,Hours,Remarks \n'+
'Indirect,,,Company A,Testing A1,abc123@testclass.com,,06/08/2021,10:20:00 AM,06/08/2021,04:00:00 PM,5,Testing only \n'+
'Indirect,,,,Testing A2,abctest2@company-a.com,,06/08/2021,10:20:00 AM,06/08/2021,04:00:00 PM,5, \n'+
'Direct,,' + v1.Volunteer_Request_No__c + ',Company ABC,Testing A3,abctest3@company-a.com,,06/08/2021,12:00:00 PM,07/08/2021,12:00:00 AM,5,normal test \n'+
'Direct,,' + v1.Volunteer_Request_No__c + ',,Testing A4,abctest4@company-a.com,,06/08/2021,10:20 AM,07/08/2021,12:10 PM,5,without second \n'+
'Direct,,' + v1.Volunteer_Request_No__c + ',,Testing X5,abctest5@company-a.com,,06/08/2021,10:20 AM,07/08/2021,12:10 PM,5,without second 2 \n'+
'Indirect,,,Company A,Testing A2,abctest2@company-a.com,,06/08/2021,10:20:00 AM,06/08/2021,04:00:00 PM \n'+
'Indirect,,,Company A,Testing A2,abctest2@company-a.com,,,10:20:00 AM,06/08/2021,04:00:00 PM,5, \n'+
'Indirect,,ABC,Company A,Testing A2,abctest2@company-a.com,,06/08/2021,10:20:00 AM,06/08/2021,04:00:00 PM,5, \n'+
'Direct,,' + v1.Volunteer_Request_No__c + ',,Testing A5,abc123@testclass.com,,06/08/2021,12:30:15 AM,07/08/2021,12:45:44 AM,5,with second';
        
        // testing controller
        AttendanceController aCtl = new AttendanceController();
        aCtl.fileCsv = Blob.valueOf(strData);
        aCtl.back();
        aCtl.upload();
        
        // check maperror
        for(Integer i: aCtl.mapErrors.keyset()) {
            system.debug('DEBUG err ' + i + ' = ' + aCtl.mapErrors.get(i));
        }
        
        // Testing SSSCsvReader
        strData = strData.replace('Testing A2', '"Testing A2"');
        SSSCsvReader csvTest = new SSSCsvReader(strData, ',');
        
        List<String> dLine = new List<String>();
        while (dLine != null)
        {
            dLine = csvTest.readLine();
        }
        
    }
    
    @isTest static void isValidNumber(){
        AttendanceController aCtl = new AttendanceController();
        
        aCtl.isValidNumber('10', true);
        aCtl.isValidNumber('10', false);
        aCtl.isValidNumber('hehe', false);
    }
    
    @isTest static void isValidDate(){
        AttendanceController aCtl = new AttendanceController();
        
        aCtl.isValidDate('2012-11-10');
        aCtl.isValidDate('anjay');
    }
    
    @isTest static void convertDate(){
        AttendanceController aCtl = new AttendanceController();
        
        aCtl.convertDate('12-05-2003');
    }
    
    @isTest static void strToTime(){
        AttendanceController aCtl = new AttendanceController();
        
        aCtl.strToTime('10:00:00');
        aCtl.strToTime('12:00');
        aCtl.strToTime('11:00:50');
    }
}