public with sharing class ContactISSCSTriggerHandler {
    public static List<String> idTypeIndividual = new List<String>{'NRIC', 'FIN'};
    public static List<String> idTypeOrganisation = new List<String>{'UEN', 'UEN-Business', 'UEN-Local Company', 'UEN-Others'};

    // TODO: change to bulkified
    public static void createAccount(Contact[] newRecordList) {
        System.debug('MASUK KE ContactISSCSTriggerHandler : createAccount');

        List<Account> newRecords = new List<Account>();

        for (Contact cItem: newRecordList) {
            // check account exist or not
                newRecords.add(new Account(
                    RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId(),
                    Name = cItem.LastName + ' Household'
                ));
        }

        Database.SaveResult[] saveResults =  Database.insert(newRecords, true);

        Id accountId;

        for(Database.SaveResult sr : saveResults) {
            if (sr.isSuccess()) {
                System.debug('result insert data\n');
                System.debug(sr);

                accountId = sr.getId();

            } else {
                System.debug('get the error :\n');
                System.debug(sr.getErrors());
            }
        }

        for (Contact cItem: newRecordList) {
            cItem.AccountId = accountId;
        }
    }
}