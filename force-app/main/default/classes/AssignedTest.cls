@isTest
public class AssignedTest {
    @TestSetup
    static void makeData(){
        List<Contact> contactToInsertList = new List<Contact>{
            new Contact(
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId(),
                Donor_Type__c = 'Individual',
                lastName = 'Apple Pine 1',
                Email = 'apple1@email.com'
            ),
            new Contact(
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId(),
                Donor_Type__c = 'Individual',
                lastName = 'Apple Pine 2',
                Email = 'apple2@email.com'
            ),
            new Contact(
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId(),
                Donor_Type__c = 'Individual',
                lastName = 'Apple Pine 3',
                Email = 'apple3@email.com'
            )
        };

        Insert contactToInsertList;
    }

	@isTest static void TestUploadVolunteerController(){
        integer progNums = 1;
        List<Volunteer_Request__c> progList = new List<Volunteer_Request__c>();
        for(Integer i=0; i<progNums; i++) {
            Volunteer_Request__c v = new Volunteer_Request__c();
            v.Name = 'Test VR';
            v.Start_Date__c = Date.today().addDays(i+3);
            v.End_Date__c = Date.today().addDays(i+9);
            v.RecordTypeId = Schema.SObjectType.Volunteer_Request__c.getRecordTypeInfosByName().get('Direct').getRecordTypeId();
            v.Start_Time__c = Time.newInstance(5, 0, 0, 0);
            v.Recruitment_Deadline__c = Date.today();
            progList.add(v);
        }
        insert(progList);
        Volunteer_Request__c v = progList[0];
        v.Start_Date__c = Date.today().addDays(-30);
        v.End_Date__c = Date.today().addDays(-10);
        update(v);
        v.Start_Date__c = Date.today().addDays(1);
        v.End_Date__c = Date.today().addDays(5);
        update(v);
        v.Start_Date__c = Date.today().addDays(-1);
        v.End_Date__c = Date.today().addDays(5);
        update(v);
        Test.startTest();
        v.Cancel_VR__c = true;
        v.Others_Please_Indicate__c = 'testing';
        update(v);
        ApexPages.CurrentPage().getParameters().put('id', progList.get(0).Id);
        UploadVolunteerController uv = new UploadVolunteerController(new ApexPages.StandardController(progList.get(0)));
        String s = 	'Fulname,Email,Mobile'+
				   	'Apple Pine 1,apple1@email.com,99999747\n'+
					'Apple Pine 2,apple2@email.com,88888888\n'+
					'Apple Pine 3,apple3@email.com,99987455';
        uv.csvFileBody = Blob.valueOf(s);
        uv.back();
        uv.importCSVFile(); 
        String s1 = 	'Firstname,Email,Mobile\n'+
				   	'Apple Pine 1,apple1@email.com,99999747\n'+
					'Apple Pine 2,apple2@email.com,88888888\n'+
					'Apple Pine 3,apple3@email.com,99987455';
        uv.csvFileBody = Blob.valueOf(s1);
        uv.importCSVFile(); 
        String s2 = 	'"Fullname","Email","Mobile"\n'+
				   	'"Apple Pine 1","apple1@email.com","99999747"\n'+
					'"Apple Pine 2","apple2@email.com","88888888"\n'+
					'"Apple Pine 3","apple3@email.com","99987455"';
        uv.csvFileBody = Blob.valueOf(s2);
        uv.importCSVFile();
        VolunteerAcceptDeclineController pa = new VolunteerAcceptDeclineController(new ApexPages.StandardController(progList.get(0)));
        pa.pt.Assignee_Status__c = 'Selected';
        pa.refreshTable();
        pa.selectAll();
        pa.unselectAll();
        pa.selectAll();
        pa.acceptVolunteer();
        pa.declineVolunteer();
        pa.back();
        Test.stopTest();
    }
}