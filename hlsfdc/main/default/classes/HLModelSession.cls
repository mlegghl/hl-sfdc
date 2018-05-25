/* -*- Mode: java; -*- */

/**
 * HLModelSession.cls
 *
 * Copyright (c) 2018 HelpLightning Inc.
 * https://helplightning.com
 */

public class HLModelSession {
    /**
     * This is the model that represents
     *  a Help Lightning Session object.
     */
    public HLModelSession(String id, String token, Boolean videoActive,
                          List<helplightning.HLModelSessionUser> users) {
        this.id = id;
        this.token = token;
        this.videoActive = videoActive;
        this.users = users;
    }

    /**
     * Build a new model from a JSON
     *  response object
     */
    public static HLModelSession build(Object sessionObject) {
        if (sessionObject == null)
            return null;

        Map<String,Object> s = (Map<String,Object>)sessionObject;

        String id = (String)s.get('id');
        String token = (String)s.get('token');
        Boolean videoActive = (Boolean)s.get('video_active');
        List<helplightning.HLModelSessionUser> users = new List<helplightning.HLModelSessionUser>();

        for (Object u: (List<Object>)s.get('users')) {
            users.add(helplightning.HLModelSessionUser.build(u));
        }

        return new HLModelSession(id, token, videoActive, users);
    }

    public String id = '';
    public String token = '';
    public Boolean videoActive = false;
    public List<helplightning.HLModelSessionUser> users = new List<helplightning.HLModelSessionUser>();
}
