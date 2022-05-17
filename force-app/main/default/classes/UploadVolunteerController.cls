public class UploadVolunteerController {
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    public List<List<String>> dataAll {get;set; }    
    public List<Assigned_Volunteer__c> volunteerlist{get;set;}
    //public List<Assigned_Volunteer__c> updatedList{get;set;}
    public String vrId {get; set;}
    public Integer totalData {get;set;}
    public Integer totalProceed {get;set;}
    public Integer totalSuccess {get;set;}
    public Integer totalFailed {get;set;}
    public String strInfo {get; set;}
    
    
    public UploadVolunteerController(ApexPages.StandardController controller) {
        vrId = ApexPages.CurrentPage().getParameters().get('id');
    }
      
    public PageReference importCSVFile(){
        //try{
            //csvAsString = csvFileBody.toString();
            Set<String> emails = new Set<String>(); 
            String strTmp;
        	totalData = 0;
			dataAll = new List<List<String>>(); 
        	csvFileLines = new String[]{};
        	volunteerlist = New List<Assigned_Volunteer__c>(); 
            system.debug('csvFileBody:'+ csvFileBody.tostring());
            CSVReader objCsv = new CSVReader(csvFileBody.toString());
            csvFileLines = objCsv.readLine();
            system.debug('csvFileLines:'+ csvFileLines.tostring());
            
            system.debug('csvFileLines:'+ csvFileLines.tostring());
            while (csvFileLines != null){
                dataAll.add(csvFileLines);
                if(csvFileLines.size() > 1 && csvFileLines[1] != null && csvFileLines[1] != ''){
                    strTmp = csvFileLines[1];
                    if (emails.contains(strTmp)) {
                        // duplicate
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Duplicate Volunteer ' + strTmp));
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
            system.debug('emails = ' +emails.size());
            List<Assigned_Volunteer__c> updatedVolunteerList = [SELECT Id, Volunteer_Name_upload__c, Uploaded__c, Email_Upload__c, Assignee_Status__c, Contact__r.Email, Mobile__c FROM Assigned_Volunteer__c WHERE (Email_Upload__c  IN :emails OR Contact__r.Email IN :emails) AND Volunteer_Request__c = :vrId];
            system.debug(updatedVolunteerList.size());
            Map<String, Assigned_Volunteer__c> volunteerMap = new Map<String, Assigned_Volunteer__c>();
            for(Assigned_Volunteer__c p : updatedVolunteerList){
                if(p.Contact__r.Email != null){
                    volunteerMap.put(p.Contact__r.Email, p);
                }else{
                    volunteerMap.put(p.Email_Upload__c, p);
                }
                system.debug(p.Volunteer_Name_upload__c +' and '+p.Email_Upload__c);
            }
            
            Map<String, Assigned_Volunteer__c> upsertParMap = new Map<String, Assigned_Volunteer__c>();
            integer k = 0, j = 0;
        	strInfo = '';
            for(Integer i=1; i<dataAll.size(); i++){
                csvFileLines = dataAll[i];
                if(volunteerMap != null && volunteerMap.get(csvFileLines[1]) != null){
                    Assigned_Volunteer__c partObj =  volunteerMap.get(csvFileLines[1]);
                    partObj.Assignee_Status__c = 'Selected';
                    partObj.Uploaded__c = true;
                    partObj.Mobile__c = csvFileLines[2]; 
                    
                    upsertParMap.put(partObj.Email_Upload__c, partObj);
                    k++;
                }else{
                    Assigned_Volunteer__c partObj = new Assigned_Volunteer__c() ;
                    partObj.Name = csvFileLines[0];
                    partObj.Volunteer_Name_upload__c = csvFileLines[0];
                    partObj.Email_Upload__c = csvFileLines[1];
                    partObj.Mobile__c = csvFileLines[2];
                    partObj.Assignee_Status__c = 'Selected';
                    partObj.Uploaded__c = true;
                    partObj.Volunteer_Request__c = vrId ; 
                    upsertParMap.put(partObj.Email_Upload__c, partObj);
                    j++;
                }
            }
            String msg = '';
            if(upsertParMap != null && upsertParMap.values().size() > 0){
                Database.UpsertResult[] srList;
            	Database.Error[] listErr;
                try{
                    srList = Database.upsert(upsertParMap.values(), false);
                	volunteerlist = upsertParMap.values();
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
                            totalFailed++;
                            for(j = 0; j < listErr.size();j++) {
                                strInfo += 'Row ' + String.valueOf(totalFailed) + ': ' + listErr[j].getMessage() + '<br/>\n';
                            }
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
    public void updatenull(){
        
    }
    
    public PageReference back(){
        pageReference pg = new pageReference('/'+vrId);
        pg.setRedirect(true);
        return pg;
    } 
}