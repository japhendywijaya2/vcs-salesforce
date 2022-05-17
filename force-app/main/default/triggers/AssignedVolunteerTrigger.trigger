trigger AssignedVolunteerTrigger on Assigned_Volunteer__c (before insert, before update) {
	AssignedVolunteerClass.updateUpload(trigger.new);
    AssignedVolunteerClass.updateVolunteerName(trigger.new, trigger.oldMap);
    AssignedVolunteerClass.updateStatus(trigger.new);
    AssignedVolunteerClass.updateDate(trigger.new);
    if(trigger.isInsert){
        AssignedVolunteerClass.validateDuplicate(trigger.new);
    }
}