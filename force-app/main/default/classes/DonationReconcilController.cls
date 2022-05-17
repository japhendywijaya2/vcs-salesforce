public class DonationReconcilController {
    public Donations__c donation {get;set;}
    public Donations__c donation1 {get;set;}
    public List<Donations__c> donationList {get;set;}
    public List<DonationObj> donationObjList {get;set;}
    public Id Id{get;set;}
    public Decimal totalDonation {get;set;}
    public Decimal selectedDonation{get;set;}
    public boolean frequencyTypeOnetime {get; set;}
    public boolean frequencyTypeRecurring {get; set;}
    
    public DonationReconcilController (ApexPages.StandardController controller){
        Id = ApexPages.CurrentPage().getParameters().get('id');
        donation = new Donations__c();
        donation1 = new Donations__c();
        donation.Cleared_Date__c = Date.today();
        donation.Donation_Status__c = null;
        donation.Frequency_Type__c = null;
        totalDonation = 0;
        selectedDonation = 0;
    }
    
    public void selectAll(){
        for(DonationObj obj : donationObjList){
            obj.updated = true;
        }
        selectedDonation = totalDonation ;
    }
    
    public void unselectAll(){
        for(DonationObj obj : donationObjList){
            obj.updated = false;
        }
        selectedDonation = 0;
    }
    
    public void search(){
        selectedDonation = 0;
        totalDonation = 0;
        String query = 'SELECT Id, Name, Donation_Date__c, 	Donor_Account__c, Donor_Name__c, ID_no__c, Amount__c, Donation_Status__c, Cleared_Date__c, Cleared_Datetime__c, Frequency_Type__c, Donation_Amount__c, Donor_type__c FROM Donations__c WHERE ';
        boolean andclaus = false; //Channel_of_Donations__c,  Donation_Purpose__c, 
        if(donation.Donation_Date__c <> null){
            Datetime dt = Datetime.newInstance(donation.Donation_Date__c.year(), donation.Donation_Date__c.month(), donation.Donation_Date__c.day());
            query += ' Donation_Date__c >=  '+dt.format('yyyy-MM-dd');
            andclaus = true;
        }
        if(donation.Cleared_Date__c <> null){
            Datetime dt = Datetime.newInstance(donation.Cleared_Date__c.year(), donation.Cleared_Date__c.month(), donation.Cleared_Date__c.day());
            if(andclaus){
                query += ' AND ';
            }
            query += ' Donation_Date__c <= '+dt.format('yyyy-MM-dd');
        }
        if(donation.Donation_Status__c != null){
            if(andclaus){
                query += ' AND ';
            }
            query += ' Donation_Status__c = \''+donation.Donation_Status__c+'\'' ;
            andclaus = true;
        }
        /*if(donation.Frequency_Type__c!= null){
            if(andclaus){
                query += ' AND ';
            }
            query += ' Frequency_Type__c = \''+donation.Frequency_Type__c+'\'';
            andclaus = true;
        }*/
        if(frequencyTypeOnetime == true && frequencyTypeRecurring == true){
        }else if(frequencyTypeOnetime == true){
            if(andclaus){
                query += ' AND ';
            }
            query += ' Frequency_Type__c = \'One-Time\'';
            andclaus = true;
        }else if(frequencyTypeRecurring == true){
            if(andclaus){
                query += ' AND ';
            }
            query += ' Frequency_Type__c = \'Recurring\'';
            andclaus = true;
        }
        if(donation.Payment_Method__c != null){
            if(andclaus){
                query += ' AND ';
            }
            query += 'Payment_Method__c = \''+donation.Payment_Method__c+'\'';
            andclaus = false;
        }
        /*if(donation.Channel_of_Donations__c != null){
            if(andclaus){
                query += ' AND ';
            }
            query += 'Channel_of_Donations__c = \''+donation.Channel_of_Donations__c+'\'';
            andclaus = false;
        }*/
        query += ' ORDER BY Donation_Date__c';
        system.debug('================='+query);
        donationList = Database.query(query);
        
        if(donationList != null){
            donationObjList = new List<DonationObj>();
            for(Donations__c d : donationList){
                totalDonation += d.Donation_Amount__c;
                DonationObj obj = new DonationObj(d);
                donationObjList.add(obj);
            }
        }
    }
    
    public PageReference back(){
        pageReference pg = new pageReference('/'+Id);
        pg.setRedirect(true);
        return pg;
    }
    
    public PageReference save(){
        integer iselect = 0;
        List<Donations__c> updatedDonation = new List<Donations__c>();
        for(DonationObj obj: donationObjList){
            if(obj.updated == true){
                Donations__c p = obj.don;
                p.Donation_Status__c = donation1.Donation_Status__c;
                if( donation1.Donation_Status__c == 'Cleared'){
                    p.Cleared_Datetime__c = Datetime.now();
                }
                else if( donation1.Donation_Status__c != 'Cleared' ){
                    p.Cleared_Datetime__c = null;
                }
                updatedDonation.add(p);
                iselect++;
            }
        }
        try{
            if(iselect == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No Volunteer selected.'));
            }else{
                update(updatedDonation);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, updatedDonation.size()+ ' donation is updated.'));
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Unable to update this Donation. ERROR CODE:'+e.getMessage()));
        }
        
        return null;
    }
    
    public void calculateSelected(){
        selectedDonation = 0; 
        for(DonationObj obj: donationObjList){
            if(obj.updated == true){
                selectedDonation += obj.don.Donation_Amount__c;
            }
        }
    }
    public class DonationObj {
        public boolean updated {get;set;}
        public Donations__c don {get;set;}
        
        public DonationObj(Donations__c d){
            updated = false;
            don = d;
        }
    }
    
    
}