/**
 * HLToken.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

public class HLToken {
    // !mwd - TODO: Don't hardcode these. They are customer
    //  specific, and need to be in an encrypted configuration
    private static final String PRIVATE_KEY = 'MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAL0EW5cFmnIXAX2FeDvHFM7/C+x10btM/+IfYKwZsWN5gdPCixZv0Zm9nxv/Ijarh6AgSNGW49TzH2owTY52qXPUuKq/QmnFovDpblPkeuKmWkybO4x6K/An4IxYHBh3hwM/YBT558PSTfBUOg3aK8wZVz4EIBqIRpIkUaF+pS+zAgMBAAECgYB3ZadNcJas9udUGNloOUtlriokBhCj1fHVLqjsTZaGFZzy3PLrC1tFWEiHcNR14Ehd18bnzf7A54qykyyKj15d3B8B8HIfV8BG0UvqRl6ySddBaS3vBH6HiqZMRM5DNsJ3E0mgtmS4z1wF29QWJ6VpLeZ95Ljf5Y6lko4YucTPAQJBAOyRg00Ww1svTiV0k2ATfzpdFffaoaFfbv1bMJOKkScEjAzBkyfiX/W5JPOFNSZCHga+yW3+1Xu7n2/L/XK3T/MCQQDMivL17HoXMcL8dF5XG28X+lLx/fY4+Sbi+Xk7vaTqo3OQKhoUYKTtiEIlanE2DIb1LLijfqeeBW5mYniselFBAkAfhgBmHFtp4jLaoN8mlVKF13Oe9H5HP61Ni4I8luFivqNe68iNLwg0eThoTt7XO0Y/BdtXkfamp0jGn/sk9zJrAkEAinR75e/+7PhoLo9u1LPjTW3K+7eXFhXBNt78K25B1fpyXWHCaYzJ12fmroEQxS9Ro2B0U2eGerbedjutx8K8gQJBANDexJydSnPxVWveNEjk1VQh8fudW+rNANHnbIq3P1yzYr3ZOTVhJ+cYzDnKCBprqJGFyx9ajxSIHVOT9aIaAKU=';
    private static final String ENTERPRISE_ID = '1055';

    /**
     * Build a new JWT token representing
     *  our enterprise and sign it with
     *  our private key
     */
    public static String build() {
        JWT jwt = new JWT('RS256');
        jwt.pkcs8 = HLToken.PRIVATE_KEY;
        jwt.iss = 'Ghazal';
        jwt.sub = 'Partner:' + HLToken.ENTERPRISE_ID;
        jwt.aud = 'Ghazal';

        String token = jwt.issue();

        return token;
    }
}
