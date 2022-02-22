/* -*- Mode: java; -*- */

/**
 * HLModelSessionAuth.cls
 *
 * Copyright (c) 2018 HelpLightning Inc.
 * https://helplightning.com
 */
public class HLModelSessionAuth {
    /**
     * This is a model that represents
     *  a SessionAuth which we will
     *  give back to clients to join
     *  into a GSS Session
     */
    public HLModelSessionAuth(String userToken, String sessionId,
                              String userDisplayName,
                              String username,
                              helplightning.HLModelVideoSession sessionAuth) {
        this.userToken = userToken;
        this.sessionId = sessionId;
        this.userDisplayName = userDisplayName;
        this.username = username;
        this.sessionAuth = sessionAuth;
    }

    public Map<String,Object> serialize() {
        return new Map<String,Object> {
            'token' => userToken,
            'sessionId' => sessionId,
            'displayName' => userDisplayName,
            'username' => username,
            'gssInfo' => sessionAuth.serialize()
        };
    }

    private String userToken;
    private string sessionId;
    private String userDisplayName;
    private String username;
    private helplightning.HLModelVideoSession sessionAuth;
}
