trigger IntakeTrigger on Intake__c (before insert, after insert, before update, after update) {
    Id issRecordTypeId = Schema.SObjectType.Intake__c.getRecordTypeInfosByName().get('Intake - ISS').getRecordTypeId();

    // filtering the records that will be processed with this Enquiry ISS Trigger
    // for every trigger sequence (before insert, after insert, etc), the list / map compile will be done over again
    List<Intake__c> issIntakeList = new List<Intake__c>();
    Map<Id, Intake__c> issIntakeNewMap = new Map<Id, Intake__c>();
    Map<Id, Intake__c> issIntakeOldMap = new Map<Id, Intake__c>();

    if(Trigger.new.size() > 0){
        for(Intake__c eItem : Trigger.new){
            if(eItem.RecordTypeId == issRecordTypeId){
                issIntakeList.add(eItem);
            }
        }
    }

    if(Trigger.newMap?.size() > 0){
        issIntakeNewMap = Trigger.newMap;
        for(Id recordId : issIntakeNewMap.keySet()){
            if(Trigger.newMap.get(recordId).RecordTypeId != issRecordTypeId){
                issIntakeNewMap.remove(recordId);
            }
        }
    }

    if(Trigger.oldMap?.size() > 0){
        issIntakeOldMap = Trigger.oldMap;
        for(Id recordId : issIntakeOldMap.keySet()){
            if(issIntakeOldMap.get(recordId).RecordTypeId != issRecordTypeId){
                issIntakeOldMap.remove(recordId);
            }
        }
    }

    switch on Trigger.operationType {
        when BEFORE_UPDATE {
            IntakeTriggerHandler.UpdateIntakeStatus(issIntakeList);
        }
        when else {
            
        }
    }


}