import { LightningElement, api } from 'lwc';
import { generateRandomId } from 'c/functionBank'

export default class CriteriaContainer extends LightningElement {
    @api buttonDetails;
    @api containerName;
    @api includeAll = false;
    @api multiSelect = false;
    
    individualParamStatus = {};
    isAllButtonSelected = false;

    
    // handle for individual option button
    handleButtonSelected(e){
        const { label, isSelected } = e.detail

        if(isSelected){
            this.template.querySelector('c-criteria-button-all').handleClick(null, true)
        }
        this.individualParamStatus[label] = isSelected

        this.dispatch_event_queryParamUpdate()
    }


    // handle for all option button
    handleButtonAllSelected(e){
        try {
            const { isSelected } = e.detail
            this.isAllButtonSelected = isSelected
            
            if(isSelected){
                this.template.querySelectorAll('c-criteria-button').forEach(el=> el.handleClick(null, true))
            }
            
            this.dispatch_event_queryParamUpdate()

        } catch (err) {
            console.error('@criteriaContainer.handleButtonAllSelected', err)
        }

    }


    dispatch_event_queryParamUpdate(){
        // let paramStatus = {}

        // if(this.isAllButtonSelected){
        //     this.buttonDetails.forEach(el=> {
        //         paramStatus[el.label] = true
        //     })
        // }
        // else {
        //     paramStatus = this.individualParamStatus
        // }
        
        const paramStatus = this.isAllButtonSelected
                            ? this.buttonDetails.reduce( (acc, curr) => {
                                    acc[curr.label] = true
                                    return acc
                                }, {})
                            : this.individualParamStatus
        
        // this.isAllButtonSelected 
        //                     ? this.buttonDetails.reduce( (acc, curr) => { return acc[curr.label] = true }, {}) // all button options will be true
        //                     : this.individualParamStatus

        this.dispatchEvent(new CustomEvent( 'query_param_update', {
            detail: {
                containerName: this.containerName,
                paramStatus
            }
        }))
    }


    get getRandomId(){
        return generateRandomId();
    }
}