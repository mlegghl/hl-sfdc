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
    bulkTarget = AUTO_DETECT;

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
        return [{ value: AUTO_DETECT, label: 'Auto-detect (clear)' }, ...this.activeWorkspaceOptions].map((o) => ({
            ...o,
            selected: o.value === this.bulkTarget
        }));
    }

    async resetAndLoad() {
        this.rows = [];
        this.afterId = null;
        this.hasMore = true;
        this.totalCount = 0;
        this.allFlaggedSelected = false;
        await this.loadMore();
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
            const newRows = (page.rows || []).map((r) => ({
                ...r,
                login: r.login || '',
                workspaceId: r.workspaceId || AUTO_DETECT,
                originalLogin: r.login || '',
                originalWorkspaceId: r.workspaceId || AUTO_DETECT,
                selected: this.allFlaggedSelected
            }));
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

    get viewRows() {
        const activeOptions = this.activeWorkspaceOptions;
        return this.rows.map((r) => {
            const status = this.workspaceStatus(r.workspaceId);
            const flagged = status === 'deactivated' || status === 'notfound';
            const emailInvalid = r.login !== '' && !EMAIL_REGEX.test(r.login);
            const dirty = r.login !== r.originalLogin || r.workspaceId !== r.originalWorkspaceId;

            const options = [{ value: AUTO_DETECT, label: 'Auto-detect' }, ...activeOptions];
            // keep invalid saved/current values visible so the dropdown never shows a different value
            [r.originalWorkspaceId, r.workspaceId].forEach((id) => {
                if (id && !options.some((o) => o.value === id)) {
                    const s = this.workspaceStatus(id);
                    options.push({ value: id, label: `${id} (${s === 'deactivated' ? 'Deactivated' : 'Not found'})` });
                }
            });

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
                options: options.map((o) => ({ ...o, selected: o.value === r.workspaceId })),
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

    get saveLabel() {
        return `Save changes (${this.dirtyCount})`;
    }

    get saveDisabled() {
        return this.dirtyCount === 0 || this.isSaving;
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
            : 'No users have a Help Lightning login or default workspace saved yet.';
    }

    get messageClass() {
        const theme = this.messageVariant === 'error' ? 'slds-theme_error' : 'slds-theme_success';
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
            this.allFlaggedSelected = false;
            this.rows.forEach((r) => { r.selected = true; });
        }
        row.selected = event.target.checked;
        this.rows = [...this.rows];
    }

    handleSelectAllLoaded(event) {
        const checked = event.target.checked;
        this.allFlaggedSelected = false;
        this.rows.forEach((r) => { r.selected = checked; });
        this.rows = [...this.rows];
    }

    handleSelectAllFlagged() {
        this.allFlaggedSelected = true;
    }

    handleClearSelection() {
        this.allFlaggedSelected = false;
        this.rows.forEach((r) => { r.selected = false; });
        this.rows = [...this.rows];
    }

    handleEmailChange(event) {
        const row = this.findRow(event.target.dataset.id);
        if (row) {
            row.login = (event.target.value || '').trim();
            this.rows = [...this.rows];
        }
    }

    handleWorkspaceChange(event) {
        const row = this.findRow(event.target.dataset.id);
        if (row) {
            row.workspaceId = event.target.value;
            this.rows = [...this.rows];
        }
    }

    handleBulkTargetChange(event) {
        this.bulkTarget = event.target.value;
    }

    confirmDiscard() {
        // eslint-disable-next-line no-alert
        return this.dirtyCount === 0 || window.confirm('You have unsaved changes that will be discarded. Continue?');
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
        const dirty = this.dirtyRows;
        if (dirty.length === 0) {
            return;
        }
        const invalid = dirty.find((r) => r.login !== '' && !EMAIL_REGEX.test(r.login));
        if (invalid) {
            this.showMessage(`Invalid email address for ${invalid.userName}: ${invalid.login}`, 'error');
            return;
        }

        this.isSaving = true;
        try {
            const count = await saveRows({
                updates: dirty.map((r) => ({
                    configId: r.configId,
                    login: r.login,
                    workspaceId: r.workspaceId
                }))
            });
            dirty.forEach((r) => {
                r.originalLogin = r.login;
                r.originalWorkspaceId = r.workspaceId;
            });
            this.rows = [...this.rows];
            this.showMessage(`Saved ${count} user${count === 1 ? '' : 's'}.`, 'success');
        } catch (error) {
            this.showMessage(this.errorText(error, 'Unable to save changes.'), 'error');
        } finally {
            this.isSaving = false;
        }
    }

    async handleBulkApply() {
        if (this.selectedCount === 0 || !this.confirmDiscard()) {
            return;
        }
        this.isSaving = true;
        try {
            const count = await bulkSetWorkspace({
                configIds: this.allFlaggedSelected ? [] : this.selectedRows.map((r) => r.configId),
                allFlagged: this.allFlaggedSelected,
                workspaceId: this.bulkTarget
            });
            const target = this.bulkTarget
                ? this.activeWorkspaceOptions.find((o) => o.value === this.bulkTarget).label
                : 'Auto-detect';
            this.showMessage(`Set ${count} user${count === 1 ? '' : 's'} to ${target}.`, 'success');
            await this.resetAndLoad();
        } catch (error) {
            this.showMessage(this.errorText(error, 'Unable to update the selected users.'), 'error');
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
