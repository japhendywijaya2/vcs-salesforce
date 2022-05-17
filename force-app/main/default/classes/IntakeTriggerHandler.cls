public with sharing class IntakeTriggerHandler {
    
    // TODO: update to bulkified
    public static void UpdateIntakeStatus(List<Intake__c> newRecordList) {
        for (Intake__c intakeItem : newRecordList) {        
            if(intakeItem.Approved__c == true && intakeItem.Verifier_Email__c != null && intakeItem.Approver_Email__c != null) {
               intakeItem.Intake_Status__c = 'Proceed';
            } else if (intakeItem.Verifier_Email__c != null && intakeItem.Approver_Email__c != null) {
                intakeItem.Intake_Status__c = 'Processing';
            }
        }
    }
       
}