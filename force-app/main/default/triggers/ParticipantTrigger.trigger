trigger ParticipantTrigger on Participant__c (before insert, before update, after update) {
    if(trigger.isBefore){
        ParticipantClass.updateUpload(trigger.new);
        ParticipantClass.updateStatus(trigger.new, trigger.oldMap);
        ParticipantClass.setAttendanceTimestamp(trigger.new, trigger.oldMap);
        if(trigger.isInsert){
            ParticipantClass.validateDuplicate(trigger.new);
        }
    }
    if(trigger.isAfter){
        if(trigger.isUpdate){
        	ParticipantClass.updateAttended(trigger.New, trigger.oldMap);
    	}
    }
    
}