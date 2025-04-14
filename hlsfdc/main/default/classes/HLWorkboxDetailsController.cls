/* -*- Mode: java; -*- */

/**
 * HLWorkboxDetailsController.cls
 *
 * Copyright (c) 2021 HelpLightning Inc.
 * https://helplightning.com
 */
public with sharing class HLWorkboxDetailsController {

  @AuraEnabled(cacheable=true)
  public static Boolean closeWorkbox(HLModelCloseWorkbox payload) {
      try {

          // use the workbox token to authenticate
          helplightning.HLGaldrClient.saveCustomFields(payload.workboxToken, payload);
          helplightning.HLGaldrClient.closeWorkbox(payload.workboxToken);

          return true;

      } catch (helplightning.HLConfigurationException e) {
          throw new AuraHandledException('The Help Lightning component must be configured first.');
      }
  }
}