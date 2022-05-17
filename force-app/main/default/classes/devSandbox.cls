public with sharing class devSandbox {
    public static void deleteAllJap(){
        Map<Id, Contact> contactJap = new Map<Id, Contact>([
            SELECT Id, AccountId
            FROM Contact
            WHERE lastName LIKE '%jap%' 
                OR lastName LIKE '%hendy%'
                OR lastName Like '%wijaya%'
                OR lastName Like '%jhw%'
        ]);

        delete new List<Donations__c>([
            SELECT Id 
            FROM Donations__c
            WHERE Donor_Name__c IN :contactJap.keySet()
        ]);

        delete new List<Recurring_Donation__c>([
            SELECT Id
            FROM Recurring_Donation__c
            WHERE Donor_Name__c IN :contactJap.keySet()
        ]);

        Set<Id> accountIdToDeleteSet = new Set<Id>();
        for(Contact cItem : contactJap.values()){
            accountIdToDeleteSet.add(cItem.AccountId);
        }

        List<Account> accountToDeleteList = new List<Account>();
        for(Id accountId : accountIdToDeleteSet){
            accountToDeleteList.add( new Account(
                id = accountId
            ));
        }

        delete accountToDeleteList;
    }

   




    
}