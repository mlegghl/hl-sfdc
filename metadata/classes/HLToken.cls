/**
 * HLToken.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

public class HLToken {
    /**
     * Build a new JWT token representing
     *  our enterprise and sign it with
     *  our private key
     */
    public static String build() {
        String privateKey = HLConfiguration.getPrivateKey();
        String enterpriseId = HLConfiguration.getEnterpriseId();

        JWT jwt = new JWT('RS256');
        jwt.pkcs8 = privateKey;
        jwt.iss = 'Ghazal';
        jwt.sub = 'Partner:' + enterpriseId;
        jwt.aud = 'Ghazal';

        String token = jwt.issue();

        return token;
    }
}
