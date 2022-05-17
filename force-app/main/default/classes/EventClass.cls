public class EventClass {
    public static void renameScheduledOrietation(List<Event> newList,Map<Id, Event> oldMap){
        Set<Id> cIds = new Set<Id>();
        Id recordIDSO = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Scheduled Orientation').getRecordTypeId();
        for(Event e : newList){
            if(!e.Subject.contains('Scheduled') && e.RecordTypeId == recordIdSO){
                e.Subject = 'Scheduled '+e.subject;
            }
        }
    }
}