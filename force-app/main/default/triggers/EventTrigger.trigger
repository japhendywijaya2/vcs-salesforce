trigger EventTrigger on Event (before insert) {
	EventClass.renameScheduledOrietation(trigger.new, trigger.oldMap);
}