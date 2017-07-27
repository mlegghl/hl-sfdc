/* -*- Mode: java; -*- */

/**
 * HLUserConfigurationController.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

public with sharing class HLUserConfigurationController {
    public Map<String,String> config { get; set; }

    public HLUserConfigurationController() {
        config = new Map<String,String>();

        // get the user settings
        String login = helplightning.HLUserHelper.getLogin();
        config.put('login', login);
    }

    public PageReference save() {
        if (config.get('login') != '') {
            helplightning.HLConfiguration.setLoginOverride(config.get('login'));
        }

        // add a success message
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,
                                                   'Configuration Saved!'));

        return null;
    }
}
