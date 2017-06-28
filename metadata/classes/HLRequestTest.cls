/**
 * HLRequestTest.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
private class HLRequestTest {
    /**
     * Mocker for the HLRequests
     */
    class HLRequestTestMocker implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
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


    @isTest
    static void testGetSuccess() {
        String token = 'fake-token';
        String route = '/get-test';

        // set up our mock
        Test.setMock(HttpCalloutMock.class, new HLRequestTestMocker());

        HLRequest request = new HLRequest(token, route);
        Object result = request.get();

        System.assertEquals(result, true);
    }

    @isTest
    static void testGetFailure() {
        String token = 'fake-token';
        String route = '/get-test-failure';

        // set up our mock
        Test.setMock(HttpCalloutMock.class, new HLRequestTestMocker());

        HLRequest request = new HLRequest(token, route);
        Object result = request.get();

        // null means failure
        System.assertEquals(result, null);
    }

    @isTest
    static void testGetWithParameters() {
        String token = 'fake-token';
        String route = '/get-test-parameters';

        // set up our mock
        Test.setMock(HttpCalloutMock.class, new HLRequestTestMocker());

        Map<String,Object> params = new Map<String,Object>();
        params.put('key1', 'asdf');
        params.put('key2', true);
        params.put('key3', 2342);

        HLRequest request = new HLRequest(token, route);
        Object result = request.get(params);

        // The result should be the same map
        //  of parameters.
        System.assertEquals(result, params);
    }

    @isTest
    static void testPostSuccess() {
        String token = 'fake-token';
        String route = '/post-test';

        // set up our mock
        Test.setMock(HttpCalloutMock.class, new HLRequestTestMocker());

        Map<String,Object> params = new Map<String,Object>();
        params.put('key1', 'asdf');
        params.put('key2', true);
        params.put('key3', 2342);

        HLRequest request = new HLRequest(token, route);
        Object result = request.post(params);

        // The result should be the same map
        //  of parameters.
        System.assertEquals(result, true);
    }
}
