/* -*- Mode: java; -*- */

/**
 * HLModelCloseWorkbox.cls
 *
 * Copyright (c) 2023 HelpLightning Inc.
 * https://helplightning.com
 */

 public class HLModelCloseWorkbox {
  @AuraEnabled
  public Integer ticketId {get;set;}
  @AuraEnabled
  public Integer expert {get;set;}
  @AuraEnabled
  public Object values {get;set;}
}
