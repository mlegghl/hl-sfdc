/* -*- Mode: java; -*- */

/**
 * HLModelWorkboxDetails.cls
 *
 * Copyright (c) 2018 HelpLightning Inc.
 * https://helplightning.com
 */

 public class HLModelWorkboxDetails {
  public HLModelWorkboxDetails(Integer workboxId, String workboxToken, String status,
                        List<helplightning.HLModelCustomFields> customFields) {
      this.workboxId = workboxId;
      this.workboxToken = workboxToken;
      this.status = status;
      this.customFields = customFields;
  }

  public static HLModelWorkboxDetails build(Object detailsObject) {
      if (detailsObject == null)
          return null;

      Map<String,Object> t = (Map<String,Object>)detailsObject;
      Map<String,Object> s = (Map<String,Object>)t.get('workbox');
      Integer workboxId = (Integer)s.get('id');
      String workboxToken = (String)s.get('token');
      String status = (String)s.get('status');
      List<helplightning.HLModelCustomFields> fields = new List<helplightning.HLModelCustomFields>();

      for (Object u: (List<Object>)s.get('ticketFieldsFull')) {
        fields.add(helplightning.HLModelCustomFields.build(u));
      }

      return new HLModelWorkboxDetails(workboxId, workboxToken, status, fields);
  }
  @auraEnabled
  public Integer workboxId = 0;
  @auraEnabled
  public String workboxToken = '';
  @auraEnabled
  public String status = '';
  @auraEnabled
  public List<helplightning.HLModelCustomFields> customFields = new List<helplightning.HLModelCustomFields>();
}
