/* -*- Mode: java; -*- */

/**
 * HLUserConfigurationControllerTest.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
private class HLUserConfigurationControllerTest {
    @isTest
    static void testController() {
        // create a non admin user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standard', Email='test-user@helplightning.com',
                           EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Chicago', UserName='test-user@helplightning.com');
        insert u;
        // assign them to the HelpLightning permission set!
        PermissionSet permissionSet = [SELECT id, Name from PermissionSet WHERE Name='HelpLightning'];
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = permissionSet.Id);
        insert psa;

        System.runAs(u) {

            helplightning.HLUserConfigurationController c = new helplightning.HLUserConfigurationController();
            Map<String,String> config = c.config;

            System.assert(config.containsKey('login'), 'Missing key login');

            config.put('login', 'controllertest@helplightning.com');

            c.save();

            c = new helplightning.HLUserConfigurationController();
            config = c.config;

            System.assertEquals('controllertest@helplightning.com', config.get('login'));
        }
    }
}
