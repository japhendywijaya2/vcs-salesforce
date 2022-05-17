import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import retrieveDonationList from '@salesforce/apex/DonationReconLWCController.retrieveDonationList'
import getSystemToday from '@salesforce/apex/DonationReconLWCController.getSystemToday'
import updateDonation from '@salesforce/apex/DonationReconLWCController.updateDonation'
import DONATIONS__C_OBJECT from '@salesforce/schema/Donations__c';
import { generateRandomId } from 'c/functionBank'

const columns = [
    {
        label: 'Donation No', 
        fieldName: 'recordUrl', 
        type: 'url',
        typeAttributes: { 
            label: {
                fieldName: 'Name'
            },
            target: '_blank'
        }
        
    },
    {label: 'Payment Method', fieldName: 'Payment_Method__c'},
    {label: 'Donation Status', fieldName: 'Donation_Status__c'},
    {label: 'Frequency Type', fieldName: 'Frequency_Type__c'},
    {
        label: 'Donation Amount', 
        fieldName: 'Donation_Amount__c', 
        type: 'currency', 
        sortable: true, 
        typeAttributes: {
            currencyCode: 'SGD',
        }
    },
    {label: 'Donation Date', fieldName: 'Donation_Date__c', type: 'date', sortable: true},
    {label: 'Cleared Date', fieldName: 'Cleared_Datetime__c', type: 'date', sortable: true}

];


export default class DonationReconciliationLWC extends LightningElement{
    isShowModal = false
    handleShowModal(e){
        this.isShowModal = !this.isShowModal
    }

    dateFromValue = null;
    dateToValue = null;
    maxDate = null;

    paymentMethodOptions = [];
    paymentMethodValue = null;

    donStatusUnfiltered = [];
    donStatusUpdateValue = null;
    donStatusUpdatePlaceholder = 'Select a Payment Method'

    frequencyTypeOptions = [];

    queryParams = { Donation_Status__c: {}, Frequency_Type__c: {} };

    donationsHeaders = columns;
    donationsListRetrieved = [];
    selectedDonationList = [];
    

    @wire(getObjectInfo, { 
        objectApiName: DONATIONS__C_OBJECT 
    })
    donations__c_objectInfo;

    @wire(getPicklistValuesByRecordType, {
        objectApiName: DONATIONS__C_OBJECT,
        recordTypeId: '$donations__c_objectInfo.data.defaultRecordTypeId'
    })
    handlegetPicklistValuesByRecordType({data, error}){
        console.log(`🚀\n ~ file: donationReconciliationLWC.js ~ line 99 ~ donations__c_objectInfo`, this.donations__c_objectInfo)
        console.log(`🚀\n ~ file: donationReconciliationLWC.js ~ line 99 ~ donations__c_objectInfo.data`, this.donations__c_objectInfo.data)

        if(data){
            const { Payment_Method__c, Donation_Status__c, Frequency_Type__c } = data.picklistFieldValues

            this.paymentMethodOptions = Payment_Method__c.values.map(el=> { 
                return { label: el.label, value: el.value }
            })

            this.frequencyTypeOptions = Frequency_Type__c.values.map(el=> {
                return { id: generateRandomId(), label: el.label }
            })

            this.donStatusUnfiltered = Donation_Status__c

        }

        if(error){
            this.dispatchEvent(new ShowToastEvent({
                title: 'error @getPicklistValuesByRecordType',
                message: error.body.message,
                variant: error,
                mode: 'pester'
            }))
        }
    }
    
    @wire(getSystemToday)
    handleGetSystemToday(result){
        console.log(`🚀\n ~ file: donationReconciliationLWC.js ~ line 101 ~ result`, result)
        const {data, error} = result
        console.log(`🚀\n ~ file: donationReconciliationLWC.js ~ line 102 ~ data`, data)

        if(data){
            this.dateToValue = data
            this.maxDate = data
        }
        if(error){
            this.displayToast('Error in getting today value', error.body.message, 'error')
        }

    }




    get donationStatusUpdateDependent(){
        if(this.donStatusUnfiltered.values.length > 0 && this.paymentMethodValue){
            const controllerValue = this.donStatusUnfiltered.controllerValues[this.paymentMethodValue]
            
            return this.donStatusUnfiltered.values
                    .filter(el=> el.validFor.includes(controllerValue))
                    .map((el)=> {
                        return { 
                            id: generateRandomId(),
                            label: el.label, 
                            value: el.value 
                        }
                    })
        }
        return []
    }


