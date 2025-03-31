/* -*- Mode: java; -*- */

/**
 * HLModelCloseWorkbox.cls
 *
 * Copyright (c) 2023 HelpLightning Inc.
 * https://helplightning.com
 */

 public class HLModelCloseWorkbox {
  @AuraEnabled
  public Integer workboxId {get;set;}
  @AuraEnabled
  public String workboxToken {get;set;}
  @AuraEnabled
  public Object values {get;set;}
}
