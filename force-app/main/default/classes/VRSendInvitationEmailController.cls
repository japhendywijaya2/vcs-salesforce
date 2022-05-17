public class VRSendInvitationEmailController {
	public Id Id{get;set;}
    public String Email{get;set;}
    public List<Volunteer_Request__c> L {get;set;}
    public List<Assigned_Volunteer__c> P {get;set;}
    public List<ObjTable> ObjtblList {get;set;}
    public List<Assigned_Volunteer__c> Acc {get;set;}
    public String emsg{get;set;}
    public String esub{get;set;}
    Volunteer_Request__c objL;
    public Volunteer_Request__c Invo {get;set;}
    public String strSelected  {get;set;}
    public String strTemplate  {get;set;}
    public String FoldId{get;set;}
    public List<SelectOption> options {get;set;}
    public List<EmailTemplate> orderItemList {get; set;}
    public List<EmailObject> EmailObjectList {get; set;}
    public Assigned_Volunteer__c dParam {get; set;}
    public boolean pageRender {get; set;}
    public Decimal noVol {get; set;}
    
    public VRSendInvitationEmailController (ApexPages.StandardController controller) {
        Id = ApexPages.CurrentPage().getParameters().get('id');   
        Email = ApexPages.CurrentPage().getParameters().get('Email');   
        System.debug('DEBUG das Id = ' + Id );  
        strTemplate = '';
        noVol = 0;
        dParam = new Assigned_Volunteer__c();
        dParam.Assignee_Status__c = 'Selected';
        //ObjtblList = new List<ObjTable>();
        if (Id == null )
        {
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.VRSendEmailError1);
          ApexPages.addMessage(myMsg);
        } 
        
        try{
            Invo = [SELECT Id,name
                    ,Assignment_Status__c
                    ,End_Date__c 
                    ,Frequency_Type__c
                    ,Key_Objective__c
                    ,Outcome_remarks__c
                    ,Programme_Event__c
                    ,Request_Date__c
                    ,Request_status__c
                    ,Request_Title__c
                    ,Start_Date__c
                    ,Type_of_Request__c
                    ,Programme_Event__r.Name
                    FROM Volunteer_Request__c WHERE Id = :Id AND Request_status__c NOT IN ('Cancelled','Terminated')];
            pageRender = true;
            refreshAll();
            refreshAssignedVolunteer();

        }catch(Exception e){
            pageRender = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, Label.VRSendEmailError2 + e.getMessage()));
        }
    }
    class EmailObject{
        public integer num {get; set;}
        public String name {get; set;}
        public String templatetype {get; set;}
        public integer noofsent {get; set;}
        public EmailTemplate guest {get; set;} 
    }   
    public void refreshAll(){    
        //Organization org = [select id,IsSandbox from Organization];           
        //if(org.IsSandbox == true){FoldId = '00l2v000003wCKv';}else{FoldId = '00l2v000003wCKv';}
        FoldId = 'Volunteer Request';
        strSelected = '';
        options = new List<SelectOption>();
        options.add(new SelectOption('','-Please Select-'));
        EmailObjectList = new List<EmailObject>();
        integer i = 1;
        
        orderItemList = [SELECT Id, Name,TemplateType, Folder.name FROM EmailTemplate WHERE Folder.name =:FoldId order by TemplateType,Name];
        for(EmailTemplate obj : orderItemList ){
            options.add(new SelectOption(obj.Id,obj.Name));
            EmailObject gObj = new EmailObject();
            gObj.num = i;
            gObj.guest = obj;
            gObj.Name = obj.name;
            gObj.templatetype = obj.TemplateType;           
            EmailObjectList.add(gObj);
            i++;
        }
    }   
    public PageReference PreviewEmail(){
        if(strSelected <> '-Please Select-' && strSelected <> null)
        {
            System.debug('DEBUG das strSelected = ' + strSelected );  
            LoadDatasendMassEmail();
        }
        else{
            System.debug('DEBUG das strSelected = ' + strSelected ); 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,Label.VRSendEmailError3));
        }
        return null;   
    }
    public PageReference LoadDatasendMassEmail(){
        L = [ SELECT Id,name
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
                FROM Volunteer_Request__c WHERE Id = :Id
            ];
            
        Decimal a;
        System.debug('DEBUG das L = ' + L ); 
        
        for(Volunteer_Request__c tempL : L){
                a = 1;
        }  
        if(a == 1){            
            EmailTemplate emsgsub;
            if(!Test.isRunningTest()){
                emsgsub =[SELECT subject,Body,DeveloperName,Id,HTMLValue  FROM EmailTemplate where id=:strSelected LIMIT 1];
            }else{
                emsgsub =[SELECT subject,Body,DeveloperName,Id,HTMLValue  FROM EmailTemplate  LIMIT 1];
            }
            System.debug('DEBUG das emsgsub.Subject = ' + emsgsub.Subject ); 
            System.debug('DEBUG das emsgsub.Body = ' + emsgsub.Body ); 
            Datetime startDatetime = DateTime.newInstance(L[0].Start_Date__c.year(),L[0].Start_Date__c.month(),L[0].Start_Date__c.day(), L[0].Start_Time__c.hour(), L[0].Start_Time__c.minute(), L[0].Start_Time__c.second());
            Datetime endDatetime;
            if(L[0].End_Date__c != null){
                endDatetime = DateTime.newInstance(L[0].End_Date__c.year(),L[0].End_Date__c.month(),L[0].End_Date__c.day(), L[0].End_Time__c.hour(), L[0].End_Time__c.minute(), L[0].End_Time__c.second());
            }
            if(emsgsub.Subject != null){
                esub = emsgsub.Subject;
                esub = (L[0].name <> null) ? esub.replace('{!Volunteer_Request__c.Name}', L[0].name) : esub.replace('{!Volunteer_Request__c.Name}', '');
                esub = (L[0].Start_Date__c <> null) ? esub.replace('{!Assigned_Volunteer__c.Start_Date__c}', startDatetime.format('dd-MMM-yyyy')) : esub.replace('{!Assigned_Volunteer__c.Start_Date__c}', '');
                esub = (L[0].Start_Time__c <> null) ? esub.replace('{!Assigned_Volunteer__c.Start_Time__c}', startDatetime.format('hh:mm a')) : esub.replace('{!Assigned_Volunteer__c.Start_Time__c}', '');
            } else {
                esub = '';
            }
            
            //if(emsgsub.Body != null){
                //emsg = emsgsub.Body.replace('\n','<br>') ;
            //} else{
                if(!Test.isRunningTest()){emsg = emsgsub.HtmlValue;}
                else{emsg = emsgsub.Body;}
            //}
            emsg = (L[0].Programme_Event__c <> null) ? emsg.replace('{!Assigned_Volunteer__c.Programme_Name__c}', L[0].Programme_Event__r.Name) : emsg.replace('{!Assigned_Volunteer__c.Programme_Name__c}', '');
            emsg = (L[0].Name <> null) ? emsg.replace('{!Assigned_Volunteer__c.Volunteer_Request__c}', L[0].Name) : emsg.replace('{!Assigned_Volunteer__c.Volunteer_Request__c}', '');
            emsg = (L[0].Start_Date__c <> null) ? emsg.replace('{!Assigned_Volunteer__c.Start_Date__c}', startDatetime.format('dd-MMM-yyyy')) : emsg.replace('{!Assigned_Volunteer__c.Start_Date__c}', '');
            emsg = (L[0].End_Date__c <> null) ? emsg.replace('{!Assigned_Volunteer__c.End_Date__c}', enddatetime.format('dd-MMM-yyyy')) : emsg.replace('{!Assigned_Volunteer__c.End_Date__c}', '');
            emsg = (L[0].Start_Time__c <> null) ? emsg.replace('{!Assigned_Volunteer__c.Start_Time__c}', string.valueof(startDatetime.format('hh:mm a'))) : emsg.replace('{!Assigned_Volunteer__c.Start_Time__c}', '');
            emsg = (L[0].End_Time__c <> null) ? emsg.replace('{!Assigned_Volunteer__c.End_Time__c}', string.valueof(endDatetime.format('hh:mm a'))) : emsg.replace('{!Assigned_Volunteer__c.End_Time__c}', '');
            emsg = (L[0].Key_Objective__c <> null) ? emsg.replace('{!Assigned_Volunteer__c.Key_Objective__c}', L[0].Key_Objective__c) : emsg.replace('{!Assigned_Volunteer__c.Key_Objective__c}', '');
            emsg = (L[0].Request_Title__c <> null) ? emsg.replace('{!Volunteer_Request__c.Request_Title__c}', L[0].Request_Title__c) : emsg.replace('{!Volunteer_Request__c.Request_Title__c}', '');
            emsg = (L[0].Owner.Name <> null) ? emsg.replace('{!Assigned_Volunteer__c.Volunteer_Manager__c}', L[0].Owner.Name) : emsg.replace('{!Assigned_Volunteer__c.Volunteer_Manager__c}', '');
            
            //DateTime.newInstance(L[0].Start_Date__c.year(),L[0].Start_Date__c.month(),L[0].Start_Date__c.day()).format('dd-mmm-yyyy');
            //DateTime.newInstance(L[0].End_Date__c.year(),L[0].End_Date__c.month(),L[0].End_Date__c.day()).format('dd-mmm-yyyy');
            return null;
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, Label.VRSendEmailError5));
            return null;
        }
        
    }
    public void refreshAssignedVolunteer(){
        ObjtblList = new List<ObjTable>();
        P = [   SELECT Id,name
                ,Contact__r.firstname
                ,Contact__r.lastname
                ,Contact__r.Email
                ,Contact__r.Phone
                ,Contact__r.MobilePhone
                ,Accepted_Date__c
                ,Assignee_Status__c
                ,Cancelled_Date__c
                ,Contact__c
                ,CreatedById
                ,Description_of_Task__c
                ,Email_Sent__c
                ,Survey_Sent__c
                ,End_Date__c
                ,EndDate__c
                ,LastModifiedById
                ,Participant_s_Role__c
                ,Programme_Event_Status__c
                ,Rejected_Date__c
                ,Sent_Notification__c
                ,Start_Date__c
                ,Volunteer_Request__c
                ,Volunteer_Request__r.name
                ,Volunteer_Hours__c
                ,Withdrawn_Date__c
                ,Key_Objective__c
                ,Programme_Name__c
                ,Invitation_URL__c
                ,Volunteer_Manager__c
                ,Start_Time__c
             	,Assignment_Status__c 
                ,End_Time__c
                FROM Assigned_Volunteer__c WHERE Volunteer_Request__c = :Id  AND Assignee_Status__c =:dParam.Assignee_Status__c AND Contact__r.Email <> NULL//AND Email_sent__c = null
            ]; 
            for(Assigned_Volunteer__c v : P){
                ObjTable obj = new ObjTable();
                //obj.selected = false;
                obj.rowObj = v;
                ObjtblList.add(obj);
            }
        
    }
    
    
    public PageReference sendEmailInBatch(){ 
        integer iselect = 0;
        for(ObjTable obj: ObjtblList ){
            if(obj.selected == true){
                iselect++;
            }
        }
        if(strSelected == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, Label.VRSendEmailError6));
        }
        else if(iselect == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Please select at least one Email to send.'));
        }else{
            String vIds = '(';
            for(ObjTable obj : ObjtblList ){
                if(obj.selected == true){
                    vIds += '\''+obj.rowObj.Id+'\',';
                }
            }
            vIds = vIds.removeEnd(',');
            vIds += ')';
            SendEmailInBatch batchEmail = new SendEmailInBatch(vIds, strSelected, id);
            Database.executeBatch(batchEmail, 10);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Emails sent.')); 
            refreshAssignedVolunteer();
        }
        return null;
    }
    public PageReference Accepted(){   
        integer z = 0;
        Acc = [ Select Id, Assignee_Status__c,Contact__r.email from Assigned_Volunteer__c WHERE Contact__r.email = :Email];
        for(Assigned_Volunteer__c I : Acc){
                z = 1;
                I.Assignee_Status__c = 'Accepted';
                I.Accepted_Date__c = date.today();
        }
        if(z == 1)
        {
            Update(Acc);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, Label.VRSendEmailError4));
        }     
        return null;  
    }
    
    public PageReference selectAll(){
        for(ObjTable obj : ObjtblList ){
            obj.selected = true;
        }
        return null;
    } 
    public PageReference unselectAll(){
        for(ObjTable obj : ObjtblList ){
            obj.selected = false;
        }
        return null;
    }
    
    public PageReference back(){
        pageReference pg = new pageReference('/'+Id);
        pg.setRedirect(true);
        return pg;
    }
    
    public class ObjTable{
        public boolean selected {get; set;}
        public Assigned_Volunteer__c rowObj {get; set;}
    }
}