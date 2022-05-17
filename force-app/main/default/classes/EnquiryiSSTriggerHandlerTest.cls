@isTest
public class EnquiryiSSTriggerHandlerTest {
    @isTest
    public static void testEnqISSTrigger() {
        Enquiry__c newEnquiry = new Enquiry__c(
            Client_Email__c = 'testtest@mail.com',
            ClientNameEntered__c = 'testtest',
            Full_Name_Referrer__c = 'referrer-test',
            Email_Refererrer__c = 'referrer-test@mail.com',
            Designation__c = 'designation',
            Direct_Contact_No__c = '111111',
            Name_of_Organisation__c = 'testaktiv',
            Department__c = 'testing',
            Enquiry_Option__c = 'LS Services'
        );

        Database.SaveResult saveResult  = Database.insert(newEnquiry);
        System.assertEquals(true, saveResult.isSuccess());
    }
}