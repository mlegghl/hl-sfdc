/**
 * HLRequest.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

public class HLRequest {
    private static final String API_KEY = '689bda5bfbd85f10941e2af10a6b353d';
    private static final String API_URL = 'http://307da411.ngrok.io/api/v1';

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
        return get(new Map<String,Object>());
    }

    public Object get(Map<String,Object> params) {
        // encode our parameters
        String paramStr = '?';
        for (String k : params.keySet()) {
            Object v = params.get(k);

            paramStr = paramStr + k + '=' + v + '&';
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
