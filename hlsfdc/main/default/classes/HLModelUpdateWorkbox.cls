/* -*- Mode: java; -*- */

/**
 * HLModelUpdateWorkbox.cls
 *
 * Copyright (c) 2023 HelpLightning Inc.
 * https://helplightning.com
 */

 public class HLModelUpdateWorkbox {
  @AuraEnabled
  public Integer workboxId {get;set;}
  @AuraEnabled
  public String workboxToken {get;set;}
  @AuraEnabled
  public Object values {get;set;}
  @AuraEnabled
  public Boolean close {get;set;}
}
