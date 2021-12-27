/* -*- Mode: java; -*- */

/**
 * HLModelContact.cls
 *
 * Copyright (c) 2021 HelpLightning Inc.
 * https://helplightning.com
 */

public class HLModelContact {
    /**
     * A model representing a contact as a result of a search.
     */
    public HLModelContact(Integer id, String name, String username, String email,
                             String avatarURL, String token) {
        this.id = id;
        this.name = name;
        this.username = username;
        this.email = email;
        this.avatarURL = avatarURL;
        this.token = token;
    }

    public static HLModelContact build(Object result) {
        Map<String,Object> s = (Map<String,Object>)result;
        Map<String,Object> avatar = (Map<String,Object>)s.get('avatar');

        return new HLModelContact((Integer)s.get('id'),
                                     (String)s.get('name'),
                                     (String)s.get('username'),
                                     (String)s.get('email'),
                                     (String)avatar.get('url'),
                                     (String)s.get('token'));
    }

    public static List<HLModelContact> buildMany(Object resultsObject) {
        List<HLModelContact> contacts = new List<HLModelContact>();

        if (resultsObject != null) {
            Map<String, Object> r = (Map<String, Object>)resultsObject;
            // get the entries
            List<Object> entries = (List<Object>)r.get('entries');

            // iterate through the entries, building models
            for (Object u: entries) {
                contacts.add(HLModelContact.build(u));
            }
        }

        return contacts;
    }

    public Map<String, Object> serialize() {
        Map<String, Object> m = new Map<String, Object>();
        m.put('id', this.id);
        m.put('name', this.name);
        m.put('username', this.username);
        m.put('email', this.email);
        m.put('avatarURL', this.avatarURL);
        m.put('token', this.token);

        return m;
    }

    public Integer id = 0;
    public String name = '';
    public String username = '';
    public String email = '';
    public String avatarURL = '';
    public String token = '';
}