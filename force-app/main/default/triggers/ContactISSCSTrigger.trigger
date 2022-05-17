trigger ContactISSCSTrigger on Contact (before insert, after insert, before update, after update) {
    List<Contact> newRecord_ISSCS_filtered = new List<Contact>();
    List<Contact> oldRecord_ISSCS_filtered = new List<Contact>();
    Map<Id, Contact> oldRecord_map_ISSCS_filtered = new Map<Id, Contact>();

    // filter only ISS and CS
    if(Trigger.new.size() > 0){
        for(Contact cItem : Trigger.new){
            if(cItem.CS_Enquiry__c || cItem.ISS_Enquiry__c){
                newRecord_ISSCS_filtered.add(cItem);
            }
        }
    }


    if(Trigger.old?.size() > 0){
        for(Contact cItem : Trigger.old){
            if(cItem.CS_Enquiry__c || cItem.ISS_Enquiry__c ){
                oldRecord_ISSCS_filtered.add(cItem);
            }
        }
    }


    if(Trigger.oldMap?.size() > 0){
        for(Id mapId : Trigger.oldMap.keySet()){
            if( Trigger.oldMap.get(mapId).ISS_Enquiry__c || Trigger.oldMap.get(mapId).CS_Enquiry__c){
                oldRecord_map_ISSCS_filtered.put(mapId, Trigger.oldMap.get(mapId));
            }
        }
    }

    if(newRecord_ISSCS_filtered.size() > 0){
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                ContactISSCSTriggerHandler.createAccount(newRecord_ISSCS_filtered);
            }
            when else {
                
            }
        }

    }





}