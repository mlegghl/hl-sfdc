/* -*- Mode: java; -*- */

/**
 * HLConfigurationController.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

public with sharing class HLConfigurationController {

    public Map<String,String> config { get; set; }

    public HLConfigurationController() {
        config = new Map<String,String>();

        // get the ORG defaults
        helplightning.Help_Lightning_Config__c hlConfig = helplightning.Help_Lightning_Config__c.getOrgDefaults();

        String enterpriseId = '';
        if (hlConfig.helplightning__Enterprise_Id__c != null)
            enterpriseId = hlConfig.helplightning__Enterprise_Id__c;

        String privateKey = '';
        if (hlConfig.helplightning__Private_Key_1__c != null &&
            hlConfig.helplightning__Private_Key_2__c != null &&
            hlConfig.helplightning__Private_Key_3__c != null &&
            hlConfig.helplightning__Private_Key_4__c != null) {

            privateKey = hlConfig.helplightning__Private_Key_1__c + hlConfig.helplightning__Private_Key_2__c +
                hlConfig.helplightning__Private_Key_3__c + hlConfig.helplightning__Private_Key_4__c;
        }

        config.put('enterpriseId', enterpriseId);
        config.put('privateKey', privateKey);
    }

    public PageReference save() {
        // get the ORG defaults
        helplightning.Help_Lightning_Config__c hlConfig = helplightning.Help_Lightning_Config__c.getOrgDefaults();

        if (config.get('enterpriseId') != '') {
            hlConfig.helplightning__Enterprise_Id__c = config.get('enterpriseId');
        }

        if (config.get('privateKey') != '') {
            String privateKey = config.get('privateKey');

            // split into chunks each 255 characters long
            hlConfig.helplightning__Private_Key_1__c = privateKey.mid(0, 255);

            if (privateKey.length() > 255) {
                hlConfig.helplightning__Private_Key_2__c = privateKey.mid(255, 255);
            }
            if (privateKey.length() > 510) {
                hlConfig.helplightning__Private_Key_3__c = privateKey.mid(510, 255);
            }
            if (privateKey.length() > 765) {
                hlConfig.helplightning__Private_Key_4__c = privateKey.mid(765, 255);
            }
        }

        // save
        upsert hlConfig helplightning.Help_Lightning_Config__c.Id;

        // add a success message
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,
                                                   'Configuration Saved!'));

        return null;
    }
}
