/* -*- Mode: java; -*- */

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
                            'session_id' => 'aabbccdd',
                            'call_id' => 'abcd',
                            'dialer' => new Map<String,Object>{
                                    'id' => '432',
                                    'name' => 'support',
                                    'email' => 'support@helplightning.com'
                                    },
                            'receiver' => new Map<String,Object>{
                                    'id' => '22',
                                    'name' => 'contact1',
                                    'email' => 'contact1@helplightning.com'
                                    },
                            'start_time' => '2017-06-28T11:30:02-05',
                            'end_time' => '2017-06-28T11:40:02-05',
                            'complete' => true,
                            'successful' => true,
                            'duration' => 600
                            };
                    calls.add(call);
                } else if (sessionId == 'wwxxyyzz') {
                    Map<String,Object> call = new Map<String,Object>{
                            'session_id' => 'wwxxyyzz',
                            'call_id' => 'wxyz',
                            'dialer' => new Map<String,Object>{
                                    'id' => '432',
                                    'name' => 'support',
                                    'email' => 'support@helplightning.com'
                                    },
                            'receiver' => new Map<String,Object>{
                                    'id' => '22',
                                    'name' => 'contact1',
                                    'email' => 'contact1@helplightning.com'
                                    },
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
     * Mocker for the testGetSession
     * This is more of a test of the mocker than it is the actual method
     */
    class GetSessionMocker implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            URL endpoint = new URL(req.getEndpoint());

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            if (req.getMethod() == 'GET' && endpoint.getPath().startsWith('/api/v1/sessions/')) {
                // return some help lightning calls.
                List<String> parts = endpoint.getPath().split('/');
                String sessionId = parts.get(parts.size()-1);

                HLModelSession result = new HLModelSession(sessionId, 'token', false, new List<helplightning.HLModelSessionUser>());

                // return this as a serialized list of maps.
                response.setBody(JSON.serialize(result));
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
                            'active' => true,
                            'token' => 'my-token',
                            'avatar' => new Map<String,String> {
                                    'original' => '/path/to/avatar.jpg',
                                    'thumb' => '/path/to/avatar-thumb.jpg'
                            }
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
     * Mocker for the checkRegistration
     */
    class CheckRegistrationMocker implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            URL endpoint = new URL(req.getEndpoint());

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            if (req.getMethod() == 'GET' && endpoint.getPath().startsWith('/api/v1/enterprise/users')) {
                Map<String, Object> result = new Map<String, Object>();

                if (endpoint.getQuery() == 'filter=email%3Dsupport%40helplightning.com') {
                    result.put('total_entries', 1);
                    result.put('entries', new List<Object> {
                            new Map<String,Object>{
                                'id' => 24,
                                'name' => 'Support',
                                'username' => 'support',
                                'email' => 'support@helplightning.com',
                                'available' => true,
                                'status' => 0,
                                'avatar' => new Map<String,String> {
                                        'original' => 'orig.jpg',
                                        'thumb' => 'thumb.jpg'
                                    },
                                'token' => 'valid-token'
                                }
                        });
                } else if (endpoint.getQuery() == 'filter=email%3Doverride1534%40helplightning.com') {
                    // this is a valid user, but we are going to fake
                    //  not return a valid token
                    result.put('total_entries', 1);
                    result.put('entries', new List<Object> {
                            new Map<String,Object>{
                                'id' => 242,
                                'name' => 'Override',
                                'username' => 'override1534',
                                'email' => 'override1534@helplightning.com',
                                'available' => true,
                                'status' => 0,
                                'avatar' => new Map<String,String> {
                                        'original' => 'orig.jpg',
                                        'thumb' => 'thumb.jpg'
                                    },
                                'token' => 'valid-token'
                                }
                        });
                } else {
                    result.put('total_entries', 0);
                    result.put('entries', new List<Object>{});
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

            if (req.getMethod() == 'GET' && endpoint.getPath().startsWith('/api/v1/enterprise/users')) {
                Map<String, Object> result = new Map<String, Object>();

                if (endpoint.getQuery() == 'filter=email%3Dsupport%40helplightning.com') {
                    result.put('total_entries', 1);
                    result.put('entries', new List<Object> {
                            new Map<String,Object>{
                                'id' => 24,
                                'name' => 'Support',
                                'username' => 'support',
                                'email' => 'support@helplightning.com',
                                'available' => true,
                                'status' => 0,
                                'avatar' => new Map<String,String> {
                                        'original' => 'orig.jpg',
                                        'thumb' => 'thumb.jpg'
                                    },
                                'token' => 'valid-token'
                                }
                        });
                } else {
                    result.put('total_entries', 0);
                    result.put('entries', new List<Object>{});
                }
                response.setStatusCode(200);
                response.setBody(JSON.serialize(result));

            } else if (req.getMethod() == 'POST' && endpoint.getPath().startsWith('/api/v1/search')) {
                Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(req.getBody());

                List<Object> result = new List<Object>();
                if (body.get('search_term') == 'contact1@helplightning.com') {
                    result.add(new Map<String,Object>{
                            'id' => 265,
                            'name' => 'Contact 1',
                            'username' => 'contact1',
                            'active' => true,
                            'token' => 'my-token',
                            'avatar' => new Map<String,String> {
                                    'original' => '/path/to/avatar.jpg',
                                    'thumb' => '/path/to/avatar-thumb.jpg'
                            }
                        });
                }

                response.setStatusCode(200);
                response.setBody(JSON.serialize(result));

            } else if (req.getMethod() == 'POST' && endpoint.getPath().startsWith('/api/v1/sessions')) {
                Map<String,Object> result = new Map<String,Object>{
                        'id' => 'session_abcd',
                        'token' => 'session_abcd_token',
                        'video_active' => false,
                        'users' => new List<Object>{
                                new Map<String,Object> {
                                    'id' => 5,
                                    'name' => 'Support',
                                    'token' => 'support-public-token',
                                    'username' => 'support',
                                    'avatar' => new Map<String,String> {
                                            'original' => 'avatar1.jpg',
                                            'thumb' => 'avatar1_thumb.jpg'
                                            }
                                },
                                new Map<String,Object> {
                                    'id' => 265,
                                    'name' => 'Contact 1',
                                    'token' => 'contact-public-token',
                                    'username' => 'contact1',
                                    'avatar' => new Map<String,String> {
                                            'original' => 'avatar2.jpg',
                                            'thumb' => 'avatar2_thumb.jpg'
                                            }
                                }
                            }
                    };

                response.setStatusCode(200);
                response.setBody(JSON.serialize(result));

            } else if (req.getMethod() == 'POST' && endpoint.getPath().startsWith('/api/v1/session/video')) {
                Map<String,Object> result = new Map<String,Object>{
                        'gss_info' => new Map<String,Object>{
                                'token' => 'gss-token',
                                'server' => 'gss+ssl://gss-001.helplightning.net',
                                'wsserver' => 'wss://gss-001.helplightning.net'
                            }
                    };

                response.setStatusCode(200);
                response.setBody(JSON.serialize(result));

            } else {
                response.setStatusCode(500);
            }

            return response;
        }
    }
    /**
     * Mocker for the testSendOneTimeUseLink
     */
class SendOneTimeUseLinkMocker implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            URL endpoint = new URL(req.getEndpoint());

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            if (req.getMethod() == 'GET' && endpoint.getPath().startsWith('/api/v1/enterprise/users')) {
                Map<String, Object> result = new Map<String, Object>();

                if (endpoint.getQuery() == 'filter=email%3Dsupport%40helplightning.com') {
                    result.put('total_entries', 1);
                    result.put('entries', new List<Object> {
                            new Map<String,Object>{
                                'id' => 234,
                                'name' => 'Support',
                                'username' => 'support',
                                'active' => true,
                                'token' => 'my-token',
                                'avatar' => new Map<String,String> {
                                        'original' => '/path/to/avatar.jpg',
                                        'thumb' => '/path/to/avatar-thumb.jpg'
                                }
                            }
                        });
                } else if (endpoint.getQuery() == 'filter=email%3Dsupport3%40helplightning.com') {
                    // this is a valid user, but we are going to fake
                    //  not return a valid token
                    result.put('total_entries', 1);
                    result.put('entries', new List<Object> {
                            new Map<String,Object>{
                                'id' => 234,
                                'name' => 'Support 3',
                                'username' => 'support3',
                                'active' => true,
                                'avatar' => new Map<String,String> {
                                        'original' => '/path/to/avatar.jpg',
                                        'thumb' => '/path/to/avatar-thumb.jpg'
                                }
                            }
                        });
                } else {
                    result.put('total_entries', 0);
                    result.put('entries', new List<Object>{});
                }
                response.setStatusCode(200);
                response.setBody(JSON.serialize(result));
            } else if (req.getMethod() == 'POST' && endpoint.getPath().startsWith('/api/v1/sessions/link/invite')) {
                Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(req.getBody());
                if (body.get('recipientEmail') == 'invalid-user@helplightning.com') {
                    // simulate invalid
                    response.setStatusCode(500);
                } else {
                    response.setStatusCode(200);
                    response.setBody(JSON.serialize(true));
                }
            } else if (req.getMethod() == 'GET' && endpoint.getPath().startsWith('/api/v1/info')) {
                Map<String, Object> result = new Map<String, Object>{
                        'id' => 234,
                        'name' => 'Support',
                        'username' => 'support',
                        'email' => 'support@helplightning.com',
                        'avatar' => new Map<String,String> {
                                'original' => '/path/to/avatar.jpg',
                                'thumb' => '/path/to/avatar-thumb.jpg'
                                },
                        'available' => true,
                        'active' => true,
                        'status' => 0,
                        'personal_room_url' => '/meet/support',
                        'personal_room_session_id' => 'xxx-yyyy-zzz'
                        };

                response.setStatusCode(200);
                response.setBody(JSON.serialize(result));
            } else if (req.getMethod() == 'GET' && endpoint.getPath().startsWith('/api/v1/sessions/xxx-yyyy-zzz')) {
                Map<String,Object> result = new Map<String,Object>{
                        'id' => 'xxx-yyyy-zzz',
                        'token' => 'session_token',
                        'video_active' => false,
                        'users' => new List<Object>{
                                new Map<String,Object> {
                                    'id' => 5,
                                    'name' => 'Support',
                                    'token' => 'support-public-token',
                                    'username' => 'support',
                                    'avatar' => new Map<String,String> {
                                            'original' => 'avatar1.jpg',
                                            'thumb' => 'avatar1_thumb.jpg'
                                            }
                                }
                            }
                    };
                response.setStatusCode(200);
                response.setBody(JSON.serialize(result));
            } else if (req.getMethod() == 'POST' && endpoint.getPath().startsWith('/api/v1/session/video')) {
                Map<String,Object> result = new Map<String,Object>{
                        'gss_info' => new Map<String,Object>{
                                'token' => 'gss-token',
                                'server' => 'gss+ssl://gss-001.helplightning.net',
                                'wsserver' => 'wss://gss-001.helplightning.net'
                            }
                    };

                response.setStatusCode(200);
                response.setBody(JSON.serialize(result));
            } else {
                response.setStatusCode(500);
            }

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

            // create some fake calls for case 1
            List<helplightning__HLCall__c> calls = new List<helplightning__HLCall__c>();
            calls.add(new helplightning__HLCall__c(helplightning__Session_Id__c = 'aabbccdd',
                                                   helplightning__HLCall_Id__c = 'abcd',
                                                   helplightning__Complete__c = true,
                                                   helplightning__Successful__c = true,
                                                   helplightning__Start_Time__c = DateTime.newInstanceGMT(2017, 6, 28, 11, 30, 0),
                                                   helplightning__Duration__c = 60,
                                                   helplightning__Contact_Email__c = 'contact1@helplightning.com',
                                                   helplightning__Type__c = 'Direct',
                                                   helplightning__Case__c = case1.Id));
            calls.add(new helplightning__HLCall__c(helplightning__Session_Id__c = 'wwxxyyzz',
                                                   helplightning__HLCall_Id__c = 'wxyz',
                                                   helplightning__Complete__c = false,
                                                   helplightning__Successful__c = false,
                                                   helplightning__Start_Time__c = DateTime.newInstanceGMT(2017, 6, 28, 11, 36, 0),
                                                   helplightning__Duration__c = 0,
                                                   helplightning__Contact_Email__c = 'contact1@helplightning.com',
                                                   helplightning__Type__c = 'Direct',
                                                   helplightning__Case__c = case1.Id));
            // add a call to the work order
            calls.add(new helplightning__HLCall__c(helplightning__Session_Id__c = 'jjkkllmm',
                                                   helplightning__HLCall_Id__c = 'jklm',
                                                   helplightning__Complete__c = true,
                                                   helplightning__Successful__c = false,
                                                   helplightning__Start_Time__c = DateTime.newInstanceGMT(2017, 6, 24, 14, 55, 0),
                                                   helplightning__Duration__c = 0,
                                                   helplightning__Contact_Email__c = 'contact2@helplightning.com',
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
        c = helplightning.HLSessionController.getContactForRecord('Case', caseId);
        System.assertNotEquals(c, null);
        System.assertEquals(c.Id, contact1.Id);
        System.assertEquals(c.Name, contact1.Name);
        System.assertEquals(c.Email, contact1.Email);

        // look up a valid work order
        c = helplightning.HLSessionController.getContactForRecord('WorkOrder', workOrderId);
        System.assertNotEquals(c, null);
        System.assertEquals(c.Id, contact2.Id);
        System.assertEquals(c.Name, contact2.Name);
        System.assertEquals(c.Email, contact2.Email);

        // look up an invalid case and work order
        c = helplightning.HLSessionController.getContactForRecord('Case', workOrderId);
        System.assertEquals(c, null);
        c = helplightning.HLSessionController.getContactForRecord('WorkOrder', caseId);
        System.assertEquals(c, null);

        // look up a valid case missing a contact
        c = helplightning.HLSessionController.getContactForRecord('Case', case2Id);
        System.assertEquals(c, null);

        // look up an unsupported record type
        c = helplightning.HLSessionController.getContactForRecord('Contact', contact1.Id);
        System.assertEquals(c, null);
    }

    /**
     * Try to get a contact for a record for a user
     *  that doesn't have permission.
     */
    @isTest
    static void testGetContactForRecordInsufficientPermission() {
        // create a very limited user
        Profile p = [SELECT Id FROM Profile WHERE Name='Chatter Free User'];
        User u = new User(Alias = 'chatter', Email='chatter-free-record@helplightning.com',
                           EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Chicago', UserName='chatter-free-record@helplightning.com');
        insert u;

        Id caseId = [SELECT Id from Case WHERE Subject = 'Case 1' LIMIT 1].Id;
        Id workOrderId = [SELECT Id from WorkOrder WHERE Subject = 'Work Order 1' LIMIT 1].Id;

        Contact result = null;
        System.RunAs(u) {
            // try a case
            result = helplightning.HLSessionController.getContactForRecord('Case', caseId);
            System.assertEquals(null, result);

            // try a work order
            result = helplightning.HLSessionController.getContactForRecord('WorkOrder', workOrderId);
            System.assertEquals(null, result);
        }
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

        c = helplightning.HLSessionController.getCase(caseId);
        System.assertEquals(c.Id, caseId);
        System.assertEquals(c.ContactId, contact.Id);
        System.assertEquals(c.ContactEmail, contact.Email);
        System.assertEquals(c.Contact.Name, contact.Name);

        // null id
        System.assertEquals(helplightning.HLSessionController.getCase(null), null);

        // case with no contacts
        c = helplightning.HLSessionController.getCase(case2Id);
        System.assertEquals(c.Id, case2Id);
        System.assertEquals(c.ContactId, null);
        System.assertEquals(c.ContactEmail, null);
        System.assertEquals(c.Contact.Name, null);

    }

    /**
     * Test getting a specific case based on its Id
     *  with a user with insufficient privilieges
     */
    @isTest
    static void testGetCaseInsufficientPermission() {
        // create a very limited user
        Profile p = [SELECT Id FROM Profile WHERE Name='Chatter Free User'];
        User u = new User(Alias = 'chatter', Email='chatter-free-record@helplightning.com',
                           EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Chicago', UserName='chatter-free-record@helplightning.com');
        insert u;

        Id caseId = [SELECT Id from Case WHERE Subject = 'Case 1' LIMIT 1].Id;

        System.RunAs(u) {
            Case c = helplightning.HLSessionController.getCase(caseId);
            System.assertEquals(null, c);
        }
    }

    /**
     * Test getting calls for a Case.
     */
    @isTest
    static void testGetCallsForRecordCase() {
        Id caseId = [SELECT Id from Case WHERE Subject = 'Case 1' LIMIT 1].Id;
        Id invalidId = [SELECT Id from WorkOrder WHERE Subject = 'Work Order 1' LIMIT 1].Id;

        List<helplightning__HLCall__c> calls = helplightning.HLSessionController.getCallsForRecord('case', caseId);

        System.assertEquals(2, calls.size());

        // test for an invalid Id
        calls = helplightning.HLSessionController.getCallsForRecord('case', invalidId);
        System.assertEquals(0, calls.size());

        // null Id
        calls = helplightning.HLSessionController.getCallsForRecord('case', null);
        System.assertEquals(0, calls.size());
    }

    /**
     * Test getting calls for a WorkOrder.
     */
    @isTest
    static void testGetCallsForRecordWorkOrder() {
        Id workOrderId = [SELECT Id from WorkOrder WHERE Subject = 'Work Order 1' LIMIT 1].Id;
        Id invalidId = [SELECT Id from Case WHERE Subject = 'Case 1' LIMIT 1].Id;

        List<helplightning__HLCall__c> calls = helplightning.HLSessionController.getCallsForRecord('WorkOrder', workOrderId);

        System.assertEquals(calls.size(), 1);

        // test for an invalid Id
        calls = helplightning.HLSessionController.getCallsForRecord('WorkOrder', invalidId);
        System.assertEquals(calls.size(), 0);

        // null Id
        calls = helplightning.HLSessionController.getCallsForRecord('WorkOrder', null);
        System.assertEquals(calls.size(), 0);
    }

    /**
     * Test getting calls for an invalid record type.
     */
    @isTest
    static void testGetCallsForRecordInvalid() {
        List<helplightning__HLCall__c> calls = helplightning.HLSessionController.getCallsForRecord('InvalidType', null);
        System.assertEquals(calls.size(), 0);
    }

    /**
     * Test saving a call
     */
    @isTest
    static void testSaveCall() {
        User u = [SELECT Id from User WHERE UserName='test-user@helplightning.com' LIMIT 1];

        // We are not allowed to do an DML operations
        //  before doing a call-out. But, we need test data
        //  to be inserted first.
        // This start/stopTest hack works around this.
        // https://salesforce.stackexchange.com/questions/46438/unit-test-you-have-uncommitted-work-pending-please-commit-or-rollback-before-c
        Test.startTest();

        System.RunAs(u) {
            helplightning__HLCall__c call = [SELECT Id, helplightning__Complete__c from helplightning__HLCall__c WHERE helplightning__Complete__c = false LIMIT 1];
            call.helplightning__Complete__c = true;

            call = helplightning.HLSessionController.saveCall(call);
            System.assertEquals(true, call.helplightning__Complete__c);

            // validate this doesn't bomb with a null call.
            call = helplightning.HLSessionController.saveCall(null);
            System.assertEquals(null, call);
        }

        Test.stopTest();
    }

    /**
     * Test saving an HLCall with insufficient rights
     */
    @isTest
    static void testSaveCallInsufficientRights() {
        // create a limited user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standard', Email='test-save-call@helplightning.com',
                           EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Chicago', UserName='test-save-call@helplightning.com');
        insert u;

        // We are not allowed to do an DML operations
        //  before doing a call-out. But, we need test data
        //  to be inserted first.
        // This start/stopTest hack works around this.
        // https://salesforce.stackexchange.com/questions/46438/unit-test-you-have-uncommitted-work-pending-please-commit-or-rollback-before-c
        Test.startTest();

        System.RunAs(u) {
            helplightning__HLCall__c call = [SELECT Id, helplightning__Complete__c from helplightning__HLCall__c WHERE helplightning__Complete__c = false LIMIT 1];
            call.helplightning__Complete__c = true;

            call = helplightning.HLSessionController.saveCall(call);
            System.assertEquals(null, call);
        }

        Test.stopTest();
    }


    /**
     * Test updating the calls for a case
     */
    @isTest
    static void testUpdateCallsCase() {
        Id caseId = [SELECT Id from Case WHERE Subject = 'Case 1' LIMIT 1].Id;

        User u = [SELECT Id from User WHERE UserName='test-user@helplightning.com' LIMIT 1];

        // We are not allowed to do an DML operations
        //  before doing a call-out. But, we need test data
        //  to be inserted first.
        // This start/stopTest hack works around this.
        // https://salesforce.stackexchange.com/questions/46438/unit-test-you-have-uncommitted-work-pending-please-commit-or-rollback-before-c
        Test.startTest();

        // set up the mock
        Test.setMock(HttpCalloutMock.class, new UpdateCallsCaseMocker());

        System.RunAs(u) {
            List<helplightning__HLCall__c> calls = helplightning.HLSessionController.updateCalls('Case', caseId);

            // validate we have 2 calls
            System.assertEquals(calls.size(), 2);

            // validate that call id 'wxyz'
            //  has been set to complete.
            helplightning__HLCall__c wxyz = null;
            for (helplightning__HLCall__c c: calls) {
                if (c.helplightning__HLCall_Id__c == 'wxyz')
                    wxyz = c;
            }

            System.assertNotEquals(wxyz, null);
            System.assertEquals(wxyz.helplightning__Complete__c, true);
            System.assertEquals(wxyz.helplightning__Duration__c, 360);
        }

        Test.stopTest();
    }

    /**
     * Test updating the calls for a case with an invalid config
     */
    @isTest
    static void testUpdateCallsCaseMissingConfig() {
        // remove the config
        helplightning__Help_Lightning_Config__c config = helplightning__Help_Lightning_Config__c.getOrgDefaults();
        config.helplightning__Enterprise_Id__c = null;
        config.helplightning__Private_Key_1__c = null;
        config.helplightning__Private_Key_2__c = null;
        config.helplightning__Private_Key_3__c = null;
        config.helplightning__Private_Key_4__c = null;
        upsert config helplightning__Help_Lightning_Config__c.Id;

        Id caseId = [SELECT Id from Case WHERE Subject = 'Case 1' LIMIT 1].Id;

        User u = [SELECT Id from User WHERE UserName='test-user@helplightning.com' LIMIT 1];


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
                helplightning.HLSessionController.updateCalls('Case', caseId);
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

        User u = [SELECT Id from User WHERE UserName='test-user@helplightning.com' LIMIT 1];

        // We are not allowed to do an DML operations
        //  before doing a call-out. But, we need test data
        //  to be inserted first.
        // This start/stopTest hack works around this.
        // https://salesforce.stackexchange.com/questions/46438/unit-test-you-have-uncommitted-work-pending-please-commit-or-rollback-before-c
        Test.startTest();

        // set up the mock
        Test.setMock(HttpCalloutMock.class, new UpdateCallsWorkOrderMocker());

        System.RunAs(u) {
            List<helplightning__HLCall__c> calls = helplightning.HLSessionController.updateCalls('WorkOrder', workOrderId);

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
        List<helplightning__HLCall__c> calls;

        calls = helplightning.HLSessionController.updateCalls('Case', null);
        System.assertEquals(calls.size(), 0);

        calls = helplightning.HLSessionController.updateCalls('Contacts', contactId);
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
        result = helplightning.HLSessionController.isHLUser('support@helplightning.com');
        System.assertEquals(true, result);

        // test a non help lightning user
        result = helplightning.HLSessionController.isHLUser('invalid@helplightning.com');
        System.assertEquals(false, result);

        Test.stopTest();
    }

    /**
     * Test if a user is a help lightning user with an invalid configuration
     */
    @isTest
    static void testIsHLUserMissingConfig() {
        helplightning__Help_Lightning_Config__c config = helplightning__Help_Lightning_Config__c.getOrgDefaults();
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
            helplightning.HLSessionController.isHLUser('support@helplightning.com');
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
        User u2 = new User(Alias = 'support2', Email='support2@helplightning.com',
                           EmailEncodingKey='UTF-8', LastName='Support 2', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Chicago', UserName='support2@helplightning.com');
        insert u2;

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
            Map<String,Object> authInfo = helplightning.HLSessionController.makeSessionWith('contact1@helplightning.com');
            Map<String,Object> gssInfo = (Map<String,Object>)authInfo.get('gssInfo');
            System.assertEquals('valid-token', authInfo.get('token'));
            System.assertEquals('session_abcd', authInfo.get('sessionId'));
            System.assertEquals('Support', authInfo.get('displayName'));
            System.assertEquals('gss-token', gssInfo.get('token'));
            System.assertEquals('gss+ssl://gss-001.helplightning.net', gssInfo.get('serverURL'));
            System.assertEquals('wss://gss-001.helplightning.net', gssInfo.get('serverWSURL'));

            //System.assertEquals('aabbccddeeff', sessionId);

            // try an invalid case
            authInfo = helplightning.HLSessionController.makeSessionWith('invalid-user@helplightning.com');
            System.assertEquals(null, authInfo);
        }
        System.RunAs(u2) {
            // try as a user that isn't part of this enterprise
            try {
                helplightning.HLSessionController.makeSessionWith('contact1@helplightning.com');
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
     * Test makeSessionWith with invalid configuration
     */
    @isTest
    static void testMakeSessionWithMissingConfig() {
        helplightning__Help_Lightning_Config__c config = helplightning__Help_Lightning_Config__c.getOrgDefaults();
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
                helplightning.HLSessionController.makeSessionWith('contact1@helplightning.com');
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
     * Test getSession
     */
    @isTest
    static void testGetSession() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'support', Email='support@helplightning.com',
                           EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Chicago', UserName='support@helplightning.com');
        insert u;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GetSessionMocker());

        System.RunAs(u) {
            helplightning.HLModelSession session = helplightning.HLGaldrClient.getSession('fake', '12345');

            System.assertEquals('12345', session.id);
            System.assertEquals('token', session.token);
            System.assertEquals(0, session.users.size());
        }

        Test.stopTest();
    }

    /**
     * Test sendOneTimeUseLink
     */
    @isTest
    static void testSendOneTimeUseLink() {
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
        Test.setMock(HttpCalloutMock.class, new SendOneTimeUseLinkMocker());

        System.RunAs(u1) {
            Map<String,Object> result;

            // try a valid case
            result = helplightning.HLSessionController.sendOneTimeUseLink('Other User', 'other@helplightning.com', '', '');

            System.assertEquals('my-token', result.get('token'));
            System.assertEquals('Support', result.get('name'));
            System.assertEquals('support', result.get('username'));
            System.assertEquals('xxx-yyyy-zzz', result.get('sessionId'));

            // try an invalid case
            result = helplightning.HLSessionController.sendOneTimeUseLink('Invalid User', 'invalid-user@helplightning.com', '', '');
            System.assertEquals(null, result);
        }

        System.RunAs(u2) {
            Map<String,Object> result;

            // try a other user, but we are not part of this enterprise
            result = helplightning.HLSessionController.sendOneTimeUseLink('Other User', 'other@helplightning.com', '', '');
            System.assertEquals(null, result);
        }
        System.RunAs(u3) {
            Map<String,Object> result;

            // simulate us not correctly returning a token
            result = helplightning.HLSessionController.sendOneTimeUseLink('Other User', 'other@helplightning.com', '', '');
            System.assertEquals(null, result);
        }

        Test.stopTest();
    }

    /**
     * Test sendOneTimeUseLink with invalid configuration
     */
    @isTest
    static void testSendOneTimeUseLinkMissingConfig() {
        helplightning__Help_Lightning_Config__c config = helplightning__Help_Lightning_Config__c.getOrgDefaults();
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
        Test.setMock(HttpCalloutMock.class, new SendOneTimeUseLinkMocker());

        System.RunAs(u1) {
            try {
                helplightning.HLSessionController.sendOneTimeUseLink('Other User', 'other@helplightning.com', '', '');
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
     * Test checkRegistration
     */
    @isTest
    static void testCheckRegistration() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u1 = new User(Alias = 'support', Email='support@helplightning.com',
                           EmailEncodingKey='UTF-8', LastName='Support', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Chicago', UserName='support@helplightning.com');
        insert u1;
        User u2 = new User(Alias = 'support2', Email='support2@helplightning.com',
                           EmailEncodingKey='UTF-8', LastName='Support2', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Chicago', UserName='support2@helplightning.com');
        insert u2;
        User u3 = new User(Alias = 'support3', Email='support3@helplightning.com',
                           EmailEncodingKey='UTF-8', LastName='Support 3', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Chicago', UserName='support3@helplightning.com');
        insert u3;

        // set an override for u2
        System.RunAs(u2) {
            HLConfiguration.setLoginOverride('override1534@helplightning.com');
        }

        // We are not allowed to do an DML operations
        //  before doing a call-out. But, we need test data
        //  to be inserted first.
        // This start/stopTest hack works around this.
        // https://salesforce.stackexchange.com/questions/46438/unit-test-you-have-uncommitted-work-pending-please-commit-or-rollback-before-c
        Test.startTest();

        // set up a mock
        Test.setMock(HttpCalloutMock.class, new CheckRegistrationMocker());


        System.RunAs(u1) {
            Boolean result = helplightning.HLSessionController.checkRegistration();
            System.assertEquals(true, result);
        }

        // make sure it works for u2 with an override.
        System.RunAs(u2) {
            Boolean result = helplightning.HLSessionController.checkRegistration();
            System.assertEquals(true, result);
        }

        // test an invalid user.
        System.RunAs(u3) {
            Boolean result = helplightning.HLSessionController.checkRegistration();
            System.assertEquals(false, result);
        }

        Test.stopTest();
    }

    /**
     * Test checkRegistration with an invalid configuration
     */
    @isTest
    static void testCheckRegistrationMissingConfig() {
        helplightning__Help_Lightning_Config__c config = helplightning__Help_Lightning_Config__c.getOrgDefaults();
        delete config;


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

        // set up a mock
        Test.setMock(HttpCalloutMock.class, new CheckRegistrationMocker());


        System.RunAs(u1) {
            try {
                helplightning.HLSessionController.checkRegistration();
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
}
