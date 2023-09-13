/* -*- Mode: java; -*- */

/**
 * HLModelWorkspace.cls
 *
 * Copyright (c) 2021 HelpLightning Inc.
 * https://helplightning.com
 */

public class HLModelWorkspace {
    /**
     * A model representing a contact as a result of a search.
     */
    public HLModelWorkspace(Integer id, String name, String token, Boolean active) {
        this.id = id;
        this.name = name;
        this.token = token;
        this.active = active;
    }

    public static HLModelWorkspace build(Object result) {
        Map<String,Object> s = (Map<String,Object>)result;

        return new HLModelWorkspace((Integer)s.get('id'),
                                     (String)s.get('name'),
                                     (String)s.get('token'),
                                     (Boolean)s.get('active'));
    }

    public static List<HLModelWorkspace> buildMany(Object resultsObject) {
        List<HLModelWorkspace> workspaces = new List<HLModelWorkspace>();

        if (resultsObject != null) {
            Map<String, Object> r = (Map<String, Object>)resultsObject;
            // get the entries
            List<Object> entries = (List<Object>)r.get('entries');

            // iterate through the entries, building models
            for (Object u: entries) {
                workspaces.add(HLModelWorkspace.build(u));
            }
        }

        return workspaces;
    }

    public Map<String, Object> serialize() {
        Map<String, Object> m = new Map<String, Object>();
        m.put('id', this.id);
        m.put('name', this.name);
        m.put('token', this.token);
        m.put('active', this.active);

        return m;
    }

    public Integer id = 0;
    public String name = '';
    public String token = '';
    public Boolean active = false;
}