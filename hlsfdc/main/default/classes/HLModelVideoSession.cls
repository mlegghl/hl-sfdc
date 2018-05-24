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
        Map<String, Map<String,String>> s = (Map<String, Map<String,String>>)sessionObject;
        Map<String,String> gss = s.get('gss_info');

        return new HLModelVideoSession(gss.get('token'),
                                       gss.get('server'),
                                       gss.get('wsserver'));
    }

    public String token = '';
    public String serverURL = '';
    public String serverWSURL = '';
}
