/* -*- Mode: java; -*- */

/**
 * HLModelSearchUser.cls
 *
 * Copyright (c) 2018 HelpLightning Inc.
 * https://helplightning.com
 */

public class HLModelSearchUser {
    /**
     * A model representing a user as a result of a search.
     */
    public HLModelSearchUser(Integer id, String name, String username,
                             String avatarURL, String token) {
        this.id = id;
        this.name = name;
        this.username = username;
        this.avatarURL = avatarURL;
        this.token = token;
    }

    public static HLModelSearchUser build(Object result) {
        Map<String,Object> s = (Map<String,Object>)result;
        Map<String,Object> avatar = (Map<String,Object>)s.get('avatar');

        return new HLModelSearchUser((Integer)s.get('id'),
                                     (String)s.get('name'),
                                     (String)s.get('username'),
                                     (String)avatar.get('original'),
                                     (String)s.get('token'));
    }

    public static List<HLModelSearchUser> buildMany(Object resultsObject) {
        List<HLModelSearchUser> users = new List<HLModelSearchUser>();

        if (resultsObject != null && resultsObject instanceOf List<Object>) {
            List<Object> l = (List<Object>)resultsObject;

            for (Object u: (List<Object>)resultsObject) {
                users.add(HLModelSearchUser.build(u));
            }
        }

        return users;
    }

    public Integer id = 0;
    public String name = '';
    public String username = '';
    public String avatarURL = '';
    public String token = '';
}
