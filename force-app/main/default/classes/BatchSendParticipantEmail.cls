global class BatchSendParticipantEmail implements Database.Batchable<sObject> {
	global String query;
    global String objName;
    global String errorMsg;
    global String volIds;
    global String templateId;
    global String vrId;
    
    global BatchSendParticipantEmail(String vIds, String tId, String vreqId){
        query = 'SELECT Id,name'+
                ',Contact_Name__r.firstname'+
            	',Contact_Name__r.Name'+
                ',Contact_Name__r.lastname'+
                ',Contact_Name__r.Email'+
                ',Contact_Name__r.Phone'+
                ',Contact_Name__r.MobilePhone'+
                ',Status__c'+
                ',Contact_Name__c'+
                ',CreatedById'+
                ',Email_Sent__c'+
            	',Email__c'+
                ',Programme_Event__c'+
                ',Invitation_Link__c'+
            	',Participant_Name__c'+
                ' FROM Participant__c'+
                ' WHERE Id IN '+vIds;
        volIds = vIds;
        system.debug('=======ericca debug query========'+query);
        templateId = tId; 
        vrId = vreqId;
    }
    
    global Database.QueryLocator start (Database.BatchableContext bc){
        system.debug('=======ericca debug query========'+volIds);
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext bc, List<SObject> scope){
        System.debug('lstRI before = ' + scope );  
        //Set<Id> pIds = new Set<Id>();
        if(scope.size()>0){
            Set<id> contIds = new Set<Id>();
            /*for(SObject s : scope){
                pIds.add((Id)s.get('Contact_Name__c'));
            }*/
            EmailTemplate emailTemp =[SELECT subject,Body,DeveloperName,Id,HTMLValue  FROM EmailTemplate where id=:templateId LIMIT 1];
        	List<Programme_Events__c> L = [ SELECT Id,name
                                            ,End_Date_Time__c 
                                            ,Frequency__c
                                            ,Programme_Remarks__c
                                            ,Start_Date_Time__c
                                            ,Programme_Stage__c
                                            ,Programme_Title__c 
                                            ,Programme_Description__c
                                          	,Owner.Name
                                            FROM Programme_Events__c WHERE Id = :vrId
                                          ];
            //Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name, Email, Phone, MobilePhone, Passcode__c 
            //                                                    FROM Contact WHERE Id IN :pIds]);
            
            for(SObject S : scope){  
                Datetime startDatetime = L[0].Start_Date_Time__c;
                Datetime endDatetime = L[0].End_Date_Time__c;
                
                String emsg;
                String esub;
                if(emailTemp.Subject != null){
                    esub = emailTemp.Subject;
                    esub = (L[0].name <> null) ? esub.replace('{!Volunteer_Request__c.Name}', L[0].name) : esub.replace('{!Volunteer_Request__c.Name}', '');
                } else {
                    esub = '';
                }
                
                if(!Test.isRunningTest()){emsg = emailTemp.HtmlValue;}
                else{emsg = emailTemp.Body;}
                
                emsg = (L[0].Name <> null) ? emsg.replace('{!Programme_Event__c.Name}', L[0].Name) : emsg.replace('{!Programme_Event__c.Name}', '');
                emsg = (L[0].Name <> null) ? emsg.replace('{!Participant__c.Program_Event_Name__c}', L[0].Name) : emsg.replace('{!Participant__c.Program_Event_Name__c}', '');

                emsg = (L[0].Programme_Description__c <> null) ? emsg.replace('{!Programme_Event__c.Programme_Description__c}', L[0].Programme_Description__c) : emsg.replace('{!Programme_Event__c.Programme_Description__c}', '');
                emsg = (L[0].Owner.Name <> null) ? emsg.replace('{!Programme_Event__c.Owner_name__c}', L[0].Owner.Name) : emsg.replace('{!Programme_Event__c.Owner_name__c}', '');

                String strname = (String)s.get('Participant_Name__c');
                esub = (L[0].Start_Date_Time__c <> null) ? esub.replace('{!Programme_Event__c.Start_Date_Time__c}', startDatetime.format('dd-MMM-yyyy hh:mm a')) : esub.replace('{!Programme_Event__c.Start_Date_Time__c}', '');
                emsg = (L[0].Start_Date_Time__c <> null) ? emsg.replace('{!Programme_Event__c.Start_Date_Time__c}', startDatetime.format('dd-MMM-yyyy hh:mm a')) : emsg.replace('{!Programme_Event__c.Start_Date_Time__c}', '');
                emsg = (L[0].End_Date_Time__c <> null) ? emsg.replace('{!Programme_Event__c.End_Date_Time__c}', enddatetime.format('dd-MMM-yyyy hh:mm a')) : emsg.replace('{!Programme_Event__c.End_Date_Time__c}', '');
            	     
                emsg = (strname <> null) ? emsg.replace('{!Participant__c.Contact_Name__c}', strname) : emsg.replace('{!Participant__c.Contact_Name__c}', '');
                emsg = ((String)s.get('Invitation_Link__c') <> null) ? emsg.replace('{!Participant__c.Invitation_Link__c}', (String)s.get('Invitation_Link__c')) : emsg.replace('{!Participant__c.Invitation_Link__c}', '');
            	
                List<String> toemail = new List<String>();
                toemail.add((String)s.get('Email__c'));
            	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            	email.setToAddresses(toemail); 
                email.setHtmlBody(emsg); 
            	email.setSubject(esub);
            	Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                
                s.put('Email_sent__c', Date.today());
                if(s.get('Status__c') == 'Selected') s.put('Status__c', 'Invitation Sent');
            }
            if(!Test.isRunningTest())update(scope);  
        }
    }
    
    global void finish (Database.BatchableContext bc){
        
    }
}