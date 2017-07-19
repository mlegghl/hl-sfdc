/**
 * HLSessionControllerTest.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
private class HLSessionControllerTest {

    /**
     * Mocker for the testUpdateCallsCase
     */
    class UpdateCallsCaseMocker implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            URL endpoint = new URL(req.getEndpoint());

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            if (req.getMethod() == 'GET' && endpoint.getPath().startsWith('/api/v1/enterprise/sessions/')) {
                // return some help lightning calls.
                List<String> parts = endpoint.getPath().split('/');
                String sessionId = parts.get(parts.size()-1);

                List<Object> calls = new List<Object>();
                if (sessionId == 'aabbccdd') {
                    Map<String,Object> call = new Map<String,Object>{
                            'call_id' => 'abcd',
                                'dialer' => 'support@helplightning.com',
                                'receiver' => 'contact1@helplightning.com',
                                'start_time' => '2017-06-28T11:30:02-05',
                                'end_time' => '2017-06-28T11:40:02-05',
                                'complete' => true,
                                'successful' => true,
                                'duration' => 600
                                };
                    calls.add(call);
                } else if (sessionId == 'wwxxyyzz') {
                    Map<String,Object> call = new Map<String,Object>{
                            'call_id' => 'wxyz',
                                'dialer' => 'support@helplightning.com',
                                'receiver' => 'contact1@helplightning.com',
                                'start_time' => '2017-06-28T11:36:05-05',
                                'end_time' => '2017-06-28T11:42:05-05',
                                'complete' => true,
                                'successful' => false,
                                'duration' => 360
                                };
                    calls.add(call);
                }

                // return this as a serialized list of maps.
                response.setBody(JSON.serialize(calls));
                response.setStatusCode(200);
            } else {
                // error
                response.setStatusCode(500);
            }

            return response;
        }
    }
    /**
     * Mocker for the testUpdateCallsWorkOrder
     */
    class UpdateCallsWorkOrderMocker implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            URL endpoint = new URL(req.getEndpoint());

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            if (req.getMethod() == 'GET' && endpoint.getPath().startsWith('/api/v1/enterprise/sessions/')) {
                // return some help lightning calls.
                List<String> parts = endpoint.getPath().split('/');
                String sessionId = parts.get(parts.size()-1);

                List<Object> calls = new List<Object>();

                // return this as a serialized list of maps.
                response.setBody(JSON.serialize(calls));
                response.setStatusCode(200);
            } else {
                // error
                response.setStatusCode(500);
            }

            return response;
        }
    }
    /**
     * Mocker for the isHLUser
     */
    class IsHLUserMocker implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            URL endpoint = new URL(req.getEndpoint());

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            if (req.getMethod() == 'POST' && endpoint.getPath().startsWith('/api/v1/search')) {
                Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(req.getBody());

                List<Object> result = new List<Object>();
                if (body.get('search_term') == 'support@helplightning.com') {
                    result.add(new Map<String,Object>{
                            'id' => 234,
                                'name' => 'Support',
                                'username' => 'support',
                                'active' => true
                                });
                }

                response.setStatusCode(200);
                response.setBody(JSON.serialize(result));
            } else {
                response.setStatusCode(500);
            }
            return response;
        }
    }
    /**
     * Mocker for the testMakeSessionWith
     */
    class MakeSessionWithMocker implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            URL endpoint = new URL(req.getEndpoint());

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            if (req.getMethod() == 'POST' && endpoint.getPath().startsWith('/api/v1/enterprise/calls')) {
                Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(req.getBody());

                if (body.get('receiver_email') == 'contact1@helplightning.com') {

                    Map<String,Object> result = new Map<String,Object>();
                    result.put('id', 'aabbccddeeff');

                    response.setStatusCode(200);
                    response.setBody(JSON.serialize(result));
                } else {
                    // fake an error here
                    response.setStatusCode(500);
                }
            } else {
                response.setStatusCode(500);
            }

            return response;
        }
    }
    /**
     * Mocker for the testInviteToPersonalRoom
     */
    class InviteToPersonalRoomMocker implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            URL endpoint = new URL(req.getEndpoint());

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            if (req.getMethod() == 'GET' && endpoint.getPath().startsWith('/api/v1/enterprise/users')) {
                Map<String, Object> result = new Map<String, Object>();

                if (endpoint.getQuery() == 'filter=email=support@helplightning.com&') {
                    result.put('total_entries', 1);
                    result.put('entries', new List<Object> {
                            new Map<String,Object>{
                                'active' => true,
                                    'token' => 'valid-token',
                                    'email' => 'support@helplightning.com'
                                    }
                        });
                } else if (endpoint.getQuery() == 'filter=email=support3@helplightning.com&') {
                    // this is a valid user, but we are going to fake
                    //  not return a valid token
                    result.put('total_entries', 1);
                    result.put('entries', new List<Object> {
                            new Map<String,Object>{
                                'active' => true,
                                    'email' => 'support3@helplightning.com'
                                    }
                        });
                } else {
                    result.put('total_entries', 0);
                    result.put('entries', new List<Object>{});
                }
                response.setStatusCode(200);
                response.setBody(JSON.serialize(result));
            } else if (req.getMethod() == 'POST' && endpoint.getPath().startsWith('/api/v1/personal_room/invite')) {
                Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(req.getBody());
                if (body.get('email') == 'invalid-user@helplightning.com') {
                    // simulate invalid
                    response.setStatusCode(500);
                } else {
                    response.setStatusCode(200);
                    response.setBody(JSON.serialize(true));
                }
            } else {
                response.setStatusCode(500);
            }

            return response;
        }
    }


    @testSetup static void setup() {
        // create some data.

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

        // create some fake calls for case 1
        List<HLCall__c> calls = new List<HLCall__c>();
        calls.add(new HLCall__c(Session_Id__c = 'aabbccdd',
                                HLCall_Id__c = 'abcd',
                                Complete__c = true,
                                Successful__c = true,
                                Start_Time__c = DateTime.newInstanceGMT(2017, 6, 28, 11, 30, 0),
                                Duration__c = 60,
                                Contact_Email__c = 'contact1@helplightning.com',
                                Type__c = 'Direct',
                                Case__c = case1.Id));
        calls.add(new HLCall__c(Session_Id__c = 'wwxxyyzz',
                                HLCall_Id__c = 'wxyz',
                                Complete__c = false,
                                Successful__c = false,
                                Start_Time__c = DateTime.newInstanceGMT(2017, 6, 28, 11, 36, 0),
                                Duration__c = 0,
                                Contact_Email__c = 'contact1@helplightning.com',
                                Type__c = 'Direct',
                                Case__c = case1.Id));
        // add a call to the work order
        calls.add(new HLCall__c(Session_Id__c = 'jjkkllmm',
                                HLCall_Id__c = 'jklm',
                                Complete__c = true,
                                Successful__c = false,
                                Start_Time__c = DateTime.newInstanceGMT(2017, 6, 24, 14, 55, 0),
                                Duration__c = 0,
                                Contact_Email__c = 'contact2@helplightning.com',
                                Type__c = 'Direct',
                                Work_Order__c = workOrder.Id));
        insert calls;

        // create a fake configuration
        Help_Lightning_Config__c config = Help_Lightning_Config__c.getOrgDefaults();
        config.Enterprise_id__c = '1';
        config.Private_Key_1__c = 'MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAMZPAm05lQqKpmm0nyBhnqSq9X0e7dEZKvoGpVv6jVrULGCG+icPcdaY5DuZ6bT9PTd7kN7ftAX0aRFPB3FPvyGr96ytiDOr0k4rRckTkB5BmC1369FLieNQXqKVts9oPEaHkF0ST3UgliNZmREE4eLrhghqZcTcHBj9rprLZBx5AgMBAAECgYBBSjgJUAEC9H0vpjkRxzIdEvA';
        config.Private_Key_2__c = '6Hpm70yZ0JQYCT26ErgBiU24+t/YJ6lKSUO1CGnIyNyuORWaW405IVZWkt9W8IuSWGdDvxM85KcdX5+3UzTABUoZ8XQ0YrLfInFc8GT4bP9qfF0jf55MBYNYUHXA1GgE/R4YylQjqxHtAip5EhQJBAOZNgCpDMGErgdl/R2nYFZ6v5LZ1hNgUd2xdcZEPgbKVT3oJhea8L/UgZf/FZjT22TVaP4EfmwXRZqBnqtm1I0sCQQDcb5xg05fiq9pLt/';
        config.Private_Key_3__c = 'DOZSbRwzOeZ6Ks++6v2tRnDCuR3dISW2rKDLNx4HACGGwpXFNUBhyYGn0urSB5UxMKb2DLAkEAqL4yYUT3psrtCoLSvX/hX3M7nmD/JB/i3NiexI3bFxGFuUJPBR/v96h0c/KcD8SqpAfrLd4NhTbH/lHXAktRfwJAUBKC3XE/FOmUDDku0epQZZXgpEPFBc0l8N8ulJgJI51N97kZW3etn0oFpd01PPj6k+T8cgv9OP1OdIPGwN2gbQJBAJqaa';
        config.Private_Key_4__c = 'ppC/arTlRa1amSTnFgEubLcFvDgA6LuxLsdVBCXD4QqUx81fIUMXlw4UiXmlg8ZoFvTtJa+NKJROM1JMl4=';
        upsert config Help_Lightning_Config__c.Id;
    }

    /**
     * Make sure we can get the necessary
     *  contact information for our supported
     *  records of type Case and WorkOrder
     */
    @isTest
    static void testGetContactForRecord() {
        Id caseId = [SELECT Id from Case WHERE Subject = 'Case 1' LIMIT 1].Id;
        Id case2Id = [SELECT Id from Case WHERE Subject = 'Case 2' LIMIT 1].Id;
        Id workOrderId = [SELECT Id from WorkOrder WHERE Subject = 'Work Order 1' LIMIT 1].Id;
        Contact contact1 = [SELECT Contact.Id, Contact.Name, Contact.Email FROM Contact
                            WHERE Email='contact1@helplightning.com' LIMIT 1];
        Contact contact2 = [SELECT Contact.Id, Contact.Name, Contact.Email FROM Contact
                            WHERE Email='contact2@helplightning.com' LIMIT 1];

        Contact c;
        // look up a valid case
        c = HLSessionController.getContactForRecord('Case', caseId);
        System.assertNotEquals(c, null);
        System.assertEquals(c.Id, contact1.Id);
        System.assertEquals(c.Name, contact1.Name);
        System.assertEquals(c.Email, contact1.Email);

        // look up a valid work order
        c = HLSessionController.getContactForRecord('WorkOrder', workOrderId);
        System.assertNotEquals(c, null);
        System.assertEquals(c.Id, contact2.Id);
        System.assertEquals(c.Name, contact2.Name);
        System.assertEquals(c.Email, contact2.Email);

        // look up an invalid case and work order
        c = HLSessionController.getContactForRecord('Case', workOrderId);
        System.assertEquals(c, null);
        c = HLSessionController.getContactForRecord('WorkOrder', caseId);
        System.assertEquals(c, null);

        // look up a valid case missing a contact
        c = HLSessionController.getContactForRecord('Case', case2Id);
        System.assertEquals(c, null);

        // look up an unsupported record type
        c = HLSessionController.getContactForRecord('Contact', contact1.Id);
        System.assertEquals(c, null);
    }

    /**
     * Test getting a specific case based on its Id
     */
    @isTest
    static void testGetCase() {
        Id caseId = [SELECT Id from Case WHERE Subject = 'Case 1' LIMIT 1].Id;
        Id case2Id = [SELECT Id from Case WHERE Subject = 'Case 2' LIMIT 1].Id;
        Contact contact = [SELECT Contact.Id, Contact.Name, Contact.Email FROM Contact
                           WHERE Email='contact1@helplightning.com' LIMIT 1];

        Case c;

        c = HLSessionController.getCase(caseId);
        System.assertEquals(c.Id, caseId);
        System.assertEquals(c.ContactId, contact.Id);
        System.assertEquals(c.ContactEmail, contact.Email);
        System.assertEquals(c.Contact.Name, contact.Name);

        // null id
        System.assertEquals(HLSessionController.getCase(null), null);

        // case with no contacts
        c = HLSessionController.getCase(case2Id);
        System.assertEquals(c.Id, case2Id);
        System.assertEquals(c.ContactId, null);
        System.assertEquals(c.ContactEmail, null);
        System.assertEquals(c.Contact.Name, null);

    }

    /**
     * Test getting calls for a Case.
     */
    @isTest
    static void testGetCallsForRecordCase() {
        Id caseId = [SELECT Id from Case WHERE Subject = 'Case 1' LIMIT 1].Id;
        Id invalidId = [SELECT Id from WorkOrder WHERE Subject = 'Work Order 1' LIMIT 1].Id;

        List<HLCall__c> calls = HLSessionController.getCallsForRecord('case', caseId);

        System.assertEquals(calls.size(), 2);

        // test for an invalid Id
        calls = HLSessionController.getCallsForRecord('case', invalidId);
        System.assertEquals(calls.size(), 0);

        // null Id
        calls = HLSessionController.getCallsForRecord('case', null);
        System.assertEquals(calls.size(), 0);
    }

    /**
     * Test getting calls for a WorkOrder.
     */
    @isTest
    static void testGetCallsForRecordWorkOrder() {
        Id workOrderId = [SELECT Id from WorkOrder WHERE Subject = 'Work Order 1' LIMIT 1].Id;
        Id invalidId = [SELECT Id from Case WHERE Subject = 'Case 1' LIMIT 1].Id;

        List<HLCall__c> calls = HLSessionController.getCallsForRecord('WorkOrder', workOrderId);

        System.assertEquals(calls.size(), 1);

        // test for an invalid Id
        calls = HLSessionController.getCallsForRecord('WorkOrder', invalidId);
        System.assertEquals(calls.size(), 0);

        // null Id
        calls = HLSessionController.getCallsForRecord('WorkOrder', null);
        System.assertEquals(calls.size(), 0);
    }

    /**
     * Test getting calls for an invalid record type.
     */
    @isTest
    static void testGetCallsForRecordInvalid() {
        List<HLCall__c> calls = HLSessionController.getCallsForRecord('InvalidType', null);
        System.assertEquals(calls.size(), 0);
    }

    /**
     * Test saving a call
     */
    @isTest
    static void testSaveCall() {
        HLCall__c call = [SELECT Id, Complete__c from HLCall__c WHERE Complete__c = false LIMIT 1];
        call.Complete__c = true;

        call = HLSessionController.saveCall(call);
        System.assertEquals(call.Complete__c, true);

        // validate this doesn't bomb with a null call.
        call = HLSessionController.saveCall(null);
        System.assertEquals(call, null);
    }

    /**
     * Test updating the calls for a case
     */
    @isTest
    static void testUpdateCallsCase() {
        Id caseId = [SELECT Id from Case WHERE Subject = 'Case 1' LIMIT 1].Id;

        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'support', Email='support@helplightning.com',
                          EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Chicago', UserName='support@helplightning.com');
        insert u;

        // We are not allowed to do an DML operations
        //  before doing a call-out. But, we need test data
        //  to be inserted first.
        // This start/stopTest hack works around this.
        // https://salesforce.stackexchange.com/questions/46438/unit-test-you-have-uncommitted-work-pending-please-commit-or-rollback-before-c
        Test.startTest();

        // set up the mock
        Test.setMock(HttpCalloutMock.class, new UpdateCallsCaseMocker());

        System.RunAs(u) {
            List<HLCall__c> calls = HLSessionController.updateCalls('Case', caseId);

            // validate we have 2 calls
            System.assertEquals(calls.size(), 2);

            // validate that call id 'wxyz'
            //  has been set to complete.
            HLCall__c wxyz = null;
            for (HLCall__c c: calls) {
                if (c.HLCall_Id__c == 'wxyz')
                    wxyz = c;
            }

            System.assertNotEquals(wxyz, null);
            System.assertEquals(wxyz.Complete__c, true);
            System.assertEquals(wxyz.Duration__c, 360);
        }

        Test.stopTest();
    }

    /**
     * Test updating the calls for a case with an invalid config
     */
    @isTest
    static void testUpdateCallsCaseMissingConfig() {
        Help_Lightning_Config__c config = Help_Lightning_Config__c.getOrgDefaults();
        delete config;

        Id caseId = [SELECT Id from Case WHERE Subject = 'Case 1' LIMIT 1].Id;

        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'support', Email='support@helplightning.com',
                          EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Chicago', UserName='support@helplightning.com');
        insert u;

        // We are not allowed to do an DML operations
        //  before doing a call-out. But, we need test data
        //  to be inserted first.
        // This start/stopTest hack works around this.
        // https://salesforce.stackexchange.com/questions/46438/unit-test-you-have-uncommitted-work-pending-please-commit-or-rollback-before-c
        Test.startTest();

        // set up the mock
        Test.setMock(HttpCalloutMock.class, new UpdateCallsCaseMocker());

        System.RunAs(u) {
            try {
                HLSessionController.updateCalls('Case', caseId);
                System.assert(false, 'Exception wasn\'t raised');
            } catch (AuraHandledException e) {
                // expected path
                System.assert(true);
            } catch (Exception e) {
                System.assert(false, 'Caught incorrect exception');
            }
        }

        Test.stopTest();
    }

    /**
     * Test updating the calls for a work order
     */
    @isTest
    static void testUpdateCallsWorkOrder() {
        Id workOrderId = [SELECT Id from WorkOrder WHERE Subject = 'Work Order 1' LIMIT 1].Id;

        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'support', Email='support@helplightning.com',
                          EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Chicago', UserName='support@helplightning.com');
        insert u;

        // We are not allowed to do an DML operations
        //  before doing a call-out. But, we need test data
        //  to be inserted first.
        // This start/stopTest hack works around this.
        // https://salesforce.stackexchange.com/questions/46438/unit-test-you-have-uncommitted-work-pending-please-commit-or-rollback-before-c
        Test.startTest();

        // set up the mock
        Test.setMock(HttpCalloutMock.class, new UpdateCallsWorkOrderMocker());

        System.RunAs(u) {
            List<HLCall__c> calls = HLSessionController.updateCalls('WorkOrder', workOrderId);

            // validate we have 1 calls
            System.assertEquals(calls.size(), 1);
        }

        Test.stopTest();
    }

    /**
     * Test updating calls for an unsupported record type
     */
    @isTest
    static void testUpdateCallsInvalid() {
        Id contactId = [SELECT Id FROM Contact WHERE Email='contact1@helplightning.com' LIMIT 1].Id;
        List<HLCall__c> calls;

        calls = HLSessionController.updateCalls('Case', null);
        System.assertEquals(calls.size(), 0);

        calls = HLSessionController.updateCalls('Contacts', contactId);
        System.assertEquals(calls.size(), 0);
    }

    /**
     * Test if a user is a help lightning user.
     */
    @isTest
    static void testIsHLUser() {
        Test.setMock(HttpCalloutMock.class, new IsHLUserMocker());
        Boolean result;

        // We are not allowed to do an DML operations
        //  before doing a call-out. But, we need test data
        //  to be inserted first.
        // This start/stopTest hack works around this.
        // https://salesforce.stackexchange.com/questions/46438/unit-test-you-have-uncommitted-work-pending-please-commit-or-rollback-before-c
        Test.startTest();

        // test a "valid user"
        result = HLSessionController.isHLUser('support@helplightning.com');
        System.assertEquals(true, result);

        // test a non help lightning user
        result = HLSessionController.isHLUser('invalid@helplightning.com');
        System.assertEquals(false, result);

        Test.stopTest();
    }

    /**
     * Test if a user is a help lightning user with an invalid configuration
     */
    @isTest
    static void testIsHLUserMissingConfig() {
        Help_Lightning_Config__c config = Help_Lightning_Config__c.getOrgDefaults();
        delete config;

        Test.setMock(HttpCalloutMock.class, new IsHLUserMocker());
        Boolean result;

        // We are not allowed to do an DML operations
        //  before doing a call-out. But, we need test data
        //  to be inserted first.
        // This start/stopTest hack works around this.
        // https://salesforce.stackexchange.com/questions/46438/unit-test-you-have-uncommitted-work-pending-please-commit-or-rollback-before-c
        Test.startTest();

        // test a "valid user"
        try {
            HLSessionController.isHLUser('support@helplightning.com');
            System.assert(false, 'Exception wasn\'t raised');
        } catch (AuraHandledException e) {
            // expected path
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Caught incorrect exception');
        }

        Test.stopTest();
    }

    /**
     * Test makeSessionWith
     */
    @isTest
    static void testMakeSessionWith() {
        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'support', Email='support@helplightning.com',
                          EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Chicago', UserName='support@helplightning.com');
        insert u;

        // We are not allowed to do an DML operations
        //  before doing a call-out. But, we need test data
        //  to be inserted first.
        // This start/stopTest hack works around this.
        // https://salesforce.stackexchange.com/questions/46438/unit-test-you-have-uncommitted-work-pending-please-commit-or-rollback-before-c
        Test.startTest();

        // set up the mock
        Test.setMock(HttpCalloutMock.class, new MakeSessionWithMocker());

        System.RunAs(u) {
            // try a valid case
            String sessionId = HLSessionController.makeSessionWith('contact1@helplightning.com');
            System.assertEquals('aabbccddeeff', sessionId);

            // try an invalid case
            sessionId = HLSessionController.makeSessionWith('invalid-user@helplightning.com');
            System.assertEquals(null, sessionId);
        }

        Test.stopTest();
    }

    /**
     * Test makeSessionWith with invalid configuration
     */
    @isTest
    static void testMakeSessionWithMissingConfig() {
        Help_Lightning_Config__c config = Help_Lightning_Config__c.getOrgDefaults();
        delete config;

        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'support', Email='support@helplightning.com',
                          EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Chicago', UserName='support@helplightning.com');
        insert u;

        // We are not allowed to do an DML operations
        //  before doing a call-out. But, we need test data
        //  to be inserted first.
        // This start/stopTest hack works around this.
        // https://salesforce.stackexchange.com/questions/46438/unit-test-you-have-uncommitted-work-pending-please-commit-or-rollback-before-c
        Test.startTest();

        // set up the mock
        Test.setMock(HttpCalloutMock.class, new MakeSessionWithMocker());

        System.RunAs(u) {
            // try a valid case
            try {
                HLSessionController.makeSessionWith('contact1@helplightning.com');
                System.assert(false, 'Exception wasn\'t raised');
            } catch (AuraHandledException e) {
                // expected path
                System.assert(true);
            } catch (Exception e) {
                System.assert(false, 'Caught incorrect exception');
            }
        }

        Test.stopTest();
    }

    /**
     * Test inviteToPersonalRoom
     */
    @isTest
    static void testInviteToPersonalRoom() {
        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u1 = new User(Alias = 'support', Email='support@helplightning.com',
                           EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Chicago', UserName='support@helplightning.com');
        insert u1;
        User u2 = new User(Alias = 'support2', Email='support2@helplightning.com',
                           EmailEncodingKey='UTF-8', LastName='Support 2', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Chicago', UserName='support2@helplightning.com');
        insert u2;
        User u3 = new User(Alias = 'support3', Email='support3@helplightning.com',
                           EmailEncodingKey='UTF-8', LastName='Support 3', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Chicago', UserName='support3@helplightning.com');
        insert u3;

        // We are not allowed to do an DML operations
        //  before doing a call-out. But, we need test data
        //  to be inserted first.
        // This start/stopTest hack works around this.
        // https://salesforce.stackexchange.com/questions/46438/unit-test-you-have-uncommitted-work-pending-please-commit-or-rollback-before-c
        Test.startTest();

        // set up the mock
        Test.setMock(HttpCalloutMock.class, new InviteToPersonalRoomMocker());

        System.RunAs(u1) {
            Boolean result;

            // try a valid case
            result = HLSessionController.inviteToPersonalRoom('Other User', 'other@helplightning.com');
            System.assertEquals(true, result);

            // try an invalid case
            result = HLSessionController.inviteToPersonalRoom('Invalid User', 'invalid-user@helplightning.com');
            System.assertEquals(false, result);
        }

        System.RunAs(u2) {
            Boolean result;

            // try a other user, but we are not part of this enterprise
            result = HLSessionController.inviteToPersonalRoom('Other User', 'other@helplightning.com');
            System.assertEquals(false, result);
        }
        System.RunAs(u3) {
            Boolean result;

            // simulate us not correctly returning a token
            result = HLSessionController.inviteToPersonalRoom('Other User', 'other@helplightning.com');
            System.assertEquals(false, result);
        }

        Test.stopTest();
    }

    /**
     * Test inviteToPersonalRoom with invalid configuration
     */
    @isTest
    static void testInviteToPersonalRoomMissingConfig() {
        Help_Lightning_Config__c config = Help_Lightning_Config__c.getOrgDefaults();
        delete config;

        // run as a support@helplightning.com user, since this
        //  looks up the current user to find a match.
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u1 = new User(Alias = 'support', Email='support@helplightning.com',
                           EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Chicago', UserName='support@helplightning.com');
        insert u1;

        // We are not allowed to do an DML operations
        //  before doing a call-out. But, we need test data
        //  to be inserted first.
        // This start/stopTest hack works around this.
        // https://salesforce.stackexchange.com/questions/46438/unit-test-you-have-uncommitted-work-pending-please-commit-or-rollback-before-c
        Test.startTest();

        // set up the mock
        Test.setMock(HttpCalloutMock.class, new InviteToPersonalRoomMocker());

        System.RunAs(u1) {
            try {
                HLSessionController.inviteToPersonalRoom('Other User', 'other@helplightning.com');
                System.assert(false, 'Exception wasn\'t raised');
            } catch (AuraHandledException e) {
                // expected path
                System.assert(true);
            } catch (Exception e) {
                System.assert(false, 'Caught incorrect exception');
            }

        }

    }
}
