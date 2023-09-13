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
     * Get the workspace id
     */
    public static String getWorkspaceId() {
      helplightning__Help_Lightning_Config__c config = helplightning__Help_Lightning_Config__c.getInstance();
      return config.helplightning__Workspace_Id__c;
    }

    /**
     * Get the internal site key flag
     */
    public static Boolean getHasSiteKey() {
      helplightning__Help_Lightning_Config__c config = helplightning__Help_Lightning_Config__c.getInstance();
      return config.helplightning__Has_Site_Key__c;
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
     * Get whether or not we should create Calendar Events from HL Calls
     */
    public static Boolean getCreateEvents() {
        helplightning__Help_Lightning_Config__c config = helplightning__Help_Lightning_Config__c.getOrgDefaults();
        return config.helplightning__Create_Events__c;
    }

    /**
     * Get whether or not we should save attachments from HL Calls
     */
    public static Boolean getSaveAttachments() {
        helplightning__Help_Lightning_Config__c config = helplightning__Help_Lightning_Config__c.getOrgDefaults();
        return config.helplightning__Save_Attachments__c;
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
     * Set a flag to indicate that the user has a site level key.
     */
    public static void setHasSiteKey(Boolean hasSiteKey) {
        helplightning__Help_Lightning_Config__c config = helplightning__Help_Lightning_Config__c.getInstance();
        config.helplightning__Has_Site_Key__c = hasSiteKey;

        upsert config;
    }

    /**
     * Set the workspace id
     */
    public static void setWorkspaceId(String workspaceId) {
        helplightning__Help_Lightning_Config__c config = helplightning__Help_Lightning_Config__c.getInstance();
        config.helplightning__Workspace_Id__c = workspaceId;

        upsert config;
    }
}
