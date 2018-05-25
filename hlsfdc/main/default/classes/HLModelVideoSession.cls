/* -*- Mode: java; -*- */

/**
 * HLModelVideoSession.cls
 *
 * Copyright (c) 2018 HelpLightning Inc.
 * https://helplightning.com
 */

public class HLModelVideoSession {
    /**
     * This is the model that represents
     *  a Help Lightning Video Session object.
     *  which includes everything needed to
     *  connect to Gss.
     */
    public HLModelVideoSession(String token, String serverURL, String serverWSURL) {
        this.token = token;
        this.serverURL = serverURL;
        this.serverWSURL = serverWSURL;
    }

    /**
     * Build a new model from a JSON
     *  response object
     */
    public static HLModelVideoSession build(Object sessionObject) {
        if (sessionObject == null)
            return null;

        Map<String, Object> s = (Map<String, Object>)sessionObject;
        Map<String, Object> gss = (Map<String, Object>)s.get('gss_info');

        return new HLModelVideoSession((String)gss.get('token'),
                                       (String)gss.get('server'),
                                       (String)gss.get('wsserver'));
    }

    public Map<String,Object> serialize() {
        return new Map<String,Object>{
            'gss_info' => new Map<String,String>{
                    'token' => token,
                    'serverURL' => serverURL,
                    'serverWSURL' => serverWSURL
                }
        };
    }

    public String token = '';
    public String serverURL = '';
    public String serverWSURL = '';
}
