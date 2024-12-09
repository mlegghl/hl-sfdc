/* -*- Mode: java; -*- */

/**
 * HLMeetingRoomAuth.cls
 *
 * Copyright (c) 2018 HelpLightning Inc.
 * https://helplightning.com
 */
public class HLMeetingRoomAuth {
    /**
     * This is a model that represents everything you need to connect to your own meeting room
     */
    public HLMeetingRoomAuth(String webUrl,
                             String userToken, String username,
                             String userDisplayName, String sessionId) {
        this.webUrl = webUrl;
        this.userToken = userToken;
        this.username = username;
        this.userDisplayName = userDisplayName;
        this.sessionId = sessionId;
    }

    public Map<String,Object> serialize() {
        return new Map<String,Object> {
            'webUrl' => webUrl,
            'token' => userToken,
            'name' => userDisplayName,
            'username' => username,
            'sessionId' => sessionId
        };
    }

    private String webUrl;
    private String userToken;
    private string username;
    private String userDisplayName;
    private String sessionId;
}
