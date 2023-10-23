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

        helplightning__Help_Lightning_Config__c hlConfig = helplightning__Help_Lightning_Config__c.getInstance();

        // get the user settings
        String login = helplightning.HLUserHelper.getLogin();

        String workspaceId = '';
        if (hlConfig.helplightning__Workspace_Id__c != null) {
          workspaceId = hlConfig.helplightning__Workspace_Id__c;
        }

        config.put('login', login);
        config.put('workspaceId', workspaceId);
    }

    public PageReference save() {
        if (config.get('login') != '') {
            helplightning.HLConfiguration.setLoginOverride(config.get('login'));
        }

        helplightning.HLConfiguration.setWorkspaceId(config.get('workspaceId'));

        // add a success message
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,
                                                   'Configuration Saved!'));

        return null;
    }
}
