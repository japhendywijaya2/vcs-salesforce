public class VolunteerRequestClass {
	public static void updateVRStatus(List<Volunteer_Request__c> listNew,Map<Id, Volunteer_Request__c> oldMap){
        for(Volunteer_Request__c p : listNew){
            if(p.Start_Date__c != null && p.End_Date__c != null){ 
                if(oldMap == null){
                    if(p.Start_Date__c <= Date.today() && p.End_Date__c >= Date.today() ){
                        p.Request_Status__c = 'Started';
                    }else{
                        if(p.End_Date__c < Date.today()){
                        	p.Request_Status__c = 'Ended';
                        }else if(p.Start_Date__c > Date.today()){
                            p.Request_Status__c = 'Planned';
                        }
                    }
                }else if((p.Start_Date__c != oldMap.get(p.Id).Start_Date__c || p.End_Date__c != oldMap.get(p.Id).End_Date__c)){
                    if(p.Start_Date__c <= Date.today() && p.End_Date__c >= Date.today() ){
                        p.Request_Status__c = 'Started';
                    }else{
                        if(p.End_Date__c < Date.today()){
                        	p.Request_Status__c = 'Ended';
                        }else if(p.Start_Date__c > Date.today()){
                            p.Request_Status__c = 'Planned';
                        }
                    }
                }
            }else{
                p.Request_Status__c = 'Planned';
            }
        }
    }
    public static void cancelVR(List<Volunteer_Request__c> listNew){
        for(Volunteer_Request__c v : listNew){
            if(v.Cancel_VR__c){
                v.Request_Status__c = 'Cancelled';
            }
        }
    }
    
    /*public static void fillAddress(List<Volunteer_Request__c> newList, Map<Id, Volunteer_Request__c> oldMap){
        Set<String> PostalCodes = new Set<String>();
        for(Volunteer_Request__c con : newList){
            if(con.Mailing_Zip_Postal_Code__c != null){
                if(oldMap != null && oldMap.get(con.Id) != null){
                    if(oldMap.get(con.Id).Mailing_Zip_Postal_Code__c != con.Mailing_Zip_Postal_Code__c ){
                        PostalCodes.add(con.Mailing_Zip_Postal_Code__c );
                    }
                }else{
                    PostalCodes.add(con.Mailing_Zip_Postal_Code__c );
                }
            }
        }
        List<Postal_Code__c> pcList = [SELECT Id, Name, Address_Type__c, Block__c, Building_Name__c, Country__c, Street__c FROM Postal_Code__c WHERE Name IN :postalCOdes];
        Map<String, Postal_Code__c> pcMap = new Map<String, Postal_Code__c>();
        if(pcList != null && pcList.size() > 0){
            for(Postal_code__c pc : pcList){
                pcMap.put(pc.Name, pc);
            }
            
            for(Volunteer_Request__c acc : newList){
                if(acc.Mailing_Zip_Postal_Code__c != null && pcMap.get(acc.Mailing_Zip_Postal_Code__c ) != null){
                    if(oldMap != null && oldMap.get(acc.Id) != null){
                        if(oldMap.get(acc.Id).Mailing_Zip_Postal_Code__c != acc.Mailing_Zip_Postal_Code__c ){
                            acc.Mailing_Street__c = '';
                            if(pcMap.get(acc.Mailing_Zip_Postal_Code__c).Block__c != null){
                                acc.Mailing_Street__c += pcMap.get(acc.Mailing_Zip_Postal_Code__c).Block__c ;
                            }
                            if(pcMap.get(acc.Mailing_Zip_Postal_Code__c).Street__c != null){
                                acc.Mailing_Street__c += ' '+pcMap.get(acc.Mailing_Zip_Postal_Code__c).Street__c ;
                            }
                            if(pcMap.get(acc.Mailing_Zip_Postal_Code__c).Building_Name__c != null){
                                acc.Mailing_Street__c += '\n'+pcMap.get(acc.Mailing_Zip_Postal_Code__c).Building_Name__c ;
                            }
                            
                            if(pcMap.get(acc.Mailing_Zip_Postal_Code__c).Country__c != null){
                                acc.Mailing_Country__c = pcMap.get(acc.Mailing_Zip_Postal_Code__c).Country__c ;
                            }
                        }
                    }else{
                        acc.Mailing_Street__c = '';
                        if(pcMap.get(acc.Mailing_Zip_Postal_Code__c).Block__c != null){
                            acc.Mailing_Street__c += pcMap.get(acc.Mailing_Zip_Postal_Code__c).Block__c ;
                        }
                        if(pcMap.get(acc.Mailing_Zip_Postal_Code__c).Street__c != null){
                            acc.Mailing_Street__c += ' '+pcMap.get(acc.Mailing_Zip_Postal_Code__c).Street__c ;
                        }
                        if(pcMap.get(acc.Mailing_Zip_Postal_Code__c).Building_Name__c != null){
                            acc.Mailing_Street__c += '\n'+pcMap.get(acc.Mailing_Zip_Postal_Code__c).Building_Name__c ;
                        }
                        
                        if(pcMap.get(acc.Mailing_Zip_Postal_Code__c).Country__c != null){
                            acc.Mailing_Country__c = pcMap.get(acc.Mailing_Zip_Postal_Code__c).Country__c ;
                        }
                    }
                }
            }
        }
    }*/
}