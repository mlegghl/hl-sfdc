/**
 * HLConfiguration.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

public class HLConfiguration {
    /**
     * Get the enterprise id
     */
    public static String getEnterpriseId() {
        Help_Lightning_Config__c config = Help_Lightning_Config__c.getOrgDefaults();

        if (config.Enterprise_Id__c == null ||
            config.Enterprise_Id__c == '') {
            throw new HLConfigurationException('Help Lightning Enterprise Id hasn\'t been configured.');
        }

        return config.Enterprise_Id__c;
    }

    /**
     * Get the partner's private key
     */
    public static String getPrivateKey() {
        Help_Lightning_Config__c config = Help_Lightning_Config__c.getOrgDefaults();

        if (config.Private_Key_1__c == null ||
            config.Private_Key_1__c == '' ||
            config.Private_Key_2__c == null ||
            config.Private_Key_2__c == '' ||
            config.Private_Key_3__c == null ||
            config.Private_Key_3__c == '' ||
            config.Private_Key_4__c == null ||
            config.Private_Key_4__c == '') {
            throw new HLConfigurationException('Help Lightning Partner Key hasn\'t been configured.');
        }

        return config.Private_Key_1__c + config.Private_Key_2__c +
            config.Private_Key_3__c + config.Private_Key_4__c;
    }

}