/** 
 * Controller for VF page to upload attendance data from CSV file
 */ 
public class AttendanceController {
    static final Integer CSV_COLUMN = 13; // minimum number of column in a row
    static final Integer COL_DATE_IN = 7; // Start Date
    static final Integer COL_DATE_OUT = 9; // End Date
    static final Integer COL_VR = 2; // 
    static final Integer COL_ACC = 3;
    static final Integer COL_NAME = 4; 
    static final Integer COL_EMAIL = 5; // index of column for Email
    static final Integer COL_PHONE = 6;
    static final Integer COL_IN = 8; // time in
    static final Integer COL_OUT = 10;  // time out
    static final Integer COL_HOURS = 11; 
    static final Integer COL_NOTE = 12; 
    
    static final String STR_OK = 'Success';
    
    public Blob fileCsv {get;set;}
    public Integer TotalData {get;set;} // total data in CSV file
    public Map<Integer, String> mapErrors {get;set;}
    
    // const
    public AttendanceController() {
        initData();
    }   
    
    // initialize field mapping
    private void initData()
    {
        TotalData = 0;
        mapErrors = new Map<Integer, String>();
    }
    
    // upload data
    public PageReference upload()
    {
        Boolean bolTmp;
        
        initData();
        // extract data, put in map
        if (fileCSV == null) return null;
        
        Id RT_Individual = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        Id RT_Contacts = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        Id RT_Organisation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organisation').getRecordTypeId();
        Id RT_Household = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        
        List<List<String>> dataAll = new List<List<String>>();
        SSSCsvReader objCsv = new SSSCsvReader(fileCsv.toString());
        List<String> dataLine = new List<String>();
        Integer iRow = 1;
        Set<String> stAccountName = new Set<String>(); // set of account name
        Set<String> stContactName = new Set<String>(); // set of contact name
        Set<String> stEmail = new Set<String>(); // set of email address, to check contact
        Set<String> stVRName = new Set<String>(); // set of VR name
        Map<Id, Id> mapAVId = new Map<Id, Id>(); // 
        
        mapErrors = new Map<Integer, String>(); // row number, error message
        Date strFirstDate, strLastDate, strTmpDate; // for checking duplicate
        
        dataLine = objCsv.readLine();
        if (dataLine != null) {
            dataLine = objCsv.readLine(); // ignore first row
        }
        while (dataLine != null) {
            iRow++;
            mapErrors.put(iRow, STR_OK); // default
            
            // trim some column
            if (dataLine[COL_EMAIL] != null) dataLine[COL_EMAIL] = dataLine[COL_EMAIL].trim();
            if (dataLine[COL_VR] != null) dataLine[COL_VR] = dataLine[COL_VR].trim();
            dataAll.add(dataLine);
            
            // do simple validation
            if (dataLine.size() < CSV_COLUMN) {
                mapErrors.put(iRow, 'Invalid row, should have at least ' + CSV_COLUMN + ' column. Found only ' + dataLine.size());
            } else if (dataLine[COL_DATE_IN] == '' || !isValidDate(convertDate(dataLine[COL_DATE_IN]))) {
                mapErrors.put(iRow, 'Invalid date in');
            } else if (dataLine[COL_DATE_OUT] == '' || !isValidDate(convertDate(dataLine[COL_DATE_OUT]))) {
                mapErrors.put(iRow, 'Invalid date out');
            } else if (dataLine[COL_VR] == '') {
                mapErrors.put(iRow, 'Volunteer Request is blank');
            } else if (dataLine[COL_EMAIL] == '') {
                mapErrors.put(iRow, 'Email address is blank');
            } /*else if (dataLine[COL_HOURS] != '' && !isValidNumber(dataLine[COL_HOURS], true) ) {
                mapErrors.put(iRow, 'Invalid number of hours');
            }*/
            
            //else { // valid so far
            // always put in the set for all data
                if (dataLine[COL_VR] != '') stVRName.add(dataLine[COL_VR]);
                if (dataLine[COL_EMAIL] != '') stEmail.add(dataLine[COL_EMAIL]);
                
                if (dataLine[COL_NAME] != '') stContactName.add(dataLine[COL_NAME]);
                if (dataLine[COL_ACC] != '') stAccountName.add(dataLine[COL_ACC]);
            //}
            
            // get first date and last date to limit period for checking attendance
            if (dataLine[COL_DATE_IN] != '' && isValidDate(convertDate(dataLine[COL_DATE_IN])) ) {
                strTmpDate = Date.valueOf(convertDate(dataLine[COL_DATE_IN]));
                
                if (strFirstDate == null || strFirstDate > strTmpDate) {
                    strFirstDate = strTmpDate;
                } 
                if (strLastDate == null || strLastDate < strTmpDate) {
                    strLastDate = strTmpDate;
                } 
            }
            
                        
            TotalData++;                
            dataLine = objCsv.readLine();
        }
        
        Map<String, Id> mapEmailContact = new Map<String, Id>(); // map email to ID of contact
        Map<String, Id> mapVRId = new Map<String, Id>();
        Map<String, Id> mapAccount = new Map<String, Id>();
        
        // check existing contact
        for(Contact C: [SELECT Id, Name, Email FROM Contact WHERE Email IN :stEmail]) 
        {
            mapEmailContact.put(C.Email.toLowerCase(), C.Id);
        }
        for(Account A: [SELECT Id, Name FROM Account WHERE Name IN :stAccountName]) 
        {
            mapAccount.put(A.Name, A.Id);
        }
        
        // check existing program
        for(Volunteer_Request__c V: [SELECT Id, Name, Volunteer_Request_No__c FROM Volunteer_Request__c WHERE Volunteer_Request_No__c IN :stVRName])
        {
            mapVRId.put(V.Volunteer_Request_No__c, V.Id);
        }
        
        Map<Id, Map<Id, Assigned_Volunteer__c>> mapAVData = new Map<Id, Map<Id, Assigned_Volunteer__c>>(); // id VR -> (id Contact -> id AV)
        Map<Id, Assigned_Volunteer__c> tmpMapId;
        Assigned_Volunteer__C tmpAV;
        List<Assigned_Volunteer__c> lsAV_Upd = new List<Assigned_Volunteer__c>(); // AV with status <> Accepted, need to be updated
        List<Assigned_Volunteer__c> lsAV_New = new List<Assigned_Volunteer__c>(); // New AV 
        List<Id> lsIdAv = new List<Id>(); // list of ID from existing AV
        for(Assigned_Volunteer__c Av: [SELECT Id, Volunteer_Request__c, Contact__c, Assignee_Status__c,Accepted_Date__c FROM Assigned_Volunteer__c 
                                      WHERE Volunteer_Request__r.Volunteer_Request_No__c IN :stVRName ORDER BY Volunteer_Request__c, Contact__c])
        {
            if (mapAVData.get(Av.Volunteer_Request__c) == null) {
                tmpMapId = new Map<Id, Assigned_Volunteer__c>();
            } else {
                tmpMapId = mapAVData.get(Av.Volunteer_Request__c);
            } 
            tmpMapId.put(Av.Contact__c, Av);
            mapAVData.put(Av.Volunteer_Request__c, tmpMapId);
            lsIdAv.add(Av.Id);
        }
        
        // get existing attendance
        Map<Id, Map<Datetime, Attendance__c>> mapAttOld = new Map<Id, Map<Datetime, Attendance__c>>(); // map of attendance by AV
        Map<Datetime, Attendance__c> mapTmpStartDate = new Map<Datetime, Attendance__c>(); // temporary, map start date/time with attendance
        if (strFirstDate != null && strLastDate != null) {
            for(Attendance__c At: [SELECT Id, Checked_In__c, Start_Date__c, Assigned_Volunteer__c, Contact__c, Volunteer_Request__c, Checked_Out__c, End_Date__c,
                                        Start_Time__c, End_Time__c, General_Remarks__c
                                    FROM Attendance__c 
                                    WHERE Assigned_Volunteer__c IN :lsIdAv AND Start_Date__c >= :strFirstDate AND Start_Date__c <= :strLastDate
                                    AND Is_Imported__c = true]) 
            {
                mapTmpStartDate = new Map<Datetime, Attendance__c>();
                if (mapAttOld.get(At.Contact__c) != null) {
                    mapTmpStartDate = mapAttOld.get(At.Contact__c);
                }
                mapTmpStartDate.put(At.Checked_In__c, At);
                mapAttOld.put(At.Assigned_Volunteer__c, mapTmpStartDate);
            }
        }
        
        List<Contact> lsContactInd = new List<Contact>(); // individual
        List<Account> lsAccountNew = new List<Account>(); // organisation
        List<Contact> lsContactNew = new List<Contact>(); // contact record type
        Account objAcc;
        Contact objCnt;
        Map<String, String> mapCntAcc = new Map<String, String>(); // contact name -> acccount name
        // validate program and contact
        iRow = 1;
        Id idTmpVR, idTmpCnt, idTmpAV, idTmpAcc;
        Set<String> stEmailNew = new Set<String>(); // set of email without contact
        Set<Id> stTmpId;
        Map<String, Set<Id>> mapVREmailNew = new Map<String, Set<Id>>(); // set VR Id belong to email without contact, for AV creation
        
        for(List<String> dt: dataAll) {
            iRow++;
            
            if (dt[COL_VR] != '' && mapVRId.get(dt[COL_VR]) == null) {
                mapErrors.put(iRow, 'Volunteer Request does not exists - ' + dt[COL_VR]);
            }
            else if (dt[COL_EMAIL] != '' && mapEmailContact.get(dt[COL_EMAIL].toLowerCase()) == null) {
                // contact not found, create new
                if (dt[COL_NAME] == '') {
                    // error, cannot create contact
                    mapErrors.put(iRow, 'Contact does not exists and contact name is blank');
                } else if (!stEmailNew.contains(dt[COL_EMAIL])) { // skip if already registered
                    if (dt[COL_ACC] == '') {
                        objCnt = new Contact(RecordTypeId = RT_Individual, LastName = dt[COL_NAME], Email = dt[COL_EMAIL]);
                        // objCnt.Volunteer_Status__c = 'Accepted';
                        // objCnt.Assignment_Status__c = 'Assigned';
                        objCnt.Volunteer_Accepted_Date__c = Date.valueOf(convertDate(dt[COL_DATE_IN]));
                        objCnt.Volunteer__c  = true;
                        //objCnt.Last_Assignment_Date__c = Date.valueOf(convertDate(dt[COL_DATE_IN]));
                        lsContactInd.add(objCnt);
                    }
                    else {
                        objCnt = new Contact(RecordTypeId = RT_Contacts, LastName = dt[COL_NAME], Email = dt[COL_EMAIL]);
                        // objCnt.Volunteer_Status__c = 'Accepted';
                        // objCnt.Assignment_Status__c = 'Assigned';
                        objCnt.Volunteer_Accepted_Date__c = Date.valueOf(convertDate(dt[COL_DATE_IN]));
                        objCnt.Volunteer__c  = true;
                        //objCnt.Last_Assignment_Date__c = Date.valueOf(convertDate(dt[COL_DATE_IN]));
                        mapCntAcc.put(dt[COL_EMAIL], dt[COL_ACC]);
                        
                        if (mapAccount.get(dt[COL_ACC]) == null) {
                            
                            objAcc = new Account(RecordTypeId = RT_Organisation, Name = dt[COL_ACC]);
                            lsAccountNew.add(objAcc);
                            
                        } else {
                          objCnt.AccountId = mapAccount.get(dt[COL_ACC]);  
                        }
                        lsContactNew.add(objCnt);
                        
                    }
                    stEmailNew.add(dt[COL_EMAIL]);
                }/*else{
                    objCnt = mapEmailContact.get(dt[COL_EMAIL]);
                    
                }*/
                
                // registered as member of new contact in VR, to create AV
                idTmpVR = mapVRId.get(dt[COL_VR]);
                if (dt[COL_NAME] != '') {
                    stTmpId = new Set<Id>();
                    if (mapVREmailNew.get(dt[COL_EMAIL]) != null) {
                        stTmpId = mapVREmailNew.get(dt[COL_EMAIL]);
                    }
                    stTmpId.add(idTmpVR);
                    mapVREmailNew.put(dt[COL_EMAIL], stTmpId);
                }
            } else if (mapEmailContact.get(dt[COL_EMAIL].toLowerCase()) != null && mapVRId.get(dt[COL_VR]) != null) {
                // check AV
                bolTmp = false; // av not found
                idTmpVR = mapVRId.get(dt[COL_VR]);
                idTmpCnt = mapEmailContact.get(dt[COL_EMAIL].toLowerCase());
                if (mapAVData.get(idTmpVR) != null) {
                    if (mapAVData.get(idTmpVR).get(idTmpCnt) != null) {
                        bolTmp = true;
                        tmpAv = mapAVData.get(idTmpVR).get(idTmpCnt);
                        if (tmpAV.Assignee_Status__c != 'Accepted') {
                            tmpAV.Assignee_Status__c = 'Accepted';
                            tmpAV.Accepted_Date__c = Date.today();
                            lsAV_Upd.add(tmpAV);
                        }
                    } 
                } 
                if (!bolTmp && idTmpVR != null && idTmpCnt != null) {
                    // create new AV
                    tmpAV = getNewAV(idTmpVR, idTmpCnt);
                    lsAV_New.add(tmpAV);
                    system.debug('DEBUG: Yudi (Exist) idVR ' + idTmpVR);
                    system.debug('DEBUG: Yudi Email ' + dt[COL_EMAIL]);
                }
            }
        }
        
        try {
            // insert individual contact
            if (lsContactInd.size() > 0) {
                insert(lsContactInd);
                
                for(Contact C: lsContactInd) {
                    MapEmailContact.put(C.Email.toLowerCase(), C.Id);
                    
                    // add new AV
                    if (mapVREmailNew.get(C.Email) != null) {
                        for(Id idVR: mapVREmailNew.get(C.Email)) {
                            if (idVR != null) {
                                tmpAV = getNewAV(idVR, C.Id);
                                lsAV_New.add(tmpAV);
                            }
                            
                        }
                    }
                    
                }
            }
            // insert account
            if (lsAccountNew.size() > 0) {
                
                insert(lsAccountNew);
                for(Account A: lsAccountNew) {
                    mapAccount.put(A.Name, A.Id);
                }
            }
            // insert org contact
            if (lsContactNew.size() > 0) {
                
                for(Contact C: lsContactNew) {
                    if (mapAccount.get(mapCntAcc.get(C.Email)) != null) {
                        C.AccountId = mapAccount.get(mapCntAcc.get(C.Email));
                    }
                }
                insert(lsContactNew);
                for(Contact C: lsContactNew) {
                    MapEmailContact.put(C.Email.toLowerCase(), C.Id);
                    
                    // add new AV
                    if (mapVREmailNew.get(C.Email) != null) {
                        for(Id idVR: mapVREmailNew.get(C.Email)) {
                            if (idVR != null) {
                                tmpAV = getNewAV(idVR, C.Id);
                                lsAV_New.add(tmpAV);
                            }
                            
                        }
                    }
                }
                system.debug('DEBUG: YK map email contact ' + mapEmailContact);
            }
            
            // insert new AV
            if (lsAV_New.size() > 0) {
                insert(lsAV_New);
                for(Assigned_Volunteer__c A: lsAV_New) {
                    
                    tmpMapId = new Map<Id, Assigned_Volunteer__c>();
                    if (mapAVData.get(A.Volunteer_Request__c) != null) {
                        tmpMapId = mapAVData.get(A.Volunteer_Request__c);
                    }
                    tmpMapId.put(A.Contact__c, A);
                    mapAVData.put(A.Volunteer_Request__c, tmpMapId);
                }
            }
                
            
        }
        catch (DmlException e) {
            // TODO - need to extract detail error
            system.debug('DEBUG: on insert contact ' + e.getMessage());
            mapErrors.put(0, e.getMessage()); // for common error
            RollBackErrors();
        }
        
        // start checking attendance data
        Integer iRec = 0;
        // List<Database.SaveResult> srList = new List<Database.SaveResult>();
        List<Database.UpsertResult> srList = new List<Database.UpsertResult>();
        Map<Integer, Integer> mapRowRecord = new Map<Integer, Integer>(); // row number -> record index
        List<Attendance__c> lsAtt = new List<Attendance__c>(); 
        Attendance__c tmpAtt;
        Datetime tmpDatetime;
        try {
            system.debug('DEBUG: MAP ' + mapAttOld);
            iRow = 1;
            for(List<String>  dt: dataAll) {
                iRow++;
                //idTmpVR = mapVRId.get(dt[COL_VR]);
                if (mapErrors.get(iRow) == STR_OK && MapEmailContact.get(dt[COL_EMAIL].toLowerCase()) != null && mapVRId.get(dt[COL_VR]) != null) { // blank means no error
                    // get AV
                    idTmpVR = mapVRId.get(dt[COL_VR]);
                    idTmpCnt = mapEmailContact.get(dt[COL_EMAIL].toLowerCase());
                    if (mapAVData.get(idTmpVR) != null && mapAVData.get(idTmpVR).get(idTmpCnt) != null) {
                        // assume all valid
                        tmpDatetime = Datetime.newInstance(Date.valueOf(convertDate(dt[COL_DATE_IN])),strToTime(dt[COL_IN]));
                        idTmpAV = mapAVData.get(idTmpVR).get(idTmpCnt).Id;
                        
                        tmpAtt = new Attendance__c();
                        // check if attendance exists
                        if (mapAttOld.get(idTmpAV) != null && mapAttOld.get(idTmpAV).get(tmpDatetime) != null) {
                            tmpAtt = mapAttOld.get(idTmpAV).get(tmpDatetime);
                        }
                        
                        //tmpAtt.StartDate__c = tmpAtt.End_Date__c = Date.valueOf(convertDate(dt[COL_DATE_IN]));
                        tmpAtt.Volunteer_Request__c = idTmpVR;
                        tmpAtt.Assigned_Volunteer__c = idTmpAV;
                        if (dt[COL_IN] != '') tmpAtt.Checked_In__c = Datetime.newInstance(Date.valueOf(convertDate(dt[COL_DATE_IN])),strToTime(dt[COL_IN]));
                        if (dt[COL_OUT] != '') tmpAtt.Checked_Out__c = Datetime.newInstance(Date.valueOf(convertDate(dt[COL_DATE_OUT])),strToTime(dt[COL_OUT]));
                        tmpAtt.General_Remarks__c = dt[COL_NOTE];
                        
                        tmpAtt.Start_Date__c = Date.valueOf(convertDate(dt[COL_DATE_IN]));
                        tmpAtt.End_Date__c = Date.valueOf(convertDate(dt[COL_DATE_OUT]));
                        if (dt[COL_IN] != '') tmpAtt.Start_Time__c  = strToTime(dt[COL_IN]);
                        if (dt[COL_OUT] != '') tmpAtt.End_Time__c = strToTime(dt[COL_OUT]);
                        //if (dt[COL_HOURS] != null && dt[COL_HOURS] != '') tmpAtt.Total_Hours__c = Double.valueOf(dt[COL_HOURS]);
                        tmpAtt.Is_Imported__c = true;
                        tmpAtt.Validated__c = true; // Added by Ericca for run the trigger to update the total volunterring hours.
                        
                        lsAtt.add(tmpAtt);
                        mapRowRecord.put(iRec, iRow);
                        system.debug('DEBUG: YK ' + iRec + ' / ' + iRow + ' ADDED ');
                        iRec++;
                    }
                    else {
                        mapErrors.put(iRow, 'Error, AV cannot be created!');
                    }
                    
                }
                else {
                    system.debug('DEBUG: YK ' + iRec + ' / ' + iRow + ' ERROR ' + mapErrors.get(iRow));
                    if (mapErrors.get(iRow) == STR_OK) {
                        mapErrors.put(iRow, 'Error, VR is ' + mapVRId.get(dt[COL_VR]) + ' and Contact is ' + MapEmailContact.get(dt[COL_EMAIL].toLowerCase()));
                    }
                }
            }
            
            // TODO - batch process
            if (lsAtt.size() > 0) {
                // srList = Database.insert(lsAtt);
                srList = Database.upsert(lsAtt);
            }
        } catch (DmlException e) {
            // TODO - need to extract detail error
            system.debug('DEBUG: on insert contact ' + e.getMessage());
            mapErrors.put(0, e.getMessage());
            RollBackErrors();
        }
        
        // Iterate through each returned result
        iRec = 0;
        String tmpStr;
        for (Database.UpsertResult sr : srList) {
            if (sr.isSuccess()) {
                
            }
            else {
                // Operation failed, so get all errors   
                tmpStr = '';             
                for(Database.Error err : sr.getErrors()) {
                    
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                    
                    tmpStr += err.getMessage() + '<br />\n';
                }
                if (mapRowRecord.get(iRec) != null)
                {
                    mapErrors.put(mapRowRecord.get(iRec), tmpStr);
                }
            }
            iRec++;
        }
        
        // check existing AV
        return null;
    }
    
