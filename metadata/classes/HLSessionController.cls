public with sharing class HLSessionController {

    /**
     * Look up all the calls associated with
     *  a case in Salesforce
     */
    @AuraEnabled
    public static List<HLCall__c> getCalls(Id caseId) {
        return [ SELECT Id, Session_Id__c,
                 Start_Time__c from HLCall__c where Case__c = :caseId];
    }

    @AuraEnabled
    public static HLCall__c saveCall(HLCall__c call) {
        upsert call;

        return [SELECT Id, Session_Id__c,
                Start_Time__c from HLCall__c where Id = :call.id];
    }

    @AuraEnabled
    public static String makeSessionWith(String otherUsersEmail) {
        System.debug('makeSessionWith');
        
        final String apiKey = '689bda5bfbd85f10941e2af10a6b353d';
        String enterpriseToken = makeToken();
        
        final String url = 'https://api-dev.helplightning.net:8080/api/v1/enterprise/calls';
        
        System.debug('enterpriseToken=' + enterpriseToken);
        
        String myUserEmail = Userinfo.getUserEmail();
        System.debug('myUserId=' + myUserEmail);
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');
        req.setHeader('Authorization', enterpriseToken);
        req.setHeader('x-helplightning-api-key', apiKey);
        req.setEndPoint(url);
        
        Map<String, String> bodyParams = new Map<String, String>();
        bodyParams.put('dialer_email', myUserEmail);
        bodyParams.put('receiver_email', otherUsersEmail);
        String body = JSON.serialize(bodyParams);
        req.setBody(body);
        
        Http http = new Http();
        HttpResponse response = http.send(req);
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('results=' + results);
            return (String)results.get('id');
        } else {
            System.debug('error with request');
            return null;
        }
    }
    
    @AuraEnabled
    public static String makeToken() {
        // test small_admin user on docker
        final String pkcs8 = 'MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAL0EW5cFmnIXAX2FeDvHFM7/C+x10btM/+IfYKwZsWN5gdPCixZv0Zm9nxv/Ijarh6AgSNGW49TzH2owTY52qXPUuKq/QmnFovDpblPkeuKmWkybO4x6K/An4IxYHBh3hwM/YBT558PSTfBUOg3aK8wZVz4EIBqIRpIkUaF+pS+zAgMBAAECgYB3ZadNcJas9udUGNloOUtlriokBhCj1fHVLqjsTZaGFZzy3PLrC1tFWEiHcNR14Ehd18bnzf7A54qykyyKj15d3B8B8HIfV8BG0UvqRl6ySddBaS3vBH6HiqZMRM5DNsJ3E0mgtmS4z1wF29QWJ6VpLeZ95Ljf5Y6lko4YucTPAQJBAOyRg00Ww1svTiV0k2ATfzpdFffaoaFfbv1bMJOKkScEjAzBkyfiX/W5JPOFNSZCHga+yW3+1Xu7n2/L/XK3T/MCQQDMivL17HoXMcL8dF5XG28X+lLx/fY4+Sbi+Xk7vaTqo3OQKhoUYKTtiEIlanE2DIb1LLijfqeeBW5mYniselFBAkAfhgBmHFtp4jLaoN8mlVKF13Oe9H5HP61Ni4I8luFivqNe68iNLwg0eThoTt7XO0Y/BdtXkfamp0jGn/sk9zJrAkEAinR75e/+7PhoLo9u1LPjTW3K+7eXFhXBNt78K25B1fpyXWHCaYzJ12fmroEQxS9Ro2B0U2eGerbedjutx8K8gQJBANDexJydSnPxVWveNEjk1VQh8fudW+rNANHnbIq3P1yzYr3ZOTVhJ+cYzDnKCBprqJGFyx9ajxSIHVOT9aIaAKU=';
        final String enterpriseId = '12093';
        
        JWT jwt = new JWT('RS256');
        jwt.pkcs8 = pkcs8;
        jwt.iss = 'Ghazal';
        jwt.sub = 'Partner:' + enterpriseId;
        jwt.aud = 'Ghazal';
        
        String token = jwt.issue();
        
        return token;
    }
}
