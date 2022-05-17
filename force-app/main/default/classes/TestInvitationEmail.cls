@isTest
public class TestInvitationEmail {
	@isTest static void TestUploadParticipantController(){
        integer progNums = 1;
        List<Programme_Events__c> progList = new List<Programme_Events__c>();
        for(Integer i=0; i<progNums; i++) {
            Programme_Events__c p = new Programme_Events__c();
            p.Name = 'Test Programme';
          //  p.Category__c = 'One-Time';
            p.Start_Date_Time__c = Datetime.now().addDays(i+1);
            p.End_Date_Time__c = Datetime.now().addDays(i+5);
            p.Programme_Stage__c = 'Planned';
            p.Engagement_Type__c = 'Direct';
            p.Programme_Description__c = 'Description';
            p.Venue_of_Event_or_Mobilisation__c = 'Venue';
            p.Event_Attire__c = 'Casual';
            progList.add(p);
        }
        insert(progList);
        
        string strSelected;
        List<EmailTemplate> etList = [SELECT name,subject,Body,DeveloperName,Id,HTMLValue  FROM EmailTemplate limit 1];
        for(EmailTemplate e : etList){
            strSelected = e.Id;
        }
        Test.startTest();
        ApexPages.CurrentPage().getParameters().put('id', progList.get(0).Id);
        UploadParticipantController v = new UploadParticipantController(new ApexPages.StandardController(progList.get(0)));
        String s = 	'Fulname,Email,Mobile\n'+
				   	'Apple Pine 1,apple1@email.com,99999747\n'+
					'Apple Pine 2,apple2@email.com,88888888\n'+
					'Apple Pine 3,apple3@email.com,99987455';
        v.csvFileBody = Blob.valueOf(s);
        List<Participant__c> pList = [SELECT Id, Name, Programme_Event__c, Status__c FROM Participant__c WHERE Programme_Event__c = :progList.get(0).Id];
        v.back();
        v.importCSVFile();
        ApexPages.CurrentPage().getParameters().put('strSelected', strSelected);
        ProgEvSendInvitationEmailController pc = new ProgEvSendInvitationEmailController(new ApexPages.StandardController(progList.get(0)));
        pc.strSelected = strSelected;
        pc.PreviewEmail();
        pc.selectAll();
        pc.unselectAll();
        pc.refreshAssignedVolunteer();
        pc.selectAll();
        pc.sendEmailInBatch();
        pc.back();    
        
        
        Participant__c p = new Participant__c();
        p.Participant_Lastname__c = 'Testing Participant';
        p.Email_Notification__c = 'testing@participant.com';
        p.Mobile__c = '94736264';
        p.uploaded__c = true;
        p.Programme_Event__c = progList.get(0).Id;
        insert(p);
        ApexPages.CurrentPage().getParameters().put('id', p.Id);
		ParticipantAcceptRejectController ar = new ParticipantAcceptRejectController(new ApexPages.StandardController(p)); 
        ar.acceptVolunteer();
        ar.declineVolunteer();
        ar.back();
        Test.stopTest();
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
            v.End_Time__c = Time.newInstance(8, 0, 0, 0);
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
        string strSelected;
        List<EmailTemplate> etList = [SELECT name,subject,Body,DeveloperName,Id,HTMLValue  FROM EmailTemplate limit 1];
        for(EmailTemplate e : etList){
            strSelected = e.Id;
        }
        
        Test.startTest();
        
        ApexPages.CurrentPage().getParameters().put('id', progList.get(0).Id);
        UploadVolunteerController uv = new UploadVolunteerController(new ApexPages.StandardController(progList.get(0)));
        String s = 	'Fulname,Email,Mobile\n'+
				   	'Apple Pine 1,apple1@email.com,99999747\n'+
					'Apple Pine 2,apple2@email.com,88888888\n'+
					'Apple Pine 3,apple3@email.com,99987455';
        uv.csvFileBody = Blob.valueOf(s);
        uv.importCSVFile(); 
        List<Contact> cList = [SELECT id, Name, Email FROM Contact];
        system.debug('Contact Test: '+cList.size());
        for(Contact c : cList){
            system.debug('Email: '+c.Email);
        }
        ApexPages.CurrentPage().getParameters().put('strSelected', strSelected);
        VRSendInvitationEmailController pc = new VRSendInvitationEmailController(new ApexPages.StandardController(progList.get(0)));
        pc.strSelected = strSelected;
        pc.PreviewEmail();
        pc.selectAll();
        pc.unselectAll();
        pc.refreshAssignedVolunteer();
        pc.selectAll();
        pc.sendEmailInBatch();
        pc.back();  
        
        /*List<Assigned_Volunteer__c> pList = [SELECT Id, Name, Volunteer_Request__c, Assignee_Status__c FROM Assigned_Volunteer__c WHERE Volunteer_Request__c = :progList.get(0).Id];
        
        ApexPages.CurrentPage().getParameters().put('id', pList.get(0).Id);
		VRAcceptDeclineController ar = new VRAcceptDeclineController(new ApexPages.StandardController(pList.get(0))); 
        ar.acceptVolunteer();
        ar.declineVolunteer();
        ar.back();*/
        Test.stopTest();
    }
}