    // rollback, remove all success message
    private void RollBackErrors()
    {
        Integer iTotal;
        iTotal = mapErrors.size();
        
        for(Integer i: mapErrors.keySet()) {
            if (mapErrors.get(i) == STR_OK) mapErrors.remove(i);
        }
    }
    
    // fungsion to get new AV
    private Assigned_Volunteer__c getNewAV(Id idVR, Id idContact)
    {
        Assigned_Volunteer__c objAV = new Assigned_Volunteer__c();
        objAV.Volunteer_Request__c = idVR;
        objAV.Contact__c = idContact;
        objAV.Assignee_Status__c = 'Accepted';
        objAV.Accepted_Date__c = Date.today();
        //objAV.Dont_Send_Email__c = true;
        
        return objAV;
    }
    
     // check if a string is numeric (integer or double)
    public Boolean isValidNumber(String str, Boolean isInteger)
    {
        Decimal decTmp;
        Integer intTmp;
        Boolean bolOK = true;
        try {
            if (isInteger){
                intTmp = Integer.valueOf(str);
            }
            else {
                decTmp = Decimal.valueOf(str);
            }
        }
        catch (Exception e) {
            bolOK = false;
        }
        return bolOK;
    }
    
    /**
     * Validate if string is a valid date, blank is true
     * @param strDate with format YYYY-MM-DD
     * @return true if date is valid
     */ 
    public Boolean isValidDate(String strDate) {
        if (strDate == null) return true;
        strDate = strDate.trim();
        if (strDate == '') return true;
        
        try {
            Date tmpDate = Date.valueOf(strDate);
            return true;
        }
        catch(Exception e) {
            system.debug('DEBUG: error on date validation ' + e.getMessage());
            return false;
        }
    }
    
