import { LightningElement, api } from 'lwc';

export default class CriteriaButton extends LightningElement {
    isSelected = false;
    buttonVariant = 'neutral';

    @api commonLabel;

    @api
    handleClick(e, switchToFalse) { // e is for the default parameter, switchToFalse is to be used when overwritting value from parent
        this.isSelected = switchToFalse ? false : !this.isSelected
        this.buttonVariant = this.isSelected ? 'brand' : 'neutral'
        this.dispatchEvent(new CustomEvent('button_selected', {
            detail: {
                label: this.commonLabel, 
                isSelected: this.isSelected
            }
        }))
    }
}