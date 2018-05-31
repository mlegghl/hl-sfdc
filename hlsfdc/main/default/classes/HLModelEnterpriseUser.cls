/* -*- Mode: java; -*- */

/**
 * HLModelEnterpriseUser.cls
 *
 * Copyright (c) 2018 HelpLightning Inc.
 * https://helplightning.com
 */

public class HLModelEnterpriseUser {
    /**
     * This is the model that represents
     *  a Help Lightning Enterprise User object.
     */
    public HLModelEnterpriseUser(Integer id, String name, String username,
                                 String email, Boolean available, Integer status,
                                 String avatarURL, String authToken) {
        this.id = id;
        this.name = name;
        this.username = username;
        this.email = email;
        this.available = available;
        this.status = status;
        this.avatarURL = avatarURL;
        this.authToken = authToken;
    }

    /**
     * Build a new model from a JSON
     *  response object
     */
    public static HLModelEnterpriseUser build(Object userObject) {
        Map<String, Object> u = (Map<String, Object>)userObject;
        Map<String,Object> avatar = (Map<String,Object>)u.get('avatar');

        return new HLModelEnterpriseUser((Integer)u.get('id'),
                                         (String)u.get('name'),
                                         (String)u.get('username'),
                                         (String)u.get('email'),
                                         (Boolean)u.get('available'),
                                         (Integer)u.get('status'),
                                         (String)avatar.get('original'),
                                         (String)u.get('token'));
    }
    /**
     * Build many users from a JSON
     *  response object
     */
    public static List<HLModelEnterpriseUser> buildMany(Object resultsObject) {
        List<HLModelEnterpriseUser> users = new List<HLModelEnterpriseUser>();

        if (resultsObject != null) {
            Map<String, Object> r = (Map<String, Object>)resultsObject;
            // get the entries
            List<Object> entries = (List<Object>)r.get('entries');

            // iterate through the entries, building models
            for (Object u: entries) {
                users.add(HLModelEnterpriseUser.build(u));
            }
        }

        return users;
    }

    public Map<String, Object> serialize() {
        Map<String, Object> m = new Map<String, Object>();
        m.put('id', this.id);
        m.put('username', this.username);
        m.put('name', this.name);
        m.put('email', this.email);
        m.put('available', this.available);
        m.put('status', this.status);
        m.put('avatarURL', this.avatarURL);
        m.put('authToken', this.authToken);

        return m;
    }

    public Integer id = 0;
    public String username = '';
    public String name = '';
    public String email = '';
    public Boolean available = true;
    public Integer status = 0;
    public String avatarURL = '';
    public String authToken = '';
}
