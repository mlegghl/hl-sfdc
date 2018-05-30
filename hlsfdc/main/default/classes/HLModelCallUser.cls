/* -*- Mode: java; -*- */

/**
 * HLModelCallUser.cls
 *
 * Copyright (c) 2018 HelpLightning Inc.
 * https://helplightning.com
 */

public class HLModelCallUser {
    /**
     * A Model representing a user in a call.
     */
    public HLModelCallUser(String id, String name, String email) {
        this.id = id;
        this.name = name;
        this.email = email;
    }

    public static HLModelCallUser build(Object result) {
        Map<String,Object> s = (Map<String,Object>)result;

        return new HLModelCallUser((String)s.get('id'),
                                   (String)s.get('name'),
                                   (String)s.get('email'));
    }

    public String id = '';
    public String name = '';
    public String email = '';
}
