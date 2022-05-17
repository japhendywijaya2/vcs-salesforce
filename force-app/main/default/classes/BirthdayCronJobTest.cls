@isTest
class BirthdayCronJobTest {

	static testmethod void test() {
		
		Integer testMonth = date.today().month();
		Integer testDay = date.today().day();
		BirthdayCronJob BCJ = new BirthdayCronJob(); 
		
		//BCJ.sendMail(); 
		Programme_Events__c programEventObj= new Programme_Events__c(
        name='testing1',
        Engagement_Type__c='Direct',
        Programme_Description__c='Test',
        Event_Attire__c='Casual',
        Venue_of_Event_or_Mobilisation__c='test',
        Start_Date_Time__c= Date.today().addDays(-30),
        End_Date_Time__c= Date.today().addDays(30),
        Active_Birthday_Programme__c = true
        );
        insert programEventObj;
        
		Contact testContact = new Contact();
		testContact.FirstName = 'Test';
		testContact.LastName = 'Contact';
		testContact.Email = 'romipaytm@gmail.com';
		testContact.Birthdate = date.today();
        testContact.Donor_Type__c = 'Individual';
		//testContact.Send_Birthday_Email__c    = true;
		
		insert testContact;
		
		
		//BCJ.sendMail();
		
		String CRON_EXP = '0 0 0 3 9 ? 2022';
		String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, new BirthdayCronJob());
        
		
		CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
							FROM CronTrigger 
							WHERE id = :jobId];
		System.assertEquals(CRON_EXP, ct.CronExpression);
	
		System.assertEquals(0, ct.TimesTriggered);
		
		//System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
		
		//delete testContact;
		
	}
}