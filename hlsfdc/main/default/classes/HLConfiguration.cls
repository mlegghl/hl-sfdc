/* -*- Mode: java; -*- */

/**
 * HLConfiguration.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

public with sharing class HLConfiguration {
    /**
     * Get the enterprise id
     */
    public static String getEnterpriseId() {
        helplightning__Help_Lightning_Config__c config = helplightning__Help_Lightning_Config__c.getOrgDefaults();

        if (config.helplightning__Enterprise_Id__c == null ||
            config.helplightning__Enterprise_Id__c == '') {
            throw new helplightning.HLConfigurationException('Help Lightning Enterprise Id hasn\'t been configured.');
        }

        return config.helplightning__Enterprise_Id__c;
    }

    /**
     * Get the partner's private key
     */
    public static String getPrivateKey() {
        helplightning__Help_Lightning_Config__c config = helplightning__Help_Lightning_Config__c.getOrgDefaults();

        if (config.helplightning__Private_Key_1__c == null ||
            config.helplightning__Private_Key_1__c == '' ||
            config.helplightning__Private_Key_2__c == null ||
            config.helplightning__Private_Key_2__c == '' ||
            config.helplightning__Private_Key_3__c == null ||
            config.helplightning__Private_Key_3__c == '' ||
            config.helplightning__Private_Key_4__c == null ||
            config.helplightning__Private_Key_4__c == '') {
            throw new helplightning.HLConfigurationException('Help Lightning Partner Key hasn\'t been configured.');
        }

        return config.helplightning__Private_Key_1__c + config.helplightning__Private_Key_2__c +
            config.helplightning__Private_Key_3__c + config.helplightning__Private_Key_4__c;
    }

    /**
     * Get the Help Lightning Login.
     * This can be overridden by each user.
     *
     * This will be NULL if the user has not
     *  set one.
     */
    public static Object getLoginOverride() {
        // Get the user's instance
        helplightning__Help_Lightning_Config__c config = helplightning__Help_Lightning_Config__c.getInstance();

        return config.helplightning__Login__c;
    }

    /**
     * Set a login override for
     *  this specific user.
     */
    public static void setLoginOverride(String login) {
        helplightning__Help_Lightning_Config__c config = helplightning__Help_Lightning_Config__c.getInstance();
        config.helplightning__Login__c = login;

        // any user can override their instance of the custom settings
        //  and set their Help Lightning login value.
        upsert config;
    }
}
