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

  /**
   * Build from response with 'workbox' wrapper (used by /enterprise/workboxes/by_call_id)
   */
  public static HLModelWorkboxDetails build(Object detailsObject) {
      if (detailsObject == null)
          return null;

      Map<String,Object> t = (Map<String,Object>)detailsObject;
      Map<String,Object> s = (Map<String,Object>)t.get('workbox');
      return buildFromWorkboxMap(s);
  }

  /**
   * Build from direct workbox data (used by /workboxes/{id})
   */
  public static HLModelWorkboxDetails buildDirect(Object workboxObject) {
      if (workboxObject == null)
          return null;

      Map<String,Object> s = (Map<String,Object>)workboxObject;
      return buildFromWorkboxMap(s);
  }

  private static HLModelWorkboxDetails buildFromWorkboxMap(Map<String,Object> s) {
      Integer workboxId = (Integer)s.get('id');
      String workboxToken = (String)s.get('token');
      String status = (String)s.get('status');
      List<helplightning.HLModelCustomFields> fields = new List<helplightning.HLModelCustomFields>();

      List<Object> ticketFields = (List<Object>)s.get('ticketFieldsFull');
      if (ticketFields != null) {
          for (Object u: ticketFields) {
              fields.add(helplightning.HLModelCustomFields.build(u));
          }
      }

      HLModelWorkboxDetails details = new HLModelWorkboxDetails(workboxId, workboxToken, status, fields);
      
      // Add additional fields for Help Thread display
      details.title = (String)s.get('title');
      
      // Parse participants
      List<Object> participantsList = (List<Object>)s.get('participants');
      if (participantsList != null) {
          for (Object p : participantsList) {
              Map<String,Object> pm = (Map<String,Object>)p;
              HLModelParticipant participant = new HLModelParticipant();
              participant.id = (Integer)pm.get('id');
              participant.name = (String)pm.get('name');
              participant.owner = pm.get('owner') == true;
              details.participants.add(participant);
          }
      }
      
      // Parse guests
      List<Object> guestsList = (List<Object>)s.get('guests');
      if (guestsList != null) {
          for (Object g : guestsList) {
              Map<String,Object> gm = (Map<String,Object>)g;
              HLModelGuest guest = new HLModelGuest();
              guest.id = (Integer)gm.get('id');
              guest.name = (String)gm.get('name');
              guest.uuid = (String)gm.get('uuid');
              guest.has_joined = gm.get('has_joined') == true;
              details.guests.add(guest);
          }
      }
      
      // Parse current field values (for displaying existing values)
      List<Object> fieldValuesList = (List<Object>)s.get('fields');
      if (fieldValuesList != null) {
          for (Object fv : fieldValuesList) {
              Map<String,Object> fvm = (Map<String,Object>)fv;
              HLModelFieldValue fieldValue = new HLModelFieldValue();
              fieldValue.id = (Integer)fvm.get('id');
              fieldValue.value = fvm.get('value');  // Can be String, Boolean, Integer, or List
              fieldValue.fieldType = (String)fvm.get('type');
              fieldValue.multiSelect = fvm.get('multiSelect') == true;
              details.fieldValues.add(fieldValue);
          }
      }

      return details;
  }

  @auraEnabled
  public Integer workboxId = 0;
  @auraEnabled
  public String workboxToken = '';
  @auraEnabled
  public String status = '';
  @auraEnabled
  public String title = '';
  @auraEnabled
  public List<helplightning.HLModelCustomFields> customFields = new List<helplightning.HLModelCustomFields>();
  @auraEnabled
  public List<HLModelParticipant> participants = new List<HLModelParticipant>();
  @auraEnabled
  public List<HLModelGuest> guests = new List<HLModelGuest>();
  @auraEnabled
  public List<HLModelFieldValue> fieldValues = new List<HLModelFieldValue>();

  // Inner class for participants
  public class HLModelParticipant {
      @auraEnabled public Integer id;
      @auraEnabled public String name;
      @auraEnabled public Boolean owner = false;
  }

  // Inner class for guests
  public class HLModelGuest {
      @auraEnabled public Integer id;
      @auraEnabled public String name;
      @auraEnabled public String uuid;
      @auraEnabled public Boolean has_joined = false;
  }

  // Inner class for current field values
  public class HLModelFieldValue {
      @auraEnabled public Integer id;
      @auraEnabled public Object value;  // Can be String, Boolean, Integer, or List
      @auraEnabled public String fieldType;
      @auraEnabled public Boolean multiSelect = false;
  }
}
