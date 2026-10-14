import { LightningElement, track } from 'lwc';
import getContext from '@salesforce/apex/HLUserWorkspacesController.getContext';
import getUsers from '@salesforce/apex/HLUserWorkspacesController.getUsers';
import saveRows from '@salesforce/apex/HLUserWorkspacesController.saveRows';
import bulkSetWorkspace from '@salesforce/apex/HLUserWorkspacesController.bulkSetWorkspace';

const PAGE_SIZE = 50;
const SCROLL_THRESHOLD_PX = 200;
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const AUTO_DETECT = '';

export default class HlUserWorkspaces extends LightningElement {
    @track rows = [];

    isLoadingContext = true;
    isLoadingRows = false;
    isSaving = false;
    ready = false;
    statusMessage = '';

    workspaces = [];
    workspaceById = new Map();

    afterId = null;
    hasMore = true;
    totalCount = 0;
    flaggedOnly = false;
    allFlaggedSelected = false;
    // workspace staged for every flagged user, including rows not loaded yet
    pendingFlaggedTarget = null;

    message = null;
    messageVariant = 'info';

    connectedCallback() {
        this.loadContext();
    }

    async loadContext() {
        this.isLoadingContext = true;
        try {
            const ctx = await getContext();
            this.ready = ctx.ready;
            this.statusMessage = ctx.statusMessage;
            this.workspaces = ctx.workspaces || [];
            this.workspaceById = new Map(this.workspaces.map((w) => [w.id, w]));
            if (this.ready) {
                await this.resetAndLoad();
            }
        } catch (error) {
            this.ready = false;
            this.statusMessage = this.errorText(error, 'Unable to load Help Lightning workspaces.');
        } finally {
            this.isLoadingContext = false;
        }
    }

    get validIds() {
        return this.workspaces.filter((w) => w.active).map((w) => w.id);
    }

    get activeWorkspaceOptions() {
        return this.workspaces
            .filter((w) => w.active)
            .map((w) => ({ value: w.id, label: `${w.name} (${w.id})` }));
    }

    get bulkOptions() {
        return [{ value: '', label: 'Choose a workspace…' }, ...this.activeWorkspaceOptions];
    }

    async resetAndLoad() {
        this.rows = [];
        this.afterId = null;
        this.hasMore = true;
        this.totalCount = 0;
        this.allFlaggedSelected = false;
        this.pendingFlaggedTarget = null;
        await this.loadMore();
    }

    isFlagged(workspaceId) {
        const status = this.workspaceStatus(workspaceId);
        return status === 'deactivated' || status === 'notfound';
    }

    // a row whose only change is the staged "all flagged" workspace is saved by the bulk update
    isCoveredByPendingFlagged(r) {
        return this.pendingFlaggedTarget !== null &&
            this.isFlagged(r.originalWorkspaceId) &&
            r.workspaceId === this.pendingFlaggedTarget &&
            r.login === r.originalLogin;
    }

    workspaceLabel(workspaceId) {
        const option = this.activeWorkspaceOptions.find((o) => o.value === workspaceId);
        return option ? option.label : workspaceId;
    }

    async loadMore() {
        if (this.isLoadingRows || !this.hasMore) {
            return;
        }
        this.isLoadingRows = true;
        try {
            const page = await getUsers({
                afterId: this.afterId,
                pageSize: PAGE_SIZE,
                flaggedOnly: this.flaggedOnly,
                validIds: this.validIds
            });
            const newRows = (page.rows || []).map((r) => {
                const saved = r.workspaceId || AUTO_DETECT;
                const staged = this.pendingFlaggedTarget !== null && this.isFlagged(saved);
                return {
                    ...r,
                    login: r.login || '',
                    workspaceId: staged ? this.pendingFlaggedTarget : saved,
                    originalLogin: r.login || '',
                    originalWorkspaceId: saved,
                    selected: this.allFlaggedSelected
                };
            });
            this.rows = [...this.rows, ...newRows];
            this.afterId = page.nextAfterId;
            this.hasMore = page.hasMore;
            if (page.totalCount !== undefined && page.totalCount !== null) {
                this.totalCount = page.totalCount;
            }
        } catch (error) {
            this.hasMore = false;
            this.showMessage(this.errorText(error, 'Unable to load users.'), 'error');
        } finally {
            this.isLoadingRows = false;
        }
    }

    workspaceStatus(workspaceId) {
        if (!workspaceId) {
            return 'auto';
        }
        const w = this.workspaceById.get(workspaceId);
        if (!w) {
            return 'notfound';
        }
        return w.active ? 'ok' : 'deactivated';
    }

    workspaceDisplay(workspaceId) {
        const status = this.workspaceStatus(workspaceId);
        if (status === 'auto') {
            return 'Auto-detect';
        }
        if (status === 'ok') {
            return this.workspaceLabel(workspaceId);
        }
        const w = this.workspaceById.get(workspaceId);
        return w ? `${w.name} (${workspaceId})` : workspaceId;
    }

