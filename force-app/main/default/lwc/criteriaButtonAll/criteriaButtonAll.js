import { LightningElement, api } from 'lwc';

export default class CriteriaButtonAll extends LightningElement {
    @api commonLabel;
    isSelected = false;
    buttonVariant = 'neutral';

    connectedCallback(){
        this.handleClick()
    }

    @api
    handleClick(e, switchToFalse){
        this.isSelected = switchToFalse ? false : !this.isSelected
        this.buttonVariant = this.isSelected ? 'brand' : 'neutral'
        this.dispatchEvent(new CustomEvent('button_all_selected', {
            detail: {
                label: this.commonLabel,
                isSelected: this.isSelected
            }
        }))
    }

}