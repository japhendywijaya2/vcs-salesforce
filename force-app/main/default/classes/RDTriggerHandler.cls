public with sharing class RDTriggerHandler {

    // run @before_insert
    public static void getAccountId(Recurring_Donation__c newRecord){
        newRecord.Account__c = [
            SELECT AccountId
            FROM Contact
            WHERE id = :newRecord.Donor_Name__c
        ].AccountId;
    }
    

    // Run @before_update
    public static void firstDonation(Recurring_Donation__c newRecord){
        newRecord.Next_Deduction_Date__c = getNextDeductionDate((Date)newRecord.Start_Date__c, newRecord.Frequency__c, true);
        newRecord.Total_Donation_to_Date__c = newRecord.Amount__c;
    }


    // Run @after_update
    public static void createNextDonation(Recurring_Donation__c newRecord, Recurring_Donation__c oldRecord){
        // 1. check if next donation already exist with status 'scheduled'
        List<donations__c> existingNextDonation = [
            SELECT ID, Donation_Date__c, Donation_Status__c
            FROM Donations__c
            WHERE Recurring_Donation__c = :oldRecord.id
                AND Donation_Date__c = :oldRecord.Next_Deduction_Date__c
                AND Donation_Status__c = 'Scheduled'
        ];

        // 2. if there are scheduled record, but payment have not been commited, then delete the records
        if(existingNextDonation.size() > 0){
            delete existingNextDonation;
        }

        // Logic #1 and #2 are used to anticipate if User manually changed next deduction date on SF platform
        // the logic will delete the latest scheduled donation 

        // 3. create the next donation base on Next_Deduction_Date__c
        createNewDonation(newRecord);
    }

    
    public static void createNewDonation(Recurring_Donation__c rDonation){
        Contact contactDetail = [
            SELECT Id, 	Donor_Type__c, name
            FROM Contact
            WHERE Id = :rDonation.Donor_Name__c
        ];

        Donations__c donation = new Donations__c(
            Frequency_Type__c = 'Recurring',
            Donation_Date__c = Date.valueOf(rDonation.Next_Deduction_Date__c),
            Donation_Status__c = 'Scheduled',
            Donation_Amount__c = rDonation.Amount__c,
            Donor_Account__c = rDonation.Account__c,
            Donor_Name__c = rDonation.Donor_Name__c,
            Donor_Type__c = contactDetail.Donor_Type__c,
            Payment_Method__c = rDonation.Payment_Method__c,
            Recurring_Donation__c = rDonation.id,
            Tax_Deductible__c = rDonation.Tax_Deductible__c,
            Tax_Recipient_Individual__c = rDonation.Tax_Recipient_Individual__c ,
            Tax_Recipient_Organisation__c = rDonation.Tax_Recipient_Organisation__c ,
            is_RD_Generated__c = true
        );


        Insert donation;
    }

    
    public static Date getNextDeductionDate(Date startDate, String frequency, Boolean noWeekEnd){
        Date deductionDate;
        try {
            if(startDate == null || frequency == null)
                throw new CustomException('Required value: [startDate, frequency]');
            else{
                switch on frequency {
                    when 'Monthly' {
                        deductionDate = startDate.addMonths(1);        
                    }
                    when 'Weekly' {
                        deductionDate = startDate.addDays(7);           
                    }
                    when 'Bi weekly' {
                        deductionDate = startDate.addDays(14);           
                    }
                    when 'Bi monthly' {
                        deductionDate = startDate.addMonths(2);           
                    }
                    when 'Quarterly' {
                        deductionDate = startDate.addMonths(3);           
                    }
                    when 'Half Yearly' {
                        deductionDate = startDate.addMonths(6);           
                    }
                    when 'Yearly' {
                        deductionDate = startDate.addYears(1);           
                    }
                    when else {
                        throw new CustomException('unRecognized Value');
                    }
                } 

                if(noWeekEnd){
                    // As of 20-09-2021, 
                    // for datetime.format('u'): Monday is 1, Sunday is 7
                    // anticipate error potential in the future if salesforce change monday to be 2 and sunday to be 1
                    Datetime dt = deductionDate;
                    Integer dayNumber = Integer.valueOf( dt.format('u') );
                    
                    if(dayNumber > 5 )
                        deductionDate = deductionDate.addDays(7-dayNumber+1);
                }

            }
        } catch (Exception e) {
            System.Debug('\n\n' + e);
        }

        return deductionDate;
    }

}