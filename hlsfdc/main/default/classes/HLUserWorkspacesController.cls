/* -*- Mode: java; -*- */

/**
 * HLUserWorkspacesController.cls
 *
 * Copyright (c) 2026 HelpLightning Inc.
 * https://helplightning.com
 */

public with sharing class HLUserWorkspacesController {
    private static final Integer MAX_PAGE_SIZE = 200;
    private static final String EMAIL_REGEX = '^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$';

    @TestVisible
    private static Boolean forceNoAccess = false;

    public class WorkspaceOption {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public Boolean active { get; set; }
    }

    public class Context {
        @AuraEnabled public Boolean ready { get; set; }
        @AuraEnabled public Boolean canEdit { get; set; }
        @AuraEnabled public String statusMessage { get; set; }
        @AuraEnabled public List<WorkspaceOption> workspaces { get; set; }
    }

    public class UserRow {
        @AuraEnabled public String configId { get; set; }
        @AuraEnabled public String userId { get; set; }
        @AuraEnabled public String userName { get; set; }
        @AuraEnabled public String userEmail { get; set; }
        @AuraEnabled public Boolean userActive { get; set; }
        @AuraEnabled public String login { get; set; }
        @AuraEnabled public String workspaceId { get; set; }
    }

    public class UserPage {
        @AuraEnabled public List<UserRow> rows { get; set; }
        @AuraEnabled public String nextAfterId { get; set; }
        @AuraEnabled public Boolean hasMore { get; set; }
        @AuraEnabled public Integer totalCount { get; set; }
    }

    public class RowUpdate {
        @AuraEnabled public String configId { get; set; }
        @AuraEnabled public String login { get; set; }
        @AuraEnabled public String workspaceId { get; set; }
    }

    /**
     * Load the active/inactive workspaces for this site and
     *  determine whether the page can be used.
     */
    @AuraEnabled
    public static Context getContext() {
        Context ctx = new Context();
        ctx.ready = false;
        ctx.canEdit = canEditConfig();
        ctx.workspaces = new List<WorkspaceOption>();

        if (!ctx.canEdit) {
            ctx.statusMessage = 'You do not have permission to manage Help Lightning configuration.';
            return ctx;
        }

        List<helplightning.HLModelWorkspace> workspaces;
        try {
            workspaces = helplightning.HLGaldrClient.getWorkspaces();
        } catch (helplightning.HLConfigurationException e) {
            ctx.statusMessage = 'Configure your Help Lightning Site ID and Private Key before managing user workspaces.';
            return ctx;
        } catch (Exception e) {
            ctx.statusMessage = 'Your Help Lightning site key could not be verified: ' + e.getMessage();
            return ctx;
        }

        if (workspaces == null || workspaces.isEmpty()) {
            ctx.statusMessage = 'User workspace assignment requires a site-level key.';
            return ctx;
        }

        for (helplightning.HLModelWorkspace w : workspaces) {
            WorkspaceOption o = new WorkspaceOption();
            o.id = String.valueOf(w.id);
            o.name = w.name;
            o.active = (w.active == true);
            ctx.workspaces.add(o);
        }
        ctx.ready = true;
        return ctx;
    }

    /**
     * Get a page of users that have a Help Lightning login or
     *  default workspace saved. Only user-level records are returned.
     *
     * When flaggedOnly is true, only users whose saved workspace is
     *  not in validIds are returned.
     */
    @AuraEnabled
    public static UserPage getUsers(String afterId, Integer pageSize, Boolean flaggedOnly, List<String> validIds) {
        requireAccess();

        Integer size = (pageSize == null || pageSize < 1) ? 50 : Math.min(pageSize, MAX_PAGE_SIZE);
        Boolean onlyFlagged = (flaggedOnly == true);
        List<String> valid = (validIds == null) ? new List<String>() : validIds;

        List<helplightning__Help_Lightning_Config__c> configs = new List<helplightning__Help_Lightning_Config__c>();
        String cursor = String.isBlank(afterId) ? null : afterId;
        Boolean exhausted = false;

        // org and profile level records are filtered out in Apex, so keep
        //  querying until the page is full or there are no more records.
        while (configs.size() < size && !exhausted) {
            List<helplightning__Help_Lightning_Config__c> batch = queryConfigs(cursor, size, onlyFlagged, valid);
            exhausted = batch.size() < size;
            for (helplightning__Help_Lightning_Config__c c : batch) {
                cursor = c.Id;
                if (isUserOwner(c.SetupOwnerId) && configs.size() < size) {
                    configs.add(c);
                }
            }
        }

        UserPage page = new UserPage();
        page.rows = buildRows(configs);
        page.nextAfterId = configs.isEmpty() ? afterId : String.valueOf(configs[configs.size() - 1].Id);
        page.hasMore = !configs.isEmpty() && hasMoreUserRecords(page.nextAfterId, onlyFlagged, valid);
        if (String.isBlank(afterId)) {
            page.totalCount = countUserRecords(onlyFlagged, valid);
        }
        return page;
    }

    /**
     * Save login and workspace edits for individual rows.
     */
    @AuraEnabled
    public static Integer saveRows(List<RowUpdate> updates) {
        requireAccess();

        if (updates == null || updates.isEmpty()) {
            return 0;
        }

        Set<String> activeIds = loadActiveWorkspaceIds();

        List<helplightning__Help_Lightning_Config__c> records = new List<helplightning__Help_Lightning_Config__c>();
        for (RowUpdate u : updates) {
            if (String.isBlank(u.configId)) {
                throw newError('A row is missing its record id.');
            }

            String login = String.isBlank(u.login) ? null : u.login.trim();
            if (login != null && !Pattern.matches(EMAIL_REGEX, login)) {
                throw newError('Invalid email address: ' + login);
            }

            String workspaceId = String.isBlank(u.workspaceId) ? null : u.workspaceId.trim();
            if (workspaceId != null && !activeIds.contains(workspaceId)) {
                throw newError('Workspace ' + workspaceId + ' is not an active workspace.');
            }

            records.add(new helplightning__Help_Lightning_Config__c(
                Id = u.configId,
                helplightning__Login__c = login,
                helplightning__Workspace_Id__c = workspaceId));
        }

        update records;
        return records.size();
    }

    /**
     * Set the default workspace for many users at once.
     *
     * When allFlagged is true, configIds is ignored and every user
     *  whose saved workspace is no longer active is updated.
     */
    @AuraEnabled
    public static Integer bulkSetWorkspace(List<String> configIds, Boolean allFlagged, String workspaceId) {
        requireAccess();

        Set<String> activeIds = loadActiveWorkspaceIds();
        if (activeIds.isEmpty()) {
            throw newError('No active workspaces were found for this site.');
        }

        String target = String.isBlank(workspaceId) ? null : workspaceId.trim();
        if (target == null) {
            throw newError('Select a workspace to assign.');
        }
        if (!activeIds.contains(target)) {
            throw newError('Workspace ' + target + ' is not an active workspace.');
        }

        List<helplightning__Help_Lightning_Config__c> records = new List<helplightning__Help_Lightning_Config__c>();
        if (allFlagged == true) {
            List<String> valid = new List<String>(activeIds);
            for (helplightning__Help_Lightning_Config__c c : [
                    SELECT Id, SetupOwnerId
                    FROM helplightning__Help_Lightning_Config__c
                    WHERE helplightning__Workspace_Id__c != null
                    AND helplightning__Workspace_Id__c NOT IN :valid]) {
                if (isUserOwner(c.SetupOwnerId)) {
                    records.add(new helplightning__Help_Lightning_Config__c(
                        Id = c.Id, helplightning__Workspace_Id__c = target));
                }
            }
        } else if (configIds != null) {
            for (String configId : configIds) {
                if (!String.isBlank(configId)) {
                    records.add(new helplightning__Help_Lightning_Config__c(
                        Id = configId, helplightning__Workspace_Id__c = target));
                }
            }
        }

        if (!records.isEmpty()) {
            update records;
        }
        return records.size();
    }

    private static Boolean canEditConfig() {
        if (forceNoAccess) {
            return false;
        }
        return Schema.SObjectType.helplightning__Help_Lightning_Config__c.isUpdateable() &&
               Schema.SObjectType.helplightning__Help_Lightning_Config__c.isCreateable();
    }

    private static void requireAccess() {
        if (!canEditConfig()) {
            throw newError('Insufficient Access');
        }
    }

    private static AuraHandledException newError(String message) {
        AuraHandledException e = new AuraHandledException(message);
        e.setMessage(message);
        return e;
    }

    private static Boolean isUserOwner(Id ownerId) {
        return ownerId != null && String.valueOf(ownerId).startsWith('005');
    }

    private static Set<String> loadActiveWorkspaceIds() {
        List<helplightning.HLModelWorkspace> workspaces;
        try {
            workspaces = helplightning.HLGaldrClient.getWorkspaces();
        } catch (Exception e) {
            throw newError('Unable to load workspaces from Help Lightning: ' + e.getMessage());
        }

        Set<String> activeIds = new Set<String>();
        if (workspaces != null) {
            for (helplightning.HLModelWorkspace w : workspaces) {
                if (w.active == true) {
                    activeIds.add(String.valueOf(w.id));
                }
            }
        }
        return activeIds;
    }

    private static List<helplightning__Help_Lightning_Config__c> queryConfigs(String afterId, Integer limitSize,
                                                                             Boolean flaggedOnly, List<String> validIds) {
        String soql = 'SELECT Id, SetupOwnerId, helplightning__Login__c, helplightning__Workspace_Id__c ' +
                      'FROM helplightning__Help_Lightning_Config__c ';
        if (flaggedOnly) {
            soql += 'WHERE helplightning__Workspace_Id__c != null ';
            if (!validIds.isEmpty()) {
                soql += 'AND helplightning__Workspace_Id__c NOT IN :validIds ';
            }
        } else {
            soql += 'WHERE (helplightning__Workspace_Id__c != null OR helplightning__Login__c != null) ';
        }
        if (afterId != null) {
            soql += 'AND Id > :afterId ';
        }
        soql += 'ORDER BY Id';
        if (limitSize != null) {
            soql += ' LIMIT :limitSize';
        }
        return Database.query(soql);
    }

    private static Integer countUserRecords(Boolean flaggedOnly, List<String> validIds) {
        Integer count = 0;
        for (helplightning__Help_Lightning_Config__c c : queryConfigs(null, null, flaggedOnly, validIds)) {
            if (isUserOwner(c.SetupOwnerId)) {
                count++;
            }
        }
        return count;
    }

    private static Boolean hasMoreUserRecords(String afterId, Boolean flaggedOnly, List<String> validIds) {
        String cursor = afterId;
        Boolean exhausted = false;
        while (!exhausted) {
            List<helplightning__Help_Lightning_Config__c> batch = queryConfigs(cursor, MAX_PAGE_SIZE, flaggedOnly, validIds);
            for (helplightning__Help_Lightning_Config__c c : batch) {
                if (isUserOwner(c.SetupOwnerId)) {
                    return true;
                }
                cursor = c.Id;
            }
            exhausted = batch.size() < MAX_PAGE_SIZE;
        }
        return false;
    }

    private static List<UserRow> buildRows(List<helplightning__Help_Lightning_Config__c> configs) {
        Set<Id> ownerIds = new Set<Id>();
        for (helplightning__Help_Lightning_Config__c c : configs) {
            ownerIds.add(c.SetupOwnerId);
        }
        Map<Id, User> users = new Map<Id, User>([
            SELECT Id, Name, Email, IsActive FROM User WHERE Id IN :ownerIds
        ]);

        List<UserRow> rows = new List<UserRow>();
        for (helplightning__Help_Lightning_Config__c c : configs) {
            User u = users.get(c.SetupOwnerId);
            UserRow r = new UserRow();
            r.configId = c.Id;
            r.userId = c.SetupOwnerId;
            r.userName = (u == null) ? String.valueOf(c.SetupOwnerId) : u.Name;
            r.userEmail = (u == null) ? null : u.Email;
            r.userActive = (u == null) ? false : u.IsActive;
            r.login = c.helplightning__Login__c;
            r.workspaceId = c.helplightning__Workspace_Id__c;
            rows.add(r);
        }
        return rows;
    }
}