    // convert date from DD/MM/YYYY to YYYY-MM-DD
    public String convertDate(String strDate)
    {
        String strResult = strDate;
        String strYear;
        if (strDate != null && strDate != '')
        {
            String[] arrStr = strDate.split('/');
            
            if (arrStr.size() >= 3) {
                strYear = arrStr[2];
                if (strYear.length() == 2) strYear = '20' + strYear;
                strResult = strYear + '-' + arrStr[1] + '-' + arrStr[0];
            }
            
        }
        return strResult;
    }
    
    // convert string to time
    public Time strToTime(String strTime) {
        Time tmResult;
        if (strTime == '') return null;
        String[] arrTmp1 = strTime.split(' '); // space
        String[] arrTmp2 = arrTmp1[0].split(':'); // colon
        if (arrTmp1.size() < 2 || arrTmp2.size() < 2) return null; // invalid
        try {
            Integer iHour = Integer.valueOf(arrTmp2[0]);
            Integer iMin = Integer.valueOf(arrTmp2[1]);
            Integer iSec = (arrTmp2.size() >= 3) ? Integer.valueOf(arrTmp2[2]) : 0;
            
            // special case for 12:00
            if (iHour == 12) {
                iHour = 0;
            }
            
            if (arrTmp1[1] == 'PM') {
                iHour = iHour + 12;
            }
            tmResult = Time.newInstance(iHour, iMin, iSec, 0);
            
            return tmResult;
        }
        catch(Exception e) {
            system.debug('DEBUG: error on time ' + e.getMessage());
        }
        return null; // default null
    }
    
    // to handle back button to return to Contact List
    public PageReference back(){
        return new ApexPages.Action('{!List}').invoke();
    } 
    
}