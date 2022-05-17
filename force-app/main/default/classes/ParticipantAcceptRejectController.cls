public class ParticipantAcceptRejectController {
	public Id participantId {get;set;}
    public Participant__c participantRecord {get;set;}
	public ParticipantAcceptRejectController(ApexPages.StandardController controller) {
        participantId = ApexPages.CurrentPage().getParameters().get('id'); 
        participantRecord = [SELECT Id, name
                                    , Status__c
                                    FROM Participant__c WHERE Id = :participantId
            ]; 
        if(participantRecord.Status__c <> 'Registered'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'This volunteer is not registered yet or already processed.'));
        }
    }
    
    public PageReference acceptVolunteer(){
        participantRecord.Status__c = 'Accepted';
        update(participantRecord);
        pageReference pg = new pageReference('/'+participantId);
        pg.setRedirect(true);
        return pg;
    }
    public PageReference declineVolunteer(){
        participantRecord.Status__c = 'Declined';
        update(participantRecord);
        pageReference pg = new pageReference('/'+participantId);
        pg.setRedirect(true);
        return pg;
    }
    public PageReference back(){
        pageReference pg = new pageReference('/'+participantId);
        pg.setRedirect(true);
        return pg;
    }
}