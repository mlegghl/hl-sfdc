/* -*- Mode: java; -*- */

/**
 * HLGaldrClientTest.cls
 *
 * Copyright (c) 2025 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
private class HLGaldrClientTest {
    /**
     * Mocker for the getWorkspaces Paginated api
     */
    class GetWorkspacesPaginatedMocker implements HttpCalloutMock {
        Integer totalEntries;
        Integer pageSize;
        GetWorkspacesPaginatedMocker(Integer totalEntries, Integer pageSize) {
            this.totalEntries = totalEntries;
            this.pageSize = pageSize;
        }
        public HTTPResponse respond(HTTPRequest req) {
            URL endpoint = new URL(req.getEndpoint());

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            List<String> parts = endpoint.getQuery().split('=');
            Integer currentPage = Integer.valueOf(parts[1].trim());

            Integer remaining = totalEntries - (this.pageSize * (currentPage-1));
            Integer numEntries = Math.min(remaining, this.pageSize);

            Integer totalPages = (this.totalEntries + this.pageSize - 1) / this.pageSize;
            Integer offset = (currentPage - 1) * this.pageSize;

            Map<String, Object> result = new Map<String, Object>();
            result.put('total_entries', this.totalEntries);
            result.put('total_pages', totalPages);
            result.put('page', currentPage);
            result.put('page_size', this.pageSize);

            List<Object> entries = new List<Object>();
            for (Integer i = 0; i < numEntries; i++) {
                entries.add(new Map<String,Object>{
                        'active' => true,
                        'admins' => new List<Object>(),
                        'id' => offset+i,
                        'name' => String.valueOf(offset+i),
                        'token' => ''
                    });
            }
            result.put('entries', entries);

            response.setStatusCode(200);
            response.setBody(JSON.serialize(result));

            return response;
        }
    }

    @testSetup static void setup() {
        // create some data.

        // create an admin user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'admin', Email='test-admin@helplightning.com',
                          EmailEncodingKey='UTF-8', LastName='Admin', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Chicago', UserName='test-admin@helplightning.com');
        insert u;
        // assign them to the HelpLightning permission set!
        PermissionSet permissionSet = [SELECT id, Name from PermissionSet WHERE Name='HelpLightning'];
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = permissionSet.Id);
        insert psa;

        // create a non admin user
        Profile p2 = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u2 = new User(Alias = 'standard', Email='test-user@helplightning.com',
                           EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p2.Id,
                           TimeZoneSidKey='America/Chicago', UserName='test-user@helplightning.com');
        insert u2;
        // assign them to the HelpLightning permission set!
        psa = new PermissionSetAssignment(AssigneeId = u2.Id, PermissionSetId = permissionSet.Id);
        insert psa;

        // Do this inside this block to avoid MIXED_DML_OPERATIONS
        System.runAs(u2) {
            // create some contacts
            List<Contact> contacts = new List<Contact>();
            contacts.add(new Contact(FirstName = 'Contact',
                                     LastName = '1',
                                     Email = 'contact1@helplightning.com'));
            contacts.add(new Contact(FirstName = 'Contact',
                                     LastName = '2',
                                     Email = 'contact2@helplightning.com'));
            contacts.add(new Contact(FirstName = 'Contact',
                                     LastName = '3',
                                     Email = 'contact3@helplightning.com'));
            insert contacts;

            Contact contact1 = contacts.get(0);
            Contact contact2 = contacts.get(1);

            // Create a case
            Case case1 = new Case(Subject = 'Case 1',
                                  Status = 'New',
                                  Origin = 'Phone',
                                  ContactId = contact1.Id);
            insert case1;

            // Create a case without a contact
            Case case2 = new Case(Subject = 'Case 2',
                                  Status = 'New',
                                  Origin = 'Phone');
            insert case2;

            // create a work order
            WorkOrder workOrder = new WorkOrder(Subject = 'Work Order 1',
                                                ContactId = contact2.Id);
            insert workOrder;

             // create a work order without a contact
            WorkOrder workOrder2 = new WorkOrder(Subject = 'Work Order 2');
            insert workOrder2;

            // create some fake calls for case 1
            List<helplightning__HLCall__c> calls = new List<helplightning__HLCall__c>();
            calls.add(new helplightning__HLCall__c(helplightning__Session_Id__c = 'aabbccdd',
                                                   helplightning__Complete__c = true,
                                                   helplightning__Successful__c = true,
                                                   helplightning__Start_Time__c = DateTime.newInstanceGMT(2017, 6, 28, 11, 30, 0),
                                                   helplightning__Duration__c = 60,
                                                   helplightning__Contact_Email__c = 'contact1@helplightning.com',
                                                   helplightning__Contact_Phone__c = '555-555-5555',
                                                   helplightning__Type__c = 'Direct',
                                                   helplightning__Case__c = case1.Id));
            calls.add(new helplightning__HLCall__c(helplightning__Session_Id__c = 'wwxxyyzz',
                                                   helplightning__HLCall_Id__c = 'wxyz',
                                                   helplightning__Complete__c = false,
                                                   helplightning__Successful__c = false,
                                                   helplightning__Start_Time__c = DateTime.newInstanceGMT(2017, 6, 28, 11, 36, 0),
                                                   helplightning__Duration__c = 0,
                                                   helplightning__Contact_Email__c = 'contact1@helplightning.com',
                                                   helplightning__Contact_Phone__c = '555-555-5555',
                                                   helplightning__Type__c = 'Direct',
                                                   helplightning__Case__c = case1.Id));
            // add some calls to the work order
            calls.add(new helplightning__HLCall__c(helplightning__Session_Id__c = 'jjkkllmm',
                                                   helplightning__HLCall_Id__c = 'jklm',
                                                   helplightning__Complete__c = true,
                                                   helplightning__Successful__c = false,
                                                   helplightning__Start_Time__c = DateTime.newInstanceGMT(2017, 6, 24, 14, 55, 0),
                                                   helplightning__Duration__c = 0,
                                                   helplightning__Contact_Email__c = 'contact2@helplightning.com',
                                                   helplightning__Contact_Phone__c = '555-555-5555',
                                                   helplightning__Type__c = 'Direct',
                                                   helplightning__Work_Order__c = workOrder.Id));
            calls.add(new helplightning__HLCall__c(helplightning__Session_Id__c = 'jjkkllmmn',
                                                   helplightning__HLCall_Id__c = '',
                                                   helplightning__Complete__c = false,
                                                   helplightning__Successful__c = false,
                                                   helplightning__Start_Time__c = DateTime.newInstanceGMT(2016, 6, 24, 14, 55, 0),
                                                   helplightning__Duration__c = 0,
                                                   helplightning__Contact_Email__c = 'contact2@helplightning.com',
                                                   helplightning__Contact_Phone__c = '555-555-5555',
                                                   helplightning__Type__c = 'Direct',
                                                   helplightning__Work_Order__c = workOrder.Id));
            insert calls;
        }

        System.RunAs(u) {
            // create a fake configuration
            helplightning__Help_Lightning_Config__c config = helplightning__Help_Lightning_Config__c.getOrgDefaults();
            config.helplightning__Enterprise_id__c = '1';
            config.Private_Key_1__c = 'MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAMZPAm05lQqKpmm0nyBhnqSq9X0e7dEZKvoGpVv6jVrULGCG+icPcdaY5DuZ6bT9PTd7kN7ftAX0aRFPB3FPvyGr96ytiDOr0k4rRckTkB5BmC1369FLieNQXqKVts9oPEaHkF0ST3UgliNZmREE4eLrhghqZcTcHBj9rprLZBx5AgMBAAECgYBBSjgJUAEC9H0vpjkRxzIdEvA';
            config.Private_Key_2__c = '6Hpm70yZ0JQYCT26ErgBiU24+t/YJ6lKSUO1CGnIyNyuORWaW405IVZWkt9W8IuSWGdDvxM85KcdX5+3UzTABUoZ8XQ0YrLfInFc8GT4bP9qfF0jf55MBYNYUHXA1GgE/R4YylQjqxHtAip5EhQJBAOZNgCpDMGErgdl/R2nYFZ6v5LZ1hNgUd2xdcZEPgbKVT3oJhea8L/UgZf/FZjT22TVaP4EfmwXRZqBnqtm1I0sCQQDcb5xg05fiq9pLt/';
            config.Private_Key_3__c = 'DOZSbRwzOeZ6Ks++6v2tRnDCuR3dISW2rKDLNx4HACGGwpXFNUBhyYGn0urSB5UxMKb2DLAkEAqL4yYUT3psrtCoLSvX/hX3M7nmD/JB/i3NiexI3bFxGFuUJPBR/v96h0c/KcD8SqpAfrLd4NhTbH/lHXAktRfwJAUBKC3XE/FOmUDDku0epQZZXgpEPFBc0l8N8ulJgJI51N97kZW3etn0oFpd01PPj6k+T8cgv9OP1OdIPGwN2gbQJBAJqaa';
            config.Private_Key_4__c = 'ppC/arTlRa1amSTnFgEubLcFvDgA6LuxLsdVBCXD4QqUx81fIUMXlw4UiXmlg8ZoFvTtJa+NKJROM1JMl4=';
            upsert config helplightning__Help_Lightning_Config__c.Id;

            // validate this was updated
            System.assertEquals('1', config.helplightning__Enterprise_id__c);
        }
    }

    /**
     * Verify pagination works in the getWorkspaces call
     */
    @isTest
    static void testGetWorkspacesPagination() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u1 = new User(Alias = 'support', Email='support@helplightning.com',
                           EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Chicago', UserName='support@helplightning.com');
        insert u1;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new GetWorkspacesPaginatedMocker(55, 10));

        System.RunAs(u1) {
            List<helplightning.HLModelWorkspace> workspaces = HLGaldrClient.getWorkspaces();
            System.assertEquals(55, workspaces.size());
        }

        Test.stopTest();
    }
}
