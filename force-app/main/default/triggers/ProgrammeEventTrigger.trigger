trigger ProgrammeEventTrigger on Programme_Events__c (before insert, before update) {
	ProgrammeEventClass.updateProgrammeStage(trigger.new, trigger.oldMap);
    ProgrammeEventClass.cancelProgramme(trigger.new);
    ProgrammeEventClass.updateActiveBirthdayProgramme(trigger.new, trigger.oldMap);
}