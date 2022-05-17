trigger ContactTrigger on Contact (before insert, after insert, before update, after update) {
    
    List<Contact> newRecord_DVMS_filtered = new List<Contact>();
    List<Contact> oldRecord_DVMS_filtered = new List<Contact>();
    Map<Id, Contact> oldRecord_map_DVMS_filtered = new Map<Id, Contact>();


    // first filtering
    if(Trigger.new.size() > 0){
        for(Contact cItem : Trigger.new){
            if(cItem.Donor__c || cItem.Volunteer__c){
                newRecord_DVMS_filtered.add(cItem);
            }
        }
    }


    if(Trigger.old?.size() > 0){
        for(Contact cItem : Trigger.old){
            if(cItem.Donor__c || cItem.Volunteer__c){
                oldRecord_DVMS_filtered.add(cItem);
            }
        }
    }


    if(Trigger.oldMap?.size() > 0){
        for(Id mapId : Trigger.oldMap.keySet()){
            if( Trigger.oldMap.get(mapId).Donor__c || Trigger.oldMap.get(mapId).Volunteer__c){
                oldRecord_map_DVMS_filtered.put(mapId, Trigger.oldMap.get(mapId));
            }
        }
    }


    if(newRecord_DVMS_filtered.size() > 0){
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                ContactTriggerHandler.checkEmailUnique(newRecord_DVMS_filtered);
                ContactTriggerHandler.createAccount(newRecord_DVMS_filtered);
                ContactTriggerHandler.setVolunteerStatus(newRecord_DVMS_filtered);
            }
    
            when AFTER_INSERT{
                ContactTriggerHandler.sendWelcomeEmailFirstTime(newRecord_DVMS_filtered); 
                ContactTriggerHandler.createTask(newRecord_DVMS_filtered);
            }
            when BEFORE_UPDATE{
                ContactTriggerHandler.setVolunteerStatus(newRecord_DVMS_filtered);
            }
            when AFTER_UPDATE{
                ContactTriggerHandler.sendWelcomeEmailUpdate(newRecord_DVMS_filtered, oldRecord_map_DVMS_filtered);
                ContactTriggerHandler.createTask(newRecord_DVMS_filtered, oldRecord_map_DVMS_filtered);
            }
            when else {
                
            }
        }

    }
    
}