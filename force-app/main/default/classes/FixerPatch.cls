public with sharing class FixerPatch {
    // 1. clear running number from ALL record
    // 2. copy existing 'tax receipt no' to field 'old number'
    // 3. regen on the existing 'tax receipt no', starting from 1
    // - utilizing the trigger function, it is temporary modified to only generate tax receipt no on donation cleared after 2021-12-31
    // - revert the trigger function to the normal one
    public static void fixDuplicateTaxReceiptNo(){
        List<Donations__c> donationToFixList = [
            SELECT Id, Tax_Receipt_No__c, Old_Tax_Receipt_No__c, Tax_Receipt_Running_No__c
            FROM Donations__c
            WHERE Donor_Name__c != null
                AND (
                    Tax_Receipt_Running_No__c != null
                    OR Tax_Receipt_No__c != null
                )
            ORDER BY Cleared_Datetime__c ASC
        ];

        for(Donations__c dItem : donationToFixList){
            dItem.Tax_Receipt_Running_No__c = null;
            dItem.Old_Tax_Receipt_No__c = dItem.Tax_Receipt_No__c;
            dItem.Tax_Receipt_No__c = null;
        }

        if(donationToFixList.size() > 0){
            Update(donationToFixList);
        }
    }
}