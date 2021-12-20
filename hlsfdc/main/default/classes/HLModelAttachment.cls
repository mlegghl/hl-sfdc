/* -*- Mode: java; -*- */

/**
 * HLModelAttachment.cls
 *
 * Copyright (c) 2021 HelpLightning Inc.
 * https://helplightning.com
 */

public class HLModelAttachment {
    /**
     * A model representing a session attachment.
     */
    public HLModelAttachment(Integer id, String type, String thumbnail, String status, String signedUrl,
                             String mimeType, String fileName) {
        this.id = id;
        this.type = type;
        this.thumbnail = thumbnail;
        this.status = status;
        this.signedUrl = signedUrl;
        this.mimeType = mimeType;
        this.fileName = fileName;
    }

    public static HLModelAttachment build(Object result) {
        Map<String,Object> s = (Map<String,Object>)result;

        return new HLModelAttachment((Integer)s.get('id'),
                                     (String)s.get('type'),
                                     (String)s.get('thumbnail'),
                                     (String)s.get('status'),
                                     (String)s.get('signed_url'),
                                     (String)s.get('mime_type'),
                                     (String)s.get('name'));
    }

    public static List<HLModelAttachment> buildMany(Object resultsObject) {
        List<HLModelAttachment> attachments = new List<HLModelAttachment>();

        if (resultsObject != null && resultsObject instanceOf List<Object>) {
            List<Object> l = (List<Object>)resultsObject;

            for (Object u: (List<Object>)resultsObject) {
                attachments.add(HLModelAttachment.build(u));
            }
        }

        return attachments;
    }

    public Map<String, Object> serialize() {
        Map<String, Object> m = new Map<String, Object>();
        m.put('id', this.id);
        m.put('type', this.type);
        m.put('thumbnail', this.thumbnail);
        m.put('status', this.status);
        m.put('signed_url', this.signedUrl);
        m.put('mime_type', this.mimeType);
        m.put('name', this.fileName);

        return m;
    }

    public Integer id = 0;
    public String type = '';
    public String thumbnail = '';
    public String status = '';
    public String signedUrl = '';
    public String mimeType = '';
    public String fileName = '';
}
