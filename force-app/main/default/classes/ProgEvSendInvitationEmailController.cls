public class ProgEvSendInvitationEmailController {
	public Id Id{get;set;}
    public String Email{get;set;}
    public List<Programme_Events__c> L {get;set;}
    public List<Participant__c> P {get;set;}
    public List<ObjTable> ObjtblList {get;set;}
    public List<Participant__c> Acc {get;set;}
    public String emsg{get;set;}
    public String esub{get;set;}
    Programme_Events__c objL;
    public Programme_Events__c Invo {get;set;}
    public String strSelected  {get;set;}
    public String strTemplate  {get;set;}
    public String FoldId{get;set;}
    public List<SelectOption> options {get;set;}
    public List<EmailTemplate> orderItemList {get; set;}
    public List<EmailObject> EmailObjectList {get; set;}
    public Participant__c dParam {get; set;}
    public boolean pageRender {get; set;}
    public Decimal noVol {get; set;}
    
    public ProgEvSendInvitationEmailController (ApexPages.StandardController controller) {
        Id = ApexPages.CurrentPage().getParameters().get('id');   
        Email = ApexPages.CurrentPage().getParameters().get('Email');   
        System.debug('DEBUG das Id = ' + Id );  
        strTemplate = '';
        noVol = 0;
        dParam = new Participant__c();
        dParam.Status__c = 'Selected';
        //ObjtblList = new List<ObjTable>();
        if (Id == null )
        {
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.VRSendEmailError1);
          ApexPages.addMessage(myMsg);
        } 
        
        try{
            Invo = [SELECT Id,name
                    ,End_Date_Time__c 
                    ,Frequency__c
                    ,Programme_Remarks__c
                    ,Start_Date_Time__c
                    ,Programme_Stage__c
                    ,Programme_Title__c 
                    ,Programme_Description__c
                    ,Owner.Name
                    FROM Programme_Events__c WHERE Id = :Id AND Programme_Stage__c NOT IN ('Cancelled','Terminated')];
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
        FoldId = 'Programme/Events';
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
                ,End_Date_Time__c
                ,Programme_Remarks__c
                ,Start_Date_Time__c
             	,Owner.Name
                ,Programme_Description__c
                FROM Programme_Events__c WHERE Id = :Id
            ];
            
        Decimal a;
        System.debug('DEBUG das L = ' + L ); 
        
        for(Programme_Events__c tempL : L){
                a = 1;
        }  
        if(a == 1){            
            EmailTemplate emsgsub;
            if(!Test.isRunningTest()){
                emsgsub =[SELECT subject,Body,DeveloperName,Id,HTMLValue  FROM EmailTemplate where id=:strSelected LIMIT 1];
            }else{
                emsgsub =[SELECT subject,Body,DeveloperName,Id,HTMLValue  FROM EmailTemplate  LIMIT 1];
            }
            Datetime startDatetime = L[0].Start_Date_Time__c;
            Datetime endDatetime = L[0].End_Date_Time__c;
            
            if(emsgsub.Subject != null){
                esub = emsgsub.Subject;
                esub = (L[0].name <> null) ? esub.replace('{!Programme_Event__c.Name}', L[0].name) : esub.replace('{!Programme_Event__c.Name}', '');
                esub = (L[0].Start_Date_Time__c <> null) ? esub.replace('{!Programme_Event__c.Start_Date_Time__c}', startDatetime.format('dd-MMM-yyyy hh:mm a')) : esub.replace('{!Programme_Event__c.Start_Date_Time__c}', '');
            }else {
                esub = '';
            }
            if(!Test.isRunningTest()){emsg = emsgsub.HtmlValue;}
            else{emsg = emsgsub.Body;}
            
            emsg = (L[0].Name <> null) ? emsg.replace('{!Participant__c.Program_Event_Name__c}', L[0].Name) : emsg.replace('{!Participant__c.Program_Event_Name__c}', '');

            emsg = (L[0].Programme_Description__c <> null) ? emsg.replace('{!Programme_Event__c.Programme_Description__c}', L[0].Programme_Description__c) : emsg.replace('{!Programme_Event__c.Programme_Description__c}', '');
            emsg = (L[0].Name <> null) ? emsg.replace('{!Programme_Event__c.Name}', L[0].Name) : emsg.replace('{!Programme_Event__c.Name}', '');
            emsg = (L[0].Start_Date_Time__c <> null) ? emsg.replace('{!Programme_Event__c.Start_Date_Time__c}', startDatetime.format('dd-MMM-yyyy hh:mm a')) : emsg.replace('{!Programme_Event__c.Start_Date_Time__c}', '');
            emsg = (L[0].End_Date_Time__c <> null) ? emsg.replace('{!Programme_Event__c.End_Date_Time__c}', enddatetime.format('dd-MMM-yyyy hh:mm a')) : emsg.replace('{!Programme_Event__c.End_Date_Time__c}', '');
            emsg = (L[0].Owner.Name <> null) ? emsg.replace('{!Programme_Event__c.Owner_name__c}', L[0].Owner.Name) : emsg.replace('{!Programme_Event__c.Owner_name__c}', '');
            
            return null;
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, Label.VRSendEmailError5));
            return null;
        }
        
    }
    public void refreshAssignedVolunteer(){
        ObjtblList = new List<ObjTable>();
        P = [   SELECT Id,name
                ,Contact_Name__r.firstname
                ,Contact_Name__r.lastname
                ,Contact_Name__r.Email
                ,Contact_Name__r.Phone
                ,Contact_Name__r.MobilePhone
                ,Status__c
                ,Contact_Name__c
                ,CreatedById
                ,Email_Sent__c
                ,LastModifiedById
                ,Programme_Event__c
                ,Invitation_URL__c
                FROM Participant__c WHERE Programme_Event__c = :Id  AND Status__c =:dParam.Status__c AND Contact_Name__r.Email <> NULL//AND Email_sent__c = null
            ]; 
            for(Participant__c v : P){
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
            BatchSendParticipantEmail batchEmail = new BatchSendParticipantEmail(vIds, strSelected, id);
            Database.executeBatch(batchEmail, 10);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Emails sent.')); 
            refreshAssignedVolunteer();
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
        public Participant__c rowObj {get; set;}
    }
}