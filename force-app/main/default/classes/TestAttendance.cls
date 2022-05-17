@isTest
public class TestAttendance {
	@isTest
    public static void testcalculatevolunteerhours(){
        Account org = new Account(
        		Name = 'Organisation',
        		RecordTypeId = Utils.GetRecordTypeId('Account', 'Organisation'));
        insert org;
		Contact con = new Contact (
            	AccountId = org.Id,
                LastName = 'AccountTest',
                Email = 'test@test.test',
                HomePhone = '90077765',
            	Organisation_Name__c = 'Interaktiv',
                //ID_No__c = 'dystem',
            	RecordTypeId = Utils.GetRecordTypeId('Contact', 'Contact')
                );
        Contact con1 = new Contact (
                LastName = 'Testing',
                RecordTypeId = Utils.GetRecordTypeId('Contact', 'Individual'),
                //c.Email_Personal__c = 'testing@interaktiv.sg';
                Email = 'testingers@interaktiv.sg',
                Donor_Type__c = 'Individual'
                );
        Contact con3 = new Contact (
            	AccountId = org.Id,
                LastName = 'AccountTest',
                Email = 'test2@test.test',
                HomePhone = '90074765',
            	Organisation_Name__c = 'Hostel',
                //ID_No__c = 'dystem',
            	RecordTypeId = Utils.GetRecordTypeId('Contact', 'Contact')
                );
        test.startTest();
        insert con;
        insert con1;
        insert con3;
        
		Attendance__c att = new Attendance__c();
		att.Contact__c = con.id;
		att.Checked_In__c = Datetime.now();
		att.Checked_Out__c = Datetime.now().addHours(5);
        att.Validated__c = true;
        insert(att);
        
        att.Checked_Out__c = Datetime.now().addHours(8);
        update(att);
        
        att.Contact__c = con1.Id;
        update(att);
        
        delete(att);
        
        Attendance__c att1 = new Attendance__c();
		//att1.Organisation_Name__c = org.id;
		att1.Checked_In__c = Datetime.now();
		att1.Checked_Out__c = Datetime.now().addHours(5);
        att1.Validated__c = true;
        insert(att1);
  //      org = [SELECT Id, Volunteering_Mins_No_Name_Volunteer__c FROM Account WHERE id =:org.Id];
  //      system.assertEquals(5*60, org.Volunteering_Mins_No_Name_Volunteer__c);
        
        att1.Checked_Out__c = Datetime.now().addHours(8);
        update(att1);
        
        
        
        delete(att1);
        test.stopTest();
    }
}