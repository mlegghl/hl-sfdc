/* -*- Mode: java; -*- */

/**
 * HLModelAccount.cls
 *
 * Copyright (c) 2018 HelpLightning Inc.
 * https://helplightning.com
 */

public class HLModelAccount {
    /**
     * A model representing the account of a user.
     */
    public HLModelAccount(Integer id, String name, String username,
                          String email, String authToken, string avatarURL,
                          Boolean available, Boolean active, Integer status,
                          String personalRoomURL, String personalRoomSessionId) {
        this.id = id;
        this.name = name;
        this.username = username;
        this.email = email;

        this.authToken = authToken;

        this.avatarURL = avatarURL;

        this.available = available;
        this.active = active;
        this.status = status;

        this.personalRoomURL = personalRoomURL;
        this.personalRoomSessionId = personalRoomSessionId;
    }

    public static HLModelAccount build(String authToken, Object result) {
        if (result == null)
            return null;

        Map<String, Object> u = (Map<String,Object>)result;
        Map<String, Object> avatar = (Map<String,Object>)u.get('avatar');

        return new HLModelAccount((Integer)u.get('id'),
                                  (String)u.get('name'),
                                  (String)u.get('username'),
                                  (String)u.get('email'),
                                  authToken,
                                  (String)avatar.get('original'),
                                  (Boolean)u.get('available'),
                                  (Boolean)u.get('active'),
                                  (Integer)u.get('status'),
                                  (String)u.get('personal_room_url'),
                                  (String)u.get('personal_room_session_id'));
    }

    public Integer id = 0;
    public String name = '';
    public String username = '';
    public String email = '';

    public String authToken = '';

    public String avatarURL = '';

    public Boolean available = true;
    public Boolean active = true;
    public Integer status = 0;

    public String personalRoomURL = '';
    public String personalRoomSessionId = '';
}