    displayToast(title, message, variant, mode = 'dismissible '){
        this.dispatchEvent(new ShowToastEvent({
            title, message, variant, mode
        }))
    }


    validationCheck(donationStatusFiltered, frequencyTypeFiltered){
        const requiredObj = {
            'Date From': this.dateFromValue,
            'Date To': this.dateToValue,
            'Payment Method': this.paymentMethodValue,
            'Donation Status': Object.keys(donationStatusFiltered)[0],
            'Frequency Type': Object.keys(frequencyTypeFiltered)[0]
        }
        
        for (const key in requiredObj) {
            if(!requiredObj[key]){
                this.displayToast('Required Field Missing', `Please select a value for ${key}`, 'error')
                return false
            }
        }

        if(this.dateFromValue > this.dateToValue){
            this.displayToast('Date Criteria Error', 'Date From cannot be greater then Date To', 'error')
            return false
        }

        return true
    }


    searchDonationClick(){
        try {
            const { Donation_Status__c, Frequency_Type__c } = this.queryParams
            for (const key in Donation_Status__c) {
                !Donation_Status__c[key] ? delete Donation_Status__c[key] : null
            }

            for (const key in Frequency_Type__c) {
                !Frequency_Type__c[key] ? delete Frequency_Type__c[key] : null
            }
            
            if(this.validationCheck(Donation_Status__c, Frequency_Type__c)){
                
                const queryString = 
                    `SELECT Id, Name, Payment_Method__c, Donation_Status__c, Frequency_Type__c, Donation_Amount__c, Donation_Date__c, Cleared_Datetime__c`
                    + ` FROM Donations__c`
                    + ` WHERE Donation_Date__c >= ${this.dateFromValue}`
                    +   ` AND Donation_Date__c <= ${this.dateToValue}`
                    +   ` AND Payment_Method__c IN ('${this.paymentMethodValue}')`
                    +   ` AND Donation_Status__c IN ('${Object.keys(Donation_Status__c).join("', '")}')`
                    +   ` AND Frequency_Type__c IN ('${Object.keys(Frequency_Type__c).join("', '")}')`
                    + ` ORDER BY Donation_Date__c DESC`
                
                console.log(`🚀\n ~ file: donationReconciliationLWC.js ~ line 128 ~ queryString`, queryString)
                
                
                retrieveDonationList({ queryString })
                .then(result=>{
                    this.donationsListRetrieved = result.map(el=> {
                        return {
                            ...el,
                            recordUrl: `/lightning/r/donations__c/${el.Id}/view` // anticipate in the future if SF change the format of the url
                        }
                    })                    
                })
                .catch(err=>{
                    throw err
                })
            }
            
        } catch (err) {
            console.error(err)
            this.dispatchEvent(this.displayToast('Error in retrieving data', err.message, 'error'))
        }
        
    }


    updateDonationRecords(){
        console.log(`
        ===============================================
        UPDATE ${this.selectedDonationList.length}
        ===============================================`)

        if(!this.donStatusUpdateValue){
            this.displayToast('Required Field Missing', 'Please select a Donation Value to update', 'error')
        }
        else{
            updateDonation({
                donationIdList: this.selectedDonationList,
                donationStatus: this.donStatusUpdateValue
            })
            .then(result=>{
                this.displayToast('Donation Reconciliation Result', result, 'success', 'sticky')
                console.log(`🚀\n ~ file: donationReconciliationLWC.js ~ line 231 ~ result`, result)
            })
            .catch(err=>{
                console.error(err)
            })
        }
        
    }



    // value change handler section
    handleDateFromChange(e){
        this.dateFromValue = e.detail.value
    }

    handleDateToChange(e){
        this.dateToValue = e.detail.value
    }

    handlePaymentMethodChange(e){
        this.paymentMethodValue = e.detail.value
        this.donStatusUpdateValue = null;
        this.donStatusUpdatePlaceholder = 'Choose an option'
    }

    handleDonStatusUpdateChange(e){
        this.donStatusUpdateValue = e.detail.value
    }

    handleQueryParamUpdate(e){
        const { containerName, paramStatus } = e.detail
        this.queryParams[containerName] = {...paramStatus}
    }

    handleRecordSelection(e){
        this.selectedDonationList = e.detail.selectedRows.map(e=> e.Id)
    }
    

    
}