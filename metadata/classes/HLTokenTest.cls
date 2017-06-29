/**
 * HLTokenTest.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
private class HLTokenTest {
    @isTest
    static void testTokenBuild() {
        String token = HLToken.build();

        // Pattern should be x+.x+.x+
        //  where x is a base64 character
        String b64 = '[A-Za-z0-9\\+\\/_=-]';
        String pattern = '^' + b64 + '+\\.' + b64 + '+\\.' + b64 + '+$';
        Boolean match = System.Pattern.matches(pattern, token);

        System.assertEquals(match, true);
    }
}
