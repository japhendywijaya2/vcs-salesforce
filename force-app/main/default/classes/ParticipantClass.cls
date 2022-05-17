public class ParticipantClass {
    public static void setAttendanceTimestamp(List<Participant__c> listNew, Map<Id, Participant__c> oldMap){
        for(Participant__c p : listNew){
            if(oldMap != null && oldMap.get(p.Id) != null){
                if(p.Status__c == 'Attended' && p.Status__c <> oldMap.get(p.Id).Status__c){
            		p.Date_Time_Stamp__c = Datetime.now();
            	}
            }else{
           		 if(p.Status__c == 'Attended'){
            		p.Date_Time_Stamp__c = Datetime.now();
            	}  
            }
        }
    }
    public static void validateDuplicate(List<Participant__c> listNew){
        Set<String> vNames = new Set<String>();
        for(Participant__c p : listNew){
            String contId = p.Contact_Name__c;
            String vrId = p.Programme_Event__c;
            if(!vNames.contains(contId.substring(0, contId.length()-3)+'|'+vrId.substring(0, vrId.length()-3))){
                vNames.add(contId.substring(0, contId.length()-3)+'|'+vrId.substring(0, vrId.length()-3));
            }else{
                p.addError(Label.ParticipantDuplicateError);
            }
        }
        
        List<Participant__c> avList = [SELECT Id, UniqueIdentifier__c FROM Participant__c WHERE UniqueIdentifier__c IN :vNames];
        if(avList != null){
            Set<String> existVol = new Set<String>();
            for(Participant__c p : avList){
                existVol.add(p.UniqueIdentifier__c);
            }
            for(Participant__c p : listNew){
                String contId = p.Contact_Name__c;
            	String vrId = p.Programme_Event__c;
            	if(existVol.contains(contId.substring(0, contId.length()-3)+'|'+vrId.substring(0, vrId.length()-3))){
                	p.addError(Label.ParticipantDuplicateError);
            	}
            }
        }
    }
    public static void updateUpload(List<Participant__c> newList){
        Set<String> emails = new Set<String>();
        Set<String> mobiles = new Set<String>();
        for(Participant__c p : newList){
            if(p.Uploaded__c){
                if(p.Email_Notification__c != null){
                	emails.add(p.Email_Notification__c); 
                }else{
                    p.addError('Email must be filled.');
                }
                if(p.Mobile__c != null){
                    mobiles.add(p.Mobile__c);
                }
            }
        }
        if(emails != null && emails.size() > 0){
            List<Contact> contList = [SELECT Id, Firstname, Lastname, Email, MobilePhone FROM Contact WHERE Email IN :emails OR MobilePhone IN :mobiles];
            Map<String, Contact> contMap = new Map<String, Contact>();
            for(Contact c : contList){
                contMap.put(c.Email, c);
                if(c.MobilePhone != null){
                    contMap.put(c.MobilePhone, c);
                }
            }
            List<Contact> insertContact = new List<Contact>();
            for(Participant__c p : newList){
                if(p.Uploaded__c && p.Email_Notification__c != null){
                    if(contMap != null && (contMap.get(p.Email_Notification__c) != null || contMap.get(p.Mobile__c) != null)){
                        if(contMap.get(p.Email_Notification__c) != null){
                            p.Contact_Name__c = contMap.get(p.Email_Notification__c).Id;
                        }else{
                            p.Contact_Name__c = contMap.get(p.Mobile__c).Id;
                        }
                    }else{
                        Contact c = new Contact();
                        //c.FirstName = p.Participant_Firstname__c;
                        c.LastName = p.Participant_Lastname__c;
                        c.Email = p.Email_Notification__c;
                        c.Donor_Type__c = 'Individual';
                        c.Volunteer_Status__c = 'Prospect';
                        //c.Volunteer_Category__c = 'Ad hoc Volunteer';
                        c.Volunteer__c = true;
                        c.MobilePhone = p.Mobile__c;
                        c.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
                        insertContact.add(c);
                    }
                }
            }
            if(insertContact != null){
                insert(insertContact);
                for(Contact c : insertContact){
                    contMap.put(c.Email, c);
                }
                for(Participant__c p : newList){
                    if(p.Uploaded__c && p.Email_Notification__c != null){
                        if(p.Contact_Name__c == null){
                            p.Contact_Name__c = contMap.get(p.Email_Notification__c).Id;
                        }
                        p.Uploaded__c = false;
                    }
                }
            }
        }
    }
    public static void updateStatus(List<Participant__c> newList, Map<Id, Participant__c> oldMap){
        for(Participant__c p : newList){
            /*if(oldMap != null && oldMap.get(p.Id) != null){
                if(p.Status__c == 'Registered'  && p.Status__c != oldMap.get(p.Id).Status__c){
                    p.Cancellation_Date__c = null;
                }
                if(p.Cancellation_Date__c != null && p.Cancellation_Date__c != oldMap.get(p.Id).Cancellation_Date__c){
                	p.Status__c = 'Cancel';
                }
                if(p.Withdraw_date__c != null && p.Withdraw_date__c != oldMap.get(p.Id).Withdraw_date__c){
                    p.Status__c = 'Withdraw';
                }
                if(p.Absent_Reason__c != null && p.Absent_Reason__c != oldMap.get(p.Id).Absent_Reason__c){
                    p.Status__c = 'Withdraw';
                }
                
            }else{*/
                if(p.Status__c == 'Registered'){
                    p.Cancellation_Date__c = null;
                }
                if(p.Cancellation_Date__c != null){
                	p.Status__c = 'Cancel';
                }
                if(p.Withdraw_date__c != null){
                    p.Status__c = 'Withdraw';
                }
                if(p.Absent_Reason__c != null){
                    p.Status__c = 'Withdraw';
                }
            //}
        }
    }
    
    public static void updateAttended(List<Participant__c> listNew, Map<Id, Participant__c> oldMap){
        Set<Id> contIds = new Set<Id>();
        for(Participant__c p : listNew){
            if(p.Status__c == 'Attended' && p.Status__c <> oldMap.get(p.Id).Status__c && p.Date_Time_Stamp__c != null){
                contIds.add(p.Contact_Name__c);
            }
        }system.debug('=======cIds======='+contIds.size());
        if(contIds.size() > 0){
            Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Last_Assignment_Date__c FROM Contact WHERE Id IN :contIds]);
            List<Contact> updatedContact = new List<Contact>();
            for(Participant__c p : listNew){
            	if(p.Status__c == 'Attended' && p.Status__c <> oldMap.get(p.Id).Status__c && p.Date_Time_Stamp__c != null){
                	Contact c = contactMap.get(p.Contact_Name__c);
                    if(c.Last_Assignment_Date__c == null || c.Last_Assignment_Date__c < p.Date_Time_Stamp__c.date()){
                        c.Last_Assignment_Date__c = p.Date_Time_Stamp__c.date();
                        updatedContact.add(c);
                    }
            	}
        	}
            if(updatedContact.size() > 0){
                update(updatedContact);
            }
        }
    }
}