    get viewRows() {
        return this.rows.map((r) => {
            const status = this.workspaceStatus(r.workspaceId);
            const flagged = status === 'deactivated' || status === 'notfound';
            const emailInvalid = r.login !== '' && !EMAIL_REGEX.test(r.login);
            const workspaceChanged = r.workspaceId !== r.originalWorkspaceId;
            const dirty = r.login !== r.originalLogin || workspaceChanged;

            let statusLabel = 'OK';
            let badgeClass = 'slds-badge slds-theme_success';
            if (status === 'auto') {
                statusLabel = 'Auto-detect';
                badgeClass = 'slds-badge';
            } else if (status === 'deactivated') {
                statusLabel = 'Deactivated';
                badgeClass = 'slds-badge slds-theme_error';
            } else if (status === 'notfound') {
                statusLabel = 'Not found';
                badgeClass = 'slds-badge slds-theme_error';
            }

            let rowClass = 'slds-hint-parent';
            if (flagged) {
                rowClass += ' hl-row-flagged';
            }
            if (dirty) {
                rowClass += ' hl-row-dirty';
            }

            return {
                ...r,
                checked: this.allFlaggedSelected || r.selected,
                workspaceText: this.workspaceDisplay(r.workspaceId),
                previousWorkspaceText: workspaceChanged ? `was ${this.workspaceDisplay(r.originalWorkspaceId)}` : null,
                statusLabel,
                badgeClass,
                rowClass,
                dirty,
                emailInvalid,
                emailClass: emailInvalid ? 'slds-input hl-input-error' : 'slds-input',
                displayName: r.userActive ? r.userName : `${r.userName} (inactive user)`
            };
        });
    }

    get dirtyRows() {
        return this.rows.filter((r) => r.login !== r.originalLogin || r.workspaceId !== r.originalWorkspaceId);
    }

    get dirtyCount() {
        return this.dirtyRows.length;
    }

    get hasChanges() {
        return this.dirtyCount > 0 || this.pendingFlaggedTarget !== null;
    }

    get saveLabel() {
        if (this.pendingFlaggedTarget !== null) {
            const extra = this.dirtyRows.filter((r) => !this.isCoveredByPendingFlagged(r)).length;
            return `Save changes (${this.totalCount + extra})`;
        }
        return `Save changes (${this.dirtyCount})`;
    }

    get saveDisabled() {
        return !this.hasChanges || this.isSaving;
    }

    get discardDisabled() {
        return !this.hasChanges || this.isSaving;
    }

    get selectedRows() {
        return this.rows.filter((r) => r.selected);
    }

    get selectedCount() {
        return this.allFlaggedSelected ? this.totalCount : this.selectedRows.length;
    }

    get selectionLabel() {
        if (this.allFlaggedSelected) {
            return `All ${this.totalCount} flagged users selected`;
        }
        return `${this.selectedCount} selected`;
    }

    get pendingFlaggedLabel() {
        return this.pendingFlaggedTarget === null
            ? null
            : `All ${this.totalCount} flagged users will be set to ${this.workspaceLabel(this.pendingFlaggedTarget)}`;
    }

    get bulkDisabled() {
        return this.selectedCount === 0 || this.isSaving;
    }

    get allLoadedSelected() {
        return this.rows.length > 0 && (this.allFlaggedSelected || this.rows.every((r) => r.selected));
    }

    get showSelectAllFlagged() {
        return this.flaggedOnly && !this.allFlaggedSelected && this.totalCount > 0 &&
            this.rows.length > 0 && this.rows.every((r) => r.selected);
    }

    get selectAllFlaggedLabel() {
        return `Select all ${this.totalCount} flagged users`;
    }

    get hasRows() {
        return this.rows.length > 0;
    }

    get showEmpty() {
        return !this.isLoadingRows && this.rows.length === 0;
    }

    get emptyMessage() {
        return this.flaggedOnly
            ? 'No users have a deactivated or unknown default workspace.'
            : 'No users have a Help Lightning email or default workspace saved yet. Users appear here after they open the Help Lightning component.';
    }

    get messageClass() {
        const themes = { error: 'slds-theme_error', success: 'slds-theme_success', info: 'slds-theme_info' };
        const theme = themes[this.messageVariant] || 'slds-theme_info';
        return `slds-notify slds-notify_alert slds-m-bottom_small ${theme}`;
    }

    findRow(configId) {
        return this.rows.find((r) => r.configId === configId);
    }

    handleScroll(event) {
        const el = event.target;
        if (el.scrollTop + el.clientHeight >= el.scrollHeight - SCROLL_THRESHOLD_PX) {
            this.loadMore();
        }
    }

