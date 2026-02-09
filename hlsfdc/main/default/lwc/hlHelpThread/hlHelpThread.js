import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getWorkboxDetails from '@salesforce/apex/HLSessionController.getWorkboxDetails';
import resendGuestInvite from '@salesforce/apex/HLSessionController.resendGuestInvite';
import removeGuest from '@salesforce/apex/HLSessionController.removeGuest';
import closeWorkbox from '@salesforce/apex/HLSessionController.closeWorkbox';
import reopenWorkbox from '@salesforce/apex/HLSessionController.reopenWorkbox';
import updateWorkbox from '@salesforce/apex/HLWorkboxDetailsController.updateWorkbox';

export default class HlHelpThread extends LightningElement {
    @api recordId;
    @api sObjectName;

    @track workboxData = null;
    @track isLoading = true;
    @track hasError = false;
    @track errorMessage = '';
    @track isSaving = false;

    _observer = null;
    _isVisible = false;
    _customFieldsInfo = null; // Mutable custom fields data (like hlCloseWorkbox pattern)

    connectedCallback() {
        this.loadWorkboxDetails();
    }

    renderedCallback() {
        // Set up IntersectionObserver to detect when tab becomes visible
        if (!this._observer) {
            this._observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting && !this._isVisible) {
                        // Component just became visible - refresh data
                        this._isVisible = true;
                        console.log('HLHelpThread: Tab became visible, refreshing data');
                        this.loadWorkboxDetails();
                    } else if (!entry.isIntersecting) {
                        this._isVisible = false;
                    }
                });
            }, { threshold: 0.1 });

            // Observe this component's container
            const container = this.template.querySelector('.help-thread-container');
            if (container) {
                this._observer.observe(container);
            }
        }
    }

    disconnectedCallback() {
        // Clean up observer when component is destroyed
        if (this._observer) {
            this._observer.disconnect();
            this._observer = null;
        }
    }

    async loadWorkboxDetails() {
        this.isLoading = true;
        this.hasError = false;
        this.errorMessage = '';

        try {
            const result = await getWorkboxDetails({
                sObjectName: this.sObjectName,
                recordId: this.recordId
            });

            console.log('HLHelpThread::loadWorkboxDetails result:', JSON.stringify(result));
            this.workboxData = result;
            
            // Transform custom fields to match hlCloseWorkbox pattern exactly
            this._customFieldsInfo = this.buildCustomFieldsInfo(result);
        } catch (error) {
            console.error('HLHelpThread::loadWorkboxDetails error:', error);
            this.hasError = true;
            this.errorMessage = error.body?.message || 'Failed to load Help Thread details.';
        } finally {
            this.isLoading = false;
        }
    }

    get showNoWorkbox() {
        return !this.isLoading && !this.hasError && !this.workboxData;
    }

    get hasWorkbox() {
        return !this.isLoading && !this.hasError && this.workboxData;
    }

    get workboxTitle() {
        return this.workboxData?.title || 'Help Thread';
    }

    // Map API status values to user-friendly labels
    get statusOptions() {
        return [
            { label: 'Active', value: 'REPORTED' },
            { label: 'Closed', value: 'CLOSED' }
        ];
    }

    get workboxStatusValue() {
        return this.workboxData?.status || 'REPORTED';
    }

    get workboxStatus() {
        const status = this.workboxData?.status;
        // Map status for display
        if (status === 'REPORTED') {
            return 'Active';
        } else if (status === 'CLOSED') {
            return 'Closed';
        }
        return status || 'Unknown';
    }

    get assignedTo() {
        const assigned = this.workboxData?.assigned_to;
        if (assigned && assigned.id !== -1) {
            return assigned.name;
        }
        return null;
    }

    // Participants are registered Help Lightning users
    get participants() {
        const participants = this.workboxData?.participants || [];
        return participants.map(p => ({
            ...p,
            displayName: p.name,
            roleLabel: p.owner ? 'Owner' : 'Participant',
            isOwner: p.owner === true
        }));
    }

    get hasParticipants() {
        return this.participants.length > 0;
    }

    // Guests are invited users (not registered)
    get guests() {
        const guests = this.workboxData?.guests || [];
        return guests.map(g => ({
            ...g,
            displayName: g.name ? `${g.name} (${g.id})` : `Guest (${g.id})`,
            statusLabel: g.has_joined ? 'Joined' : 'Pending'
        }));
    }

    get hasGuests() {
        return this.guests.length > 0;
    }

    get noGuests() {
        return !this.hasGuests;
    }

    // Build custom fields info matching hlCloseWorkbox pattern exactly
    // Now uses the properly structured Apex model (HLModelWorkboxDetails)
    buildCustomFieldsInfo(data) {
        if (!data) return null;
        
        // Model returns customFields (field definitions) and fieldValues (current values)
        const fieldDefs = data.customFields || [];
        const fieldValues = data.fieldValues || [];
        
        // hlCloseWorkbox reverses the array, we'll keep them in order
        const orderedFields = [...fieldDefs].reverse();
        
        return {
            workboxId: data.workboxId,      // Model uses workboxId
            workboxToken: data.workboxToken, // Model uses workboxToken
            customFields: orderedFields
                .filter(cf => !cf.hidden)
                .map((cf) => {
                    // Get current value from fieldValues array
                    const fieldValue = fieldValues.find(f => f.id === cf.id);
                    let value = null;
                    
                    if (cf.type === 'TEXT') {
                        value = fieldValue?.value || '';
                    } else if (cf.type === 'BOOLEAN') {
                        value = fieldValue?.value === true;
                    } else if (cf.type === 'LIST' && !cf.multiSelect) {
                        // Single-select: API returns array of objects, extract first ID
                        const listVal = fieldValue?.value;
                        if (Array.isArray(listVal) && listVal.length > 0) {
                            value = listVal[0].id;  // Integer ID
                        }
                    } else if (cf.type === 'LIST' && cf.multiSelect) {
                        // Multi-select: extract IDs from array of objects
                        const listVal = fieldValue?.value;
                        if (Array.isArray(listVal)) {
                            value = listVal.map(v => v.id);  // Array of integer IDs
                        } else {
                            value = [];
                        }
                    }
                    
                    // Options already come from model with label/value format
                    // Add 'selected' state for multi-select
                    const options = cf.options?.map(opt => ({
                        ...opt,
                        selected: cf.multiSelect && Array.isArray(value) && value.includes(opt.value)
                    })) || [];
                    
                    return {
                        ...cf,
                        value: value,  // Mutable value property (like hlCloseWorkbox)
                        required: cf.mandatory === "MANDATORY_ON_CREATION" || cf.mandatory === "MANDATORY_ON_CLOSE",
                        isText: cf.type === "TEXT",
                        isBoolean: cf.type === "BOOLEAN",
                        isList: cf.type === "LIST" && cf.multiSelect === false,
                        isMultiList: cf.type === "LIST" && cf.multiSelect === true,
                        options: options
                    };
                })
        };
    }

    get customFields() {
        return this._customFieldsInfo?.customFields || [];
    }

    get hasCustomFields() {
        return this.customFields.length > 0;
    }

    // Change handlers matching hlCloseWorkbox exactly (using data-index)
    handleInputChange(event) {
        let clone = [...this._customFieldsInfo.customFields];
        clone[event.target.dataset.index].value = event.detail.value;
        this._customFieldsInfo = { ...this._customFieldsInfo, customFields: clone };
    }

    handleCheckChange(event) {
        let clone = [...this._customFieldsInfo.customFields];
        clone[event.target.dataset.index].value = event.target.checked;
        this._customFieldsInfo = { ...this._customFieldsInfo, customFields: clone };
    }

    handleSelectChange(event) {
        let clone = [...this._customFieldsInfo.customFields];
        clone[event.target.dataset.index].value = parseInt(event.detail.value);
        this._customFieldsInfo = { ...this._customFieldsInfo, customFields: clone };
    }

    handleMultiSelectChange(event) {
        // Exact same pattern as hlCloseWorkbox
        const selectedOptions = [];
        event.detail.data.forEach((i) => {
            if (i.selected) {
                selectedOptions.push(i.value);
            }
        });
        let clone = [...this._customFieldsInfo.customFields];
        clone[event.detail.index].value = selectedOptions;
        this._customFieldsInfo = { ...this._customFieldsInfo, customFields: clone };
    }

    async handleSaveFields() {
        console.log('Save fields clicked');
        
        // Build payload matching buttonWrapper exactly
        const payload = {
            workboxId: this._customFieldsInfo.workboxId,
            workboxToken: this._customFieldsInfo.workboxToken,
            values: this._customFieldsInfo.customFields.map((cf) => ({
                id: cf.id,
                value: cf.value
            })),
            close: false
        };

        console.log('Save payload:', JSON.stringify(payload));

        this.isSaving = true;
        try {
            await updateWorkbox({ payload: payload });

            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Custom fields saved successfully.',
                variant: 'success',
                mode: 'dismissable'
            }));

            // Refresh to show updated values
            this.loadWorkboxDetails();
        } catch (error) {
            console.error('Error saving custom fields:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body?.message || 'Failed to save custom fields.',
                variant: 'error',
                mode: 'dismissable'
            }));
        } finally {
            this.isSaving = false;
        }
    }

    handleOpenChat() {
        // Fire event to open the Help Lightning chat window
        const workboxId = this.workboxData?.workboxId;
        console.log('Open Chat clicked for workbox:', workboxId);
        
        // Dispatch custom event to parent component
        this.dispatchEvent(new CustomEvent('openchat', {
            detail: { workboxId: workboxId },
            bubbles: true,
            composed: true
        }));
    }

    async handleStatusChange(event) {
        const newStatus = event.detail.value;
        console.log('Status change requested:', newStatus);
        
        if (newStatus === 'CLOSED') {
            // Confirm before closing
            if (!confirm('Are you sure you want to close this Help Thread?')) {
                // Reset the dropdown to current value
                return;
            }

            try {
                await closeWorkbox({
                    sObjectName: this.sObjectName,
                    recordId: this.recordId
                });

                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Help Thread closed successfully.',
                    variant: 'success',
                    mode: 'dismissable'
                }));

                // Refresh to show updated status
                this.loadWorkboxDetails();
            } catch (error) {
                console.error('Error closing workbox:', error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: error.body?.message || 'Failed to close Help Thread.',
                    variant: 'error',
                    mode: 'dismissable'
                }));
            }
        } else if (newStatus === 'REPORTED') {
            // Reopen the workbox
            try {
                await reopenWorkbox({
                    sObjectName: this.sObjectName,
                    recordId: this.recordId
                });

                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Help Thread reopened successfully.',
                    variant: 'success',
                    mode: 'dismissable'
                }));

                // Refresh to show updated status
                this.loadWorkboxDetails();
            } catch (error) {
                console.error('Error reopening workbox:', error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: error.body?.message || 'Failed to reopen Help Thread.',
                    variant: 'error',
                    mode: 'dismissable'
                }));
            }
        }
    }

    handleRefresh() {
        this.loadWorkboxDetails();
    }

    async handleResendInvite(event) {
        const guestUuid = event.target.dataset.guestUuid;
        console.log('Resend invite for guest uuid:', guestUuid);

        try {
            await resendGuestInvite({
                sObjectName: this.sObjectName,
                recordId: this.recordId,
                guestUuid: guestUuid
            });

            const toastEvent = new ShowToastEvent({
                title: 'Success',
                message: 'Invite resent successfully.',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(toastEvent);
        } catch (error) {
            console.error('Error resending invite:', error);
            const errorToast = new ShowToastEvent({
                title: 'Error',
                message: error.body?.message || 'Failed to resend invite.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(errorToast);
        }
    }

    async handleRemoveGuest(event) {
        const guestUuid = event.target.dataset.guestUuid;
        const guestName = event.target.dataset.guestName;
        console.log('Remove guest uuid:', guestUuid, guestName);

        // Confirm before removing
        if (!confirm(`Are you sure you want to remove ${guestName}?`)) {
            return;
        }

        try {
            await removeGuest({
                sObjectName: this.sObjectName,
                recordId: this.recordId,
                guestUuid: guestUuid
            });

            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Guest removed successfully.',
                variant: 'success'
            }));

            // Refresh the data
            this.loadWorkboxDetails();
        } catch (error) {
            console.error('Error removing guest:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body?.message || 'Failed to remove guest.',
                variant: 'error'
            }));
        }
    }
}
