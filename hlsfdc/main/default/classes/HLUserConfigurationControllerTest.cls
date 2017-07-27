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