    handleRowSelect(event) {
        const row = this.findRow(event.target.dataset.id);
        if (!row) {
            return;
        }
        if (this.allFlaggedSelected) {
            // leaving "all flagged" mode keeps every loaded row selected except this one
            this.leaveAllFlagged();
            this.rows.forEach((r) => { r.selected = true; });
        }
        row.selected = event.target.checked;
        this.rows = [...this.rows];
    }

    handleSelectAllLoaded(event) {
        const checked = event.target.checked;
        this.leaveAllFlagged();
        this.rows.forEach((r) => { r.selected = checked; });
        this.rows = [...this.rows];
    }

    handleSelectAllFlagged() {
        this.allFlaggedSelected = true;
    }

    handleClearSelection() {
        this.leaveAllFlagged();
        this.rows.forEach((r) => { r.selected = false; });
        this.rows = [...this.rows];
    }

    // rows already loaded keep their staged workspace as normal row edits;
    //  rows that were never loaded are no longer included
    leaveAllFlagged() {
        this.allFlaggedSelected = false;
        this.pendingFlaggedTarget = null;
    }

    handleEmailChange(event) {
        const row = this.findRow(event.target.dataset.id);
        if (row) {
            row.login = (event.target.value || '').trim();
            this.rows = [...this.rows];
        }
    }

    handleBulkTargetChange(event) {
        const target = event.target.value;
        // reset to the prompt so the same workspace can be chosen again for another selection
        event.target.value = '';
        if (!target) {
            return;
        }

        let count;
        if (this.allFlaggedSelected) {
            this.pendingFlaggedTarget = target;
            this.rows.forEach((r) => {
                if (this.isFlagged(r.originalWorkspaceId)) {
                    r.workspaceId = target;
                }
            });
            count = this.totalCount;
        } else {
            const selected = this.selectedRows;
            selected.forEach((r) => { r.workspaceId = target; });
            count = selected.length;
        }
        this.rows = [...this.rows];
        this.showMessage(
            `${count} user${count === 1 ? '' : 's'} set to ${this.workspaceLabel(target)}. Click Save changes to apply.`,
            'info');
    }

    handleDiscard() {
        this.pendingFlaggedTarget = null;
        this.rows.forEach((r) => {
            r.login = r.originalLogin;
            r.workspaceId = r.originalWorkspaceId;
        });
        this.rows = [...this.rows];
        this.message = null;
    }

    confirmDiscard() {
        // eslint-disable-next-line no-alert
        return !this.hasChanges || window.confirm('You have unsaved changes that will be discarded. Continue?');
    }

    handleFlaggedToggle(event) {
        const checked = event.target.checked;
        if (!this.confirmDiscard()) {
            event.target.checked = this.flaggedOnly;
            return;
        }
        this.flaggedOnly = checked;
        this.resetAndLoad();
    }

    async handleSave() {
        if (!this.hasChanges) {
            return;
        }
        const rowEdits = this.dirtyRows.filter((r) => !this.isCoveredByPendingFlagged(r));
        const invalid = rowEdits.find((r) => r.login !== '' && !EMAIL_REGEX.test(r.login));
        if (invalid) {
            this.showMessage(`Invalid email address for ${invalid.userName}: ${invalid.login}`, 'error');
            return;
        }

        this.isSaving = true;
        let saved = 0;
        const usedBulk = this.pendingFlaggedTarget !== null;
        try {
            // the bulk update runs first so individual row edits win over it
            if (usedBulk) {
                saved += await bulkSetWorkspace({
                    configIds: [],
                    allFlagged: true,
                    workspaceId: this.pendingFlaggedTarget
                });
                this.rows.forEach((r) => {
                    if (this.isCoveredByPendingFlagged(r)) {
                        r.originalWorkspaceId = r.workspaceId;
                    }
                });
                this.pendingFlaggedTarget = null;
            }

            if (rowEdits.length > 0) {
                saved += await saveRows({
                    updates: rowEdits.map((r) => ({
                        configId: r.configId,
                        login: r.login,
                        workspaceId: r.workspaceId
                    }))
                });
                rowEdits.forEach((r) => {
                    r.originalLogin = r.login;
                    r.originalWorkspaceId = r.workspaceId;
                });
            }

            this.rows = [...this.rows];
            this.showMessage(`Saved ${saved} user${saved === 1 ? '' : 's'}.`, 'success');
            if (usedBulk) {
                await this.resetAndLoad();
            }
        } catch (error) {
            this.rows = [...this.rows];
            this.showMessage(this.errorText(error, 'Unable to save changes.'), 'error');
        } finally {
            this.isSaving = false;
        }
    }

    handleDismissMessage() {
        this.message = null;
    }

    showMessage(text, variant) {
        this.message = text;
        this.messageVariant = variant;
    }

    errorText(error, fallback) {
        return (error && error.body && error.body.message) || fallback;
    }
}
