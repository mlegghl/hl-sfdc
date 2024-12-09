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
    private static final String US_API_KEY = '01e0bbdecb85a1f83bf6ade3624af03b';
    private static final String EU_API_KEY = 'nmp2ovlzdnzhwej2zmvtdw4rzncwzz09';

    // Help Lightning API Endpoing
    private static final String US_API_URL = 'https://api.helplightning.net/api';
    private static final String EU_API_URL = 'https://api.eu1.helplightning.net/api';

    private static final Map<String, Map<String,String>> ENVIRONMENTS;

    private String token;
    private String route;
    private Map<String,String> environment;

    // Static initializer block to initialize the nested map
    static {
        Map<String, String> usConfig = new Map<String, String>{
                'api_key' => US_API_KEY,
                'url' => US_API_URL
                };

        Map<String, String> euConfig = new Map<String, String>{
                'api_key' => EU_API_URL,
                'url' => EU_API_URL
                };

        ENVIRONMENTS = new Map<String, Map<String, String>>{
                'US' => usConfig,
                'EU' => euConfig
                };
    }

    public HLRequest(String environment, String token, String route) {
        this.environment = ENVIRONMENTS.get(environment);
        if (this.environment == null) {
            throw new helplightning.HLRequestException('Invalid Environment selected');
        }

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
        req.setHeader('x-helplightning-api-key', this.environment.get('api_key'));
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
        return this.environment.get('url') + route;
    }
}
