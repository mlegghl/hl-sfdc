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
        helplightning__Help_Lightning_Config__c[] results = [SELECT Id, helplightning__Enterprise_Id__c
                                                             FROM helplightning__Help_Lightning_Config__c
                                                             ORDER BY Id
                                                             LIMIT 1];
        if (results == null || results.size() == 0 ||
            results.get(0).helplightning__Enterprise_Id__c == null ||
            results.get(0).helplightning__Enterprise_Id__c == '') {
            throw new HLConfigurationException('Help Lightning Enterprise Id hasn\'t been configured.');
        }

        return results.get(0).helplightning__Enterprise_Id__c;
    }

    /**
     * Get the partner's private key
     */
    public static String getPrivateKey() {
        helplightning__Help_Lightning_Config__c[] results = [SELECT Id, helplightning__Private_Key_1__c,
                                                             helplightning__Private_Key_2__c
                                                             FROM helplightning__Help_Lightning_Config__c
                                                             ORDER BY helplightning__Enterprise_Id__c
                                                             LIMIT 1];

        if (results == null || results.size() == 0 ||
            results.get(0).helplightning__Private_Key_1__c == null ||
            results.get(0).helplightning__Private_Key_1__c == '' ||
            results.get(0).helplightning__Private_Key_2__c == null ||
            results.get(0).helplightning__Private_Key_2__c == '') {
            throw new HLConfigurationException('Help Lightning Partner Key hasn\'t been configured.');
        }

        // concat the two keys together
        return results.get(0).helplightning__Private_Key_1__c + results.get(0).helplightning__Private_Key_2__c;
    }
}
