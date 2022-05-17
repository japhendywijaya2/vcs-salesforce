trigger DonationsTrigger on Donations__c (before insert, after insert, before update, after update ) {
    List<Donations__c> newRecordList = Trigger.new;
    List<Donations__c> oldRecordList = Trigger.old;


    switch on Trigger.operationType {
        when BEFORE_INSERT{
            DonationsTriggerHandler.createDonationBulkified(Trigger.new);
            DonationsTriggerHandler.getAccountIdBulk(Trigger.new);
            DonationsTriggerHandler.discrepancyCheck(Trigger.new);
            DonationsTriggerHandler.donationStatusCleared(Trigger.new);
            DonationsTriggerHandler.generateTaxReceiptNo(Trigger.new);
        }

        when AFTER_INSERT{
            DonationsTriggerHandler.sendEmailResponseInBatch(Trigger.new, Trigger.oldMap);
            DonationsTriggerHandler.updateContactDonationInfo(Trigger.new);            
            DonationsTriggerHandler.updateAccountDonationInfo(Trigger.new);
            DonationsTriggerHandler.updateProgramme(Trigger.new, null);
        }

        when BEFORE_UPDATE{
            DonationsTriggerHandler.discrepancyCheck(Trigger.new);
            DonationsTriggerHandler.donationStatusCleared(Trigger.new);
            DonationsTriggerHandler.generateTaxReceiptNo(Trigger.new);
        }

        when AFTER_UPDATE{
            // Only run for Single Transaction 
            if(newRecordList.size() == 1 && !newRecordList[0].Import__c){
                Donations__c newRecord = Trigger.new[0];
                Donations__c oldRecord = Trigger.old[0];

                if( 
                    newRecord.Donation_Status__c == 'Cleared'
                    && newRecord.Donation_Datetime__c != null 
                    && newRecord.Frequency_Type__c == 'Recurring'
                    && newRecord.Recurring_Donation__c != null
                    && newRecord.Donation_Amount__c != null 
                ){
                    DonationsTriggerHandler.updateRD(newRecord, oldRecord);
                }

            }

            // Bulkified
            DonationsTriggerHandler.sendEmailResponseInBatch(Trigger.new, Trigger.oldMap);            
            DonationsTriggerHandler.updateContactDonationInfo(Trigger.new);
            DonationsTriggerHandler.updateAccountDonationInfo(Trigger.new);
            DonationsTriggerHandler.updateProgramme(Trigger.new, Trigger.old);
                
        }
        when else {
            
        }
    }



    
}