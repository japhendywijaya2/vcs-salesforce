public class UploadParticipantController {
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    public List<List<String>> dataAll {get;set; }    
    public List<Participant__c> participantlist{get;set;}
    public List<Participant__c> updatedList{get;set;}
    public String progId {get; set;}
    public Integer totalData {get;set;}
    public Integer totalProceed {get;set;}
    public Integer totalSuccess {get;set;}
    public Integer totalFailed {get;set;}
    public String strInfo {get; set;}
    
    
    public UploadParticipantController(ApexPages.StandardController controller) {
        progId = ApexPages.CurrentPage().getParameters().get('id');
    }
      
    public PageReference importCSVFile(){
        //try{
            //csvAsString = csvFileBody.toString();
            CSVReader objCsv = new CSVReader(csvFileBody.toString());
            participantlist = New List<Participant__c>(); 
            dataAll = new List<List<String>>();
            csvFileLines = objCsv.readLine();
            Set<String> emails = new Set<String>(); 
            String strTmp;
        	totalData = 0;
            strInfo = '';
            system.debug('csvFileLines:'+ csvFileLines.tostring());
            while (csvFileLines != null){
                dataAll.add(csvFileLines);
                if(csvFileLines.size() > 1 && csvFileLines[1] != null && csvFileLines[1] != ''){
                    strTmp = csvFileLines[1];
                    if (emails.contains(strTmp)) {
                        // duplicate
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Duplicate Participant ' + strTmp));
                        totalData = 0;
                        return null;
                    }
                    else {
                        emails.add(strTmp);
                    }
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Email cannot be blank. Please fix the data.'));
                    totalData = 0;
                    return null;
                }
                totalData++;                
                csvFileLines = objCsv.readLine();
            }
            totalData = totalData-1;
            List<Participant__c> updatedParticipantList = [SELECT Id, Uploaded__c, Participant_Lastname__c, Email_Notification__c, Status__c, Contact_Name__r.Email, Mobile__c FROM Participant__c WHERE (Email_Notification__c  IN :emails OR Contact_Name__r.Email IN :emails) AND Programme_Event__c = :progId];
            //system.debug(updatedParticipantList.size());
            Map<String, Participant__c> participantMap = new Map<String, Participant__c>();
            for(Participant__c p : updatedParticipantList){
                if(p.Contact_Name__r.Email != null){
                    participantMap.put(p.Contact_Name__r.Email, p);
                }else{
                    participantMap.put(p.Email_Notification__c, p);
                }
                //system.debug(p.Participant_Lastname__c +' and '+p.Email_Notification__c);
            }
            
            Map<String, Participant__c> upsertParMap = new Map<String, Participant__c>();
            integer k = 0, j = 0;
            for(Integer i=1; i<dataAll.size(); i++){
                csvFileLines = dataAll[i];
                if(participantMap != null && participantMap.get(csvFileLines[1]) != null){
                    Participant__c partObj =  participantMap.get(csvFileLines[1]);
                    partObj.Status__c = 'Selected';
                    partObj.Uploaded__c = true;
                    partObj.Mobile__c = csvFileLines[2]; 
                    
                    upsertParMap.put(partObj.Email_Notification__c, partObj);
                    k++;
                }else{
                    Participant__c partObj = new Participant__c() ;
                    partObj.Participant_Lastname__c = csvFileLines[0];
                    partObj.Email_Notification__c = csvFileLines[1];
                    partObj.Mobile__c = csvFileLines[2];
                    partObj.Status__c = 'Selected';
                    partObj.Uploaded__c = true;
                    partObj.Programme_Event__c = progId ; 
                    upsertParMap.put(partObj.Email_Notification__c, partObj);
                    j++;
                }
            }
            String msg = '';
            if(upsertParMap != null && upsertParMap.values().size() > 0){
                Database.UpsertResult[] srList;
            	Database.Error[] listErr;
                try{
                    srList = Database.upsert(upsertParMap.values(), false);
                	participantlist = upsertParMap.values();
                	msg += ' '+j+' records inserted and '+k+' records updated.';
                }catch (DmlException e){
                    ApexPages.addMessages(e);
                }

                totalSuccess = 0;
                totalFailed = 0;
                totalProceed = 0;
                
                List<String> stContactSuccess = new List<String>();
                if (srList != null) {
                    for(Database.UpsertResult sr: srList) {
                        totalProceed++;
                        if (listErr != null) listErr.clear();
                        
                        if (sr.isSuccess()) {
                            stContactSuccess.add(sr.getId());
                            totalSuccess++;
                        }
                        else {
                            listErr = sr.getErrors();
                            for(j = 0; j < listErr.size();j++) {
                                strInfo += 'Row ' + String.valueOf(totalProceed) + ': ' + listErr[j].getMessage() + '<br/>\n';
                            }
                            totalFailed++;
                        }
                    }
                }
            }
            
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.CONFIRM,'Participant is processed.'+msg);
            ApexPages.addMessage(errorMessage);
            return null;
            //insert participantlist;
        /*}catch (Exception e){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importin data Please make sure input csv file is correct'+e.getMessage());
            ApexPages.addMessage(errorMessage);
            return null;
        }  */
    }
    public PageReference back(){
        pageReference pg = new pageReference('/'+progId);
        pg.setRedirect(true);
        return pg;
    } 
}