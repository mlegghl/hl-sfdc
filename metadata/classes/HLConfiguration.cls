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
        helplightning__Help_Lightning_Config__c config = helplightning__Help_Lightning_Config__c.getOrgDefaults();

        if (config.helplightning__Enterprise_Id__c == null ||
            config.helplightning__Enterprise_Id__c == '') {
            throw new HLConfigurationException('Help Lightning Enterprise Id hasn\'t been configured.');
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
            throw new HLConfigurationException('Help Lightning Partner Key hasn\'t been configured.');
        }

        return config.helplightning__Private_Key_1__c + config.helplightning__Private_Key_2__c +
            config.helplightning__Private_Key_3__c + config.helplightning__Private_Key_4__c;
    }

}
