public class VolunteerAcceptDeclineController {
	public Volunteer_Request__c vr {get; set;}
    public Assigned_Volunteer__c pt {get; set;}
    public Id vrId {get; set;}
    public List<Assigned_Volunteer__c> participantRecords {get; set;}
    public List<ObjTable> ObjtblList {get;set;}
    
    public VolunteerAcceptDeclineController(ApexPages.StandardController controller) {
        vrId = ApexPages.CurrentPage().getParameters().get('id'); 
        pt = new Assigned_Volunteer__c();
        pt.Volunteer_Request__c = vrId;
        pt.Assignee_Status__c = 'Registered';
        refreshTable();
                        
    }
    public void refreshTable(){
        vr = [SELECT Id, name FROM Volunteer_Request__c WHERE Id = :pt.Volunteer_Request__c];
        
        ObjtblList = new List<ObjTable>();
        if(pt.Assignee_Status__c == null){
            participantRecords = [SELECT Id
                              ,name
                              ,Contact__r.Lastname
                              ,Assignee_Status__c
                              ,Email_Sent__c
                              FROM Assigned_Volunteer__c WHERE Volunteer_Request__c = :pt.Volunteer_Request__c]; 
        }else{
			participantRecords = [SELECT Id
                              ,name
                              ,Contact__r.Lastname
                              ,Assignee_Status__c
                              ,Email_Sent__c
                              FROM Assigned_Volunteer__c WHERE Volunteer_Request__c = :pt.Volunteer_Request__c AND Assignee_Status__c = :pt.Assignee_Status__c]; 
        }
        
        for(Assigned_Volunteer__c v : participantRecords ){
            ObjTable obj = new ObjTable();
            obj.rowObj = v;
            ObjtblList.add(obj);
        }                      
    }
    
    public PageReference acceptVolunteer(){
        List<Assigned_Volunteer__c> pList = new List<Assigned_Volunteer__c>();
        integer iselect = 0;
        for(ObjTable obj: ObjtblList ){
            if(obj.selected == true){
                Assigned_Volunteer__c p = obj.rowObj ;
                p.Assignee_Status__c = 'Accepted';
                p.Accepted_Date__c = Date.today();
                p.Rejected_Date__c = null;
                pList.add(p);
                iselect++;
            }
        }
        try{
            if(iselect == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No Volunteer selected.'));
            }else{
                update(pList );
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, pList.size()+ ' Volunteer(s) is Accepted.'));
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Unable to reject this Participant. ERROR CODE:'+e.getMessage()));
        }
        return null;
    }
    public PageReference declineVolunteer(){
        List<Assigned_Volunteer__c> pList = new List<Assigned_Volunteer__c>();
        integer iselect = 0;
        for(ObjTable obj: ObjtblList ){
            if(obj.selected == true){
                Assigned_Volunteer__c p = obj.rowObj ;
                p.Assignee_Status__c = 'Declined';
                p.Rejected_Date__c = Date.today();
                p.Accepted_Date__c = null;
                pList.add(p);
                iselect++;
            }
        }
        try{
            if(iselect == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No Volunteer selected.'));
            }else{
                update(pList);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, pList.size()+ ' Volunteer(s) is Declined.'));
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Unable to reject this Volunteer. ERROR CODE:'+e.getMessage()));
        }
        
        return null;
    }
    public PageReference back(){
        pageReference pg = new pageReference('/'+vrId);
        pg.setRedirect(true);
        return pg;
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
    
    public class ObjTable{
        public boolean selected {get; set;}
        public Assigned_Volunteer__c rowObj {get; set;}
    }
}