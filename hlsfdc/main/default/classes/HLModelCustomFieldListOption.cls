/* -*- Mode: java; -*- */

/**
 * HLModelCustomFieldListOption.cls
 *
 * Copyright (c) 2023 HelpLightning Inc.
 * https://helplightning.com
 */

public class HLModelCustomFieldListOption {
    public HLModelCustomFieldListOption(String label, Integer value) {
        this.label = label;
        this.value = value;
    }

    public static HLModelCustomFieldListOption build(Object result) {
        if (result == null)
            return null;

        Map<String, Object> u = (Map<String,Object>)result;

        // In ticketFieldsFull the id is the value that is used to then save back to the custom field
        // in /v1r1/workbox/custom_fields. The label is the name of the option.
        return new HLModelCustomFieldListOption((String)u.get('name'),
                                  (Integer)u.get('id'));
    }

    @auraEnabled
    public String label = '';
    @auraEnabled
    public Integer value = 0;
}
