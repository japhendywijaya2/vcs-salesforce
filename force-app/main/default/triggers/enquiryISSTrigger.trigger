trigger enquiryISSTrigger on Enquiry__c (before insert, after insert) {
    Id issRecordTypeId = Schema.SObjectType.Enquiry__c.getRecordTypeInfosByName().get('Enquiry - ISS').getRecordTypeId();

    // filtering the records that will be processed with this Enquiry ISS Trigger
    // for every trigger sequence (before insert, after insert, etc), the list / map compile will be done over again
    List<Enquiry__c> issEnquiryList = new List<Enquiry__c>();
    Map<Id, Enquiry__c> issEnquiryNewMap = new Map<Id, Enquiry__c>();
    Map<Id, Enquiry__c> issEnquiryOldMap = new Map<Id, Enquiry__c>();

    if(Trigger.new.size() > 0){
        for(Enquiry__c eItem : Trigger.new){
            if(eItem.RecordTypeId == issRecordTypeId){
                issEnquiryList.add(eItem);
            }
        }
    }

    if(Trigger.newMap?.size() > 0){
        issEnquiryNewMap = Trigger.newMap;
        for(Id recordId : issEnquiryNewMap.keySet()){
            if(Trigger.newMap.get(recordId).RecordTypeId != issRecordTypeId){
                issEnquiryNewMap.remove(recordId);
            }
        }
    }

    if(Trigger.oldMap?.size() > 0){
        issEnquiryOldMap = Trigger.oldMap;
        for(Id recordId : issEnquiryOldMap.keySet()){
            if(issEnquiryOldMap.get(recordId).RecordTypeId != issRecordTypeId){
                issEnquiryOldMap.remove(recordId);
            }
        }
    }
    
    // tests to see if the compile is correct
    // safe to be removed at all
    // System.debug('\n\nnissEnquiryList size \n' + issEnquiryList.size());
    // System.debug('\nissEnquiryList \n' + issEnquiryList);
    // System.debug('\n\nissEnquiryNewMap size \n' + issEnquiryNewMap.size());
    // System.debug('\nissEnquiryNewMap \n' + issEnquiryNewMap);
    
    // Process only records with record type of 'Enquiry - ISS'
    if(issEnquiryList.size() > 0) {
        switch on Trigger.operationType {
            when BEFORE_INSERT {
            }
            when AFTER_INSERT {
                enquiryISSTriggerHandler.setContactandIntake(issEnquiryList);
                enquiryISSTriggerHandler.setNeedAssessment(issEnquiryList);
            }
            when else {
                
            }
        }
                
    }
    


}