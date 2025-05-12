/* -*- Mode: java; -*- */

/**
 * HLModelSessionLink.cls
 *
 * Copyright (c) 2025 HelpLightning Inc.
 * https://helplightning.com
 */

public class HLModelSessionLink {
    /**
     * This is the model that represents
     *  a Help Lightning Session Link object.
     */
    public HLModelSessionLink(String link, String longLink, String signature) {
        this.link = link;
        this.longLink = longLink;
        this.signature = signature;
    }

    /**
     * Build a new model from a JSON
     *  response object
     */
    public static HLModelSessionLink build(Object linkObject) {
        Map<String,Object> l = (Map<String,Object>)linkObject;

        String link = (String)l.get('link');
        String longLink = (String)l.get('long_link');
        String signature = (String)l.get('signature');

        return new HLModelSessionLink(link, longLink, signature);
    }

    @auraEnabled
    public String link = '';
    @auraEnabled
    public String longLink = '';
    @auraEnabled
    public String signature = '';
}
