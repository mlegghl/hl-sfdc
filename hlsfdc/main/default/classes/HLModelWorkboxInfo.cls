/* -*- Mode: java; -*- */

/**
 * HLModelWorkboxInfo.cls
 *
 * Copyright (c) 2018 HelpLightning Inc.
 * https://helplightning.com
 */

 public class HLModelWorkboxInfo {
  public HLModelWorkboxInfo(Integer ticketId, String status) {
      this.ticketId = ticketId;
      this.status = status;
  }

  public static HLModelWorkboxInfo build(Object infoObject) {
      if (infoObject == null)
          return null;

      Map<String,Object> t = (Map<String,Object>)infoObject;

      Integer ticketId = (Integer)t.get('ticket_id');
      String status = (String)t.get('status');

      return new HLModelWorkboxInfo(ticketId, status);
  }
  public Integer ticketId = 0;
  public String status = '';
}
