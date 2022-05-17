public class ProgrammeEventClass {
	 public static void updateProgrammeStage(List<Programme_Events__c> listNew,Map<Id, Programme_Events__c> oldMap){
        for(Programme_Events__c p : listNew){
            if(p.Start_Date_time__c != null && p.End_Date_time__c != null){ 
                if(oldMap == null){
                    if(p.Start_Date_time__c <= Date.today() && p.End_Date_time__c >= Date.today() ){
                        p.Programme_Stage__c = 'Started';
                    }else{
                        if(p.End_Date_time__c < Datetime.now()){
                        	p.Programme_Stage__c = 'Ended';
                        }else if(p.Start_Date_time__c > Date.today()){
                            p.Programme_Stage__c = 'Planned';
                        }
                    }
                }else if((p.Start_Date_time__c != oldMap.get(p.Id).Start_Date_time__c || p.End_Date_time__c != oldMap.get(p.Id).End_Date_time__c)){
                    if(p.Start_Date_time__c <= Date.today() && p.End_Date_time__c >= Date.today() ){
                        p.Programme_Stage__c = 'Started';
                    }else{
                        if(p.End_Date_time__c < Datetime.now()){
                        	p.Programme_Stage__c = 'Ended';
                        }else if(p.Start_Date_time__c > Date.today()){
                            p.Programme_Stage__c = 'Planned';
                        }
                    }
                }
            }else{
                p.Programme_Stage__c = 'Planned';
            }
        }
    }
    public static void cancelProgramme(List<Programme_Events__c> listNew){
        for(Programme_Events__c p : listNew){
            if(p.Cancel_Programme_Event__c ){
                p.Programme_Stage__c = 'Cancelled';
            }
        }
    }
    
    public static void updateActiveBirthdayProgramme(List<Programme_Events__c> listNew,Map<Id, Programme_Events__c> oldMap){
        integer i = 0;
        for(Programme_Events__c p : listNew){
            if(oldMap != null && oldMap.get(p.Id) != null){
                if(p.Programme_Stage__c != 'Cancelled' && p.Active_Birthday_Programme__c && !oldMap.get(p.Id).Active_Birthday_Programme__c){
                    i++;
                }
            }else{
                if(p.Programme_Stage__c != 'Cancelled' && p.Active_Birthday_Programme__c){
                    i++;
                }
            }
        }
        if(i == 1){
            List<Programme_Events__c> prList = [SELECT Id, Active_Birthday_Programme__c FROM Programme_Events__c WHERE Active_Birthday_Programme__c = true AND Id NOT IN :listnew];
            for(Programme_Events__c p : prList){
                p.Active_Birthday_Programme__c = false;
            }
            update(prList);
        }else if(i > 1){
            for(Programme_Events__c p : listNew){
                if(oldMap != null && oldMap.get(p.Id) != null){
                    if(p.Active_Birthday_Programme__c && !oldMap.get(p.Id).Active_Birthday_Programme__c){
                        p.Active_Birthday_Programme__c.addError('Only allow 1 active Birthday Programme.');
                    }
                }else{
                    if(p.Active_Birthday_Programme__c){
                        p.Active_Birthday_Programme__c.addError('Only allow 1 active Birthday Programme.');
                    }
                }
            }
        }
    }
}