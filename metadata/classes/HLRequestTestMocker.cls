/**
 * HLRequestTestMocker.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */


/**
 * This is a Mock class for
 *  our Callout tests used
 *  in the HLRequestTest
 */
@isTest
global class HLRequestTestMocker implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        URL endpoint = new URL(req.getEndpoint());

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');

        // decide what our response should be
        if (req.getMethod() == 'GET') {
            if (endpoint.getPath() == '/api/v1/get-test') {
                response.setBody(JSON.serialize(true));
                response.setStatusCode(200);
            } else if (endpoint.getPath() == '/api/v1/get-test-failure') {
                response.setStatusCode(500);
            } else if (endpoint.getPath() == '/api/v1/get-test-parameters') {
                System.assertEquals(endpoint.getQuery(), 'key1=asdf&key2=true&key3=2342&');

                Map<String,Object> body = new Map<String,Object>();
                body.put('key1', 'asdf');
                body.put('key2', true);
                body.put('key3', 2342);

                response.setBody(JSON.serialize(body));
                response.setStatusCode(200);
            }
        } else if (req.getMethod() == 'POST') {
            if (endpoint.getPath() == '/api/v1/post-test') {
                Map<String,Object> body = new Map<String,Object>();
                body.put('key1', 'asdf');
                body.put('key2', true);
                body.put('key3', 2342);
                String serialized = JSON.serialize(body);

                System.assertEquals(serialized, req.getBody());

                response.setBody(JSON.serialize(true));
                response.setStatusCode(200);
            }
        }

        return response;
    }
}
