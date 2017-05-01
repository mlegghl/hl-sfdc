public with sharing class HLSessionController {

    /**
     * Look up all the calls associated with
     *  a case in Salesforce
     */
    @AuraEnabled
    public static List<HLCall__c> getCalls(Id caseId) {
        return [ SELECT Id, Session_Id__c, HLCall_Id__c,
                 Complete__c, Successful__c,
                 Start_Time__c, Duration__c from HLCall__c
                 WHERE Case__c = :caseId
                 ORDER BY Start_Time__c DESC
                 ];
    }

    @AuraEnabled
    public static HLCall__c saveCall(HLCall__c call) {
        upsert call;

        return [ SELECT Id, Session_Id__c, HLCall_Id__c,
                 Complete__c, Successful__c,
                 Start_Time__c, Duration__c from HLCall__c
                 WHERE  Id = :call.id
                 ];
    }

    /**
     * update all the incomplete calls
     * related to a specific case
     */
    @AuraEnabled
    public static List<HLCall__c> updateCalls(Id caseId) {
        HLCall__c[] calls = [SELECT Id, Session_Id__c, HLCall_Id__c, Contact_Email__c,
                             Start_Time__c from HLCall__c WHERE Case__c = :caseId
                             AND Complete__c = false];


        for (HLCall__c call : calls) {
            System.debug('getting Info about call ' + call);
            Object results = makeRequest('/enterprise/sessions/' + call.Session_Id__c,
                                         'GET', new Map<String,String>());

            // try to find a match based on a fuzzy start time
            System.debug('result of /sessions/calls/ ' + results);

            if (results != null) {
                // results is a list of calls, try to make matches
                if (findCallMatchAndUpdate(call, (Object[])results)) {
                    // a match was found, we need to update the
                    //  database with the changes.
                    update call;
                }
            }

        }

        // return a fresh list of all calls
        return getCalls(caseId);
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

    public static Object makeRequest(String route, String method, Map<String, String> params) {
        final String apiKey = '689bda5bfbd85f10941e2af10a6b353d';
        final String baseUrl = 'https://api-dev.helplightning.net:8080/api/v1';

        String token = makeToken();
        String url = baseUrl + route;

        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setHeader('content-type', 'application/json');
        req.setHeader('Authorization', token);
        req.setHeader('x-helplightning-api-key', apiKey);
        req.setEndPoint(url);

        if (method.equals('POST')) {
            String body = JSON.serialize(params);
            req.setBody(body);
        }

        Http http = new Http();
        HttpResponse response = http.send(req);
        if (response.getStatusCode() == 200) {
            Object results = JSON.deserializeUntyped(response.getBody());
            System.debug('results=' + results);
            return results;
        } else {
            System.debug('error with request');
            return null;
        }
    }

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

    /**
     * Look through all the hlCalls
     *  and see if we have a match,
     *  if so, update the relevant
     *  information in the call object.
     *
     * @return true if this found a match
     *  and updated the parameters.
     * THIS DOES NOT DO A DATABASE UPDATE!
     */
    public static Boolean findCallMatchAndUpdate(HLCall__c call, Object[] hlCalls) {
        System.debug('findCallMatchAndUpdate');

        // If we don't have an HLCall_Id, then we need to
        //  search through the list and try to find a call
        //  that was started at close to the same time
        //  as our call record. This is a little fuzzy
        //  and it just uses the closest match, not necessarily
        //  the best call.
        if (call.HLCall_id__c == null || call.HLCall_Id__c.equals('')) {
            // we haven't found a matching help lightning call
            //  see if any of these are close based on time
            Map<String,Object> closestObject = null;
            Long closestTime = -1;

            for (Object c: hlCalls) {
                Map<String,Object> cc = (Map<String,Object>)c;
                System.debug('checking call ' + cc);

                String dialer = (String)((Map<String,Object>)cc.get('dialer')).get('email');
                String receiver = (String)((Map<String,Object>)cc.get('receiver')).get('email');

                // first make sure the receiver of this call
                //  matches the reciever of our desired call
                if (Userinfo.getUserEmail().equals(dialer)) {
                    System.debug('we are the dialer');
                    if (!call.Contact_Email__c.equals(receiver)) {
                        System.debug('found a call with a mismatching receiver: ' + receiver);
                        continue;
                    }
                } else if (Userinfo.getUserEmail().equals(receiver)) {
                    System.debug('we are the receiver');
                    if (!call.Contact_Email__c.equals(dialer)) {
                        System.debug('found a call with a mismatching dialer: ' + dialer);
                        continue;
                    }
                } else {
                    System.debug('found a call where we aren\'t the dialer or receiver');
                    continue;
                }

                // We parse the time by deserialize the time as a json string :-\
                DateTime d = (DateTime)JSON.deserialize('"' + cc.get('start_time') + '"', DateTime.class);
                System.debug('start_time=' + d);

                // find the difference in time
                Long timeDifference = Math.abs(call.Start_Time__c.getTime() - d.getTime());
                if (closestTime == -1 || timeDifference < closestTime) {
                    closestTime = timeDifference;
                    closestObject = cc;
                }
            }

            System.debug('closestTime=' + closestTime);
            System.debug('closestObject=' + closestObject);

            // if our closest match is within 90 seconds, we'll consider this good
            if (closestTime == -1) {
                // no match, if it has been more than 3 minutes
                //  consider this a failure
                DateTime now = DateTime.now();
                if (now.getTime() - call.Start_Time__c.getTime() > 180000) {
                    System.debug('couldn\'t find a match after 3 minutes, assuming a failure');
                    call.Complete__c = true;
                    call.Successful__c = false;
                    call.Duration__c = 0;
                    call.End_Time__c = call.Start_Time__c;
                    return true;
                }
            } else if (closestTime < 90000) {
                System.debug('found a match!');

                // update everything we can
                call.HLCall_id__c = (String)closestObject.get('call_id');

                if (closestObject.get('end_time') != null && !closestObject.get('end_time').equals('')) {
                    System.debug('setting call as complete');
                    DateTime endTime = (DateTime)JSON.deserialize('"' + closestObject.get('end_time') + '"', DateTime.class);

                    call.Complete__c = true;
                    call.Successful__c = (Boolean)closestObject.get('successful');
                    call.Duration__c = (Decimal)closestObject.get('duration');
                    call.End_time__c = endTime;
                } else {
                    // The call is still pending.
                    //  we have match the call_id, so
                    //  future updates will be simpler.

                    System.debug('call is still pending');
                }
                return true;
            } else {
                // we didn't find a good match, but
                //  we haven't hit our upper limit yet
                // we'll try again later.
                return false;
            }
        } else {
            // we have a known call id, just find
            //  the correct call then

            for (Object c: hlCalls) {
                Map<String,Object> cc = (Map<String,Object>)c;
                String callId = (String)cc.get('call_id');

                if (call.HLCall_Id__c.equals(callId)) {
                    // do an update
                    if (cc.get('end_time') != null && !cc.get('end_time').equals('')) {
                        System.debug('setting call as complete');
                        DateTime endTime = (DateTime)JSON.deserialize('"' + cc.get('end_time') + '"', DateTime.class);

                        call.Complete__c = true;
                        call.Successful__c = (Boolean)cc.get('successful');
                        call.Duration__c = (Decimal)cc.get('duration');
                        call.End_time__c = endTime;
                    } else {
                        System.debug('call is still pending');
                    }

                    // stop execution
                    return true;
                }
            }
        }

        return false;
    }
}
