@isTest
public class ProgrammeEventClassTest {
	@isTest
    public static void updateProgram() {
		Programme_Events__c programEventObj= new Programme_Events__c(
        name='testing1',
        Engagement_Type__c='Direct',
        Programme_Description__c='Test',
        Event_Attire__c='Casual',
        Venue_of_Event_or_Mobilisation__c='test',
        Start_Date_Time__c= Date.today(),
        End_Date_Time__c= Date.today(),
        Active_Birthday_Programme__c = true
        );
        insert programEventObj;
        
        Programme_Events__c programEventObj1= new Programme_Events__c(
        name='testing2',
        Engagement_Type__c='Direct',
        Programme_Description__c='Test',
        Event_Attire__c='Casual',
        Venue_of_Event_or_Mobilisation__c='test',
        Start_Date_Time__c= Date.today(),
        End_Date_Time__c= Date.today(),
        Active_Birthday_Programme__c = true
        );
        insert programEventObj1;
        
        Programme_Events__c programEventObj2= new Programme_Events__c(
        name='testin3g',
        Engagement_Type__c='Direct',
        Programme_Description__c='Test',
        Event_Attire__c='Casual',
        Venue_of_Event_or_Mobilisation__c='test',
        Start_Date_Time__c= Datetime.now().addDays(1),
        End_Date_Time__c= Datetime.now().addDays(3),
        Active_Birthday_Programme__c = false
        );
        insert programEventObj2;
        
        Programme_Events__c programEventObj3= new Programme_Events__c(
        name='testing1',
        Engagement_Type__c='Direct',
        Programme_Description__c='Test',
        Event_Attire__c='Casual',
        Venue_of_Event_or_Mobilisation__c='test',
        Start_Date_Time__c= Datetime.now().addDays(-2),
        End_Date_Time__c= Datetime.now().addDays(-1),
        Active_Birthday_Programme__c = true
        );
        insert programEventObj3;
        
        Programme_Events__c programEventObj4= new Programme_Events__c(
        name='testing1',
        Engagement_Type__c='Direct',
        Programme_Description__c='Test',
        Event_Attire__c='Casual',
        Venue_of_Event_or_Mobilisation__c='test',
        Active_Birthday_Programme__c = true
        );
        insert programEventObj4;
        
        //Update Started
        
        programEventObj2.Cancel_Programme_Event__c = true;
        programEventObj2.Active_Birthday_Programme__c = true;
        programEventObj2.Start_Date_Time__c= Date.today();
        programEventObj2.End_Date_Time__c= Date.today();
        update programEventObj2;
        
        //Update Ended
        programEventObj1.Start_Date_Time__c= Datetime.now().addDays(-2);
        programEventObj1.End_Date_Time__c= Datetime.now().addDays(-1);
        update programEventObj1;
        
        //Update Planned
        programEventObj.Start_Date_Time__c= Datetime.now().addDays(1);
        programEventObj.End_Date_Time__c= Datetime.now().addDays(3);
        update programEventObj;
        
        //Cancel
        programEventObj2.Cancel_Programme_Event__c = true;
        programEventObj2.Active_Birthday_Programme__c = true;
        update programEventObj2;
    }
}