/* -*- Mode: java; -*- */

/**
 * HLContactListControllerTest.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
private class HLContactListControllerTest {
    /**
     * Mocker for the contact list request
     */
    class ContactListMocker implements HttpCalloutMock {
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
     * Test if contact list is returned.
     */
    @isTest
    static void testContactList() {
        Test.setMock(HttpCalloutMock.class, new ContactListMocker());
        List<helplightning.HLModelEnterpriseUser> result;

        // We are not allowed to do an DML operations
        //  before doing a call-out. But, we need test data
        //  to be inserted first.
        // This start/stopTest hack works around this.
        // https://salesforce.stackexchange.com/questions/46438/unit-test-you-have-uncommitted-work-pending-please-commit-or-rollback-before-c
        Test.startTest();

        result = helplightning.HLContactListController.getContacts('support@helplightning.com');
        System.assertEquals(result.size(), 0);

        Test.stopTest();
    }

     /**
     * Test if a user is a help lightning user with an invalid configuration
     */
    @isTest
    static void contactListMissingConfig() {
        helplightning__Help_Lightning_Config__c config = helplightning__Help_Lightning_Config__c.getOrgDefaults();
        delete config;

        Test.setMock(HttpCalloutMock.class, new ContactListMocker());
        List<helplightning.HLModelEnterpriseUser> result;

        // We are not allowed to do an DML operations
        //  before doing a call-out. But, we need test data
        //  to be inserted first.
        // This start/stopTest hack works around this.
        // https://salesforce.stackexchange.com/questions/46438/unit-test-you-have-uncommitted-work-pending-please-commit-or-rollback-before-c
        Test.startTest();

        // test a "valid user"
        try {
            helplightning.HLContactListController.getContacts('support@helplightning.com');
            System.assert(false, 'Exception wasn\'t raised');
        } catch (AuraHandledException e) {
            // expected path
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Caught incorrect exception');
        }

        Test.stopTest();
    }
    
}
