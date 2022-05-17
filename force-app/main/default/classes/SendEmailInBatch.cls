global class SendEmailInBatch implements Database.Batchable<sObject> {
	global String query;
    global String objName;
    global String errorMsg;
    global String volIds;
    global String templateId;
    global String vrId;
    
    global SendEmailInBatch(String vIds, String tId, String vreqId){
        query = 'SELECT Id,name'+
                ',Contact__r.firstname'+
            	',Contact__r.Name'+
                ',Contact__r.lastname'+
                ',Contact__r.Email'+
                ',Contact__r.Phone'+
                ',Contact__r.MobilePhone'+
                ',Accepted_Date__c'+
            	',Assignee_Status__c'+
                ',Cancelled_Date__c'+
                ',Contact__c'+
                ',CreatedById'+
                ',Description_of_Task__c'+
                ',Email_Sent__c'+
                ',Survey_Sent__c'+
                ',End_Date__c'+
                ',EndDate__c'+
                ',LastModifiedById'+
                ',Participant_s_Role__c'+
                ',Programme_Event_Status__c'+
                ',Rejected_Date__c'+
                ',Sent_Notification__c'+
                ',Start_Date__c'+
                ',Volunteer_Request__c'+
                ',Volunteer_Request__r.name'+
                ',Withdrawn_Date__c'+
                ',Key_Objective__c'+
                ',Programme_Name__c'+
                ',Invitation_URL__c'+
                ',Volunteer_Manager__c'+
                ',Start_Time__c'+
             	',End_Time__c'+
            	',Email__c'+
                ' FROM Assigned_Volunteer__c'+
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
        Set<Id> pIds = new Set<Id>();
        if(scope.size()>0){
            Set<id> contIds = new Set<Id>();
            for(SObject s : scope){
                pIds.add((Id)s.get('Contact__c'));
            }
            EmailTemplate emailTemp =[SELECT subject,Body,DeveloperName,Id,HTMLValue  FROM EmailTemplate where id=:templateId LIMIT 1];
        	List<Volunteer_Request__c> L = [ SELECT Id,name
                                            ,Assignment_Status__c
                                            ,End_Date__c
                                            ,Frequency_Type__c
                                            ,Outcome_remarks__c
                                            ,Programme_Event__c
                                            ,Request_Date__c
                                            ,Request_status__c
                                            ,Request_Title__c
                                            ,Start_Date__c
                                            ,Type_of_Request__c
                                         	,Key_Objective__c
                                         	,Programme_Event__r.Name
                                         	,Start_Time__c
                                         	,End_Time__c
                                         	,Owner.Name
                                            FROM Volunteer_Request__c WHERE Id = :vrId
                                          ];
            //Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name, Email, Phone, MobilePhone, Passcode__c 
            //                                                    FROM Contact WHERE Id IN :pIds]);
            
            for(SObject S : scope){  
                Datetime startDatetime = DateTime.newInstance(L[0].Start_Date__c.year(),L[0].Start_Date__c.month(),L[0].Start_Date__c.day(), L[0].Start_Time__c.hour(), L[0].Start_Time__c.minute(), L[0].Start_Time__c.second());
                Datetime endDatetime;
                if(L[0].End_Date__c != null){
                    endDatetime = DateTime.newInstance(L[0].End_Date__c.year(),L[0].End_Date__c.month(),L[0].End_Date__c.day(), L[0].End_Time__c.hour(), L[0].End_Time__c.minute(), L[0].End_Time__c.second());
                }
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
                
                emsg = (L[0].Programme_Event__c <> null) ? emsg.replace('{!Assigned_Volunteer__c.Programme_Name__c}', L[0].Programme_Event__r.Name) : emsg.replace('{!Assigned_Volunteer__c.Programme_Name__c}', '');
                emsg = (L[0].Name <> null) ? emsg.replace('{!Assigned_Volunteer__c.Volunteer_Request__c}', L[0].Name) : emsg.replace('{!Assigned_Volunteer__c.Volunteer_Request__c}', '');
                emsg = (L[0].Key_Objective__c <> null) ? emsg.replace('{!Assigned_Volunteer__c.Key_Objective__c}', L[0].Key_Objective__c) : emsg.replace('{!Assigned_Volunteer__c.Key_Objective__c}', '');
                emsg = (L[0].Request_Title__c <> null) ? emsg.replace('{!Volunteer_Request__c.Request_Title__c}', L[0].Request_Title__c) : emsg.replace('{!Volunteer_Request__c.Request_Title__c}', '');
                emsg = (L[0].Owner.Name <> null) ? emsg.replace('{!Assigned_Volunteer__c.Volunteer_Manager__c}', L[0].Owner.Name) : emsg.replace('{!Assigned_Volunteer__c.Volunteer_Manager__c}', '');

                String strname = (String)s.get('Name');
                Datetime startdt;
                Datetime enddt;
                
                if(s.get('Start_Date__c') != null && s.get('Start_Time__c') != null){
                    startdt = DateTime.newInstance(((Date)s.get('Start_Date__c')).year(),((Date)s.get('Start_Date__c')).month(),((Date)s.get('Start_Date__c')).day(), ((Time)s.get('Start_Time__c')).hour(), ((Time)s.get('Start_Time__c')).minute(), ((Time)s.get('Start_Time__c')).second());
        			esub = esub.replace('{!Assigned_Volunteer__c.Start_Date__c}', startdt.format('dd-MMM-yyyy'));
                    emsg = emsg.replace('{!Assigned_Volunteer__c.Start_Date__c}', startdt.format('dd-MMM-yyyy'));
                    esub = esub.replace('{!Assigned_Volunteer__c.Start_Time__c}', startdt.format('hh:mm a'));
                    emsg = emsg.replace('{!Assigned_Volunteer__c.Start_Time__c}', startdt.format('hh:mm a'));
                }else{
                    esub = (L[0].Start_Date__c <> null) ? esub.replace('{!Assigned_Volunteer__c.Start_Date__c}', startDatetime.format('dd-MMM-yyyy')) : esub.replace('{!Assigned_Volunteer__c.Start_Date__c}', '');
                	esub = (L[0].Start_Time__c <> null) ? esub.replace('{!Assigned_Volunteer__c.Start_Time__c}', startDatetime.format('hh:mm a')) : esub.replace('{!Assigned_Volunteer__c.Start_Time__c}', '');
                	
                    emsg = (L[0].Start_Date__c <> null) ? emsg.replace('{!Assigned_Volunteer__c.Start_Date__c}', startDatetime.format('dd-MMM-yyyy')) : emsg.replace('{!Assigned_Volunteer__c.Start_Date__c}', '');
                    emsg = (L[0].Start_Time__c <> null) ? emsg.replace('{!Assigned_Volunteer__c.Start_Time__c}', startDatetime.format('hh:mm a')) : emsg.replace('{!Assigned_Volunteer__c.Start_Time__c}', '');
            	} 
                
                if(s.get('End_Date__c') != null && s.get('End_Time__c') != null){
                    enddt = DateTime.newInstance(((Date)s.get('End_Date__c')).year(),((Date)s.get('End_Date__c')).month(),((Date)s.get('End_Date__c')).day(), ((Time)s.get('End_Time__c')).hour(), ((Time)s.get('End_Time__c')).minute(), ((Time)s.get('End_Time__c')).second());
        			emsg = emsg.replace('{!Assigned_Volunteer__c.End_Date__c}', enddt.format('dd-MMM-yyyy'));
            		emsg = emsg.replace('{!Assigned_Volunteer__c.End_Time__c}', enddt.format('hh:mm a'));
                }else{
                    emsg = (L[0].End_Date__c <> null) ? emsg.replace('{!Assigned_Volunteer__c.End_Date__c}', enddatetime.format('dd-MMM-yyyy')) : emsg.replace('{!Assigned_Volunteer__c.End_Date__c}', '');
            		emsg = (L[0].End_Time__c <> null) ? emsg.replace('{!Assigned_Volunteer__c.End_Time__c}', endDatetime.format('hh:mm a')) : emsg.replace('{!Assigned_Volunteer__c.End_Time__c}', '');
                }                
                emsg = (strname <> null) ? emsg.replace('{!Assigned_Volunteer__c.Contact__c}', strname) : emsg.replace('{!Assigned_Volunteer__c.Contact__c}', '');
                emsg = ((String)s.get('Invitation_URL__c') <> null) ? emsg.replace('{!Assigned_Volunteer__c.Invitation_URL__c}', (String)s.get('Invitation_URL__c')) : emsg.replace('{!Assigned_Volunteer__c.Invitation_URL__c}', '');
            	
                List<String> toemail = new List<String>();
                toemail.add((String)s.get('Email__c'));
            	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            	email.setToAddresses(toemail); 
                email.setHtmlBody(emsg); 
            	email.setSubject(esub);
            	Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                
                s.put('Email_sent__c', Date.today());
                if(s.get('Assignee_Status__c') == 'Selected') s.put('Assignee_Status__c', 'Contacted');
            }
            if(!Test.isRunningTest())update(scope);  
        }
    }
    
    global void finish (Database.BatchableContext bc){
        //AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        //Disbursement_Item__c d = [SELECT Id, Status__c, Batch_Remarks__c FROM Disbursement_Item__c WHERE Id = :disbItemId];
        
        //d.Status__c = 'Disbursed';
        //d.Batch_Remarks__c = 'The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.';
        //update(d);
    }
}