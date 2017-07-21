public with sharing class HLConfigurationController {

    public Map<String,String> config { get; set; }

    public HLConfigurationController() {
        config = new Map<String,String>();

        // get the ORG defaults
        Help_Lightning_Config__c hlConfig = Help_Lightning_Config__c.getOrgDefaults();

        String enterpriseId = '';
        if (hlConfig.Enterprise_Id__c != null)
            enterpriseId = hlConfig.Enterprise_Id__c;

        String privateKey = '';
        if (hlConfig.Private_Key_1__c != null &&
            hlConfig.Private_Key_2__c != null &&
            hlConfig.Private_Key_3__c != null &&
            hlConfig.Private_Key_4__c != null) {

            privateKey = hlConfig.Private_Key_1__c + hlConfig.Private_Key_2__c +
                hlConfig.Private_Key_3__c + hlConfig.Private_Key_4__c;
        }

        config.put('enterpriseId', enterpriseId);
        config.put('privateKey', privateKey);

        // config.put('enterpriseId', '108800aa');
        // config.put('privateKey', 'asdfasdfasdfasdfasdfasdf');
    }

    public PageReference save() {
        return null;
    }
}
