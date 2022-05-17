global class BirthdayCronJob implements Schedulable{ 
	
	global void execute(SchedulableContext SC) {
    	Contact[] contacts = [SELECT Id, email, Birthdate
	        				FROM Contact 
	        				WHERE DAY_IN_MONTH(Birthdate) = : date.today().day() 
							AND CALENDAR_MONTH(Birthdate) = : date.today().month()   
	        				];
		List<Programme_Events__c> bdProgramme = [SELECT Id, Active_Birthday_Programme__c FROM Programme_Events__c WHERE Active_Birthday_Programme__c = true AND Programme_Stage__c != 'Cancelled' limit 1];
        if(bdProgramme != null){
            List<Participant__c> pList = [SELECT Id, Contact_Name__c, Programme_Event__c FROM Participant__c WHERE Programme_Event__c = :bdProgramme.get(0).Id AND Contact_Name__c IN :contacts];
            Set<Id> partExist = new Set<Id>();
            if(pList != null){
                for(Participant__c p : pList){
                    p.Birthday_Programme__c = true;
                    partExist.add(p.Contact_Name__c);
                }
            }
            for(Contact c : contacts) {
                if(!partExist.contains(c.Id)){
                    // create participant record
                    Participant__c p = new Participant__c();
                    p.Contact_Name__c = c.Id;
                    p.Programme_Event__c = bdProgramme.get(0).Id;
                    p.Birthday_Programme__c = true;
                    p.Remarks__c = 'Participant for donate Birthday';
                    pList.add(p);
                }
            } 
            upsert(pList);
        }
        
	}
}