import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getWorkboxDetails from '@salesforce/apex/HLSessionController.getWorkboxDetails';
import initWorkbox from '@salesforce/apex/HLSessionController.initWorkbox';
import reopenWorkbox from '@salesforce/apex/HLSessionController.reopenWorkbox';

export default class HlHelpThread extends LightningElement {
    @api recordId;
    @api sObjectName;
    @api contactName;
    @api contactEmail;
    @api contactPhone;

    @track workboxData = null;
    @track isLoading = true;
    @track hasError = false;
    @track errorMessage = '';
    @track isStartingThread = false;

    _observer = null;
    _isVisible = false;

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

    get isWorkboxClosed() {
        return this.workboxStatusValue === 'CLOSED';
    }

    get showInviteActions() {
        return !this.isWorkboxClosed;
    }

    get statusBadgeClass() {
        return this.isWorkboxClosed
            ? 'slds-badge slds-theme_error'
            : 'slds-badge slds-theme_success';
    }

    get assignedTo() {
        const assigned = this.workboxData?.assigned_to;
        if (assigned && assigned.id !== -1) {
            return assigned.name;
        }
        return null;
    }

    async handleStartHelpThread() {
        this.isStartingThread = true;
        try {
            await initWorkbox({
                sObjectName: this.sObjectName,
                recordId: this.recordId
            });

            await this.loadWorkboxDetails();
        } catch (error) {
            console.error('Error starting help thread:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body?.message || 'Failed to start Help Thread.',
                variant: 'error',
                mode: 'dismissable'
            }));
        } finally {
            this.isStartingThread = false;
        }
    }

    handleOpenChat() {
        this.dispatchOpenChatEvent();
    }

    handleVideoInvite() {
        this.dispatchOpenChatEvent('video');
    }

    handleChatInvite() {
        this.dispatchOpenChatEvent('chat');
    }

    handleAddContact() {
        this.dispatchOpenChatEvent('add_contact');
    }

    dispatchOpenChatEvent(actionType = null) {
        const workboxId = this.workboxData?.workboxId;
        this.dispatchEvent(new CustomEvent('openchat', {
            detail: {
                workboxId: workboxId,
                actionType: actionType
            },
            bubbles: true,
            composed: true
        }));
    }

    handleCloseHelpThread() {
        this.dispatchOpenChatEvent('close');
    }

    async handleReopenHelpThread() {
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

    handleRefresh() {
        this.loadWorkboxDetails();
    }

}
