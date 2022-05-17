public class AssignedVolunteerClass {
    public static void updateStatus(List<Assigned_Volunteer__c> listNew){
        for(Assigned_Volunteer__c p : listNew){
            if(p.Rejected_Date__c != null){
                p.Assignee_Status__c = 'Rejected';
            }if(p.Cancelled_Date__c != null){
                p.Assignee_Status__c = 'Cancelled';
            }else if(p.Withdrawn_Date__c != null){
                p.Assignee_Status__c = 'Withdraw';
            }else if(p.Rejected_Date__c != null){ //redundant
                p.Assignee_Status__c = 'Rejected';
            }else if(p.Accepted_Date__c != null){
                p.Assignee_Status__c = 'Accepted';
            }else if(p.Email_Sent__c != null){
                p.Assignee_Status__c = 'Contacted';
            }else{
                p.Assignee_Status__c = 'Selected';
            }
        }
    }
	public static void validateDuplicate(List<Assigned_Volunteer__c> listNew){
        Set<String> vNames = new Set<String>();
        for(Assigned_Volunteer__c p : listNew){
            String contId = p.Contact__c;
            String vrId = p.Volunteer_Request__c;
            if(!vNames.contains(contId.substring(0, contId.length()-3)+'|'+vrId.substring(0, vrId.length()-3))){
                vNames.add(contId.substring(0, contId.length()-3)+'|'+vrId.substring(0, vrId.length()-3));
            }else{
                p.addError(Label.AVDuplicateError);
            }
        }
        
        List<Assigned_Volunteer__c> avList = [SELECT Id, UniqueIdentifier__c FROM Assigned_Volunteer__c WHERE UniqueIdentifier__c IN :vNames];
        if(avList != null){
            Set<String> existVol = new Set<String>();
            for(Assigned_Volunteer__c p : avList){
                existVol.add(p.UniqueIdentifier__c);
            }
            for(Assigned_Volunteer__c p : listNew){
                String contId = p.Contact__c;
            	String vrId = p.Volunteer_Request__c;
            	if(existVol.contains(contId.substring(0, contId.length()-3)+'|'+vrId.substring(0, vrId.length()-3))){
                	p.addError(Label.AVDuplicateError);
            	}
            }
        }
    }
    public static void updateVolunteerName(List<Assigned_Volunteer__c> newList, Map<Id,Assigned_Volunteer__c>oldMap ){
        Set<Id> contIds = new Set<id>();
        for(Assigned_Volunteer__c p : newList){
            if(p.Contact__c != null){
                if(oldMap == null || oldMap.get(p.Id) == null){
                    contIds.add(p.Contact__c);
                }else{
                    if(p.Contact__c <> oldMap.get(p.Id).Contact__c){
                        contIds.add(p.Contact__c);
                    }
                }
            }
        }
        if(contIds != null){
            Map<Id, Contact> contMap = new Map<Id, Contact>([SELECT Id, Firstname, Lastname, Name, Email, MobilePhone FROM Contact WHERE Id IN :contIds]);
            for(Assigned_Volunteer__c p : newList){
                if(p.Contact__c != null){
                    if(oldMap == null || oldMap.get(p.Id) == null){
                        p.Name = contMap.get(p.Contact__c).Name;
                    }else{
                        if(p.Contact__c <> oldMap.get(p.Id).Contact__c){
                            p.Name = contMap.get(p.Contact__c).Name;
                        }
                    }
                }
            }
        }
    }
	    
	public static void updateUpload(List<Assigned_Volunteer__c> newList){
        Set<String> emails = new Set<String>();
        Set<String> mobiles = new Set<String>();
        for(Assigned_Volunteer__c p : newList){
            if(p.Uploaded__c){
                if(p.Email_Upload__c != null){
                	emails.add(p.Email_Upload__c); 
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
            for(Assigned_Volunteer__c p : newList){
                if(p.Uploaded__c && p.Email_Upload__c != null){
                    if(contMap != null && (contMap.get(p.Email_Upload__c) != null || contMap.get(p.Mobile__c) != null)){
                        if(contMap.get(p.Email_Upload__c) != null){
                            p.Contact__c = contMap.get(p.Email_Upload__c).Id;
                        }else{
                            p.Contact__c = contMap.get(p.Mobile__c).Id;
                        }
                    }else{
                        Contact c = new Contact();
                        //c.FirstName = p.Participant_Firstname__c;
                        c.LastName = p.Volunteer_Name_upload__c;
                        c.Email = p.Email_Upload__c;
                        c.MobilePhone = p.Mobile__c;
                        c.Donor_Type__c = 'Individual';
                        c.Volunteer_Status__c = 'Prospect';
                        //c.Volunteer_Category__c = 'Ad hoc Volunteer';
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
                for(Assigned_Volunteer__c p : newList){
                    if(p.Uploaded__c && p.Email_Upload__c != null){
                        if(p.Contact__c == null){
                            p.Contact__c = contMap.get(p.Email_Upload__c).Id;
                        }
                        p.Uploaded__c = false;
                    }
                }
            }
        }
    }
    public static void updateDate(List<Assigned_Volunteer__c> newList){
        Set<Id> vrIds = new Set<id>();
        for(Assigned_Volunteer__c a : newList){
            if(a.Start_Date__c == null || a.End_Date__c == null){
                vrIds.add(a.Volunteer_Request__c);
            }
        }
        if(vrIds != null){
            Map<Id, Volunteer_Request__c> vrMap = new Map <Id, Volunteer_Request__c>([SELECT Id, Start_Date__c, Start_Time__c, End_Date__c, End_Time__c FROM Volunteer_Request__c WHERE Id IN :vrIds]);
            for(Assigned_Volunteer__c a : newList){
                if(a.Start_Date__c == null){
                    a.Start_Date__c = vrMap.get(a.Volunteer_Request__c).Start_Date__c;
                }
                if(a.End_Date__c == null){
                    a.End_Date__c = vrMap.get(a.Volunteer_Request__c).End_Date__c;
                }
                if(a.Start_Time__c == null){
                    a.Start_Time__c = vrMap.get(a.Volunteer_Request__c).Start_Time__c;
                }
                if(a.End_Time__c == null){
                    a.End_Time__c = vrMap.get(a.Volunteer_Request__c).End_Time__c;
                }
            }
        }
    }
}