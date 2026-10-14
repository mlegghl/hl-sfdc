/* -*- Mode: java; -*- */

/**
 * HLUserWorkspacesControllerTest.cls
 *
 * Copyright (c) 2026 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
private class HLUserWorkspacesControllerTest {

    /**
     * Returns workspaces 50 and 51 (active) and 52 (deactivated).
     * mode 'empty' returns no workspaces, mode 'error' returns a 500.
     */
    class WorkspacesMocker implements HttpCalloutMock {
        String mode;
        WorkspacesMocker(String mode) {
            this.mode = mode;
        }
        public HTTPResponse respond(HTTPRequest req) {
            URL endpoint = new URL(req.getEndpoint());

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            if (mode != 'error' && req.getMethod() == 'GET' &&
                endpoint.getPath().startsWith('/api/v1r1/enterprise/workspaces')) {
                List<Map<String,Object>> entries = new List<Map<String,Object>>();
                if (mode != 'empty') {
                    entries.add(new Map<String,Object>{ 'id' => 50, 'name' => 'West', 'token' => 'valid-token', 'active' => true });
                    entries.add(new Map<String,Object>{ 'id' => 51, 'name' => 'East', 'token' => 'valid-token', 'active' => true });
                    entries.add(new Map<String,Object>{ 'id' => 52, 'name' => 'Old', 'token' => 'valid-token', 'active' => false });
                }
                Map<String, Object> result = new Map<String, Object>();
                result.put('total_entries', entries.size());
                result.put('total_pages', 1);
                result.put('entries', entries);
                response.setStatusCode(200);
                response.setBody(JSON.serialize(result));
            } else {
                response.setStatusCode(500);
            }
            return response;
        }
    }

    @testSetup static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        List<User> users = new List<User>();
        for (Integer i = 1; i <= 5; i++) {
            users.add(new User(Alias = 'hluw' + i, Email='hluw-user' + i + '@helplightning.com',
                               EmailEncodingKey='UTF-8', LastName='Workspace User ' + i, LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = p.Id,
                               TimeZoneSidKey='America/Chicago', UserName='hluw-user' + i + '@helplightning.com'));
        }
        insert users;

        // Do this inside this block to avoid MIXED_DML_OPERATIONS
        System.runAs(new User(Id = UserInfo.getUserId())) {
            helplightning__Help_Lightning_Config__c config = helplightning__Help_Lightning_Config__c.getOrgDefaults();
            config.helplightning__Enterprise_id__c = '1';
            config.Private_Key_1__c = 'MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAMZPAm05lQqKpmm0nyBhnqSq9X0e7dEZKvoGpVv6jVrULGCG+icPcdaY5DuZ6bT9PTd7kN7ftAX0aRFPB3FPvyGr96ytiDOr0k4rRckTkB5BmC1369FLieNQXqKVts9oPEaHkF0ST3UgliNZmREE4eLrhghqZcTcHBj9rprLZBx5AgMBAAECgYBBSjgJUAEC9H0vpjkRxzIdEvA';
            config.Private_Key_2__c = '6Hpm70yZ0JQYCT26ErgBiU24+t/YJ6lKSUO1CGnIyNyuORWaW405IVZWkt9W8IuSWGdDvxM85KcdX5+3UzTABUoZ8XQ0YrLfInFc8GT4bP9qfF0jf55MBYNYUHXA1GgE/R4YylQjqxHtAip5EhQJBAOZNgCpDMGErgdl/R2nYFZ6v5LZ1hNgUd2xdcZEPgbKVT3oJhea8L/UgZf/FZjT22TVaP4EfmwXRZqBnqtm1I0sCQQDcb5xg05fiq9pLt/';
            config.Private_Key_3__c = 'DOZSbRwzOeZ6Ks++6v2tRnDCuR3dISW2rKDLNx4HACGGwpXFNUBhyYGn0urSB5UxMKb2DLAkEAqL4yYUT3psrtCoLSvX/hX3M7nmD/JB/i3NiexI3bFxGFuUJPBR/v96h0c/KcD8SqpAfrLd4NhTbH/lHXAktRfwJAUBKC3XE/FOmUDDku0epQZZXgpEPFBc0l8N8ulJgJI51N97kZW3etn0oFpd01PPj6k+T8cgv9OP1OdIPGwN2gbQJBAJqaa';
            config.Private_Key_4__c = 'ppC/arTlRa1amSTnFgEubLcFvDgA6LuxLsdVBCXD4QqUx81fIUMXlw4UiXmlg8ZoFvTtJa+NKJROM1JMl4=';
            // org and profile level workspaces must never show up as rows
            config.helplightning__Workspace_Id__c = '52';
            upsert config helplightning__Help_Lightning_Config__c.Id;

            List<helplightning__Help_Lightning_Config__c> configs = new List<helplightning__Help_Lightning_Config__c>();
            configs.add(new helplightning__Help_Lightning_Config__c(
                SetupOwnerId = p.Id, helplightning__Workspace_Id__c = '99999'));
            // active workspace
            configs.add(new helplightning__Help_Lightning_Config__c(
                SetupOwnerId = users[0].Id, helplightning__Workspace_Id__c = '50'));
            // active workspace with a login override
            configs.add(new helplightning__Help_Lightning_Config__c(
                SetupOwnerId = users[1].Id, helplightning__Workspace_Id__c = '51',
                helplightning__Login__c = 'hluw-override2@helplightning.com'));
            // deactivated workspace
            configs.add(new helplightning__Help_Lightning_Config__c(
                SetupOwnerId = users[2].Id, helplightning__Workspace_Id__c = '52'));
            // unknown workspace
            configs.add(new helplightning__Help_Lightning_Config__c(
                SetupOwnerId = users[3].Id, helplightning__Workspace_Id__c = '99999'));
            // login override only
            configs.add(new helplightning__Help_Lightning_Config__c(
                SetupOwnerId = users[4].Id, helplightning__Login__c = 'hluw-override5@helplightning.com'));
            insert configs;
        }
    }

    /**
     * Map of test user number (1-5) to that user's config record id
     */
    static Map<Integer, Id> configIdsByUser() {
        Map<Id, Integer> userNumbers = new Map<Id, Integer>();
        for (User u : [SELECT Id, UserName FROM User WHERE UserName LIKE 'hluw-user%@helplightning.com']) {
            userNumbers.put(u.Id, Integer.valueOf(u.UserName.substringBetween('hluw-user', '@')));
        }
        Map<Integer, Id> result = new Map<Integer, Id>();
        for (helplightning__Help_Lightning_Config__c c : [
                SELECT Id, SetupOwnerId FROM helplightning__Help_Lightning_Config__c
                WHERE SetupOwnerId IN :userNumbers.keySet()]) {
            result.put(userNumbers.get(c.SetupOwnerId), c.Id);
        }
        return result;
    }

    static helplightning__Help_Lightning_Config__c loadConfig(Id configId) {
        return [SELECT Id, helplightning__Login__c, helplightning__Workspace_Id__c
                FROM helplightning__Help_Lightning_Config__c WHERE Id = :configId];
    }

    static Set<Id> rowIds(List<HLUserWorkspacesController.UserRow> rows, Set<Id> scope) {
        Set<Id> ids = new Set<Id>();
        for (HLUserWorkspacesController.UserRow r : rows) {
            Id configId = Id.valueOf(r.configId);
            if (scope.contains(configId)) {
                ids.add(configId);
            }
        }
        return ids;
    }

    @isTest
    static void testGetContext() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WorkspacesMocker('normal'));
        HLUserWorkspacesController.Context ctx = HLUserWorkspacesController.getContext();
        Test.stopTest();

        System.assertEquals(true, ctx.ready);
        System.assertEquals(true, ctx.canEdit);
        System.assertEquals(3, ctx.workspaces.size());

        Map<String, Boolean> activeById = new Map<String, Boolean>();
        for (HLUserWorkspacesController.WorkspaceOption w : ctx.workspaces) {
            activeById.put(w.id, w.active);
        }
        System.assertEquals(true, activeById.get('50'));
        System.assertEquals(true, activeById.get('51'));
        System.assertEquals(false, activeById.get('52'));
    }

    @isTest
    static void testGetContextEmptyWorkspaces() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WorkspacesMocker('empty'));
        HLUserWorkspacesController.Context ctx = HLUserWorkspacesController.getContext();
        Test.stopTest();

        System.assertEquals(false, ctx.ready);
        System.assertNotEquals(null, ctx.statusMessage);
    }

    @isTest
    static void testGetContextCalloutError() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WorkspacesMocker('error'));
        HLUserWorkspacesController.Context ctx = HLUserWorkspacesController.getContext();
        Test.stopTest();

        System.assertEquals(false, ctx.ready);
        System.assertNotEquals(null, ctx.statusMessage);
    }

    @isTest
    static void testGetContextNotConfigured() {
        delete [SELECT Id FROM helplightning__Help_Lightning_Config__c
                WHERE SetupOwnerId = :UserInfo.getOrganizationId()];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WorkspacesMocker('normal'));
        HLUserWorkspacesController.Context ctx = HLUserWorkspacesController.getContext();
        Test.stopTest();

        System.assertEquals(false, ctx.ready);
        System.assertNotEquals(null, ctx.statusMessage);
    }

    @isTest
    static void testGetUsersPaging() {
        Map<Integer, Id> configIds = configIdsByUser();
        Set<Id> scope = new Set<Id>(configIds.values());

        Set<Id> seen = new Set<Id>();
        String afterId = null;
        Boolean hasMore = true;
        Integer pages = 0;
        Integer totalCount = null;
        while (hasMore && pages < 20) {
            HLUserWorkspacesController.UserPage page = HLUserWorkspacesController.getUsers(afterId, 2, false, null);
            if (pages == 0) {
                totalCount = page.totalCount;
            }
            System.assert(page.rows.size() <= 2, 'Page was larger than the page size');
            for (HLUserWorkspacesController.UserRow r : page.rows) {
                System.assert(r.userId.startsWith('005'), 'Non-user record returned');
                System.assert(!seen.contains(Id.valueOf(r.configId)), 'Row returned twice');
            }
            seen.addAll(rowIds(page.rows, scope));
            afterId = page.nextAfterId;
            hasMore = page.hasMore;
            pages++;
        }

        System.assertEquals(false, hasMore);
        System.assertEquals(scope, seen);
        System.assert(totalCount >= 5, 'Total count is missing test users');
    }

    @isTest
    static void testGetUsersRowDetails() {
        Map<Integer, Id> configIds = configIdsByUser();

        HLUserWorkspacesController.UserPage page = HLUserWorkspacesController.getUsers(null, 50, false, null);
        Map<Id, HLUserWorkspacesController.UserRow> rows = new Map<Id, HLUserWorkspacesController.UserRow>();
        for (HLUserWorkspacesController.UserRow r : page.rows) {
            rows.put(Id.valueOf(r.configId), r);
        }

        HLUserWorkspacesController.UserRow row2 = rows.get(configIds.get(2));
        System.assertEquals('51', row2.workspaceId);
        System.assertEquals('hluw-override2@helplightning.com', row2.login);
        System.assertEquals('hluw-user2@helplightning.com', row2.userEmail);
        System.assertEquals(true, row2.userActive);

        HLUserWorkspacesController.UserRow row5 = rows.get(configIds.get(5));
        System.assertEquals(null, row5.workspaceId);
        System.assertEquals('hluw-override5@helplightning.com', row5.login);
    }

    @isTest
    static void testGetUsersFlaggedOnly() {
        Map<Integer, Id> configIds = configIdsByUser();
        Set<Id> scope = new Set<Id>(configIds.values());

        HLUserWorkspacesController.UserPage page = HLUserWorkspacesController.getUsers(
            null, 50, true, new List<String>{ '50', '51' });
        System.assertEquals(new Set<Id>{ configIds.get(3), configIds.get(4) }, rowIds(page.rows, scope));
        System.assert(page.totalCount >= 2, 'Flagged count is missing test users');

        // with no valid ids, every user with a saved workspace is flagged
        page = HLUserWorkspacesController.getUsers(null, 50, true, new List<String>());
        System.assertEquals(new Set<Id>{ configIds.get(1), configIds.get(2), configIds.get(3), configIds.get(4) },
                            rowIds(page.rows, scope));
    }

    @isTest
    static void testSaveRows() {
        Map<Integer, Id> configIds = configIdsByUser();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WorkspacesMocker('normal'));

        System.assertEquals(0, HLUserWorkspacesController.saveRows(new List<HLUserWorkspacesController.RowUpdate>()));

        // invalid input fails before any DML
        HLUserWorkspacesController.RowUpdate badEmail = new HLUserWorkspacesController.RowUpdate();
        badEmail.configId = configIds.get(1);
        badEmail.login = 'not-an-email';
        badEmail.workspaceId = '50';
        assertSaveFails(badEmail);

        HLUserWorkspacesController.RowUpdate inactive = new HLUserWorkspacesController.RowUpdate();
        inactive.configId = configIds.get(1);
        inactive.workspaceId = '52';
        assertSaveFails(inactive);

        HLUserWorkspacesController.RowUpdate missingId = new HLUserWorkspacesController.RowUpdate();
        missingId.workspaceId = '50';
        assertSaveFails(missingId);

        HLUserWorkspacesController.RowUpdate update1 = new HLUserWorkspacesController.RowUpdate();
        update1.configId = configIds.get(1);
        update1.login = 'hluw-new1@helplightning.com';
        update1.workspaceId = '51';

        HLUserWorkspacesController.RowUpdate update2 = new HLUserWorkspacesController.RowUpdate();
        update2.configId = configIds.get(2);
        update2.login = '';
        update2.workspaceId = '';

        Integer saved = HLUserWorkspacesController.saveRows(
            new List<HLUserWorkspacesController.RowUpdate>{ update1, update2 });
        Test.stopTest();

        System.assertEquals(2, saved);

        helplightning__Help_Lightning_Config__c c1 = loadConfig(configIds.get(1));
        System.assertEquals('hluw-new1@helplightning.com', c1.helplightning__Login__c);
        System.assertEquals('51', c1.helplightning__Workspace_Id__c);

        helplightning__Help_Lightning_Config__c c2 = loadConfig(configIds.get(2));
        System.assertEquals(null, c2.helplightning__Login__c);
        System.assertEquals(null, c2.helplightning__Workspace_Id__c);
    }

    static void assertSaveFails(HLUserWorkspacesController.RowUpdate u) {
        Boolean failed = false;
        try {
            HLUserWorkspacesController.saveRows(new List<HLUserWorkspacesController.RowUpdate>{ u });
        } catch (AuraHandledException e) {
            failed = true;
        }
        System.assert(failed, 'saveRows should have failed');
    }

    @isTest
    static void testSaveRowsCalloutError() {
        Map<Integer, Id> configIds = configIdsByUser();
        HLUserWorkspacesController.RowUpdate u = new HLUserWorkspacesController.RowUpdate();
        u.configId = configIds.get(1);
        u.workspaceId = '51';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WorkspacesMocker('error'));
        assertSaveFails(u);
        Test.stopTest();

        System.assertEquals('50', loadConfig(configIds.get(1)).helplightning__Workspace_Id__c);
    }

    @isTest
    static void testBulkSetSelected() {
        Map<Integer, Id> configIds = configIdsByUser();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WorkspacesMocker('normal'));

        // a deactivated target is rejected before any DML
        Boolean failed = false;
        try {
            HLUserWorkspacesController.bulkSetWorkspace(new List<String>{ String.valueOf(configIds.get(3)) }, false, '52');
        } catch (AuraHandledException e) {
            failed = true;
        }
        System.assert(failed, 'bulkSetWorkspace should reject a deactivated workspace');

        Integer updated = HLUserWorkspacesController.bulkSetWorkspace(
            new List<String>{ String.valueOf(configIds.get(3)), '' }, false, '51');
        Test.stopTest();

        System.assertEquals(1, updated);
        System.assertEquals('51', loadConfig(configIds.get(3)).helplightning__Workspace_Id__c);
        System.assertEquals('99999', loadConfig(configIds.get(4)).helplightning__Workspace_Id__c);
    }

    @isTest
    static void testBulkSetAllFlagged() {
        Map<Integer, Id> configIds = configIdsByUser();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WorkspacesMocker('normal'));
        Integer updated = HLUserWorkspacesController.bulkSetWorkspace(null, true, '');
        Test.stopTest();

        System.assert(updated >= 2, 'Flagged users were not updated');
        System.assertEquals(null, loadConfig(configIds.get(3)).helplightning__Workspace_Id__c);
        System.assertEquals(null, loadConfig(configIds.get(4)).helplightning__Workspace_Id__c);
        // valid workspaces are untouched
        System.assertEquals('50', loadConfig(configIds.get(1)).helplightning__Workspace_Id__c);
        System.assertEquals('51', loadConfig(configIds.get(2)).helplightning__Workspace_Id__c);
        // org default is not a user record, so it is untouched
        System.assertEquals('52', helplightning__Help_Lightning_Config__c.getOrgDefaults().helplightning__Workspace_Id__c);
    }

    @isTest
    static void testBulkSetNoActiveWorkspaces() {
        Map<Integer, Id> configIds = configIdsByUser();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WorkspacesMocker('empty'));
        Boolean failed = false;
        try {
            HLUserWorkspacesController.bulkSetWorkspace(new List<String>{ String.valueOf(configIds.get(3)) }, false, '');
        } catch (AuraHandledException e) {
            failed = true;
        }
        Test.stopTest();

        System.assert(failed, 'bulkSetWorkspace should fail without active workspaces');
    }

    @isTest
    static void testNoAccess() {
        HLUserWorkspacesController.forceNoAccess = true;

        HLUserWorkspacesController.Context ctx = HLUserWorkspacesController.getContext();
        System.assertEquals(false, ctx.canEdit);
        System.assertEquals(false, ctx.ready);

        Integer failures = 0;
        try {
            HLUserWorkspacesController.getUsers(null, 50, false, null);
        } catch (AuraHandledException e) {
            failures++;
        }
        try {
            HLUserWorkspacesController.saveRows(new List<HLUserWorkspacesController.RowUpdate>());
        } catch (AuraHandledException e) {
            failures++;
        }
        try {
            HLUserWorkspacesController.bulkSetWorkspace(new List<String>(), false, '');
        } catch (AuraHandledException e) {
            failures++;
        }
        System.assertEquals(3, failures);
    }
}
