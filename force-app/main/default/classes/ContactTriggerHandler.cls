public with sharing class ContactTriggerHandler {
    public static List<String> idTypeIndividual = new List<String>{'NRIC', 'FIN'};
    public static List<String> idTypeOrganisation = new List<String>{'UEN', 'UEN-Business', 'UEN-Local Company', 'UEN-Others'};


    public static void checkEmailUnique(Contact[] newRecordList){
        List<String> emailCheckList = new List<String>();
        List<String> idNoCheckList = new List<String>();

        for(Contact cItem : newRecordList){
            if(cItem.Email != null){
                if(emailCheckList.contains(cItem.Email)){
                    cItem.addError('Duplicate email usage in the bulk import data');
                }
                else{
                    emailCheckList.add(cItem.Email); 
                }
            }

            if(cItem.ID_No__c != null){
                if(idNoCheckList.contains(cItem.ID_No__c)){
                    cItem.addError('Duplicate Id Number usage in the bulk import data');
                }
                else{
                    idNoCheckList.add(cItem.ID_No__c);
                }
            }
            
        }

    }


    public static void createAccount(Contact[] newRecordListRaw){
        List<Contact> newRecordList = new List<Contact>();

        for(Contact cItem : newRecordListRaw){
            if(!cItem.CS_Enquiry__c && !cItem.ISS_Enquiry__c ){
                newRecordList.add(cItem);
            }
        }

        if(newRecordList.size() > 0){
            try {
                // Duplicate email checking is handled by sf trigger
    
                // 1. Account Creation
                List<Account> accountToCreate = new List<Account>();
                
    
                Id anonymousAccountId = [
                    SELECT Id
                    FROM Account
                    WHERE Name = 'Anonymous'
                        AND RecordTypeId = :Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId()
                ]?.id;
    
                if(anonymousAccountId == null){
                    Account createAnon = new Account(
                        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId(),
                        name = 'Anonymous'
                    );
                    Insert createAnon;
                    
                    anonymousAccountId = createAnon.id;
                }
    
    
                // check and retrieve for existing data
                // remove the duplicate rule in salesfor if this is success
                List<String> idNumberList = new List<String>();
                for(Contact cItem : newRecordList){
                    if( cItem.Tax_Recipient_Id_Type_Org__c != null
                        && cItem.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId()
                         && idTypeOrganisation.contains(cItem.Tax_Recipient_Id_Type_Org__c) ){
                        idNumberList.add(citem.Tax_Recipient_ID_No_Org__c);
                    }
                }
    
                List<Account> orgAccountExisted = ([
                    SELECT Id, ID_No__c
                    FROM Account
                    WHERE ID_No__c in :idNumberList
                ]);
    
                Map<String, Id> orgIdNoMap = new Map<String, Id>();
    
                for(Account aItem : orgAccountExisted){
                    orgIdNoMap.put(aItem.ID_No__c, aItem.id);
                }
                
                for(String item : orgIdNoMap.keySet()){
                    System.debug('\n\n item = ' + item );
                    System.debug('value = ' + orgIdNoMap.get(item) );
                }
    
    
    
                // compile list grouping
                for(Contact cItem : newRecordList){
                    System.debug('\n\ncItem.lastName \n' + cItem.lastName);
                    System.debug('\ncItem.isTaxRecipient__c \n' + cItem.isTaxRecipient__c);
                    System.debug('\ncItem.Email \n' + cItem.Email);
    
    
                    if( (cItem.isTaxRecipient__c == false || cItem.isTaxRecipient__c == null) && cItem.Email == null){
                        cItem.addError('Email is required if isTaxRecipient = false');
                    }
                    else{
                        System.debug('\n\nINSIDE the else \n');
                        Account AToAdd;
                        switch on cItem.Donor_Type__c {
                            when 'Organisation' {
                                System.debug('\n\ncItem.Tax_Recipient_ID_No_Org__c \n' + cItem.Tax_Recipient_ID_No_Org__c);
                                if(orgIdNoMap.containsKey(cItem.Tax_Recipient_ID_No_Org__c)){
                                    System.debug('\n\nMASUK \n');
                                    cItem.AccountId = orgIdNoMap.get(cItem.Tax_Recipient_ID_No_Org__c);
                                }
                                else{
                                    AToAdd = new Account(
                                        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organisation').getRecordTypeId(),
                                        Name = cItem.Organisation_Name__c,
                                        ID_Type__c = idTypeOrganisation.contains(cItem.Tax_Recipient_Id_Type_Org__c) ? cItem.Tax_Recipient_Id_Type_Org__c : null,
                                        ID_No__c = idTypeOrganisation.contains(cItem.Tax_Recipient_Id_Type_Org__c) ? cItem.Tax_Recipient_Id_No_Org__c : null
                                    );
                                    // accountToCreate.add(new Account(
                                    //     RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organisation').getRecordTypeId(),
                                    //     Name = cItem.Organisation_Name__c,
                                    //     ID_Type__c = idTypeOrganisation.contains(cItem.Tax_Recipient_Id_Type_Org__c) ? cItem.Tax_Recipient_Id_Type_Org__c : null,
                                    //     ID_No__c = idTypeOrganisation.contains(cItem.Tax_Recipient_Id_Type_Org__c) ? cItem.Tax_Recipient_Id_No_Org__c : null
                                    // ));
    
                                }
    
                                
                            }
        
                            when 'Individual' {
                                AToAdd = new Account(
                                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId(),
                                    Name = cItem.lastName + ' Household',
                                    ID_Type__c = idTypeIndividual.contains(cItem.ID_Type__c) ? cItem.ID_Type__c : null,
                                    ID_No__c = idTypeIndividual.contains(cItem.ID_Type__c) ? cItem.ID_No__c : null,
                                    Tax_Recipient_Full_Name__c = idTypeIndividual.contains(cItem.ID_Type__c) ? cItem.lastName : null
                                );
                                // accountToCreate.add(new Account(
                                //     RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId(),
                                //     Name = cItem.lastName + ' Household',
                                //     ID_Type__c = idTypeIndividual.contains(cItem.ID_Type__c) ? cItem.ID_Type__c : null,
                                //     ID_No__c = idTypeIndividual.contains(cItem.ID_Type__c) ? cItem.ID_No__c : null,
                                //     Tax_Recipient_Full_Name__c = idTypeIndividual.contains(cItem.ID_Type__c) ? cItem.lastName : null
                                // ));
                                
                            }
        
                            when 'Anonymous' {
                                cItem.AccountId = anonymousAccountId;
                                cItem.lastName = 'Anonymous-'+ cItem.Email;
                            }
                            
                        }
    
                        if(AToAdd != null && accountToCreate.contains(AToAdd) == false){
                            accountToCreate.add(AToAdd);
                        }
                        
                    }
                    
                }
    
                for(Account aItem : accountToCreate){
                    System.Debug('\n\naccountToCreate aItem.name \n' + aItem.name);
                    System.Debug('accountToCreate aItem.ID_Type__c \n' + aItem.ID_Type__c);
                    System.Debug('accountToCreate aItem.ID_No__c \n' + aItem.ID_No__c);
                }
    
                // 2. Insert the Account
                Database.SaveResult[] dbInsertResult = Database.insert(accountToCreate, false);
    
                // compile for account map for successfull creation
                Map<String, Id> accountMap = new Map<String, Id>();
                for(Account accItem : accountToCreate ){
                    if(accItem.Id != null){
                        accountMap.put(accItem.Name.toLowerCase()
                                    + ' - ' 
                                    + accItem.ID_Type__c 
                                    + ' - ' 
                                    + accItem.ID_No__c
                                    , accItem.Id);
                    }
                    
                }
    
                // change account map property where the account name already existed
                for(Database.SaveResult sr : dbInsertResult){
                    System.Debug('\n\ndbInsertResult sr \n' + sr);
                    if(!sr.isSuccess()){
                        System.Debug('\n\nNOT SUCCESS \n' + sr.getErrors());
                        for(Database.Error duplicateError : sr.getErrors()){
                            Datacloud.DuplicateResult duplicateResult = 
                                ((Database.DuplicateError)duplicateError).getDuplicateResult();
                            
                            
                            SObject matchRecord = duplicateResult.getMatchResults()[0].getMatchRecords()[0].getRecord();
                            System.Debug('\n\nmatchRecord \n' + matchRecord);
                            String accountName = (String) matchRecord.get('Name');
                            accountMap.put(accountName.toLowerCase()
                                                + ' - ' 
                                                + matchRecord.get('ID_Type__c')
                                                + ' - '
                                                + matchRecord.get('ID_No__c')
                                                , matchRecord.Id);
    
                        }
                    }
    
                }
    
                for(String key : accountMap.keySet()){
                    System.Debug('\n\naccountMap key : ' + key);
                    System.Debug(accountMap.get(key));
    
                }
       
    
                // 3. Tag contact to the accountId accordingly
                for(Contact cItem : newRecordList){
                    if(cItem.AccountId == null){
                        System.debug('\n\nMASUK DONG \n');
                        switch on cItem.Donor_Type__c {
                            when 'Individual' {
                                cItem.AccountId = accountMap.get(
                                    (cItem.lastname + ' Household').toLowerCase()
                                    + ' - '
                                    + cItem.ID_Type__c
                                    + ' - '
                                    + cItem.ID_No__c
                                );
                                
                            }
        
                            when 'Organisation' {
                                cItem.AccountId = accountMap.get(
                                    cItem.Organisation_Name__c.toLowerCase()
                                    + ' - '
                                    + cItem.Tax_Recipient_Id_Type_Org__c
                                    + ' - '
                                    + cItem.Tax_Recipient_Id_No_Org__c
                                );
                            }
                        }
                        
                    }
                    
                    System.debug('\n\ncItem.lastName \n' + cItem.lastName);
                    System.debug('cItem.AccountId \n' + cItem.AccountId);
                    if(cItem.AccountId == null){
                        System.debug('\n\nthrow error acccountid blank \n');
                        cItem.addError('Can\'t create Account, check for duplicate possibility'); 
                    }
                  
                }
    
                
            } catch (Exception err) {
                CustomException.printErrorInfo('contactTriggerHandler.createAccount', err) ;
                Trigger.new[0].addError(err.getMessage());
            }
            
        }
    }


    public static void sendWelcomeEmailFirstTime(Contact[] newRecordList){
        List<Id> contactIdToSendList = new List<Id>();

        for(Contact cItem : newRecordList){
            if(!cItem.Imported__c && String.isNotBlank(cItem.Email) && cItem.Volunteer__c){
                contactIdToSendList.add(cItem.Id);
            }
        }
        
        if(contactIdToSendList?.size() > 0){
            Utils.sendMassEmail(contactIdToSendList, 'Welcome Email');
        }
    }


    public static void sendWelcomeEmailUpdate(Contact[] newRecordList, Map<Id, Contact> oldRecordMap){
        List<Id> contactIdToSendList = new List<Id>();

        for(Contact cItem : newRecordList){
            if(!oldRecordMap.get(cItem.Id).Volunteer__c && cItem.Volunteer__c){
                contactIdToSendList.add(cItem.Id);
            }
        }
        
        if(contactIdToSendList?.size() > 0){
            Utils.sendMassEmail(contactIdToSendList, 'Welcome Email');
        }

    }


	public static void setVolunteerStatus(List<Contact> listNew){
        Date lastFY;
        if(Date.today().month() > 7) lastFY = Date.newInstance(Date.today().year(), 7, 1);
        else lastFY = Date.newInstance(Date.today().year()-1, 7, 1);    
        for(Contact c : listNew){
            if(c.Volunteer__c){
                if(c.Resignation_Date__c <> null){
                    c.Volunteer_Status__c = 'Resigned';
                    c.Assignment_Status__c = 'Unavailable';
                }
                if(c.Reason_of_Declined__c <> null){
                        c.Volunteer_Status__c = 'Declined';
                        c.Assignment_Status__c = 'Unavailable';
                }
                if(c.Dormant_Start_Date__c != null && c.Dormant_End_Date__c != null){
                    if(c.Dormant_Start_Date__c <= Date.today() && c.Dormant_End_Date__c >= Date.today() ){
                        c.Volunteer_Activity_Status__c = 'Dormant';
                        c.Assignment_Status__c = 'Unavailable';
                    }else{
                        if(c.Orientation_Completed__c){
                            c.Assignment_Status__c = 'Available';
                        }else{
                            c.Assignment_Status__c = 'Pending';
                        }
                        if(c.Last_Assignment_Date__c != null){
                            if(c.Last_Assignment_Date__c > lastFY){
                                c.Volunteer_Activity_Status__c = 'Active';
                            }else{
                                c.Volunteer_Activity_Status__c = 'Inactive';
                            }
                        }else{
                             c.Volunteer_Activity_Status__c = 'Pending';
                        }
                    }
                }
                if(c.Dormant_Start_Date__c == null && c.Dormant_End_Date__c == null && c.Resignation_Date__c == null && c.Reason_of_Declined__c == null){  
                    if(c.Orientation_Completed__c){
                        c.Volunteer_Status__c = 'Accepted';
                        c.Assignment_Status__c = 'Available';
                    }else if(c.Volunteer_Accepted_Date__c <> null){
                        c.Volunteer_Status__c = 'Accepted';
                        c.Assignment_Status__c = 'Pending';
                    }else if(c.Reason_of_Declined__c <> null){
                        c.Volunteer_Status__c = 'Declined';
                        c.Assignment_Status__c = 'Unavailable';
                    }else{
                        c.Volunteer_Status__c = 'Applied';
                        c.Assignment_Status__c = 'Pending';
                    }
                    if(c.Last_Assignment_Date__c != null){
                        if(c.Last_Assignment_Date__c > lastFY){
                            c.Volunteer_Activity_Status__c = 'Active';
                        }else{
                            c.Volunteer_Activity_Status__c = 'Inactive';
                        }
                    }else{
                        c.Volunteer_Activity_Status__c = 'Pending';
                    }
                }
        	}
        }
    }
    
    public static void createTask(List<Contact> listNew){
        
        system.debug('@@@'+ listNew);
        date todayDate = date.today(); 
        List<Task> tskList = new List<Task>();
        
        for(Contact c : listNew)
        {
            if(!c.Imported__c && c.Volunteer__c == true){
                Task tsk = new Task();
                tsk.Status='Not Started';
                tsk.Priority='High';
                tsk.ActivityDate = AddBusinessDays(todayDate,5); //Due Date
                if(c.FirstName != null){
                    tsk.Subject = 'Volunteer Interview with'+' '+ c.FirstName+' '+c.LastName;                
                }else{
                    tsk.Subject = 'Volunteer Interview with'+' '+ c.LastName;
                }
                tsk.Status = 'Not Started';
                tsk.Priority = 'High';
                tsk.WhoId = c.Id;
                tsk.WhatId = c.AccountId; //RelatedTO Id
                tsk.OwnerId = c.OwnerId; // AssignTo Id
                
                tskList.add(tsk);
            }            
        }
        if(tskList!=null && tskList.size()>0){
            insert tskList;
            
        }       
    }
    
    public static void createTask(List<Contact> listNew, Map<Id, Contact> oldMap){
        
        system.debug('@@@'+ listNew);
        date todayDate = date.today(); 
        List<Task> tskList = new List<Task>();
        
        for(Contact c : listNew)
        {
            if(!c.Imported__c && c.Volunteer__c == true && oldMap.get(c.Id).Volunteer__c == false){
                Task tsk = new Task();
                tsk.Status='Not Started';
                tsk.Priority='High';
                tsk.ActivityDate = AddBusinessDays(todayDate,5); //Due Date
                if(c.FirstName != null){
                    tsk.Subject = 'Volunteer Interview with'+' '+ c.FirstName+' '+c.LastName;                
                }else{
                    tsk.Subject = 'Volunteer Interview with'+' '+ c.LastName;
                }
                tsk.Status = 'Not Started';
                tsk.Priority = 'High';
                tsk.WhoId = c.Id;
                tsk.WhatId = c.AccountId; //RelatedTO Id
                tsk.OwnerId = c.OwnerId; // AssignTo Id
                
                tskList.add(tsk);
            }            
        }
        if(tskList!=null && tskList.size()>0){
            insert tskList;
            
        }       
    }
    
	public static Date AddBusinessDays(Date StartDate, integer BusinessDaysToAdd ){
        //Add or decrease in BusinessDaysToAdd days 
        Date finalDate = StartDate;
        system.debug('finaldate = '+finalDate);
        integer direction = BusinessDaysToAdd < 0 ? -1 : 1;
        system.debug('direction = '+direction);
        while(BusinessDaysToAdd != 0){
            finalDate = finalDate.AddDays(direction);
            system.debug('BusinessDaysToAdd = '+BusinessDaysToAdd);            
            system.debug('finaldate = '+finalDate);
            if (!isWeekendDay(finalDate)){
                BusinessDaysToAdd -= direction;
                
            }
        }
        return finalDate;
    }
    
    public static Boolean IsWeekendDay(Date dateParam){
        boolean result     = false;
        system.debug('dateParam = '+dateParam); 
        //Recover the day of the week
        Date startOfWeek   = dateParam.toStartOfWeek();
        system.debug('startOfWeek = '+startOfWeek);
        Integer dayOfWeek  = dateParam.day() - startOfWeek.day();
        system.debug('dayOfWeek = '+dayOfWeek);   
        result = dayOfWeek == 0 || dayOfWeek == 6 ? true : false;
        system.debug('result = '+result); 
        return result;
    } 
}