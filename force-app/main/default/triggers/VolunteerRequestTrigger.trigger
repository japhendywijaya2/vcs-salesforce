trigger VolunteerRequestTrigger on Volunteer_Request__c (before insert, before update) {
	VolunteerRequestClass.updateVRStatus(trigger.new, trigger.oldMap);
    VolunteerRequestClass.cancelVR(trigger.new);
}