trigger AttendanceTrigger on Attendance__c (before insert, before update, after insert, after update, before delete) {
    if(trigger.isBefore){
        if(!trigger.isdelete){
            AttendanceClass.updateVolunteerName(trigger.new, trigger.oldMap);
        }else{
            AttendanceClass.calcuateVolunteerHours(trigger.new, trigger.oldMap);
        }
    }
    if(trigger.isAfter){
        if(!trigger.isdelete){
            AttendanceClass.calcuateVolunteerHours(trigger.new, trigger.oldMap);
        }
        if(trigger.isInsert){
            AttendanceClass.setLastAssignmentDate(trigger.new);
        }
    }
}