trigger RDTrigger on Recurring_Donation__c (before insert, before update, after update ) {
    List<Recurring_Donation__c> newRecordList = Trigger.new;
    List<Recurring_Donation__c> oldRecordList = Trigger.old;

    // Only run for single transaction
    if(newRecordList.size() == 1){
        Recurring_Donation__c newRecord = newRecordList[0];

        switch on Trigger.operationType {
            when BEFORE_INSERT {
                RDTriggerHandler.getAccountId(newRecord);
            }
            when BEFORE_UPDATE {
                // Triggered by first Donation
                if(oldRecordList[0].RD_Status__c == 'Pending'
                    && newRecord.RD_Status__c == 'Approved'){ 
                        RDTriggerHandler.firstDonation(newRecord);
                }

                
            }
            when AFTER_UPDATE {
                if(newRecord.Next_Deduction_Date__c != oldRecordList[0].Next_Deduction_Date__c){
                        RDTriggerHandler.createNextDonation(newRecord, oldRecordList[0]);
                }
                
            }
            when else {
                
            }
        }

    }
    



    // refactoring
    // 1. trigger before insert buat itung next deduction date
    // 2. trigger after update buat create next donation object base on old trigger next deduction datenya berubah
    
}