public with sharing class DonationReconLWCController {
    
    @AuraEnabled
    public static List<Donations__c> retrieveDonationList(String queryString){
        try {
            return Database.query(queryString);
        } catch (Exception err) {
            CustomException.printErrorInfo('DonationReconLWCController.retrieveDonationList', err);
            throw new CustomException(err.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getSystemToday(){
        try {
            System.Debug('\n\nget system today exe\n');
            return Datetime.now().format('yyyy-MM-dd', 'Asia/Singapore');
        } catch (Exception err) {
            CustomException.printErrorInfo('DonationReconLWCController.getSystemToday', err);
            throw new CustomException(err.getMessage());
        }
    }
}