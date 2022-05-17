trigger NeedAssessmentTrigger on Needs_Assessment__c (before insert, after insert) {
    List<Needs_Assessment__c> newRecordList = Trigger.new;
    List<Needs_Assessment__c> oldRecordList = Trigger.old;
    
    switch on Trigger.operationType {
        when AFTER_INSERT {
            NeedAssessmentTriggerHandler.updateIntakeIDandEnquiryID(newRecordList);
            NeedAssessmentTriggerHandler.generateQuestions(newRecordList);
        }
        when else {
            
        }
    }

}