/* -*- Mode: java; -*- */

/**
 * HLModelWorkboxDetails.cls
 *
 * Copyright (c) 2018 HelpLightning Inc.
 * https://helplightning.com
 */

 public class HLModelWorkboxDetails {
  public HLModelWorkboxDetails(Integer workboxId, String status,
                        List<helplightning.HLModelCustomFields> customFields) {
      this.workboxId = workboxId;
      this.status = status;
      this.customFields = customFields;
  }

  public static HLModelWorkboxDetails build(Object detailsObject) {
      if (detailsObject == null)
          return null;

      Map<String,Object> t = (Map<String,Object>)detailsObject;
      Map<String,Object> s = (Map<String,Object>)t.get('Result');

      Integer workboxId = (Integer)s.get('ticketId');
      String status = (String)s.get('status');
      List<helplightning.HLModelCustomFields> fields = new List<helplightning.HLModelCustomFields>();

      for (Object u: (List<Object>)s.get('ticketFieldsFull')) {
        fields.add(helplightning.HLModelCustomFields.build(u));
      }

      return new HLModelWorkboxDetails(workboxId, status, fields);
  }
  @auraEnabled
  public Integer workboxId = 0;
  @auraEnabled
  public String status = '';
  @auraEnabled
  public List<helplightning.HLModelCustomFields> customFields = new List<helplightning.HLModelCustomFields>();
}
