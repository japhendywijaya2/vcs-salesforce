public with sharing class sendDonationResponseEmailBatchable implements Database.Batchable<SObject>{
    public String query;
    public String emailTemplateName;
    public List<Id> donationIdList = new List<Id>();

    public sendDonationResponseEmailBatchable(List<Donations__c> donationList, String emailTemplateName){
        for(Donations__c dItem : donationList){
            this.donationIdList.add(dItem.id);
        }

        query = 'SELECT Id, Donor_Name__c, Donor_Account__c '
            + 'FROM Donations__c '
            + 'WHERE '
            + 'Id in :donationIdList';

        this.emailTemplateName = emailTemplateName;
    }

    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }


    public void execute(Database.BatchableContext BC, List<Donations__c> donationList){

        for(Donations__c dItem : donationList){
            Utils.sendSingleEmailTemplate(dItem.Donor_Name__c, emailTemplateName, dItem.id);
        }
    }


    public void finish(Database.BatchableContext BC){
        System.debug('\n\nSend Donation response email in batch done \n');
    }


}