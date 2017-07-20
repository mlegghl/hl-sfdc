/* -*- Mode: java; -*- */

/**
 * HLConfigurationTest.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
private class HLConfigurationTest {
    static void createConfig() {
        // create a fake configuration
        Help_Lightning_Config__c config = Help_Lightning_Config__c.getOrgDefaults();
        config.Enterprise_id__c = '1';
        config.Private_Key_1__c = 'MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAMZPAm05lQqKpmm0nyBhnqSq9X0e7dEZKvoGpVv6jVrULGCG+icPcdaY5DuZ6bT9PTd7kN7ftAX0aRFPB3FPvyGr96ytiDOr0k4rRckTkB5BmC1369FLieNQXqKVts9oPEaHkF0ST3UgliNZmREE4eLrhghqZcTcHBj9rprLZBx5AgMBAAECgYBBSjgJUAEC9H0vpjkRxzIdEvA';
        config.Private_Key_2__c = '6Hpm70yZ0JQYCT26ErgBiU24+t/YJ6lKSUO1CGnIyNyuORWaW405IVZWkt9W8IuSWGdDvxM85KcdX5+3UzTABUoZ8XQ0YrLfInFc8GT4bP9qfF0jf55MBYNYUHXA1GgE/R4YylQjqxHtAip5EhQJBAOZNgCpDMGErgdl/R2nYFZ6v5LZ1hNgUd2xdcZEPgbKVT3oJhea8L/UgZf/FZjT22TVaP4EfmwXRZqBnqtm1I0sCQQDcb5xg05fiq9pLt/';
        config.Private_Key_3__c = 'DOZSbRwzOeZ6Ks++6v2tRnDCuR3dISW2rKDLNx4HACGGwpXFNUBhyYGn0urSB5UxMKb2DLAkEAqL4yYUT3psrtCoLSvX/hX3M7nmD/JB/i3NiexI3bFxGFuUJPBR/v96h0c/KcD8SqpAfrLd4NhTbH/lHXAktRfwJAUBKC3XE/FOmUDDku0epQZZXgpEPFBc0l8N8ulJgJI51N97kZW3etn0oFpd01PPj6k+T8cgv9OP1OdIPGwN2gbQJBAJqaa';
        config.Private_Key_4__c = 'ppC/arTlRa1amSTnFgEubLcFvDgA6LuxLsdVBCXD4QqUx81fIUMXlw4UiXmlg8ZoFvTtJa+NKJROM1JMl4=';
        upsert config Help_Lightning_Config__c.Id;
    }

    @isTest
    static void testMissingConfig() {
        // make sure getEnterpriseId returns a
        // HLConfigurationException if we haven't
        // set up our config.
        try {
            HLConfiguration.getEnterpriseId();
            System.assert(false, 'getEnterpriseId didn\'t raise exception');
        } catch (HLConfigurationException e) {
            // all good here
        } catch (Exception e) {
            System.assert(false, 'getEnterpriseId returned wrong exception');
        }

        // make sure getPrivateKey returns a
        // HLConfigurationException if we haven't
        // set up our config.
        try {
            HLConfiguration.getPrivateKey();
            System.assert(false, 'getPrivateKey didn\'t raise exception');
        } catch (HLConfigurationException e) {
            // all good here
        } catch (Exception e) {
            System.assert(false, 'getPrivateKey returned wrong exception');
        }
    }

    @isTest
    static void testEnterpriseId() {
        // we need a valid config first
        createConfig();

        System.assertEquals(HLConfiguration.getEnterpriseId(), '1');
    }

    @isTest
    static void testPrivateKey() {
        // we need a valid config first
        createConfig();

        String expected = 'MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAMZPAm05lQqKpmm0nyBhnqSq9X0e7dEZKvoGpVv6jVrULGCG+icPcdaY5DuZ6bT9PTd7kN7ftAX0aRFPB3FPvyGr96ytiDOr0k4rRckTkB5BmC1369FLieNQXqKVts9oPEaHkF0ST3UgliNZmREE4eLrhghqZcTcHBj9rprLZBx5AgMBAAECgYBBSjgJUAEC9H0vpjkRxzIdEvA6Hpm70yZ0JQYCT26ErgBiU24+t/YJ6lKSUO1CGnIyNyuORWaW405IVZWkt9W8IuSWGdDvxM85KcdX5+3UzTABUoZ8XQ0YrLfInFc8GT4bP9qfF0jf55MBYNYUHXA1GgE/R4YylQjqxHtAip5EhQJBAOZNgCpDMGErgdl/R2nYFZ6v5LZ1hNgUd2xdcZEPgbKVT3oJhea8L/UgZf/FZjT22TVaP4EfmwXRZqBnqtm1I0sCQQDcb5xg05fiq9pLt/DOZSbRwzOeZ6Ks++6v2tRnDCuR3dISW2rKDLNx4HACGGwpXFNUBhyYGn0urSB5UxMKb2DLAkEAqL4yYUT3psrtCoLSvX/hX3M7nmD/JB/i3NiexI3bFxGFuUJPBR/v96h0c/KcD8SqpAfrLd4NhTbH/lHXAktRfwJAUBKC3XE/FOmUDDku0epQZZXgpEPFBc0l8N8ulJgJI51N97kZW3etn0oFpd01PPj6k+T8cgv9OP1OdIPGwN2gbQJBAJqaappC/arTlRa1amSTnFgEubLcFvDgA6LuxLsdVBCXD4QqUx81fIUMXlw4UiXmlg8ZoFvTtJa+NKJROM1JMl4=';

        System.assertEquals(HLConfiguration.getPrivateKey(), expected);
    }

    @isTest
    static void testSettingLoginOverride() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u1 = new User(Alias = 'user1', Email='user1@helplightning.com',
                           EmailEncodingKey='UTF-8', LastName='User1', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Chicago', UserName='user1@helplightning.com');
        insert u1;
        User u2 = new User(Alias = 'user2', Email='user2@helplightning.com',
                           EmailEncodingKey='UTF-8', LastName='User2', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Chicago', UserName='user2@helplightning.com');
        insert u2;

        // test with an override
        System.RunAs(u1) {
            HLConfiguration.setLoginOverride('override5983@helplightning.com');
            System.assertEquals('override5983@helplightning.com', HLConfiguration.getLoginOverride());
        }

        // test without an override
        System.RunAs(u2) {
            System.assertEquals(null, HLConfiguration.getLoginOverride());
        }
    }
}
