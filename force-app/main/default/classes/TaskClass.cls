public class TaskClass {
	public static void updateAccepted(List<Task> newList,Map<Id, Task> oldMap){
        for(Task t : newList){
            if(t.Interview_Outcome__c <> null && t.Interview_Outcome__c <> oldMap.get(t.Id).Interview_Outcome__c){
                t.Status = 'Completed';
            }
        }
    }
    public static void updateStatusafter3rdMissedCall(List<Task> newList,Map<Id, Task> oldMap){
        for(Task t : newList){
            if(t.Missed_Cal__c <> oldMap.get(t.Id).Missed_Cal__c && t.Missed_Cal__c == '3rd Call' && t.Status <> 'Completed'){
                t.Interview_Outcome__c = 'Declined';
                t.Decline_Reason__c = 'Can not be reached';
                //t.Status__c = 'Completed';
            }
        }
    }
    
    public static void updateContactCall(List<Task> newList,Map<Id, Task> oldMap){
        Set<Id>contactIds = new Set<Id>();
        for(Task t : newList){
            if(t.Missed_Cal__c <> null && t.Missed_Cal__c <> oldMap.get(t.Id).Missed_Cal__c){
                contactIds.add(t.WhoId);
            }
            if((t.Interview_Outcome__c == 'Declined' || oldMap.get(t.Id).Interview_Outcome__c == 'Declined') && oldMap.get(t.Id).Interview_Outcome__c <> t.Interview_Outcome__c){
                system.debug('=====debug 1======');
                contactIds.add(t.WhoId);
            }
        }
        if(contactIds.size() > 0){
            Map<Id, Contact> contMap = new Map<Id, Contact>([SELECT Id, Name, Date_of_First_Call__c, Date_of_Second_Call__c, Date_of_Third_Call__c,Volunteer_Status__c, Assignment_Status__c, Reason_of_Declined__c
                                                             FROM Contact WHERE Id IN :contactIds]);
            List<Contact> updatedContact = new List<Contact>();
            for(Task t : newList){
                if(t.Missed_Cal__c <> null && t.Missed_Cal__c <> oldMap.get(t.Id).Missed_Cal__c ){
                    Contact c = contMap.get(t.WhoId);
                    if(t.Missed_Cal__c == '1st Call'){
                        c.Date_of_First_Call__c = Date.today();
                    }else if(t.Missed_Cal__c == '2nd Call'){
                        c.Date_of_Second_Call__c = Date.today();
                    }else if(t.Missed_Cal__c == '3rd Call'){
                        c.Date_of_Third_Call__c = date.today();
                        c.Volunteer_Status__c = 'Declined'; 
                        c.Assignment_Status__c = 'Unavailable'; 
                    }
                    contMap.put(c.Id, c);
            	}
                if(t.Interview_Outcome__c == 'Declined' && t.Interview_Outcome__c <> oldMap.get(t.Id).Interview_Outcome__c){
                    Contact c = contMap.get(t.WhoId);
                    system.debug('=====debug 2======');
                    //Volunteer_Status__c = 'Declined'; 
                    //Assignment_Status__c = 'Unavailable'; 
                    c.Volunteer_Accepted_Date__c = null;
                    if(t.Decline_Reason__c != null){
                        c.Reason_of_Declined__c = t.Decline_Reason__c;
                    }else{
                        c.Reason_of_Declined__c = 'Interview Declined';
                    }
                    
                    contMap.put(c.Id, c);
                }
                if(oldMap.get(t.Id).Interview_Outcome__c == 'Declined' && t.Interview_Outcome__c <> oldMap.get(t.Id).Interview_Outcome__c){
                    Contact c = contMap.get(t.WhoId);
                    //Volunteer_Status__c = 'Declined'; 
                    //Assignment_Status__c = 'Unavailable'; 
                    c.Reason_of_Declined__c = null;
                    contMap.put(c.Id, c);
                }
            }
            update(contMap.values());
        }
    }
    
    public static void createOrientation(List<Task> newList,Map<Id, Task> oldMap){
        List<Task> updatedTask = new List<Task>();
        for(Task t : newList){
            if(t.Interview_Outcome__c == 'Accepted' && t.Interview_Outcome__c <> oldMap.get(t.Id).Interview_Outcome__c){
                updatedTask.add(t);
            }
        }
        if(updatedTask.size() > 0){
            Datetime dt = Datetime.now();
            if(dt.format('EEEE') == 'Friday'){
                dt.addDays(2);
            }else if(dt.format('EEEE') == 'Saturday'){
                dt.addDays(1);
            }else{
            }
            Set<Id>contactIds = new Set<Id>();
            for(Task taskRecord : updatedTask){
                contactIds.add(taskRecord.WhoId);
            }
            Map<Id, Contact> contMap = new Map<Id, Contact>([SELECT Id, Name FROM Contact WHERE Id IN :contactIds]);
            Map<Id, boolean> existFlag = new Map<Id, boolean>();
            List<Event> activeEvents = [SELECT Id, WhoId, Event_Status__c FROM Event 
                                        WHERE WhoId IN :contactIds AND (Event_Status__c <> 'Completed' AND Event_Status__c <> 'Declined') 
                                        AND RecordType.Name = 'Regular Orientation'];
            if(activeEvents != null){
                for(Event e : activeEvents){
                    existFlag.put(e.WhoId, true);
                }
            }
            
            List<Event> scheduledOrientationList = [SELECT Id, StartDateTime, EndDateTime
                                     FROM Event 
                                     WHERE StartDateTime >= :dt.addDays(3) AND RecordType.Name = 'Scheduled Orientation' ORDER BY StartDateTime ASC LIMIT 1 ];
            Id RegOrientationRT = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Regular Orientation').getRecordTypeId();
            Id AdHocOrientationRT = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Ad-Hoc Orientation').getRecordTypeId();
            List<Event> newEventList = new List<Event>();
            List<Contact> acceptedContList = new List<Contact>();
            Event scheduledOrientation = new Event();
            if(scheduledOrientationList.size() > 0){
                scheduledOrientation = scheduledOrientationList.get(0);
            }
            for(Task taskRecord : updatedTask){
                if(existFlag == null || existFlag.get(taskRecord.WhoId) <> true){
                    Event eventRecord = new Event();
                    eventRecord.Type = 'Email';
                    eventRecord.WhoId = taskRecord.whoId;
                    eventRecord.WhatId = taskRecord.whatId;
                    eventRecord.Event_Status__c = 'Not Started';
                    eventRecord.Location = 'Sadeaf Office';
                    Date orientationDate;
                    if(taskRecord.Orientation_Datetime__c != null){
                        eventRecord.Subject = 'Ad-Hoc Orientation for'+' '+contMap.get(taskRecord.whoId).Name;
                        eventRecord.recordtypeId = AdHocOrientationRT;
                        //eventRecord.Orientation_Date__c = taskRecord.Orientation_Datetime__c.date();
                        eventRecord.ActivityDateTime = taskRecord.Orientation_Datetime__c;
                        eventRecord.StartDateTime = taskRecord.Orientation_Datetime__c;
                        eventRecord.EndDateTime = taskRecord.Orientation_End_Datetime__c; 
                        orientationDate = taskRecord.Orientation_Datetime__c.date();
                    }else if(scheduledOrientation != null){
                        eventRecord.recordtypeId = RegOrientationRT;
                        eventRecord.Subject = 'Orientation for'+' '+contMap.get(taskRecord.whoId).Name;
                        //eventRecord.Orientation_Date__c = Date.newInstance(scheduledOrientation.StartDateTime.year(), scheduledOrientation.StartDateTime.month(), scheduledOrientation.StartDateTime.day());
                        eventRecord.ActivityDateTime = scheduledOrientation.StartDateTime;
                        eventRecord.StartDateTime = scheduledOrientation.StartDateTime;
                        eventRecord.EndDateTime = scheduledOrientation.EndDateTime;
                        orientationDate = scheduledOrientation.StartDateTime.date();
                    }else{
                        eventRecord.Subject = 'Ad-Hoc Orientation for'+' '+contMap.get(taskRecord.whoId).Name;
                        eventRecord.recordtypeId = AdHocOrientationRT;
                        //eventRecord.Orientation_Date__c = Date.newInstance(dt.addDays(3).year(), dt.addDays(3).month(), dt.addDays(3).day());
                        eventRecord.ActivityDateTime = dt.addDays(3);
                        eventRecord.StartDateTime = Date.newInstance(dt.addDays(3).year(), dt.addDays(3).month(), dt.addDays(3).day());
                        eventRecord.DurationInMinutes = 60; 
                        orientationDate = dt.addDays(3).date();
                    }
                    eventRecord.Description = 'Orientation for selected Volunteer'; //string
                    //eventRecord.Interview_Outcome__c = 'Accepted';
                    eventRecord.OwnerId = UserInfo.getUserId(); //user id
                    
                    //eventRecord.ActivityDateTime  =  taskRecord.Orientation_Date__c;  
                    eventRecord.Send_Orientation_Invitation__c = taskRecord.Send_Orientation_Invitation__c;
                    newEventList.add(eventRecord);
                    
                    Contact c = contMap.get(taskRecord.whoId);
                    c.Volunteer_Status__c = 'Accepted'; 
                    c.Assignment_Status__c = 'Pending';
                    c.Volunteer_Activity_Status__c = 'Pending';
                    c.Volunteer__c = true;
                    c.Orientation_Created__c = true;
                    c.Volunteer_Accepted_Date__c = date.today();
                    c.Date_of_Orientation_Session__c = orientationdate;
                    acceptedContList.add(c);
                } 
            }
            if(newEventList.size() > 0){
                insert newEventList;  
            }
            if(acceptedContList.size() > 0){
                update acceptedContList;  
            }
        }
    }
}