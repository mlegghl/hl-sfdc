/* -*- Mode: java; -*- */

/**
 * HLConfigurationControllerTest.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
private class HLConfigurationControllerTest {
    static String privateKey = 'MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAMZPAm05lQqKpmm0nyBhnqSq9X0e7dEZKvoGpVv6jVrULGCG+icPcdaY5DuZ6bT9PTd7kN7ftAX0aRFPB3FPvyGr96ytiDOr0k4rRckTkB5BmC1369FLieNQXqKVts9oPEaHkF0ST3UgliNZmREE4eLrhghqZcTcHBj9rprLZBx5AgMBAAECgYBBSjgJUAEC9H0vpjkRxzIdEvA6Hpm70yZ0JQYCT26ErgBiU24+t/YJ6lKSUO1CGnIyNyuORWaW405IVZWkt9W8IuSWGdDvxM85KcdX5+3UzTABUoZ8XQ0YrLfInFc8GT4bP9qfF0jf55MBYNYUHXA1GgE/R4YylQjqxHtAip5EhQJBAOZNgCpDMGErgdl/R2nYFZ6v5LZ1hNgUd2xdcZEPgbKVT3oJhea8L/UgZf/FZjT22TVaP4EfmwXRZqBnqtm1I0sCQQDcb5xg05fiq9pLt/DOZSbRwzOeZ6Ks++6v2tRnDCuR3dISW2rKDLNx4HACGGwpXFNUBhyYGn0urSB5UxMKb2DLAkEAqL4yYUT3psrtCoLSvX/hX3M7nmD/JB/i3NiexI3bFxGFuUJPBR/v96h0c/KcD8SqpAfrLd4NhTbH/lHXAktRfwJAUBKC3XE/FOmUDDku0epQZZXgpEPFBc0l8N8ulJgJI51N97kZW3etn0oFpd01PPj6k+T8cgv9OP1OdIPGwN2gbQJBAJqaappC/arTlRa1amSTnFgEubLcFvDgA6LuxLsdVBCXD4QqUx81fIUMXlw4UiXmlg8ZoFvTtJa+NKJROM1JMl4=';

    @isTest
    static void testController() {
        helplightning.HLConfigurationController c = new helplightning.HLConfigurationController();
        Map<String,String> config = c.config;

        System.assert(config.containsKey('enterpriseId'), 'Missing key enterprise_id');
        System.assert(config.containsKey('privateKey'), 'Missing key privateKey');

        config.put('enterpriseId', '1');
        config.put('privateKey', HLConfigurationControllerTest.privateKey);

        System.assertEquals('US', c.environment);

        c.save();

        c = new helplightning.HLConfigurationController();
        config = c.config;

        System.assertEquals('1', config.get('enterpriseId'));
        System.assertEquals(HLConfigurationControllerTest.privateKey, config.get('privateKey'));
    }

    @isTest
    static void testControllerInsufficientPermission() {
        // create a very limited user
        Profile p = [SELECT Id FROM Profile WHERE Name='Chatter Free User'];
        User u = new User(Alias = 'chatter', Email='chatter-free-record@helplightning.com',
                           EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Chicago', UserName='chatter-free-record@helplightning.com');
        insert u;

        helplightning.HLConfigurationController c = new helplightning.HLConfigurationController();
        Map<String,String> config = c.config;

        System.assert(config.containsKey('enterpriseId'), 'Missing key enterprise_id');
        System.assert(config.containsKey('privateKey'), 'Missing key privateKey');

        config.put('enterpriseId', '1');
        config.put('privateKey', HLConfigurationControllerTest.privateKey);

        // try this with a limted permission
        System.RunAs(u) {
            c.save();
        }

        c = new helplightning.HLConfigurationController();
        config = c.config;

        System.assertEquals('', config.get('enterpriseId'));
        System.assertEquals('', config.get('privateKey'));

    }

    @isTest
    static void testControllerInvalidEnvironment() {
        helplightning.HLConfigurationController c = new helplightning.HLConfigurationController();

        // set an invalid environment
        c.environment = 'Invalid Environment';

        // nothing should happen
        c.save();

        c = new helplightning.HLConfigurationController();
        System.assertEquals('US', c.environment);
    }
}
