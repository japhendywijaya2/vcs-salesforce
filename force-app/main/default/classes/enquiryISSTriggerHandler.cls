public with sharing class enquiryISSTriggerHandler {
    
    // TODO: change to bulkified
    public static void setContactandIntake(Enquiry__c[] newRecordList) {
        // check contact with email is exist or not
        // if not exist => create contact with ISS_Enquiry__c true
        // connect to intake
        // if exist, change record type with ISS_Enquiry__c true, and type change to Client
        // connect to intake

        for (Enquiry__c enItem: newRecordList) {
            // validate from inserting data, 
            // Client_Email__c  must not null to execute trigger
            if (enItem.Client_Email__c != null || enItem.Client_Email__c != '') {

                // check contact available or not or not
                Contact[] contacts = [SELECT Id, Name, RecordTypeId, ISS_Enquiry__c FROM Contact WHERE Email = :enItem.Client_Email__c];
                            
                Id contactId;

                if (contacts.size() > 0){
                    // contact exist
                    for (Contact cItem: contacts) {
                        //enquiryContactIds.add(cItem.Id);

                        cItem.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Client').getRecordTypeId();
                        cItem.ISS_Enquiry__c = true;

                        contactId = cItem.Id;
                    }

                    Database.update(contacts, false);
                } else {
                    List<Contact> contactToCreate = new List<Contact>();

                    contactToCreate.add(new Contact(
                        RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Client').getRecordTypeId(),
                        LastName = enItem.ClientNameEntered__c,
                        // ID_No__c = enItem.ID_Number__c, // Tax Recipient ID No  (delete soon)
                        // ID_Type__c = enItem.ID_Type__c, // Tax Recipient ID Type : NRIC, dll  (delete soon)
                        // Tax_Recipient_Full_Name__c= enItem.ClientNameEntered__c, // Tax_Recipient_Full_Name__c (delete soon)
                        Phone = enItem.Contact_Number__c,
                        Email = enItem.Client_Email__c,
                        ISS_Enquiry__c = true                   
                    ));

                    System.debug('contact to add \n');
                    System.debug(contactToCreate);

                    Database.SaveResult[] saveResult = Database.insert(contactToCreate, false);

                    for (Database.SaveResult sr : saveResult) {
                        if(sr.isSuccess()) {
                            contactId = sr.getId();
                        } else {
                            System.debug('error insert data contact\n' + sr.getErrors());
                        }
                    }
                }

                // create intake 
                List<Intake__c> intakeToCreate = new List<Intake__c>();

                intakeToCreate.Add(new Intake__c(
                    RecordTypeId = Schema.SObjectType.Intake__c.getRecordTypeInfosByName().get('Intake - ISS').getRecordTypeId(),
                    Client_Name__c = contactId,
                    Enquiry_No__c = enItem.id
                ));

                Database.SaveResult[] saveResult = Database.insert(intakeToCreate, false);
                for (Database.SaveResult sr : saveResult) {
                    if(sr.isSuccess()) {
                        System.debug('success insert Intake\n' + sr);
                    } else {
                        System.debug('error insert data intake\n' + sr.getErrors());
                    }
                }
            }
        }
    }

    // TODO: change to bulkified
    public static void setNeedAssessment(Enquiry__c[] newRecordList) {

        for (Enquiry__c neItem: newRecordList) {
            // create need assessment 

            // get IntakeID
            String intakeId;

            List<Intake__c> intakeRecord = [SELECT Id, Name FROM Intake__c WHERE Enquiry_No__c = :neItem.Id];

            for (Intake__c inItem : intakeRecord) {
                intakeId = inItem.Id;
            }

            List<Needs_Assessment__c> needAssessmentToCreate = new List<Needs_Assessment__c>();

            needAssessmentToCreate.Add(new Needs_Assessment__c(
                Enquiry__c = neItem.Id,
                Intake_No__c = intakeId
            ));

            Database.SaveResult[] saveResult = Database.insert(needAssessmentToCreate, false);
            for (Database.SaveResult sr : saveResult) {
                if(sr.isSuccess()) {
                    System.debug('success insert need assessment\n' + sr);
                } else {
                    System.debug('error insert data need assessment\n' + sr.getErrors());
                }
            }
        }
    }
}