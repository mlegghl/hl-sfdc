@isTest
private class HLTokenHelperTest {
   /**
   * Mocker for the getWorkspaceById
   */
  class GetWorkspaceByIdMocker implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        URL endpoint = new URL(req.getEndpoint());

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');

        if (req.getMethod() == 'GET' && endpoint.getPath().startsWith('/api/v1r1/enterprise/workspaces/')) {

          List<String> parts = endpoint.getPath().split('/');
          String workspaceId = parts.get(parts.size()-1);

          Map<String,Object> res = new Map<String,Object>{
            'id' => 123,
            'name' => 'name',
            'token' => 'valid-token',
            'active' => true
            };

          response.setBody(JSON.serialize(res));
          response.setStatusCode(200);
        } else {
            System.debug('ERROR: ' + endpoint.getPath());
            // error
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
   * Test testCheckRegistrationWithDefaultWorkspace
   */
  @isTest
  static void testGetTokenWithWorkspace() {
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
      List<helplightning.HLModelWorkspace> workspaces = new List<helplightning.HLModelWorkspace>();
      
      System.RunAs(u1) {
        HLConfiguration.setWorkspaceId('123');
        HLConfiguration.setHasSiteKey(true);
      }

      System.RunAs(u2) {
        HLConfiguration.setHasSiteKey(true);
      }

      // We are not allowed to do an DML operations
      //  before doing a call-out. But, we need test data
      //  to be inserted first.
      // This start/stopTest hack works around this.
      // https://salesforce.stackexchange.com/questions/46438/unit-test-you-have-uncommitted-work-pending-please-commit-or-rollback-before-c
      Test.startTest();

      // set up a mock
      Test.setMock(HttpCalloutMock.class, new GetWorkspaceByIdMocker());

      System.RunAs(u1) {
        Integer result = helplightning.HLSessionController.checkForDefaultWorkspace(workspaces);
        System.assertEquals(123, result);
        String token = HLTokenHelper.getToken();
      }

      System.RunAs(u2) {
        String token = HLTokenHelper.getToken();
      }

      Test.stopTest();
  }
}
