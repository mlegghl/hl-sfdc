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
    public static Integer getEnterpriseId() {
        helplightning__Help_Lightning_Config__c result = [SELECT Id, helplightning__Enterprise_Id__c
                                                          FROM helplightning__Help_Lightning_Config__c
                                                          ORDER BY Id
                                                          LIMIT 1];
        if (result == null || result.helplightning__Enterprise_Id__c == null) {
            throw new HLConfigurationException('Help Lightning Enterprise Id hasn\'t been configured.');
        }

        return (Integer)result.helplightning__Enterprise_Id__c;
    }

    /**
     * Get the partner's private key
     */
    public static String getPrivateKey() {
        helplightning__Help_Lightning_Config__c result = [SELECT Id, helplightning__Private_Key_1__c,
                                                          helplightning__Private_Key_2__c
                                                          FROM helplightning__Help_Lightning_Config__c
                                                          ORDER BY helplightning__Enterprise_Id__c
                                                          LIMIT 1];

        if (result == null ||
            result.helplightning__Private_Key_1__c == null ||
            result.helplightning__Private_Key_1__c == '' ||
            result.helplightning__Private_Key_2__c == null ||
            result.helplightning__Private_Key_2__c == '') {
            throw new HLConfigurationException('Help Lightning Parnter Key hasn\'t been configured.');
        }

        // concat the two keys together
        return result.helplightning__Private_Key_1__c + result.helplightning__Private_Key_2__c;
    }
}
