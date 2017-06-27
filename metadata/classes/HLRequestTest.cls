/**
 * HLRequestTest.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
private class HLRequestTest {
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
