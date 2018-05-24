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
    public HLModelCallUser(String id, String name) {
        this.id = id;
        this.name = name;
    }

    public static HLModelCallUser build(Object result) {
        Map<String,Object> s = (Map<String,Object>)result;

        return new HLModelCallUser((String)s.get('id'),
                                   (String)s.get('email'));
    }

    public String id = '';
    public String name = '';
}
