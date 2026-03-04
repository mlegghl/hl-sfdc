import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getWorkboxDetails from '@salesforce/apex/HLSessionController.getWorkboxDetails';
import initWorkbox from '@salesforce/apex/HLSessionController.initWorkbox';
import resendGuestInvite from '@salesforce/apex/HLSessionController.resendGuestInvite';
import removeGuest from '@salesforce/apex/HLSessionController.removeGuest';
import closeWorkbox from '@salesforce/apex/HLSessionController.closeWorkbox';
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

    async handleCloseHelpThread() {
        await this.updateWorkboxStatus('CLOSED');
    }

    async handleReopenHelpThread() {
        await this.updateWorkboxStatus('REPORTED');
    }

    async updateWorkboxStatus(newStatus) {
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
