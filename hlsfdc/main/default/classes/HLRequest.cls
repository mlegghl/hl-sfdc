/* -*- Mode: java; -*- */

/**
 * HLRequest.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

public class HLRequest {
    // This is the API Key for the SalesForce Integration App developed
    //  by Help Lightning.
    private static final String API_KEY = '01e0bbdecb85a1f83bf6ade3624af03b';

    // Help Lightning API Endpoing
    private static final String API_URL = 'https://api.helplightning.net/api';

    private String token;
    private String route;

    public HLRequest(String token, String route) {
        this.token = token;
        this.route = route;
    }

    public Object post(Map<String,Object> params) {
        HttpRequest req = createRequest('POST', this.route);

        // serialize the params
        String body = JSON.serialize(params);
        req.setBody(body);

        return sendRequest(req);
    }

    public Object get() {
        return get(new Map<String,String>());
    }

    public Object get(Map<String,String> params) {
        // encode our parameters
        String paramStr = '';
        String sep = '?';
        for (String k : params.keySet()) {
            // encode the parameter
            String v = EncodingUtil.urlEncode(params.get(k), 'UTF-8');

            paramStr = paramStr + sep + k + '=' + v;

            // change the separator to &
            sep = '&';
        }
        String route = this.route + paramStr;

        HttpRequest req = createRequest('GET', route);

        return sendRequest(req);
    }

    private HttpRequest createRequest(String method, String route) {
        HttpRequest req = new HttpRequest();

        req.setMethod(method);
        req.setHeader('content-type', 'application/json');
        req.setHeader('Authorization', this.token);
        req.setHeader('x-helplightning-api-key', HLRequest.API_KEY);
        req.setEndPoint(buildUrl(route));

        return req;
    }

    private Object sendRequest(HttpRequest req) {
        Http http = new Http();
        HttpResponse response = http.send(req);

        if (response.getStatusCode() == 200 && response.getBody() != null) {
            return JSON.deserializeUntyped(response.getBody());
        } else {
            System.debug('Error making request: ' + response);
            return null;
        }
    }

    private String buildUrl(String route) {
        return HLRequest.API_URL + route;
    }
}
