/* -*- Mode: java; -*- */

/**
 * JWTTest.cls
 *
 * Unit tests for the JWT class covering HS256, NONE algorithms and claims.
 */
@isTest
private class JWTTest {

    @isTest
    static void testHS256WithClaims() {
        JWT j = new JWT(JWT.HS256);
        j.iss = 'test-issuer';
        j.sub = 'test-subject';
        j.aud = 'test-audience';
        j.privateKey = EncodingUtil.base64Encode(Blob.valueOf('supersecretkey1234567890abcdef'));

        j.claims = new Map<String,String>();
        j.claims.put('custom_claim', 'custom_value');
        j.claims.put('role', 'admin');

        String token = j.issue();

        System.assertNotEquals(null, token, 'Token should not be null');
        List<String> parts = token.split('\\.');
        System.assertEquals(3, parts.size(), 'HS256 token should have 3 parts');
    }

    @isTest
    static void testNoneAlgorithm() {
        JWT j = new JWT(JWT.NONE);
        j.iss = 'test-issuer';
        j.sub = 'test-subject';
        j.aud = 'test-audience';

        String token = j.issue();

        System.assertNotEquals(null, token, 'Token should not be null');
        System.assert(token.endsWith('.'), 'NONE token should end with a dot');
    }

    @isTest
    static void testRS256WithPkcs8() {
        JWT j = new JWT(JWT.RS256);
        j.iss = 'test-issuer';
        j.sub = 'test-subject';
        j.aud = 'test-audience';
        j.validFor = 600;
        j.pkcs8 = 'MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAMZPAm05lQqKpmm0nyBhnqSq9X0e7dEZKvoGpVv6jVrULGCG+icPcdaY5DuZ6bT9PTd7kN7ftAX0aRFPB3FPvyGr96ytiDOr0k4rRckTkB5BmC1369FLieNQXqKVts9oPEaHkF0ST3UgliNZmREE4eLrhghqZcTcHBj9rprLZBx5AgMBAAECgYBBSjgJUAEC9H0vpjkRxzIdEvA6Hpm70yZ0JQYCT26ErgBiU24+t/YJ6lKSUO1CGnIyNyuORWaW405IVZWkt9W8IuSWGdDvxM85KcdX5+3UzTABUoZ8XQ0YrLfInFc8GT4bP9qfF0jf55MBYNYUHXA1GgE/R4YylQjqxHtAip5EhQJBAOZNgCpDMGErgdl/R2nYFZ6v5LZ1hNgUd2xdcZEPgbKVT3oJhea8L/UgZf/FZjT22TVaP4EfmwXRZqBnqtm1I0sCQQDcb5xg05fiq9pLt/DOZSbRwzOeZ6Ks++6v2tRnDCuR3dISW2rKDLNx4HACGGwpXFNUBhyYGn0urSB5UxMKb2DLAkEAqL4yYUT3psrtCoLSvX/hX3M7nmD/JB/i3NiexI3bFxGFuUJPBR/v96h0c/KcD8SqpAfrLd4NhTbH/lHXAktRfwJAUBKC3XE/FOmUDDku0epQZZXgpEPFBc0l8N8ulJgJI51N97kZW3etn0oFpd01PPj6k+T8cgv9OP1OdIPGwN2gbQJBAJqaappC/arTlRa1amSTnFgEubLcFvDgA6LuxLsdVBCXD4QqUx81fIUMXlw4UiXmlg8ZoFvTtJa+NKJROM1JMl4=';

        String token = j.issue();

        System.assertNotEquals(null, token, 'Token should not be null');
        List<String> parts = token.split('\\.');
        System.assertEquals(3, parts.size(), 'RS256 token should have 3 parts');
    }

    @isTest
    static void testAutoProperties() {
        JWT j = new JWT(JWT.HS256);
        j.exp = '12345';
        j.iat = '67890';

        System.assertEquals('12345', j.exp);
        System.assertEquals('67890', j.iat);
        System.assertEquals(JWT.HS256, j.alg);
        System.assertEquals(300, j.validFor);
    }
}
