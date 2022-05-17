public with sharing class NeedAssessmentTriggerHandler {

    public static void updateIntakeIDandEnquiryID(List<Needs_Assessment__c> newRecords) {
        try {
            // TODO: update to bulkified
            List<Needs_Assessment__c> naAfterInserts = new List<Needs_Assessment__c>();
 
            for (Needs_Assessment__c nAItem: newRecords) {
                if (String.isNotBlank(nAItem.Intake_No__c)) {
                    List<Intake__c> intakeRecord = [SELECT Id, Name, Enquiry_No__c, Client_Name__c FROM Intake__c WHERE Id = :nAItem.Intake_No__c];

                    Id enqId;
                    Id clientId;

                    for (Intake__c iItem: intakeRecord ){
                        enqId = iItem.Enquiry_No__c;
                        clientId = iItem.Client_Name__c;
                    }

                    Needs_Assessment__c naNew = new Needs_Assessment__c(Id = nAItem.Id);
                    
                    naNew.Enquiry_Id__c = enqId;
                    naNew.Client_Name__c = clientId;

                    naAfterInserts.add(naNew);
                } 
            }   

            Database.update(naAfterInserts, false);
            
        } catch (Exception err) {
            System.debug('\n\nError NeedsAssessment Handler');
            System.debug('Message : ' + err.getMessage());
            System.debug('Line Number : ' + err.getLineNumber());
            Trigger.new[0].addError(err.getMessage());
        }
    }

    // TODO: change to bulkified
    public static void generateQuestions(Needs_Assessment__c[] newRecords) {
        List<Integer> orderQuestions = new List<Integer>();

        // set selection all question from order number 1 to 44, 
        // 1 - 22, need assessment question
        // 23 - 37, other communication skill
        // 38 - 44, first row
        for (Integer i = 1 ; i <= 47 ; i++) {
            orderQuestions.Add(i);
        }
        
        for (Needs_Assessment__c naItem: newRecords) {
            // create list question for need assessmet

            List<Question__c> questions = [SELECT Id, Name FROM Question__c WHERE Order_Number__c IN :orderQuestions ORDER BY Order_Number__c ASC];

            // create new Questionaire items
            List<Questionnaire_Item__c> insertQuestionaires = new List<Questionnaire_Item__c>();

            // comparing with question items created before
            List<Questionnaire_Item__c> existsQuestionaires = [SELECT Id, Name, Assessment_Questionnaire__r.Order_Number__c, Needs_Assessment__c, Needs_Assessment__r.Name 
                FROM Questionnaire_Item__c 
                WHERE Needs_Assessment__c = :naItem.Id
                ORDER BY Assessment_Questionnaire__r.Order_Number__c ASC];

            for(Question__c qItem: questions) {
                Boolean exist = false;
                
                // check existing questionaire
                // avoid duplicate question in need assessment
                for (Questionnaire_Item__c existQItem: existsQuestionaires) {
                    if (existQItem.Assessment_Questionnaire__r.Order_Number__c == qItem.Order_Number__c) {
                        exist = true;
                        break;
                    }
                }

                if(exist) {
                    continue;
                } else {
                    insertQuestionaires.Add(new Questionnaire_Item__c(
                        Needs_Assessment__c = naItem.Id,
                        Assessment_Questionnaire__c = qItem.Id
                    ));
                }
            }

            Database.SaveResult[] saveResult = Database.insert(insertQuestionaires, false);
            for (Database.SaveResult sr : saveResult) {
                if (sr.isSuccess()) {
                    System.debug('success insert data questionaire\n' + sr);
                } else {
                    System.debug('error insert data question in need assessmnet enquiry\n' + sr.getErrors());
                }
            }
        }

    }   
}