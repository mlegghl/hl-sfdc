import { LightningElement, wire, api } from 'lwc';
import getContacts from '@salesforce/apex/HLContactListController.getContacts';

/** The delay used when debouncing event handlers before invoking Apex. */
const DELAY = 400;
export default class HlContacts extends LightningElement {
    searchTerm = '';
    @api recordId;
    @api sObjectName;

    @wire(getContacts, { searchTerm: '$searchTerm' }) contacts;

    connectedCallback() {
        console.log('recordId ' + this.recordId);
        console.log('sObjectName ' + this.sObjectName); 
    }

    handleTermChange(event) {
        window.clearTimeout(this.delayTimeout);
        console.log(this.contacts)
        const searchTerm = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.searchTerm = searchTerm;
        }, DELAY);
    }

    handleClickCall(e) {
        const contactEmail = e.target.dataset.value;
        const valueChangeEvent = new CustomEvent("callcontact", {
            detail: { email: contactEmail }
        });
        this.dispatchEvent(valueChangeEvent);
    }
} 