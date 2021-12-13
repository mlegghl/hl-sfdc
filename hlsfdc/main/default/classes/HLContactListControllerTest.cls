/* -*- Mode: java; -*- */

/**
 * HLContactListControllerTest.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
private class HLContactListControllerTest {
    /**
     * Mocker for the isHLUser
     */
    class IsHLUserMocker implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            URL endpoint = new URL(req.getEndpoint());

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            if (req.getMethod() == 'POST' && endpoint.getPath().startsWith('/api/v1/search')) {
                Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(req.getBody());

                List<Object> result = new List<Object>();
                if (body.get('search_term') == 'support@helplightning.com') {
                    result.add(new Map<String,Object>{
                            'id' => 234,
                            'name' => 'Support',
                            'username' => 'support',
                            'active' => true,
                            'token' => 'my-token',
                            'avatar' => new Map<String,String> {
                                    'original' => '/path/to/avatar.jpg',
                                    'thumb' => '/path/to/avatar-thumb.jpg'
                            }
                        });
                }

                response.setStatusCode(200);
                response.setBody(JSON.serialize(result));
            } else {
                response.setStatusCode(500);
            }
            return response;
        }
    }
}
