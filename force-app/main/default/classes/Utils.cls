public class Utils {
    /*
	public static String searchbyDevCode(String devCode) {
        string msg = 'Error not set in the Error Message object';
        List<Error_Code__c> lstE = [SELECT Error_Message__c,name FROM Error_Code__c WHERE Dev_Code__c =:devCode];
        for(Error_Code__c e:lstE ){
            msg = e.Name + ' : ' + e.Error_Message__c;
        }
        return msg;
    } */
    
    public static id GetRecordTypeId(string objectAPIName, string recordTypeName){
        Map<String, Schema.SObjectType> sobjectSchemaMap = Schema.getGlobalDescribe();
        
        Schema.SObjectType sObjType = sobjectSchemaMap.get(objectAPIName) ;
        Schema.DescribeSObjectResult cfrSchema = sObjType.getDescribe() ;
        Map<String,Schema.RecordTypeInfo> RecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id recordTypeId = RecordTypeInfo.get(recordTypeName).getRecordTypeId();
        return recordTypeId;
    }


    @future
    public static void sendMassEmail(List<Id> contactIdList, String emailTemplateName){
        try {
            EmailTemplate emailTemplateRecord = [
                SELECT Id
                FROM EmailTemplate
                WHERE Name = :emailTemplateName
            ];
    
            
            Messaging.MassEmailMessage massEmail = new Messaging.MassEmailMessage();
            massEmail.setTargetObjectIds(contactIdList);
            massEmail.setTemplateId(emailTemplateRecord.id);
            
            Messaging.reserveMassEmailCapacity(contactIdList.size());
            Messaging.sendEmail(new Messaging.MassEmailMessage[] {massEmail}, false);


        } catch (Exception e) {
            System.Debug('\n\nsendMassEmail error \n' + e);
        }
    }


    // This method is run in sync mode
    public static void sendSingleEmailTemplate(Id targetContactId, String emailTemplateName, Id whatId){
        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();

        EmailTemplate emailTemplateRecord = [
            SELECT Id
            FROM EmailTemplate
            WHERE Name = :emailTemplateName
        ];

        singleEmail.setTargetObjectId(targetContactId);
        singleEmail.setTemplateId(emailTemplateRecord.id);
        singleEmail.setWhatId(whatId);
        
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{singleEmail});
    }


    

}