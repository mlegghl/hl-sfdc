/* -*- Mode: java; -*- */

/**
 * HLModelSessionUser.cls
 *
 * Copyright (c) 2018 HelpLightning Inc.
 * https://helplightning.com
 */

public class HLModelSessionUser {
    /**
     * This is the model that represents
     *  a Help Lightning User in a Session object.
     */
    public HLModelSessionUser(String id, String name, String token,
                              String username, String avatarURL) {
        this.id = id;
        this.name = name;
        this.token = token;
        this.username = username;
        this.avatarURL = avatarURL;
    }

    public static HLModelSessionUser build(Object resultsObject) {
        Map<String,Object> s = (Map<String,Object>)resultsObject;

        Map<String,Object> avatar = (Map<String,Object>)s.get('avatar');

        String id = (String)s.get('id');
        String name = (String)s.get('name');
        String token = (String)s.get('token');
        String username = (String)s.get('username');
        String avatarURL = (String)avatar.get('original');

        return new HLModelSessionUser(id, name, token, username, avatarURL);
    }

    public String id = '';
    public String name = '';
    public String token = '';
    public String username = '';
    public String avatarURL = '';
}
