trigger TaskTrigger on Task (before update, after update) {
	if(trigger.isBefore){
        TaskClass.updateStatusafter3rdMissedCall(trigger.new,trigger.oldMap);
        TaskClass.updateAccepted(trigger.new,trigger.oldMap);
    }
    if(trigger.isAfter){
        TaskClass.updateContactCall(trigger.new,trigger.oldMap);
        TaskClass.createOrientation(trigger.new,trigger.oldMap);
    }
}